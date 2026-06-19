#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
DEFAULT_HEALTH_ROOT="$OCTON_DIR/generated/cognition/projections/materialized/runs"
DEFAULT_FIXTURES_ROOT="$OCTON_DIR/framework/assurance/runtime/_ops/fixtures/run-health-read-model"
DEFAULT_EVIDENCE_ROOT="$OCTON_DIR/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health"
source "$SCRIPT_DIR/validator-result-common.sh"

reset_validator_result_metadata
validator_result_add_contract ".octon/framework/engine/runtime/spec/operator-read-models-v1.md"
validator_result_add_contract ".octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json"
validator_result_add_evidence ".octon/generated/cognition/projections/materialized/runs/index.yml"
validator_result_add_evidence ".octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health/generation.yml"
validator_result_add_runtime_test ".octon/framework/assurance/runtime/_ops/tests/test-run-health-read-model.sh"
validator_result_add_negative_control "missing-non-authority-classification-denies"
validator_result_add_negative_control "authority-widening-denies"
validator_result_add_negative_control "source-digest-drift-denies"
validator_result_add_negative_control "fixture-status-mismatch-denies"
validator_result_add_negative_control "missing-proof-state-denies"
validator_result_add_negative_control "approval-boundary-erasure-denies"
validator_result_add_negative_control "proposal-local-evidence-denies-generated-freshness"
validator_result_add_negative_control "parent-evidence-denies-generated-freshness"
validator_result_add_negative_control "generated-output-denies-closeout-authority"
validator_result_add_schema_version "run-health-read-model-v1"

set +e
python3 - "$ROOT_DIR" "$OCTON_DIR" "$DEFAULT_HEALTH_ROOT" "$DEFAULT_FIXTURES_ROOT" "$DEFAULT_EVIDENCE_ROOT" "$@" <<'PY'
import argparse
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

try:
    import jsonschema
except ImportError:
    jsonschema = None

try:
    import yaml
except ImportError:
    yaml = None

ROOT_DIR = Path(sys.argv[1])
OCTON_DIR = Path(sys.argv[2])
DEFAULT_HEALTH_ROOT = Path(sys.argv[3])
DEFAULT_FIXTURES_ROOT = Path(sys.argv[4])
DEFAULT_EVIDENCE_ROOT = Path(sys.argv[5])
ARGV = sys.argv[6:]

SCHEMA_PATH = OCTON_DIR / "framework/engine/runtime/spec/run-health-read-model-v1.schema.json"
GENERATOR_SCRIPT_PATH = OCTON_DIR / "framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh"
REQUIRED_STATUSES = {
    "healthy",
    "blocked",
    "stale",
    "unsupported",
    "revoked",
    "authority-ambiguity",
    "review-required",
    "evidence-incomplete",
    "rollback-required",
    "intervention-required",
    "disclosure-incomplete",
    "closure-ready",
}
REQUIRED_PROOF_STATES = {
    "proof-valid",
    "proof-missing",
    "proof-failed",
    "proof-stale",
    "proof-contradictory",
    "proof-scope-mismatch",
    "proof-unknown",
}
REQUIRED_HUMAN_BOUNDARY_STATES = {
    "none",
    "approval-required",
    "review-required",
    "exception-required",
    "revocation-active",
    "denied",
    "unknown",
}
FORBIDDEN_CONSUMERS = {
    "runtime",
    "policy",
    "authority",
    "support-claim-evaluation",
}
GENERATED_RUN_HEALTH_ROOT = ".octon/generated/cognition/projections/materialized/runs/"
GENERATOR_REF = ".octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh"
VALIDATOR_REF = ".octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh"


def normalize_fixture_status(value):
    if value == "approval-required":
        return "authority-ambiguity"
    return value


def parse_args():
    parser = argparse.ArgumentParser(description="Validate run-health read-model artifacts.")
    parser.add_argument("--health-root", default=str(DEFAULT_HEALTH_ROOT))
    parser.add_argument("--health-file", action="append", default=[])
    parser.add_argument("--fixtures-root", default=str(DEFAULT_FIXTURES_ROOT))
    parser.add_argument("--fixture-output-root", default=None)
    parser.add_argument("--evidence-root", default=None)
    parser.add_argument("--no-live", action="store_true")
    parser.add_argument("--no-fixtures", action="store_true")
    parser.add_argument("--no-report", action="store_true")
    return parser.parse_args(ARGV)


def load_yaml(path):
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


def is_non_empty_string(value):
    return isinstance(value, str) and len(value) > 0


def is_ref_array(value):
    return isinstance(value, list) and all(is_non_empty_string(item) for item in value) and len(value) == len(set(value))


def is_hash_string(value):
    if not isinstance(value, str) or not value.startswith("sha256:") or len(value) != 71:
        return False
    return all(ch in "0123456789abcdef" for ch in value[7:])


def is_repo_relative_generated_run_health_ref(value):
    if not is_non_empty_string(value):
        return False
    if value.startswith("/") or Path(value).is_absolute():
        return False
    return value.startswith(GENERATED_RUN_HEALTH_ROOT)


def require_object(data, key, failures, context):
    value = data.get(key)
    if not isinstance(value, dict):
        failures.append(f"{context}: schema validation failed: {key} must be an object")
        return {}
    return value


def validate_schema_or_fallback(schema, data, context):
    if jsonschema is not None:
        try:
            jsonschema.validate(data, schema)
        except jsonschema.ValidationError as exc:
            return [f"{context}: schema validation failed: {exc.message}"]
        return []

    failures = []
    if not isinstance(data, dict):
        return [f"{context}: schema validation failed: document must be an object"]

    required_top_level = (
        "schema_version",
        "run_id",
        "generated_at",
        "generator",
        "authority",
        "freshness",
        "canonical_refs",
        "source_digests",
        "health",
        "lifecycle",
        "support",
        "authorization",
        "evidence",
        "rollback",
        "intervention",
        "disclosure",
        "closure",
        "diagnostics",
    )
    for key in required_top_level:
        if key not in data:
            failures.append(f"{context}: schema validation failed: missing required property {key}")
    if failures:
        return failures

    if data.get("schema_version") != "run-health-read-model-v1":
        failures.append(f"{context}: schema validation failed: schema_version must be run-health-read-model-v1")
    if not is_non_empty_string(data.get("run_id")):
        failures.append(f"{context}: schema validation failed: run_id must be a non-empty string")
    if not is_non_empty_string(data.get("generated_at")):
        failures.append(f"{context}: schema validation failed: generated_at must be a non-empty string")

    generator = require_object(data, "generator", failures, context)
    if generator.get("id") != "generate-run-health-read-model.sh":
        failures.append(f"{context}: schema validation failed: generator.id is invalid")
    if not is_non_empty_string(generator.get("version")):
        failures.append(f"{context}: schema validation failed: generator.version must be a non-empty string")
    if generator.get("validator_ref") != ".octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh":
        failures.append(f"{context}: schema validation failed: generator.validator_ref is invalid")

    authority = require_object(data, "authority", failures, context)
    if authority.get("classification") != "generated_read_model_non_authoritative":
        failures.append(f"{context}: schema validation failed: authority.classification is invalid")
    if authority.get("may_authorize") is not False:
        failures.append(f"{context}: schema validation failed: authority.may_authorize must be false")
    if authority.get("may_widen_support") is not False:
        failures.append(f"{context}: schema validation failed: authority.may_widen_support must be false")
    if not is_ref_array(authority.get("allowed_consumers")):
        failures.append(f"{context}: schema validation failed: authority.allowed_consumers must be a unique string list")
    elif not set(authority["allowed_consumers"]).issubset({"operators", "validators"}):
        failures.append(f"{context}: schema validation failed: authority.allowed_consumers has unsupported values")
    if not is_ref_array(authority.get("forbidden_consumers")):
        failures.append(f"{context}: schema validation failed: authority.forbidden_consumers must be a unique string list")
    elif not set(authority["forbidden_consumers"]).issubset(
        {"runtime", "policy", "authority", "support-claim-evaluation", "state-reconstruction", "direct-runtime-reads"}
    ):
        failures.append(f"{context}: schema validation failed: authority.forbidden_consumers has unsupported values")

    freshness = require_object(data, "freshness", failures, context)
    if freshness.get("mode") not in {"digest-bound", "ttl-bound", "receipt-bound", "unknown"}:
        failures.append(f"{context}: schema validation failed: freshness.mode is invalid")
    if freshness.get("status") not in {"fresh", "stale", "unknown"}:
        failures.append(f"{context}: schema validation failed: freshness.status is invalid")
    if freshness.get("source_digest_algorithm") != "sha256":
        failures.append(f"{context}: schema validation failed: freshness.source_digest_algorithm must be sha256")
    if not is_hash_string(freshness.get("combined_source_digest")):
        failures.append(f"{context}: schema validation failed: freshness.combined_source_digest must be a sha256 hash")
    if not is_non_empty_string(freshness.get("checked_at")):
        failures.append(f"{context}: schema validation failed: freshness.checked_at must be a non-empty string")
    if "freshness_refs" in freshness and not is_ref_array(freshness.get("freshness_refs")):
        failures.append(f"{context}: schema validation failed: freshness.freshness_refs must be a unique string list")

    canonical = require_object(data, "canonical_refs", failures, context)
    for key in (
        "run_contract",
        "run_manifest",
        "events_journal",
        "events_manifest",
        "runtime_state",
        "authority_decision",
        "authority_bundle",
        "rollback_posture",
        "evidence_root",
        "evidence_classification",
        "retained_evidence",
        "replay_pointers",
        "intervention_log",
        "disclosure_run_card",
        "support_targets",
        "support_reconciliation",
        "run_continuity",
    ):
        if key not in canonical:
            failures.append(f"{context}: schema validation failed: canonical_refs.{key} is required")

    digests = require_object(data, "source_digests", failures, context)
    if not digests:
        failures.append(f"{context}: schema validation failed: source_digests must not be empty")
    for key, item in digests.items():
        if not isinstance(item, dict):
            failures.append(f"{context}: schema validation failed: source_digests.{key} must be an object")
            continue
        if "ref" not in item or "digest" not in item or "status" not in item:
            failures.append(f"{context}: schema validation failed: source_digests.{key} is missing required fields")
        if item.get("status") not in {"present", "missing", "not-applicable"}:
            failures.append(f"{context}: schema validation failed: source_digests.{key}.status is invalid")
        digest = item.get("digest")
        if digest not in {"missing", "not-applicable"} and not is_hash_string(digest):
            failures.append(f"{context}: schema validation failed: source_digests.{key}.digest is invalid")

    health = require_object(data, "health", failures, context)
    if health.get("status") not in REQUIRED_STATUSES:
        failures.append(f"{context}: schema validation failed: health.status is invalid")
    if not is_non_empty_string(health.get("summary")):
        failures.append(f"{context}: schema validation failed: health.summary must be a non-empty string")
    if not is_non_empty_string(health.get("next_required_action")):
        failures.append(f"{context}: schema validation failed: health.next_required_action must be a non-empty string")

    lifecycle = require_object(data, "lifecycle", failures, context)
    for key in ("state", "decision_state", "drift_status", "latest_event_hash"):
        if key not in lifecycle:
            failures.append(f"{context}: schema validation failed: lifecycle.{key} is required")
    if lifecycle.get("latest_event_hash") is not None and not is_hash_string(lifecycle.get("latest_event_hash")):
        failures.append(f"{context}: schema validation failed: lifecycle.latest_event_hash is invalid")

    support = require_object(data, "support", failures, context)
    if support.get("route_status") not in {"allow", "stage-only", "deny", "unsupported", "unknown"}:
        failures.append(f"{context}: schema validation failed: support.route_status is invalid")
    if support.get("pack_status") not in {"allow", "stage-only", "deny", "unsupported", "unknown"}:
        failures.append(f"{context}: schema validation failed: support.pack_status is invalid")
    if support.get("support_status") not in {"supported", "stage-only", "unsupported", "unknown"}:
        failures.append(f"{context}: schema validation failed: support.support_status is invalid")
    if "requested_capability_packs" in support and not is_ref_array(support.get("requested_capability_packs")):
        failures.append(f"{context}: schema validation failed: support.requested_capability_packs must be a unique string list")

    authorization = require_object(data, "authorization", failures, context)
    if authorization.get("status") not in {"authorized", "authority-ambiguity", "revoked", "denied", "review-required", "unknown"}:
        failures.append(f"{context}: schema validation failed: authorization.status is invalid")
    if authorization.get("proof_state") not in REQUIRED_PROOF_STATES:
        failures.append(f"{context}: schema validation failed: authorization.proof_state is invalid")
    if authorization.get("human_boundary_state") not in REQUIRED_HUMAN_BOUNDARY_STATES:
        failures.append(f"{context}: schema validation failed: authorization.human_boundary_state is invalid")
    for key in ("active_grants", "open_approvals", "active_exceptions", "active_revocations"):
        if not is_ref_array(authorization.get(key)):
            failures.append(f"{context}: schema validation failed: authorization.{key} must be a unique string list")

    evidence = require_object(data, "evidence", failures, context)
    if evidence.get("completeness") not in {"complete", "incomplete", "unknown"}:
        failures.append(f"{context}: schema validation failed: evidence.completeness is invalid")
    if not is_ref_array(evidence.get("missing_required")):
        failures.append(f"{context}: schema validation failed: evidence.missing_required must be a unique string list")

    rollback = require_object(data, "rollback", failures, context)
    if rollback.get("status") not in {"ready", "required", "unavailable", "unknown"}:
        failures.append(f"{context}: schema validation failed: rollback.status is invalid")

    intervention = require_object(data, "intervention", failures, context)
    if intervention.get("status") not in {"none", "present", "required", "unknown"}:
        failures.append(f"{context}: schema validation failed: intervention.status is invalid")
    if not isinstance(intervention.get("undisclosed_count"), int) or intervention.get("undisclosed_count") < 0:
        failures.append(f"{context}: schema validation failed: intervention.undisclosed_count must be a non-negative integer")
    if not isinstance(intervention.get("records"), list):
        failures.append(f"{context}: schema validation failed: intervention.records must be a list")

    disclosure = require_object(data, "disclosure", failures, context)
    if disclosure.get("status") not in {"complete", "incomplete", "unknown"}:
        failures.append(f"{context}: schema validation failed: disclosure.status is invalid")

    closure = require_object(data, "closure", failures, context)
    if closure.get("status") not in {"ready", "not-ready", "blocked", "unknown"}:
        failures.append(f"{context}: schema validation failed: closure.status is invalid")

    diagnostics = data.get("diagnostics")
    if not isinstance(diagnostics, list):
        failures.append(f"{context}: schema validation failed: diagnostics must be a list")
    else:
        for index, item in enumerate(diagnostics):
            if not isinstance(item, dict):
                failures.append(f"{context}: schema validation failed: diagnostics[{index}] must be an object")
                continue
            if item.get("severity") not in {"info", "warning", "error"}:
                failures.append(f"{context}: schema validation failed: diagnostics[{index}].severity is invalid")
            if not is_non_empty_string(item.get("code")):
                failures.append(f"{context}: schema validation failed: diagnostics[{index}].code must be a non-empty string")
            if not is_non_empty_string(item.get("message")):
                failures.append(f"{context}: schema validation failed: diagnostics[{index}].message must be a non-empty string")
            if not is_ref_array(item.get("refs")):
                failures.append(f"{context}: schema validation failed: diagnostics[{index}].refs must be a unique string list")

    return failures


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


def health_files_from(root):
    root = Path(root)
    if not root.exists():
        return []
    return sorted(path for path in root.glob("*/health.yml") if path.is_file())


def validate_compact_manifest(path):
    failures = []
    data = load_yaml(path)
    context = str(path)
    if not isinstance(data, dict):
        return [f"{context}: compact manifest must be a YAML object"]
    if data.get("schema_version") != "run-health-compact-manifest-v1":
        failures.append(f"{context}: schema_version must be run-health-compact-manifest-v1")

    producer = data.get("producer")
    if not isinstance(producer, dict):
        failures.append(f"{context}: producer must be an object")
        producer = {}
    if producer.get("id") != "generate-run-health-read-model.sh":
        failures.append(f"{context}: producer.id is invalid")
    if producer.get("validator_ref") != ".octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh":
        failures.append(f"{context}: producer.validator_ref is invalid")

    consumer = data.get("consumer")
    if not isinstance(consumer, dict):
        failures.append(f"{context}: consumer must be an object")
        consumer = {}
    if "validators" not in set(consumer.get("allowed_consumers") or []):
        failures.append(f"{context}: consumer.allowed_consumers must include validators")
    if not FORBIDDEN_CONSUMERS.issubset(set(consumer.get("forbidden_consumers") or [])):
        failures.append(f"{context}: consumer.forbidden_consumers is incomplete")

    authority = data.get("authority")
    if not isinstance(authority, dict):
        failures.append(f"{context}: authority must be an object")
        authority = {}
    if authority.get("classification") != "generated_read_model_non_authoritative":
        failures.append(f"{context}: authority.classification is invalid")
    if authority.get("may_authorize") is not False:
        failures.append(f"{context}: authority.may_authorize must be false")
    if authority.get("may_widen_support") is not False:
        failures.append(f"{context}: authority.may_widen_support must be false")

    source_refs = data.get("source_refs")
    if not is_ref_array(source_refs):
        failures.append(f"{context}: source_refs must be a unique string list")
        source_refs = []
    for ref in source_refs:
        if ".octon/inputs/" in ref:
            failures.append(f"{context}: input-path ref is forbidden in compact manifest: {ref}")

    source_digests = data.get("source_digests")
    if not isinstance(source_digests, list) or not source_digests:
        failures.append(f"{context}: source_digests must be a non-empty list")
        source_digests = []
    digest_refs = set()
    for index, item in enumerate(source_digests):
        if not isinstance(item, dict):
            failures.append(f"{context}: source_digests[{index}] must be an object")
            continue
        ref = item.get("ref")
        digest_refs.add(ref)
        if ref not in source_refs:
            failures.append(f"{context}: source_digests[{index}].ref must appear in source_refs")
        if item.get("status") == "present":
            actual = sha256_path(resolve_ref(ref))
            if actual is None:
                failures.append(f"{context}: compact digest source missing: {ref}")
            elif actual != item.get("sha256"):
                failures.append(f"{context}: compact digest drift for {ref}: expected {item.get('sha256')}, got {actual}")
        elif item.get("status") == "missing":
            if item.get("sha256") != "missing":
                failures.append(f"{context}: missing compact source must carry sha256=missing: {ref}")
        else:
            failures.append(f"{context}: source_digests[{index}].status is invalid")
    for ref in source_refs:
        if ref not in digest_refs:
            failures.append(f"{context}: source ref lacks digest entry: {ref}")

    validation = data.get("validation")
    if not isinstance(validation, dict):
        failures.append(f"{context}: validation must be an object")
        validation = {}
    run_health = data.get("run_health")
    if not isinstance(run_health, list):
        failures.append(f"{context}: run_health must be a list")
        run_health = []
    failing_slices = data.get("failing_slices")
    if not isinstance(failing_slices, list):
        failures.append(f"{context}: failing_slices must be a list")
        failing_slices = []
    if validation.get("health_count") != len(run_health):
        failures.append(f"{context}: validation.health_count must match run_health length")
    if validation.get("failing_slice_count") != len(failing_slices):
        failures.append(f"{context}: validation.failing_slice_count must match failing_slices length")
    if not is_ref_array(validation.get("failing_slice_refs", [])):
        failures.append(f"{context}: validation.failing_slice_refs must be a unique string list")

    for index, item in enumerate(run_health):
        if not isinstance(item, dict):
            failures.append(f"{context}: run_health[{index}] must be an object")
            continue
        health_ref = item.get("health_ref")
        if not is_repo_relative_generated_run_health_ref(health_ref):
            failures.append(f"{context}: run_health[{index}].health_ref must be repo-relative under {GENERATED_RUN_HEALTH_ROOT}")
        if health_ref and health_ref not in source_refs:
            failures.append(f"{context}: run_health[{index}].health_ref must appear in source_refs")
        actual = sha256_path(resolve_ref(health_ref)) if health_ref else None
        if item.get("health_sha256") not in {"missing", actual}:
            failures.append(f"{context}: run_health[{index}].health_sha256 drift for {health_ref}")

    fail_closed = set(((data.get("failure_behavior") or {}).get("fail_closed_on") or []))
    for required in ("missing-source", "source-digest-mismatch", "stale-freshness", "authority-boundary-violation"):
        if required not in fail_closed:
            failures.append(f"{context}: failure_behavior must include {required}")

    if not is_ref_array(data.get("evidence_refs")):
        failures.append(f"{context}: evidence_refs must be a unique string list")

    return failures


def validate_generation_receipt(evidence_root):
    evidence_root = Path(evidence_root)
    receipt_path = evidence_root / "generation.yml"
    failures = []
    if not receipt_path.is_file():
        return [f"missing generation receipt: {receipt_path}"]

    data = load_yaml(receipt_path)
    context = str(receipt_path)
    if not isinstance(data, dict):
        return [f"{context}: generation receipt must be a YAML object"]

    if data.get("schema_version") != "run-health-generation-receipt-v1":
        failures.append(f"{context}: schema_version must be run-health-generation-receipt-v1")
    if data.get("generator_ref") != ".octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh":
        failures.append(f"{context}: generator_ref is invalid")
    if data.get("schema_ref") != ".octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json":
        failures.append(f"{context}: schema_ref is invalid")
    if data.get("validator_ref") != ".octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh":
        failures.append(f"{context}: validator_ref is invalid")

    freshness_scope = data.get("generated_freshness_scope")
    if freshness_scope is not None:
        if not isinstance(freshness_scope, dict):
            failures.append(f"{context}: generated_freshness_scope must be an object when present")
            freshness_scope = {}
        if freshness_scope.get("owner_generator_ref") != GENERATOR_REF:
            failures.append(f"{context}: generated freshness scope must cite owning generator")
        if freshness_scope.get("owner_validator_ref") != VALIDATOR_REF:
            failures.append(f"{context}: generated freshness scope must cite owning validator")
        if freshness_scope.get("proposal_local_or_parent_evidence_satisfies_freshness") is not False:
            failures.append(f"{context}: proposal-local or parent evidence must not satisfy generated freshness")
        if freshness_scope.get("generated_output_authorizes_closeout_or_archive") is not False:
            failures.append(f"{context}: generated output must not authorize closeout or archive")

    authority = data.get("authority")
    if not isinstance(authority, dict):
        failures.append(f"{context}: authority must be an object")
        authority = {}
    if authority.get("classification") != "generated_read_model_non_authoritative":
        failures.append(f"{context}: authority.classification is invalid")
    if authority.get("may_authorize") is not False:
        failures.append(f"{context}: authority.may_authorize must be false")
    if authority.get("may_widen_support") is not False:
        failures.append(f"{context}: authority.may_widen_support must be false")

    published_paths = data.get("published_paths")
    if not isinstance(published_paths, list) or not published_paths:
        failures.append(f"{context}: published_paths must be a non-empty list")
        published_paths = []
    elif len(published_paths) != len(set(published_paths)):
        failures.append(f"{context}: published_paths must be unique")

    published_set = set()
    for item in published_paths:
        if not is_repo_relative_generated_run_health_ref(item):
            failures.append(f"{context}: published_paths item must be repo-relative under {GENERATED_RUN_HEALTH_ROOT}: {item}")
            continue
        published_set.add(item)
        resolved = resolve_ref(item)
        if resolved is None or not resolved.is_file():
            failures.append(f"{context}: published path missing on disk: {item}")

    index_ref = GENERATED_RUN_HEALTH_ROOT + "index.yml"
    if published_paths and index_ref not in published_set:
        failures.append(f"{context}: published_paths must include {index_ref}")

    pruned_paths = data.get("pruned_paths", [])
    if not isinstance(pruned_paths, list):
        failures.append(f"{context}: pruned_paths must be a list")
        pruned_paths = []
    elif len(pruned_paths) != len(set(pruned_paths)):
        failures.append(f"{context}: pruned_paths must be unique")

    pruned_set = set()
    for item in pruned_paths:
        if not is_repo_relative_generated_run_health_ref(item):
            failures.append(f"{context}: pruned_paths item must be repo-relative under {GENERATED_RUN_HEALTH_ROOT}: {item}")
            continue
        pruned_set.add(item)
    if published_set & pruned_set:
        failures.append(f"{context}: published_paths and pruned_paths must be disjoint")

    compact_manifest_ref = data.get("compact_manifest_ref")
    compact_manifest_digest = data.get("compact_manifest_digest")
    if compact_manifest_ref:
        if not is_repo_relative_generated_run_health_ref(compact_manifest_ref):
            failures.append(f"{context}: compact_manifest_ref must be repo-relative under {GENERATED_RUN_HEALTH_ROOT}")
        elif compact_manifest_ref not in published_set:
            failures.append(f"{context}: compact_manifest_ref must appear in published_paths")
        compact_path = resolve_ref(compact_manifest_ref)
        if compact_path is None or not compact_path.is_file():
            failures.append(f"{context}: compact manifest missing on disk: {compact_manifest_ref}")
        else:
            actual = sha256_path(compact_path)
            if compact_manifest_digest != actual:
                failures.append(f"{context}: compact_manifest_digest drift for {compact_manifest_ref}")
            failures.extend(validate_compact_manifest(compact_path))

    outputs = data.get("outputs")
    if not isinstance(outputs, list) or not outputs:
        failures.append(f"{context}: outputs must be a non-empty list")
        outputs = []
    for index, item in enumerate(outputs):
        if not isinstance(item, dict):
            failures.append(f"{context}: outputs[{index}] must be an object")
            continue
        health_ref = item.get("health_ref")
        if not is_repo_relative_generated_run_health_ref(health_ref):
            failures.append(f"{context}: outputs[{index}].health_ref must be repo-relative under {GENERATED_RUN_HEALTH_ROOT}")
            continue
        if health_ref not in published_set:
            failures.append(f"{context}: outputs[{index}].health_ref must appear in published_paths")

    return failures


def assert_no_inputs_refs(data, failures, context):
    refs = []
    refs.extend([value for value in data.get("canonical_refs", {}).values() if isinstance(value, str)])
    for value in data.get("canonical_refs", {}).values():
        if isinstance(value, list):
            refs.extend(value)
    for item in data.get("source_digests", {}).values():
        if isinstance(item.get("ref"), str):
            refs.append(item["ref"])
    for ref in refs:
        if ".octon/inputs/" in ref:
            failures.append(f"{context}: input-path ref is forbidden in run health: {ref}")


def validate_generator_scope_contract():
    if not GENERATOR_SCRIPT_PATH.is_file():
        return [f"missing run-health generator script: {GENERATOR_SCRIPT_PATH}"]
    text = GENERATOR_SCRIPT_PATH.read_text(encoding="utf-8")
    required_tokens = {
        "GENERATOR_REF": "owning generator ref constant",
        "GENERATED_FRESHNESS_OWNER": "generated freshness owner constant",
        "GENERATED_FRESHNESS_OUTCOMES": "generated freshness outcome list",
        "proposal_local_or_parent_evidence_satisfies_freshness": "proposal-local freshness denial",
        "generated_output_authorizes_closeout_or_archive": "closeout/archive authority denial",
    }
    failures = []
    for token, label in required_tokens.items():
        if token not in text:
            failures.append(f"run-health generator missing {label}")
    return failures


def validate_one(schema, path):
    failures = []
    data = load_yaml(path)
    context = str(path)
    schema_failures = validate_schema_or_fallback(schema, data, context)
    if schema_failures:
        failures.extend(schema_failures)
        return failures, data

    authority = data["authority"]
    if authority["classification"] != "generated_read_model_non_authoritative":
        failures.append(f"{context}: invalid non-authority classification")
    if authority["may_authorize"] is not False or authority["may_widen_support"] is not False:
        failures.append(f"{context}: generated health must not authorize or widen support")
    if not FORBIDDEN_CONSUMERS.issubset(set(authority.get("forbidden_consumers", []))):
        failures.append(f"{context}: forbidden consumer classification is incomplete")

    status = data["health"]["status"]
    if status not in REQUIRED_STATUSES:
        failures.append(f"{context}: unsupported health status {status}")

    assert_no_inputs_refs(data, failures, context)

    digest_entries = data.get("source_digests", {})
    for key, item in digest_entries.items():
        ref = item.get("ref")
        status_value = item.get("status")
        digest_value = item.get("digest")
        if status_value == "present":
            actual = sha256_path(resolve_ref(ref))
            if actual is None:
                failures.append(f"{context}: digest source missing for present source {key}: {ref}")
            elif actual != digest_value:
                failures.append(f"{context}: digest drift for {key}: expected {digest_value}, got {actual}")
        elif status_value == "missing" and digest_value != "missing":
            failures.append(f"{context}: missing source {key} must carry digest=missing")

    expected_combined = combined_digest(digest_entries)
    if data["freshness"]["combined_source_digest"] != expected_combined:
        failures.append(f"{context}: combined source digest mismatch")

    canonical = data["canonical_refs"]
    for required_key in ("run_manifest", "runtime_state"):
        ref = canonical.get(required_key)
        if not ref or not (resolve_ref(ref) and resolve_ref(ref).is_file()):
            failures.append(f"{context}: required canonical ref is missing: {required_key}")

    diagnostics = data.get("diagnostics", [])
    if status == "review-required" and not diagnostics:
        failures.append(f"{context}: review-required health must explain uncertainty in diagnostics")
    if status == "authority-ambiguity" and data["authorization"]["status"] != "authority-ambiguity":
        failures.append(f"{context}: authority-ambiguity health must match authorization status")
    proof_state = data["authorization"].get("proof_state")
    human_boundary_state = data["authorization"].get("human_boundary_state")
    auth_status = data["authorization"]["status"]
    if auth_status == "authorized" and proof_state not in {"proof-valid", "proof-stale"}:
        failures.append(f"{context}: authorized posture must carry proof-valid or proof-stale")
    if auth_status == "authority-ambiguity" and proof_state not in {"proof-missing", "proof-contradictory", "proof-scope-mismatch", "proof-unknown"}:
        failures.append(f"{context}: authority-ambiguity must carry a fail-closed proof state")
    if data["authorization"].get("open_approvals") and human_boundary_state != "approval-required":
        failures.append(f"{context}: open approvals must surface approval-required human boundary")
    if proof_state == "proof-missing" and human_boundary_state not in {"approval-required", "review-required", "unknown"}:
        failures.append(f"{context}: proof-missing must carry a typed human boundary")
    if proof_state in {"proof-contradictory", "proof-scope-mismatch"} and human_boundary_state not in {"review-required", "revocation-active"}:
        failures.append(f"{context}: contradictory or scope-mismatched proof must require review or expose revocation")
    if proof_state == "proof-stale" and data["freshness"]["status"] != "stale":
        failures.append(f"{context}: proof-stale must match stale freshness")
    if auth_status == "denied" and human_boundary_state != "denied":
        failures.append(f"{context}: denied authorization must surface denied human boundary")
    if auth_status == "revoked" and human_boundary_state != "revocation-active":
        failures.append(f"{context}: revoked authorization must surface revocation-active human boundary")
    if status == "revoked" and data["authorization"]["status"] != "revoked" and data["lifecycle"]["state"] != "revoked":
        failures.append(f"{context}: revoked health must cite revoked authorization or lifecycle state")
    if status == "unsupported" and data["support"]["support_status"] != "unsupported":
        failures.append(f"{context}: unsupported health must match unsupported support posture")
    if status == "evidence-incomplete" and data["evidence"]["completeness"] != "incomplete":
        failures.append(f"{context}: evidence-incomplete health must match evidence completeness")
    if status == "rollback-required" and data["rollback"]["status"] not in ("required", "unavailable"):
        failures.append(f"{context}: rollback-required health must match rollback posture")
    if status == "intervention-required" and data["intervention"]["status"] != "required":
        failures.append(f"{context}: intervention-required health must match intervention posture")
    if status == "disclosure-incomplete" and data["disclosure"]["status"] != "incomplete":
        failures.append(f"{context}: disclosure-incomplete health must match disclosure posture")
    if status == "closure-ready" and data["closure"]["status"] != "ready":
        failures.append(f"{context}: closure-ready health must carry closure.status=ready")

    return failures, data


def mutate_negative_controls(schema, valid_file):
    failures = []
    if not valid_file:
        return ["negative controls skipped because no valid health file exists"]
    original = load_yaml(valid_file)

    missing_classification = copy.deepcopy(original)
    missing_classification["authority"]["classification"] = "authority"
    if not validate_schema_or_fallback(schema, missing_classification, "missing-non-authority-classification"):
        failures.append("missing-non-authority-classification negative control unexpectedly passed schema")

    authority_widening = copy.deepcopy(original)
    authority_widening["authority"]["may_authorize"] = True
    if not validate_schema_or_fallback(schema, authority_widening, "authority-widening"):
        failures.append("authority-widening negative control unexpectedly passed schema")

    missing_proof_state = copy.deepcopy(original)
    missing_proof_state["authorization"].pop("proof_state", None)
    if not validate_schema_or_fallback(schema, missing_proof_state, "missing-proof-state"):
        failures.append("missing-proof-state negative control unexpectedly passed schema")

    approval_boundary_erasure = copy.deepcopy(original)
    approval_boundary_erasure["authorization"]["status"] = "authority-ambiguity"
    approval_boundary_erasure["authorization"]["proof_state"] = "proof-missing"
    approval_boundary_erasure["authorization"]["human_boundary_state"] = "none"
    approval_boundary_erasure["authorization"]["open_approvals"] = ["fixture/approval-request.yml"]
    if not validate_schema_or_fallback(schema, approval_boundary_erasure, "approval-boundary-erasure"):
        if not (
            approval_boundary_erasure["authorization"].get("open_approvals")
            and approval_boundary_erasure["authorization"].get("human_boundary_state") != "approval-required"
        ):
            failures.append("approval-boundary-erasure negative control unexpectedly passed semantic check")

    digest_drift = copy.deepcopy(original)
    first_key = next(iter(digest_drift["source_digests"]))
    digest_drift["source_digests"][first_key]["digest"] = "sha256:" + "f" * 64
    expected_combined = combined_digest(digest_drift["source_digests"])
    if digest_drift["freshness"]["combined_source_digest"] == expected_combined:
        failures.append("source-digest-drift negative control did not perturb combined digest")
    return failures


def validate_fixture_contract(fixtures_root, fixture_output_root, schema):
    failures = []
    fixture_set_path = Path(fixtures_root) / "fixture-set.yml"
    if not fixture_set_path.is_file():
        failures.append(f"missing fixture set: {fixture_set_path}")
        return failures
    fixture_set = load_yaml(fixture_set_path)
    expected_statuses = {normalize_fixture_status(case.get("expected_status")) for case in fixture_set.get("cases", [])}
    missing = REQUIRED_STATUSES - expected_statuses
    extra = expected_statuses - REQUIRED_STATUSES
    if missing:
        failures.append(f"fixture set missing health statuses: {sorted(missing)}")
    if extra:
        failures.append(f"fixture set declares unknown health statuses: {sorted(extra)}")

    output_root = Path(fixture_output_root) if fixture_output_root else Path(fixtures_root) / "generated"
    if output_root.exists():
        by_case = {case["case_id"]: normalize_fixture_status(case.get("expected_status")) for case in fixture_set.get("cases", [])}
        for health_file in health_files_from(output_root):
            file_failures, data = validate_one(schema, health_file)
            failures.extend(file_failures)
            expected = by_case.get(data.get("run_id"))
            actual = data.get("health", {}).get("status")
            if expected and actual != expected:
                failures.append(f"{health_file}: expected fixture status {expected}, got {actual}")
            expected_case = next((case for case in fixture_set.get("cases", []) if case.get("case_id") == data.get("run_id")), {})
            expected_proof_state = expected_case.get("expected_proof_state")
            if expected_proof_state and data.get("authorization", {}).get("proof_state") != expected_proof_state:
                failures.append(
                    f"{health_file}: expected proof state {expected_proof_state}, got {data.get('authorization', {}).get('proof_state')}"
                )
            expected_boundary = expected_case.get("expected_human_boundary_state")
            if expected_boundary and data.get("authorization", {}).get("human_boundary_state") != expected_boundary:
                failures.append(
                    f"{health_file}: expected human boundary {expected_boundary}, got {data.get('authorization', {}).get('human_boundary_state')}"
                )
    return failures


def main():
    args = parse_args()
    schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
    failures = []
    validated_files = []

    failures.extend(validate_generator_scope_contract())

    candidate_files = []
    candidate_files.extend(Path(item) for item in args.health_file)
    if not args.no_live:
        candidate_files.extend(health_files_from(args.health_root))

    for health_file in sorted(set(candidate_files)):
        file_failures, _ = validate_one(schema, health_file)
        failures.extend(file_failures)
        if not file_failures:
            validated_files.append(health_file)

    if not args.no_live and not candidate_files:
        failures.append(f"no run-health files found under {args.health_root}")

    evidence_root = Path(args.evidence_root) if args.evidence_root else (DEFAULT_EVIDENCE_ROOT if not args.no_live else None)
    if evidence_root is not None:
        failures.extend(validate_generation_receipt(evidence_root))

    fixture_files_for_negative = []
    if not args.no_fixtures:
        failures.extend(validate_fixture_contract(args.fixtures_root, args.fixture_output_root, schema))
        fixture_output_root = Path(args.fixture_output_root) if args.fixture_output_root else Path(args.fixtures_root) / "generated"
        fixture_files_for_negative = health_files_from(fixture_output_root)

    negative_source = validated_files[0] if validated_files else (fixture_files_for_negative[0] if fixture_files_for_negative else None)
    failures.extend(mutate_negative_controls(schema, negative_source))

    if failures:
        print("== Run Health Read Model Validation ==")
        for failure in failures:
            print(f"[ERROR] {failure}")
        print(f"Validation summary: errors={len(failures)}")
        return 1

    print("== Run Health Read Model Validation ==")
    print(f"[OK] schema present: {SCHEMA_PATH.relative_to(ROOT_DIR)}")
    print(f"[OK] validated health files: {len(validated_files)}")
    print("[OK] fixture status coverage complete")
    print("[OK] negative controls fail closed")
    print("Validation summary: errors=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
PY
status=$?
set -e

if [[ $status -eq 0 ]]; then
  emit_validator_result "validate-run-health-read-model.sh" "run_health_read_model" "semantic" "semantic" "pass"
else
  emit_validator_result "validate-run-health-read-model.sh" "run_health_read_model" "semantic" "existence" "fail"
fi

exit "$status"
