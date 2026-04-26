#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
DEFAULT_OUTPUT_ROOT="$OCTON_DIR/generated/cognition/projections/materialized/runs"
DEFAULT_EVIDENCE_ROOT="$OCTON_DIR/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health"

python3 - "$ROOT_DIR" "$OCTON_DIR" "$DEFAULT_OUTPUT_ROOT" "$DEFAULT_EVIDENCE_ROOT" "$@" <<'PY'
import argparse
import hashlib
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None

ROOT_DIR = Path(sys.argv[1])
OCTON_DIR = Path(sys.argv[2])
DEFAULT_OUTPUT_ROOT = Path(sys.argv[3])
DEFAULT_EVIDENCE_ROOT = Path(sys.argv[4])
ARGV = sys.argv[5:]

GENERATOR_VERSION = "1.0.0"
SCHEMA_REF = ".octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json"
VALIDATOR_REF = ".octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh"
ROUTE_BUNDLE_REF = ".octon/generated/effective/runtime/route-bundle.yml"
PACK_ROUTES_REF = ".octon/generated/effective/capabilities/pack-routes.effective.yml"
SUPPORT_RECONCILIATION_REF = ".octon/generated/effective/governance/support-envelope-reconciliation.yml"

TERMINAL_OR_CLOSEOUT_STATES = {
    "closed",
    "succeeded",
    "failed",
    "rolled_back",
    "rolled-back",
    "denied",
    "revoked",
    "staged",
}


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate non-authoritative per-run health read models."
    )
    parser.add_argument("--run-id", action="append", default=[])
    parser.add_argument("--all-runs", action="store_true")
    parser.add_argument("--output-root", default=str(DEFAULT_OUTPUT_ROOT))
    parser.add_argument("--evidence-root", default=str(DEFAULT_EVIDENCE_ROOT))
    parser.add_argument("--fixtures-root", default=None)
    parser.add_argument("--generated-at", default=os.environ.get("OCTON_RUN_HEALTH_GENERATED_AT"))
    parser.add_argument("--no-evidence", action="store_true")
    return parser.parse_args(ARGV)


def utc_now():
    if os.environ.get("SOURCE_DATE_EPOCH"):
        return datetime.fromtimestamp(int(os.environ["SOURCE_DATE_EPOCH"]), tz=timezone.utc).strftime(
            "%Y-%m-%dT%H:%M:%SZ"
        )
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def load_yaml(path):
    if not path or not Path(path).is_file():
        return {}
    path = Path(path)
    if yaml is not None:
        with path.open("r", encoding="utf-8") as handle:
            data = yaml.safe_load(handle)
        return data or {}
    result = subprocess.run(
        ["yq", "-o=json", ".", str(path)],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return json.loads(result.stdout or "{}")


def write_yaml(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    if yaml is not None:
        path.write_text(yaml.safe_dump(data, sort_keys=False), encoding="utf-8")
    else:
        path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def repo_ref(path):
    if path is None:
        return None
    path = Path(path)
    try:
        return path.resolve().relative_to(ROOT_DIR.resolve()).as_posix()
    except ValueError:
        return path.as_posix()


def resolve_ref(ref):
    if not ref:
        return None
    raw = str(ref)
    if raw.startswith("/.octon/") or raw.startswith("/.github/"):
        return ROOT_DIR / raw[1:]
    if raw.startswith(".octon/") or raw.startswith(".github/"):
        return ROOT_DIR / raw
    candidate = Path(raw)
    if candidate.is_absolute():
        return candidate
    return ROOT_DIR / raw


def repo_relative_path(path):
    if path is None:
        return None
    try:
        return Path(path).resolve().relative_to(ROOT_DIR.resolve()).as_posix()
    except ValueError:
        return None


def is_retained_evidence_path(path):
    rel = repo_relative_path(path)
    if not rel:
        return False
    retained_roots = (
        ".octon/state/evidence/runs/",
        ".octon/state/evidence/disclosure/runs/",
    )
    return any(rel == root.rstrip("/") or rel.startswith(root) for root in retained_roots)


def git_tracked_files_for(path):
    rel = repo_relative_path(path)
    if not rel:
        return None
    query = rel
    if Path(path).is_dir() or (not Path(path).exists() and Path(path).suffix == ""):
        query = rel.rstrip("/") + "/"
    try:
        result = subprocess.run(
            ["git", "-C", str(ROOT_DIR), "ls-files", "--", query],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    except (OSError, subprocess.CalledProcessError):
        return None
    return [ROOT_DIR / line for line in result.stdout.splitlines() if line]


def retained_evidence_file_exists(path):
    if not path:
        return False
    path = Path(path)
    if is_retained_evidence_path(path):
        tracked = git_tracked_files_for(path) or []
        return any(item == path and item.is_file() for item in tracked)
    return path.is_file()


def ensure_list(value):
    if value is None:
        return []
    if isinstance(value, list):
        return [str(item) for item in value if item not in (None, "")]
    if value == "":
        return []
    return [str(value)]


def sha256_file(path):
    if not path or not Path(path).is_file():
        return None
    digest = hashlib.sha256()
    with Path(path).open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return "sha256:" + digest.hexdigest()


def sha256_path(path):
    if not path:
        return None
    path = Path(path)
    if is_retained_evidence_path(path):
        tracked = git_tracked_files_for(path) or []
        if path.is_file():
            return sha256_file(path) if path in tracked else None
        if not tracked:
            return None
        entries = []
        for child in sorted(item for item in tracked if item.is_file()):
            try:
                child_ref = child.relative_to(path).as_posix()
            except ValueError:
                continue
            child_digest = sha256_file(child)
            entries.append({"path": child_ref, "digest": child_digest})
        if not entries:
            return None
        encoded = json.dumps(entries, sort_keys=True, separators=(",", ":")).encode("utf-8")
        return "sha256:" + hashlib.sha256(encoded).hexdigest()
    if path.is_file():
        return sha256_file(path)
    if path.is_dir():
        entries = []
        for child in sorted(item for item in path.rglob("*") if item.is_file()):
            child_digest = sha256_file(child)
            try:
                child_ref = child.relative_to(path).as_posix()
            except ValueError:
                child_ref = child.as_posix()
            entries.append({"path": child_ref, "digest": child_digest})
        encoded = json.dumps(entries, sort_keys=True, separators=(",", ":")).encode("utf-8")
        return "sha256:" + hashlib.sha256(encoded).hexdigest()
    return None


def combined_digest(digest_entries):
    payload = []
    for key in sorted(digest_entries):
        item = digest_entries[key]
        payload.append({"key": key, "ref": item["ref"], "digest": item["digest"], "status": item["status"]})
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return "sha256:" + hashlib.sha256(encoded).hexdigest()


def add_diag(diagnostics, severity, code, message, refs=None):
    diagnostics.append(
        {
            "severity": severity,
            "code": code,
            "message": message,
            "refs": sorted(set(refs or [])),
        }
    )


def normalize_state(value):
    raw = str(value or "unknown").strip()
    aliases = {
        "rolled_back": "rolled-back",
        "stage_only": "staged",
        "stage-only": "staged",
    }
    return aliases.get(raw, raw)


def normalize_route(value):
    raw = str(value or "unknown").strip().lower().replace("_", "-")
    aliases = {
        "allow": "allow",
        "allowed": "allow",
        "stage-only": "stage-only",
        "staged": "stage-only",
        "escalate": "stage-only",
        "deny": "deny",
        "denied": "deny",
        "unsupported": "unsupported",
    }
    return aliases.get(raw, "unknown")


def tuple_from_manifest(manifest, runtime_state):
    for key in ("support_target_tuple_ref", "support_target_tuple_id"):
        value = runtime_state.get(key) or manifest.get(key)
        if value:
            return str(value)
    target = manifest.get("support_target") or {}
    required = [
        "model_tier",
        "workload_tier",
        "language_resource_tier",
        "locale_tier",
        "host_adapter",
    ]
    if all(target.get(key) for key in required):
        return "tuple://{}/{}/{}/{}/{}".format(
            target.get("model_tier"),
            target.get("workload_tier"),
            target.get("language_resource_tier"),
            target.get("locale_tier"),
            target.get("host_adapter"),
        )
    return None


def first_existing(*refs):
    for ref in refs:
        if not ref:
            continue
        path = resolve_ref(ref)
        if path and path.exists():
            return str(ref)
    for ref in refs:
        if ref:
            return str(ref)
    return None


def canonical_refs_for(run_id, control_root, manifest, runtime_state):
    evidence_root = manifest.get("evidence_root") or f".octon/state/evidence/runs/{run_id}"
    disclosure_root = manifest.get("disclosure_root") or f".octon/state/evidence/disclosure/runs/{run_id}"
    return {
        "run_contract": manifest.get("run_contract_ref") or repo_ref(control_root / "run-contract.yml"),
        "run_manifest": repo_ref(control_root / "run-manifest.yml"),
        "events_journal": runtime_state.get("source_ledger_ref") or repo_ref(control_root / "events.ndjson"),
        "events_manifest": runtime_state.get("source_ledger_manifest_ref") or repo_ref(control_root / "events.manifest.yml"),
        "runtime_state": manifest.get("runtime_state_ref") or repo_ref(control_root / "runtime-state.yml"),
        "authority_decision": first_existing(
            manifest.get("decision_artifact_ref"),
            manifest.get("authority_decision_ref"),
            repo_ref(control_root / "authority" / "decision.yml"),
        ),
        "authority_bundle": first_existing(
            manifest.get("authority_bundle_ref"),
            manifest.get("authority_grant_bundle_ref"),
            repo_ref(control_root / "authority" / "grant-bundle.yml"),
        ),
        "approval_request": manifest.get("approval_request_ref"),
        "approval_grants": ensure_list(manifest.get("approval_grant_refs")),
        "exception_leases": ensure_list(manifest.get("exception_lease_refs") or manifest.get("exception_refs")),
        "revocations": ensure_list(manifest.get("revocation_refs")),
        "rollback_posture": manifest.get("rollback_posture_ref") or repo_ref(control_root / "rollback-posture.yml"),
        "evidence_root": evidence_root,
        "evidence_classification": manifest.get("evidence_classification_ref") or f"{evidence_root}/evidence-classification.yml",
        "retained_evidence": manifest.get("retained_evidence_ref") or f"{evidence_root}/retained-run-evidence.yml",
        "replay_pointers": manifest.get("replay_pointers_ref") or f"{evidence_root}/replay-pointers.yml",
        "intervention_log": f"{manifest.get('intervention_root') or f'{evidence_root}/interventions'}/log.yml",
        "disclosure_run_card": manifest.get("run_card_ref") or f"{disclosure_root}/run-card.yml",
        "support_targets": manifest.get("support_target_ref") or ".octon/instance/governance/support-targets.yml",
        "support_reconciliation": SUPPORT_RECONCILIATION_REF,
        "run_continuity": manifest.get("run_continuity_ref"),
    }


def source_digests(refs, extra_refs=None):
    entries = {}
    all_refs = dict(refs)
    if extra_refs:
        all_refs.update(extra_refs)
    for key, value in all_refs.items():
        if isinstance(value, list):
            for index, ref in enumerate(value):
                path = resolve_ref(ref)
                digest = sha256_path(path)
                entries[f"{key}_{index}"] = {
                    "ref": ref,
                    "digest": digest or "missing",
                    "status": "present" if digest else "missing",
                }
            if not value:
                entries[key] = {"ref": None, "digest": "not-applicable", "status": "not-applicable"}
            continue
        path = resolve_ref(value)
        digest = sha256_path(path) if value else None
        entries[key] = {
            "ref": value,
            "digest": digest or ("missing" if value else "not-applicable"),
            "status": "present" if digest else ("missing" if value else "not-applicable"),
        }
    return entries


def route_status_for(tuple_id, route_bundle_ref=ROUTE_BUNDLE_REF):
    route_bundle = load_yaml(resolve_ref(route_bundle_ref))
    for route in route_bundle.get("routes", []) or []:
        if route.get("tuple_id") == tuple_id:
            return normalize_route(route.get("route"))
    return "unsupported" if tuple_id else "unknown"


def pack_status_for(tuple_id, requested_packs, pack_routes_ref=PACK_ROUTES_REF):
    if not tuple_id:
        return "unknown"
    if not requested_packs:
        return "unknown"
    pack_routes = load_yaml(resolve_ref(pack_routes_ref))
    statuses = []
    packs = {pack.get("pack_id"): pack for pack in pack_routes.get("packs", []) or []}
    for pack_id in requested_packs:
        pack = packs.get(pack_id)
        if not pack:
            statuses.append("unsupported")
            continue
        matched = None
        for route in pack.get("tuple_routes", []) or []:
            if route.get("tuple_id") == tuple_id:
                matched = normalize_route(route.get("route"))
                break
        statuses.append(matched or "unsupported")
    if any(item in ("unsupported", "deny") for item in statuses):
        return "unsupported" if "unsupported" in statuses else "deny"
    if any(item == "stage-only" for item in statuses):
        return "stage-only"
    if statuses and all(item == "allow" for item in statuses):
        return "allow"
    return "unknown"


def load_authority(refs, diagnostics):
    decision = load_yaml(resolve_ref(refs.get("authority_decision")))
    grant_bundle = load_yaml(resolve_ref(refs.get("authority_bundle")))

    decision_refs = decision.get("authority_refs") or {}
    approval_request = refs.get("approval_request") or decision.get("approval_request_ref") or decision_refs.get("approval_request_ref")
    approval_grants = ensure_list(refs.get("approval_grants"))
    approval_grants.extend(ensure_list(decision.get("approval_grant_refs") or decision_refs.get("approval_grant_refs")))
    approval_grants.extend(ensure_list(grant_bundle.get("approval_grant_refs")))
    exception_leases = ensure_list(refs.get("exception_leases"))
    exception_leases.extend(ensure_list(decision.get("exception_refs") or decision.get("exception_lease_refs") or decision_refs.get("exception_lease_refs")))
    revocations = ensure_list(refs.get("revocations"))
    revocations.extend(ensure_list(decision.get("revocation_refs") or decision_refs.get("revocation_refs")))

    approval_request_doc = load_yaml(resolve_ref(approval_request))
    approval_request_status = str(approval_request_doc.get("status") or "").lower()
    route_outcome = str(decision.get("route_outcome") or decision.get("decision") or grant_bundle.get("route_outcome") or "").lower()

    active_revocations = sorted(set(item for item in revocations if item))
    active_grants = sorted(set(item for item in approval_grants if item))
    if refs.get("authority_bundle") and resolve_ref(refs.get("authority_bundle")) and resolve_ref(refs.get("authority_bundle")).is_file():
        active_grants = sorted(set(active_grants + [refs["authority_bundle"]]))

    open_approvals = []
    if approval_request and approval_request_status not in ("granted", "approved", "closed", "satisfied"):
        open_approvals.append(approval_request)
    elif approval_request and not active_grants:
        open_approvals.append(approval_request)

    if active_revocations:
        status = "revoked"
    elif route_outcome in ("deny", "denied", "deny_route", "deny-route", "DENY".lower()):
        status = "denied"
    elif open_approvals:
        status = "approval-required"
    elif route_outcome in ("allow", "allowed") or active_grants:
        status = "authorized"
    elif route_outcome in ("stage_only", "stage-only", "escalate", "escalation"):
        status = "review-required"
    else:
        status = "unknown"
        add_diag(
            diagnostics,
            "warning",
            "authorization-unknown",
            "Authorization posture could not be resolved from decision or grant artifacts.",
            [refs.get("authority_decision"), refs.get("authority_bundle")],
        )

    return {
        "status": status,
        "active_grants": active_grants,
        "open_approvals": sorted(set(open_approvals)),
        "active_exceptions": sorted(set(item for item in exception_leases if item)),
        "active_revocations": active_revocations,
    }


def evidence_status(refs, lifecycle_state):
    required = [
        ("evidence_classification", refs.get("evidence_classification")),
        ("retained_evidence", refs.get("retained_evidence")),
        ("replay_pointers", refs.get("replay_pointers")),
    ]
    if lifecycle_state in TERMINAL_OR_CLOSEOUT_STATES:
        required.extend(
            [
                ("events_journal", refs.get("events_journal")),
                ("events_manifest", refs.get("events_manifest")),
                ("rollback_posture", refs.get("rollback_posture")),
            ]
        )
        evidence_root = refs.get("evidence_root")
        if evidence_root:
            required.extend(
                [
                    ("journal_snapshot", f"{evidence_root}/run-journal/events.snapshot.ndjson"),
                    ("journal_manifest_snapshot", f"{evidence_root}/run-journal/events.manifest.snapshot.yml"),
                ]
            )
    missing = [name for name, ref in required if not ref or not retained_evidence_file_exists(resolve_ref(ref))]
    return {
        "completeness": "incomplete" if missing else "complete",
        "missing_required": missing,
    }


def rollback_status(refs):
    posture = load_yaml(resolve_ref(refs.get("rollback_posture")))
    if not posture:
        return {"status": "unavailable", "hard_reset_required": None}
    hard_reset = posture.get("hard_reset_required")
    contamination = str(posture.get("contamination_state") or "unknown").lower()
    if hard_reset is True or contamination not in ("clean", "none", "not-applicable"):
        return {"status": "required", "hard_reset_required": hard_reset}
    return {"status": "ready", "hard_reset_required": hard_reset if hard_reset is not None else False}


def intervention_status(refs):
    log_ref = resolve_ref(refs.get("intervention_log"))
    log = load_yaml(log_ref) if retained_evidence_file_exists(log_ref) else {}
    if not log:
        return {"status": "unknown", "undisclosed_count": 0, "records": []}
    records = log.get("interventions") or []
    undisclosed = [
        record for record in records if record.get("disclosed") is not True or str(record.get("status") or "").lower() in ("required", "open")
    ]
    if undisclosed:
        status = "required"
    elif records:
        status = "present"
    else:
        status = "none"
    return {
        "status": status,
        "undisclosed_count": len(undisclosed),
        "records": records,
    }


def disclosure_status(refs, lifecycle_state):
    run_card = refs.get("disclosure_run_card")
    exists = bool(run_card and retained_evidence_file_exists(resolve_ref(run_card)))
    if exists:
        return {"status": "complete"}
    if lifecycle_state in TERMINAL_OR_CLOSEOUT_STATES:
        return {"status": "incomplete"}
    return {"status": "unknown"}


def lifecycle_status(refs, runtime_state, diagnostics):
    lifecycle_state = normalize_state(runtime_state.get("state") or runtime_state.get("status"))
    events_manifest = load_yaml(resolve_ref(refs.get("events_manifest")))
    latest_hash = runtime_state.get("last_applied_event_hash")
    latest_sequence = runtime_state.get("last_applied_sequence")
    manifest_hash = ((events_manifest.get("last_event_ref") or {}).get("event_hash"))
    manifest_sequence = ((events_manifest.get("last_event_ref") or {}).get("sequence"))

    if latest_hash and manifest_hash and latest_hash != manifest_hash:
        add_diag(
            diagnostics,
            "error",
            "runtime-state-journal-head-mismatch",
            "runtime-state.yml last applied event hash differs from the events manifest tail hash.",
            [refs.get("runtime_state"), refs.get("events_manifest")],
        )
    if latest_sequence and manifest_sequence and int(latest_sequence) != int(manifest_sequence):
        add_diag(
            diagnostics,
            "error",
            "runtime-state-journal-sequence-mismatch",
            "runtime-state.yml last applied sequence differs from the events manifest tail sequence.",
            [refs.get("runtime_state"), refs.get("events_manifest")],
        )

    drift_status = runtime_state.get("drift_status")
    if drift_status and drift_status != "in-sync":
        add_diag(
            diagnostics,
            "error",
            "runtime-state-drift",
            "runtime-state.yml reports drift and cannot support a current health view without review.",
            [refs.get("runtime_state")],
        )

    return {
        "state": lifecycle_state,
        "decision_state": runtime_state.get("decision_state"),
        "drift_status": drift_status,
        "latest_event_hash": latest_hash or manifest_hash,
        "latest_sequence": latest_sequence or manifest_sequence,
    }


def freshness_status(refs, digests, diagnostics, generated_at):
    status = "fresh"
    events_ref = refs.get("events_journal")
    manifest_ref = refs.get("events_manifest")
    manifest = load_yaml(resolve_ref(manifest_ref))
    events_digest = sha256_file(resolve_ref(events_ref))
    ledger_digest = manifest.get("ledger_digest")
    if events_ref and manifest_ref and events_digest and ledger_digest and events_digest != ledger_digest:
        status = "stale"
        add_diag(
            diagnostics,
            "error",
            "journal-ledger-digest-stale",
            "events.manifest.yml ledger_digest does not match events.ndjson.",
            [events_ref, manifest_ref],
        )
    missing_current_sources = [
        key
        for key in ("run_manifest", "runtime_state")
        if digests.get(key, {}).get("status") == "missing"
    ]
    if missing_current_sources:
        status = "unknown"
        add_diag(
            diagnostics,
            "error",
            "required-current-source-missing",
            "Required current source files are missing from the run-health input set.",
            [refs.get(key) for key in missing_current_sources],
        )
    return {
        "mode": "digest-bound",
        "status": status,
        "source_digest_algorithm": "sha256",
        "combined_source_digest": combined_digest(digests),
        "checked_at": generated_at,
        "expires_at": None,
        "freshness_refs": [manifest_ref] if manifest_ref else [],
    }


def derive_health(lifecycle, support, authorization, evidence, rollback, intervention, disclosure, freshness, diagnostics):
    state = lifecycle["state"]
    diag_codes = {item["code"] for item in diagnostics}

    if "required-current-source-missing" in diag_codes:
        status = "blocked"
    elif authorization["status"] == "revoked" or state == "revoked":
        status = "revoked"
    elif freshness["status"] == "stale":
        status = "stale"
    elif support["route_status"] in ("deny", "unsupported") or support["pack_status"] in ("deny", "unsupported"):
        status = "unsupported"
    elif authorization["status"] == "approval-required":
        status = "approval-required"
    elif "runtime-state-journal-head-mismatch" in diag_codes or "runtime-state-journal-sequence-mismatch" in diag_codes or "runtime-state-drift" in diag_codes:
        status = "review-required"
    elif authorization["status"] == "denied" or state in ("failed", "denied", "staged"):
        status = "blocked"
    elif support["route_status"] == "stage-only" or support["pack_status"] == "stage-only" or authorization["status"] == "review-required":
        status = "review-required"
    elif intervention["status"] == "required":
        status = "intervention-required"
    elif rollback["status"] in ("required", "unavailable"):
        status = "rollback-required"
    elif evidence["completeness"] == "incomplete":
        status = "evidence-incomplete"
    elif disclosure["status"] == "incomplete":
        status = "disclosure-incomplete"
    elif state in ("succeeded", "closed") and evidence["completeness"] == "complete" and disclosure["status"] == "complete":
        status = "closure-ready"
    elif state in ("bound", "authorized", "running", "paused", "authorizing") and authorization["status"] in ("authorized", "unknown") and support["route_status"] == "allow":
        status = "healthy"
    else:
        status = "review-required"

    if status == "review-required" and not diagnostics:
        if support["route_status"] == "stage-only" or support["pack_status"] == "stage-only":
            add_diag(
                diagnostics,
                "warning",
                "support-stage-only",
                "Support tuple or capability pack route is stage-only; operator review is required before relying on this projection.",
            )
        elif authorization["status"] == "review-required":
            add_diag(
                diagnostics,
                "warning",
                "authorization-review-required",
                "Authorization posture requires operator review before relying on this projection.",
            )
        else:
            add_diag(
                diagnostics,
                "warning",
                "review-required-uncertainty",
                "Run-health derivation reached a review-required state without a more specific diagnostic.",
            )

    summaries = {
        "healthy": "Run inputs are fresh and no blocking operator action is currently required.",
        "blocked": "Run cannot continue until the blocking lifecycle or authorization condition is resolved.",
        "stale": "Run-health sources are stale relative to their digest-bound freshness checks.",
        "unsupported": "Run support tuple or requested pack route is unsupported or denied.",
        "revoked": "A revocation or revoked lifecycle state applies to this run.",
        "approval-required": "Run is waiting on a canonical approval grant.",
        "review-required": "Run inputs disagree or require human review before relying on this projection.",
        "evidence-incomplete": "Required retained run evidence is incomplete for the current lifecycle posture.",
        "rollback-required": "Rollback posture is required or unavailable before the run can safely progress.",
        "intervention-required": "Intervention evidence is required or contains undisclosed material intervention.",
        "disclosure-incomplete": "Disclosure evidence is incomplete for a terminal or closeout-ready run.",
        "closure-ready": "Run has the retained evidence, rollback posture, and disclosure needed for closure review.",
    }
    actions = {
        "healthy": "none",
        "blocked": "inspect canonical lifecycle and authority refs",
        "stale": "regenerate from current canonical sources",
        "unsupported": "reconcile support target, route bundle, and pack-route posture",
        "revoked": "stop execution and follow rollback or closeout posture",
        "approval-required": "resolve approval request in canonical control roots",
        "review-required": "review diagnostics and repair source disagreement",
        "evidence-incomplete": "complete missing retained evidence refs",
        "rollback-required": "repair or record rollback posture",
        "intervention-required": "disclose, resolve, or record required intervention",
        "disclosure-incomplete": "generate or repair the canonical RunCard disclosure",
        "closure-ready": "proceed to closeout review using canonical evidence roots",
    }
    closure = {"status": "ready" if status == "closure-ready" else ("blocked" if status in ("blocked", "revoked", "unsupported") else "not-ready")}
    return {
        "health": {
            "status": status,
            "summary": summaries[status],
            "next_required_action": actions[status],
        },
        "closure": closure,
    }


def generate_for_run(run_id, control_root, generated_at, route_bundle_ref=ROUTE_BUNDLE_REF, pack_routes_ref=PACK_ROUTES_REF):
    diagnostics = []
    manifest_path = control_root / "run-manifest.yml"
    runtime_state_path = control_root / "runtime-state.yml"
    manifest = load_yaml(manifest_path)
    runtime_state = load_yaml(runtime_state_path)

    refs = canonical_refs_for(run_id, control_root, manifest, runtime_state)
    tuple_id = tuple_from_manifest(manifest, runtime_state)
    requested_packs = ensure_list(manifest.get("requested_capability_packs"))
    route_status = route_status_for(tuple_id, route_bundle_ref)
    pack_status = pack_status_for(tuple_id, requested_packs, pack_routes_ref)
    support_status = "supported"
    if route_status in ("unsupported", "deny") or pack_status in ("unsupported", "deny"):
        support_status = "unsupported"
    elif route_status == "stage-only" or pack_status == "stage-only":
        support_status = "stage-only"
    elif route_status == "unknown":
        support_status = "unknown"

    extra_source_refs = {
        "runtime_route_bundle": route_bundle_ref,
        "pack_routes": pack_routes_ref,
        "schema": SCHEMA_REF,
        "operator_read_model_contract": ".octon/framework/engine/runtime/spec/operator-read-models-v1.md",
    }
    digests = source_digests(refs, extra_source_refs)
    if digests.get("support_reconciliation", {}).get("status") == "missing":
        add_diag(
            diagnostics,
            "warning",
            "support-reconciliation-missing",
            "Support-envelope reconciliation output is not present; support posture is derived from route bundle and pack routes only.",
            [refs.get("support_reconciliation")],
        )

    lifecycle = lifecycle_status(refs, runtime_state, diagnostics)
    authorization = load_authority(refs, diagnostics)
    evidence = evidence_status(refs, lifecycle["state"])
    rollback = rollback_status(refs)
    intervention = intervention_status(refs)
    disclosure = disclosure_status(refs, lifecycle["state"])
    freshness = freshness_status(refs, digests, diagnostics, generated_at)
    support = {
        "tuple": tuple_id,
        "route_status": route_status,
        "pack_status": pack_status,
        "support_status": support_status,
        "requested_capability_packs": requested_packs,
    }
    derived = derive_health(
        lifecycle,
        support,
        authorization,
        evidence,
        rollback,
        intervention,
        disclosure,
        freshness,
        diagnostics,
    )

    return {
        "schema_version": "run-health-read-model-v1",
        "run_id": run_id,
        "generated_at": generated_at,
        "generator": {
            "id": "generate-run-health-read-model.sh",
            "version": GENERATOR_VERSION,
            "validator_ref": VALIDATOR_REF,
        },
        "authority": {
            "classification": "generated_read_model_non_authoritative",
            "may_authorize": False,
            "may_widen_support": False,
            "allowed_consumers": ["operators", "validators"],
            "forbidden_consumers": [
                "runtime",
                "policy",
                "authority",
                "support-claim-evaluation",
                "state-reconstruction",
                "direct-runtime-reads",
            ],
        },
        "freshness": freshness,
        "canonical_refs": refs,
        "source_digests": digests,
        "health": derived["health"],
        "lifecycle": lifecycle,
        "support": support,
        "authorization": authorization,
        "evidence": evidence,
        "rollback": rollback,
        "intervention": intervention,
        "disclosure": disclosure,
        "closure": derived["closure"],
        "diagnostics": diagnostics,
    }


def fixture_ref(fixtures_root, case_id, relative):
    return (fixtures_root / "sources" / case_id / relative).as_posix()


def materialize_fixture_sources(fixtures_root, case, generated_at):
    case_id = case["case_id"]
    facts = case.get("facts") or {}
    source_root = fixtures_root / "sources" / case_id
    control_root = source_root / "control"
    evidence_root = source_root / "evidence"
    disclosure_root = source_root / "disclosure"
    tuple_id = facts.get("tuple") or f"tuple://repo-local-governed/repo-consequential/reference-owned/english-primary/{case_id}-fixture"

    control_root.mkdir(parents=True, exist_ok=True)
    (control_root / "authority").mkdir(parents=True, exist_ok=True)
    evidence_root.mkdir(parents=True, exist_ok=True)

    run_id = case_id
    run_contract_ref = fixture_ref(fixtures_root, case_id, "control/run-contract.yml")
    run_manifest_ref = fixture_ref(fixtures_root, case_id, "control/run-manifest.yml")
    runtime_state_ref = fixture_ref(fixtures_root, case_id, "control/runtime-state.yml")
    events_ref = fixture_ref(fixtures_root, case_id, "control/events.ndjson")
    events_manifest_ref = fixture_ref(fixtures_root, case_id, "control/events.manifest.yml")
    rollback_ref = fixture_ref(fixtures_root, case_id, "control/rollback-posture.yml")
    decision_ref = fixture_ref(fixtures_root, case_id, "control/authority/decision.yml")
    grant_ref = fixture_ref(fixtures_root, case_id, "control/authority/grant-bundle.yml")
    approval_ref = fixture_ref(fixtures_root, case_id, "control/authority/approval-request.yml")
    evidence_ref = fixture_ref(fixtures_root, case_id, "evidence/retained-run-evidence.yml")
    classification_ref = fixture_ref(fixtures_root, case_id, "evidence/evidence-classification.yml")
    replay_ref = fixture_ref(fixtures_root, case_id, "evidence/replay-pointers.yml")
    intervention_ref = fixture_ref(fixtures_root, case_id, "evidence/interventions/log.yml")
    run_card_ref = fixture_ref(fixtures_root, case_id, "disclosure/run-card.yml")

    write_yaml(control_root / "run-contract.yml", {"schema_version": "run-contract-fixture-v1", "run_id": run_id})

    manifest = {
        "schema_version": "run-manifest-v2",
        "run_id": run_id,
        "run_contract_ref": run_contract_ref,
        "runtime_state_ref": runtime_state_ref,
        "support_target_tuple_id": tuple_id,
        "support_target_ref": ".octon/instance/governance/support-targets.yml",
        "requested_capability_packs": facts.get("requested_capability_packs", ["repo", "shell"]),
        "decision_artifact_ref": decision_ref,
        "authority_bundle_ref": grant_ref,
        "approval_request_ref": approval_ref if facts.get("authorization") == "approval-required" else None,
        "approval_grant_refs": [] if facts.get("authorization") == "approval-required" else [grant_ref],
        "revocation_refs": [fixture_ref(fixtures_root, case_id, "control/authority/revocation.yml")] if facts.get("authorization") == "revoked" else [],
        "rollback_posture_ref": rollback_ref,
        "evidence_root": evidence_root.as_posix(),
        "evidence_classification_ref": classification_ref,
        "retained_evidence_ref": evidence_ref,
        "replay_pointers_ref": replay_ref,
        "intervention_root": (evidence_root / "interventions").as_posix(),
        "run_card_ref": run_card_ref,
    }
    write_yaml(control_root / "run-manifest.yml", {k: v for k, v in manifest.items() if v is not None})

    event_hash = "sha256:" + hashlib.sha256(f"{case_id}:event".encode("utf-8")).hexdigest()
    event = {
        "schema_version": "run-event-v2",
        "event_id": f"evt-{case_id}",
        "run_id": run_id,
        "sequence": 1,
        "event_type": "fixture",
        "integrity": {"event_hash": event_hash},
    }
    events_text = json.dumps(event, sort_keys=True, separators=(",", ":")) + "\n"
    (control_root / "events.ndjson").write_text(events_text, encoding="utf-8")
    ledger_digest = "sha256:" + hashlib.sha256(events_text.encode("utf-8")).hexdigest()
    if facts.get("freshness") == "stale":
        ledger_digest = "sha256:" + "0" * 64
    write_yaml(
        control_root / "events.manifest.yml",
        {
            "schema_version": "run-event-ledger-v2",
            "run_id": run_id,
            "ledger_ref": events_ref,
            "manifest_ref": events_manifest_ref,
            "ledger_digest": ledger_digest,
            "event_count": 1,
            "last_event_ref": {"event_id": f"evt-{case_id}", "sequence": 1, "event_hash": event_hash},
            "drift_status": facts.get("drift_status", "in-sync"),
        },
    )

    runtime_hash = "sha256:" + hashlib.sha256(f"{case_id}:runtime-mismatch".encode("utf-8")).hexdigest() if facts.get("runtime_disagreement") else event_hash
    write_yaml(
        control_root / "runtime-state.yml",
        {
            "schema_version": "runtime-state-v2",
            "run_id": run_id,
            "state": facts.get("lifecycle_state", "running"),
            "decision_state": facts.get("decision_state", "allow"),
            "source_ledger_ref": events_ref,
            "source_ledger_manifest_ref": events_manifest_ref,
            "support_target_tuple_ref": tuple_id,
            "last_applied_event_hash": runtime_hash,
            "last_applied_sequence": 1,
            "drift_status": facts.get("drift_status", "in-sync"),
            "updated_at": generated_at,
        },
    )

    if facts.get("rollback") != "missing":
        write_yaml(
            control_root / "rollback-posture.yml",
            {
                "schema_version": "run-rollback-posture-v1",
                "run_id": run_id,
                "contamination_state": "tainted" if facts.get("rollback") == "required" else "clean",
                "hard_reset_required": facts.get("rollback") == "required",
                "updated_at": generated_at,
            },
        )

    route_outcome = facts.get("route_status", "allow")
    if facts.get("authorization") == "revoked":
        route_outcome = "deny"
    elif facts.get("authorization") == "denied":
        route_outcome = "deny"
    elif facts.get("authorization") == "approval-required":
        route_outcome = "stage_only"
    write_yaml(
        control_root / "authority" / "decision.yml",
        {
            "schema_version": "authority-decision-artifact-v2",
            "run_id": run_id,
            "route_outcome": route_outcome,
            "approval_request_ref": approval_ref if facts.get("authorization") == "approval-required" else None,
            "approval_grant_refs": [] if facts.get("authorization") == "approval-required" else [grant_ref],
            "revocation_refs": manifest["revocation_refs"],
        },
    )
    if facts.get("authorization") != "approval-required":
        write_yaml(
            control_root / "authority" / "grant-bundle.yml",
            {
                "schema_version": "authority-grant-bundle-v2",
                "run_id": run_id,
                "route_outcome": route_outcome,
                "approval_grant_refs": [grant_ref],
            },
        )
    else:
        write_yaml(
            control_root / "authority" / "approval-request.yml",
            {
                "schema_version": "authority-approval-request-v1",
                "run_id": run_id,
                "status": "pending",
            },
        )

    if facts.get("evidence") != "missing":
        write_yaml(evidence_root / "retained-run-evidence.yml", {"schema_version": "retained-run-evidence-v1", "run_id": run_id})
        write_yaml(evidence_root / "evidence-classification.yml", {"schema_version": "run-evidence-classification-v1", "run_id": run_id})
        write_yaml(evidence_root / "replay-pointers.yml", {"schema_version": "run-replay-pointers-v1", "run_id": run_id})
        if facts.get("lifecycle_state") in TERMINAL_OR_CLOSEOUT_STATES:
            (evidence_root / "run-journal").mkdir(parents=True, exist_ok=True)
            (evidence_root / "run-journal" / "events.snapshot.ndjson").write_text(events_text, encoding="utf-8")
            write_yaml(evidence_root / "run-journal" / "events.manifest.snapshot.yml", load_yaml(control_root / "events.manifest.yml"))

    (evidence_root / "interventions").mkdir(parents=True, exist_ok=True)
    intervention_records = []
    if facts.get("intervention") == "required":
        intervention_records.append({"event_id": f"evt-{case_id}-intervention", "kind": "manual-intervention", "disclosed": False})
    elif facts.get("intervention") == "present":
        intervention_records.append({"event_id": f"evt-{case_id}-intervention", "kind": "manual-review", "disclosed": True})
    write_yaml(
        evidence_root / "interventions" / "log.yml",
        {
            "schema_version": "intervention-log-v1",
            "subject_kind": "run",
            "subject_ref": run_contract_ref,
            "interventions": intervention_records,
            "recorded_at": generated_at,
        },
    )

    if facts.get("disclosure") == "complete":
        disclosure_root.mkdir(parents=True, exist_ok=True)
        write_yaml(disclosure_root / "run-card.yml", {"schema_version": "run-card-v2", "run_id": run_id, "status": "succeeded"})

    return control_root


def materialize_fixture_effective_outputs(fixtures_root, cases, generated_at):
    route_bundle = {
        "schema_version": "octon-runtime-effective-route-bundle-v1",
        "generation_id": "fixture-run-health-routes",
        "generated_at": generated_at,
        "publication_status": "fixture",
        "publication_receipt_path": "fixture",
        "routes": [],
        "extensions": {"generation_id": "fixture", "status": "fixture", "quarantine_count": 0},
    }
    pack_routes = {
        "schema_version": "octon-runtime-pack-routes-effective-v1",
        "generation_id": "fixture-run-health-pack-routes",
        "generated_at": generated_at,
        "publication_status": "fixture",
        "publication_receipt_path": "fixture",
        "packs": [
            {"pack_id": "repo", "admission_status": "admitted", "default_route": "allow", "tuple_routes": []},
            {"pack_id": "shell", "admission_status": "admitted", "default_route": "allow", "tuple_routes": []},
        ],
    }
    for case in cases:
        facts = case.get("facts") or {}
        tuple_id = facts.get("tuple") or f"tuple://repo-local-governed/repo-consequential/reference-owned/english-primary/{case['case_id']}-fixture"
        route = facts.get("route_status", "allow")
        pack_route = facts.get("pack_status", route)
        route_bundle["routes"].append({"tuple_id": tuple_id, "route": route, "claim_effect": "fixture", "requires_mission": False, "allowed_capability_packs": ["repo", "shell"]})
        for pack in pack_routes["packs"]:
            pack["tuple_routes"].append({"tuple_id": tuple_id, "route": pack_route, "claim_effect": "fixture", "requires_mission": False})
    write_yaml(fixtures_root / "effective" / "route-bundle.yml", route_bundle)
    write_yaml(fixtures_root / "effective" / "pack-routes.effective.yml", pack_routes)
    return (
        (fixtures_root / "effective" / "route-bundle.yml").as_posix(),
        (fixtures_root / "effective" / "pack-routes.effective.yml").as_posix(),
    )


def generate_fixtures(fixtures_root, output_root, generated_at):
    fixture_set = load_yaml(fixtures_root / "fixture-set.yml")
    cases = fixture_set.get("cases") or []
    route_bundle_ref, pack_routes_ref = materialize_fixture_effective_outputs(fixtures_root, cases, generated_at)
    results = []
    for case in cases:
        control_root = materialize_fixture_sources(fixtures_root, case, generated_at)
        health = generate_for_run(case["case_id"], control_root, generated_at, route_bundle_ref, pack_routes_ref)
        out_file = output_root / case["case_id"] / "health.yml"
        write_yaml(out_file, health)
        results.append({"run_id": case["case_id"], "health_ref": out_file.as_posix(), "status": health["health"]["status"]})
    write_yaml(
        output_root / "index.yml",
        {
            "schema_version": "run-health-read-model-index-v1",
            "generated_at": generated_at,
            "authority": {
                "classification": "generated_read_model_non_authoritative",
                "may_authorize": False,
                "may_widen_support": False,
            },
            "runs": results,
        },
    )
    return results


def run_ids_from_repo():
    root = OCTON_DIR / "state/control/execution/runs"
    if not root.is_dir():
        return []
    return sorted(path.name for path in root.iterdir() if path.is_dir() and (path / "run-manifest.yml").is_file())


def write_evidence(evidence_root, generated_at, outputs, no_evidence):
    if no_evidence:
        return
    records = []
    for item in outputs:
        health_ref = item["health_ref"]
        digest = sha256_file(resolve_ref(health_ref) or Path(health_ref))
        records.append({**item, "health_digest": digest})
    write_yaml(
        evidence_root / "generation.yml",
        {
            "schema_version": "run-health-generation-receipt-v1",
            "generated_at": generated_at,
            "generator_ref": ".octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh",
            "schema_ref": SCHEMA_REF,
            "validator_ref": VALIDATOR_REF,
            "authority": {
                "classification": "generated_read_model_non_authoritative",
                "may_authorize": False,
                "may_widen_support": False,
            },
            "outputs": records,
        },
    )


def main():
    args = parse_args()
    generated_at = args.generated_at or utc_now()
    output_root = Path(args.output_root)
    evidence_root = Path(args.evidence_root)

    if args.fixtures_root:
        results = generate_fixtures(Path(args.fixtures_root), output_root, generated_at)
        write_evidence(evidence_root, generated_at, results, args.no_evidence)
        print(f"Generated {len(results)} fixture run-health read models under {output_root}")
        return

    run_ids = list(args.run_id)
    if args.all_runs:
        run_ids.extend(run_ids_from_repo())
    run_ids = sorted(set(run_ids))
    if not run_ids:
        raise SystemExit("No run ids supplied. Use --run-id <id> or --all-runs.")

    outputs = []
    for run_id in run_ids:
        control_root = OCTON_DIR / "state/control/execution/runs" / run_id
        if not control_root.is_dir():
            raise SystemExit(f"Run control root not found: {control_root}")
        health = generate_for_run(run_id, control_root, generated_at)
        out_file = output_root / run_id / "health.yml"
        write_yaml(out_file, health)
        outputs.append({"run_id": run_id, "health_ref": repo_ref(out_file), "status": health["health"]["status"]})

    write_yaml(
        output_root / "index.yml",
        {
            "schema_version": "run-health-read-model-index-v1",
            "generated_at": generated_at,
            "authority": {
                "classification": "generated_read_model_non_authoritative",
                "may_authorize": False,
                "may_widen_support": False,
            },
            "runs": outputs,
        },
    )
    write_evidence(evidence_root, generated_at, outputs, args.no_evidence)
    print(f"Generated {len(outputs)} run-health read models under {output_root}")


if __name__ == "__main__":
    main()
PY
