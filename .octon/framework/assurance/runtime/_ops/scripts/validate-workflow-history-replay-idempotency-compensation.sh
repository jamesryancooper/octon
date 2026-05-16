#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
EVIDENCE_ROOT=""

usage() {
  cat <<'EOF'
Usage: validate-workflow-history-replay-idempotency-compensation.sh [--evidence-root <path>]

Validates Workflow History Replay v1 contracts, idempotency, retry,
compensation, unsupported replay, failure receipts, authority boundaries, and
retained evidence placement.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --evidence-root)
      EVIDENCE_ROOT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

rel() {
  local path="$1"
  printf '%s\n' "${path#$ROOT_DIR/}"
}

require_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    pass "found $(rel "$file")"
  else
    fail "missing $(rel "$file")"
  fi
}

require_text() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if rg -Fq -- "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

echo "== Workflow History Replay Static Contract Validation =="

if command -v python3 >/dev/null 2>&1; then
  pass "python3 available"
else
  fail "python3 is required"
fi

SPEC="$OCTON_DIR/framework/engine/runtime/spec/workflow-history-replay-v1.md"
REPORT_SCHEMA="$OCTON_DIR/framework/constitution/contracts/runtime/workflow-history-replay-v1.schema.json"
IDEMPOTENCY_SCHEMA="$OCTON_DIR/framework/constitution/contracts/runtime/idempotency-record-v1.schema.json"
RETRY_SCHEMA="$OCTON_DIR/framework/constitution/contracts/runtime/retry-record-v1.schema.json"
COMPENSATION_SCHEMA="$OCTON_DIR/framework/constitution/contracts/runtime/compensation-record-v1.schema.json"
FAILURE_SCHEMA="$OCTON_DIR/framework/constitution/contracts/runtime/failure-receipt-v1.schema.json"
FAMILY="$OCTON_DIR/framework/constitution/contracts/runtime/family.yml"
README="$OCTON_DIR/framework/constitution/contracts/runtime/README.md"

for file in "$SPEC" "$REPORT_SCHEMA" "$IDEMPOTENCY_SCHEMA" "$RETRY_SCHEMA" "$COMPENSATION_SCHEMA" "$FAILURE_SCHEMA" "$FAMILY" "$README"; do
  require_file "$file"
done

require_text "Workflow history replay reconstructs from the canonical Run Journal first" "$SPEC" "spec binds reconstruction to canonical journal first"
require_text "Live side-effect replay is blocked unless" "$SPEC" "spec requires fresh authorization for live side-effect replay"
require_text "Silent duplicate acceptance is invalid" "$SPEC" "spec rejects silent duplicate idempotency"
require_text "must never imply" "$SPEC" "spec rejects compensation overclaim"
require_text "global transactionality" "$SPEC" "spec names global transactionality exclusion"
require_text "Durable Object" "$SPEC" "spec excludes Durable Object authority"
require_text "workflow_history_replay:" "$FAMILY" "runtime family registers workflow history replay"
require_text "idempotency_records:" "$FAMILY" "runtime family registers idempotency records"
require_text "failure_receipts:" "$FAMILY" "runtime family registers failure receipts"

if [[ -n "$EVIDENCE_ROOT" ]]; then
  mkdir -p "$ROOT_DIR/$EVIDENCE_ROOT"
fi

python3 - "$ROOT_DIR" "$EVIDENCE_ROOT" <<'PY'
import copy
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT_DIR = Path(sys.argv[1])
EVIDENCE_ROOT_RAW = sys.argv[2]
EVIDENCE_ROOT = ROOT_DIR / EVIDENCE_ROOT_RAW if EVIDENCE_ROOT_RAW else None
OCTON_DIR = ROOT_DIR / ".octon"

SCHEMAS = {
    "workflow_history_replay": OCTON_DIR / "framework/constitution/contracts/runtime/workflow-history-replay-v1.schema.json",
    "idempotency": OCTON_DIR / "framework/constitution/contracts/runtime/idempotency-record-v1.schema.json",
    "retry": OCTON_DIR / "framework/constitution/contracts/runtime/retry-record-v1.schema.json",
    "compensation": OCTON_DIR / "framework/constitution/contracts/runtime/compensation-record-v1.schema.json",
    "failure": OCTON_DIR / "framework/constitution/contracts/runtime/failure-receipt-v1.schema.json",
}

ALLOWED_RETRY_CLASSES = {
    "retryable_transient",
    "retryable_validation",
    "retryable_environment",
    "rollback_then_retry",
    "manual_review_required",
    "non_retryable_contract_violation",
    "contamination_reset_required",
}

FAILURE_REQUIRING_REPLAY_OUTCOMES = {"drifted", "incomplete", "unsupported", "blocked"}
NON_RETRYABLE_CLASSES = {
    "manual_review_required",
    "non_retryable_contract_violation",
    "contamination_reset_required",
}


def repo_ref(path: str) -> str:
    return str(Path(path))


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def event_ref(event_id: str, sequence: int, event_type: str) -> dict:
    return {
        "event_id": event_id,
        "sequence": sequence,
        "event_hash": "sha256:" + f"{sequence:064x}"[-64:],
        "event_type": event_type,
        "ledger_ref": ".octon/state/control/execution/runs/run-fixture/events.ndjson",
        "manifest_ref": ".octon/state/control/execution/runs/run-fixture/events.manifest.yml",
    }


def failure_receipt(receipt_id: str, failure_class: str, outcome: str) -> dict:
    return {
        "receipt_id": receipt_id,
        "failure_class": failure_class,
        "outcome": outcome,
        "retained_evidence_ref": ".octon/state/evidence/runs/run-fixture/failure-receipts/" + receipt_id + ".yml",
        "disclosure_ref": ".octon/state/evidence/disclosure/runs/run-fixture/run-card.yml",
    }


def base_report() -> dict:
    evt1 = event_ref("evt-001-run-bound", 1, "run-bound")
    evt2 = event_ref("evt-002-stage-completed", 2, "stage-completed")
    evidence_root = (
        EVIDENCE_ROOT_RAW
        if EVIDENCE_ROOT_RAW
        else ".octon/state/evidence/validation/proposals/workflow-history-replay-idempotency-compensation/fixture"
    )
    return {
        "schema_version": "workflow-history-replay-v1",
        "report_id": "fixture-valid",
        "run_id": "run-fixture",
        "source_authority": {
            "journal_ref": ".octon/state/control/execution/runs/run-fixture/events.ndjson",
            "manifest_ref": ".octon/state/control/execution/runs/run-fixture/events.manifest.yml",
            "runtime_state_ref": ".octon/state/control/execution/runs/run-fixture/runtime-state.yml",
            "run_manifest_ref": ".octon/state/control/execution/runs/run-fixture/run-manifest.yml",
            "run_contract_ref": ".octon/state/control/execution/runs/run-fixture/run-contract.yml",
            "reconstruction_authority": "canonical-run-journal-first",
            "generated_projection_authority": False,
            "proposal_lineage_authority": False,
            "raw_input_authority": False,
            "durable_object_authority": False,
            "external_workflow_engine_authority": False,
            "mcp_or_tool_availability_authority": False,
        },
        "reconstruction": {
            "replay_outcome": "valid",
            "latest_sequence": 2,
            "latest_hash": evt2["event_hash"],
            "runtime_state_match": True,
            "manifest_match": True,
            "hash_chain_status": "verified",
            "gap_refs": [],
            "drift_findings": [],
            "unsupported_reason_refs": [],
            "live_side_effect_replay_requested": False,
            "live_side_effect_replay_requires_fresh_authorization": True,
            "fresh_authorization_ref": None,
            "failure_receipt_ref": None,
        },
        "event_ref_index": {
            "state_rebuild_event_refs": [evt1, evt2],
            "transition_event_refs": [evt2],
            "replay_event_refs": [evt1, evt2],
            "disclosure_event_refs": [],
            "evidence_snapshot_event_refs": [],
            "drift_event_refs": [],
        },
        "idempotency_records": [
            {
                "record_id": "idem-001",
                "idempotency_key": "run-fixture:stage-1",
                "operation_ref": ".octon/state/control/execution/runs/run-fixture/stage-attempts/initial.yml",
                "first_event_ref": evt1,
                "duplicate_detected": False,
                "duplicate_policy": "unique",
                "duplicate_of_event_ref": None,
                "outcome": "accepted",
                "failure_receipt_ref": None,
            }
        ],
        "retry_records": [
            {
                "retry_id": "retry-001",
                "retry_class": "retryable_transient",
                "attempt_counter": 1,
                "attempt_limit": 3,
                "route_taken": "allow",
                "result": "succeeded",
                "triggering_artifact_ref": ".octon/state/control/execution/runs/run-fixture/stage-attempts/initial.yml",
                "live_side_effect_replay_requested": False,
                "fresh_authorization_ref": None,
                "failure_receipt_ref": None,
            }
        ],
        "compensation_records": [
            {
                "record_id": "comp-001",
                "compensation_scope": "bounded-compensating-action",
                "compensation_plan_ref": None,
                "status": "not-needed",
                "transactionality_claims": {
                    "bounded_compensation_only": True,
                    "global_transactionality_claimed": False,
                    "full_rollback_claimed": False,
                    "external_system_replay_claimed": False,
                },
                "affected_refs": [],
                "failure_receipt_ref": None,
                "recorded_at": "2026-05-15T00:00:00Z",
            }
        ],
        "failure_receipts": [],
        "evidence_placement": {
            "retained_evidence_root": evidence_root,
            "retained_evidence_refs": [evidence_root + "/child-specific-validator.yml"],
            "generated_evidence_written": False,
            "placement_receipt_ref": evidence_root + "/child-specific-validator.yml",
        },
        "generated_at": "2026-05-15T00:00:00Z",
        "generated_by": {
            "actor_class": "validator",
            "actor_ref": ".octon/framework/assurance/runtime/_ops/scripts/validate-workflow-history-replay-idempotency-compensation.sh",
        },
    }


def check_schema_shape() -> list[str]:
    errors = []
    for name, path in SCHEMAS.items():
        schema = load_json(path)
        for key in ("$schema", "$id", "title", "type", "properties"):
            if key not in schema:
                errors.append(f"{name} schema missing {key}")
        if schema.get("$schema") != "https://json-schema.org/draft/2020-12/schema":
            errors.append(f"{name} schema is not Draft 2020-12")
        if schema.get("additionalProperties") is not False:
            errors.append(f"{name} schema must reject additional properties")
    report_required = set(load_json(SCHEMAS["workflow_history_replay"]).get("required", []))
    for required in (
        "source_authority",
        "reconstruction",
        "idempotency_records",
        "retry_records",
        "compensation_records",
        "failure_receipts",
        "evidence_placement",
    ):
        if required not in report_required:
            errors.append(f"workflow history schema missing required field {required}")
    return errors


def bad_ref(value: object) -> str | None:
    if not isinstance(value, str):
        return None
    markers = (
        ".octon/generated/",
        "/.octon/generated/",
        ".octon/inputs/",
        "/.octon/inputs/",
        "durable-object://",
        "external-workflow://",
        "mcp://",
        "tool-availability://",
    )
    lowered = value.lower()
    for marker in markers:
        if marker in lowered:
            return marker
    return None


def walk_values(value):
    if isinstance(value, dict):
        for item in value.values():
            yield from walk_values(item)
    elif isinstance(value, list):
        for item in value:
            yield from walk_values(item)
    else:
        yield value


def validate_report(report: dict) -> list[str]:
    errors = []
    authority = report.get("source_authority", {})
    if authority.get("reconstruction_authority") != "canonical-run-journal-first":
        errors.append("reconstruction authority is not canonical journal first")
    authority_flags = {
        "generated_projection_authority": "generated projections",
        "proposal_lineage_authority": "proposal lineage",
        "raw_input_authority": "raw inputs",
        "durable_object_authority": "Durable Object",
        "external_workflow_engine_authority": "external workflow engine",
        "mcp_or_tool_availability_authority": "MCP or tool availability",
    }
    for field, label in authority_flags.items():
        if authority.get(field) is not False:
            errors.append(f"{label} used as authority")

    for value in walk_values(report):
        marker = bad_ref(value)
        if marker:
            errors.append(f"forbidden authority ref present: {marker}")

    reconstruction = report.get("reconstruction", {})
    outcome = reconstruction.get("replay_outcome")
    failure_ids = {item.get("receipt_id") for item in report.get("failure_receipts", [])}
    if outcome == "drifted" and not reconstruction.get("drift_findings"):
        errors.append("drifted replay missing drift finding")
    if outcome == "incomplete" and not reconstruction.get("gap_refs"):
        errors.append("incomplete replay missing gap refs")
    if outcome == "unsupported" and not reconstruction.get("unsupported_reason_refs"):
        errors.append("unsupported replay missing unsupported reason refs")
    if outcome in FAILURE_REQUIRING_REPLAY_OUTCOMES and not reconstruction.get("failure_receipt_ref"):
        errors.append(f"{outcome} replay missing failure receipt")
    if reconstruction.get("failure_receipt_ref") and reconstruction["failure_receipt_ref"] not in failure_ids:
        errors.append("replay failure receipt ref does not resolve")
    if reconstruction.get("live_side_effect_replay_requested") and not reconstruction.get("fresh_authorization_ref"):
        errors.append("live side-effect replay lacks fresh authorization")

    seen_keys = {}
    for record in report.get("idempotency_records", []):
        key = record.get("idempotency_key")
        if not key:
            errors.append("idempotency record missing key")
            continue
        if key in seen_keys:
            if record.get("duplicate_policy") not in {"duplicate-rejected", "duplicate-classified"}:
                errors.append("duplicate idempotency key not rejected or classified")
            if record.get("outcome") not in {"duplicate-rejected", "duplicate-classified", "blocked"}:
                errors.append("duplicate idempotency key has invalid outcome")
            if not record.get("failure_receipt_ref"):
                errors.append("duplicate idempotency key missing failure receipt")
        seen_keys[key] = record

    for record in report.get("retry_records", []):
        retry_class = record.get("retry_class")
        if retry_class not in ALLOWED_RETRY_CLASSES:
            errors.append(f"invalid retry class: {retry_class}")
        if record.get("attempt_counter", 0) > record.get("attempt_limit", 0):
            errors.append("retry attempt exceeds limit")
        if retry_class in NON_RETRYABLE_CLASSES and record.get("result") == "succeeded":
            errors.append("non-retryable retry silently succeeded")
        if record.get("live_side_effect_replay_requested") and not record.get("fresh_authorization_ref"):
            errors.append("retry live side-effect replay lacks fresh authorization")

    for record in report.get("compensation_records", []):
        claims = record.get("transactionality_claims", {})
        if claims.get("global_transactionality_claimed"):
            errors.append("compensation claims global transactionality")
        if claims.get("full_rollback_claimed"):
            errors.append("compensation claims full rollback")
        if claims.get("external_system_replay_claimed"):
            errors.append("compensation claims external system replay")
        if claims.get("bounded_compensation_only") is not True:
            errors.append("compensation must be bounded compensation only")
        if record.get("compensation_scope") in {"unsupported-rollback", "no-compensation-available"}:
            if record.get("status") not in {"blocked", "unsupported"}:
                errors.append("unsupported compensation has invalid status")
            if not record.get("failure_receipt_ref"):
                errors.append("unsupported compensation missing failure receipt")

    placement = report.get("evidence_placement", {})
    if not str(placement.get("retained_evidence_root", "")).startswith(".octon/state/evidence/"):
        errors.append("evidence placement must be under .octon/state/evidence")
    if placement.get("generated_evidence_written") is not False:
        errors.append("generated evidence written for retained replay proof")
    for ref in placement.get("retained_evidence_refs", []):
        if not str(ref).startswith(".octon/state/evidence/"):
            errors.append("retained evidence ref outside .octon/state/evidence")

    return errors


def make_unsupported_valid() -> dict:
    report = base_report()
    receipt = failure_receipt("fr-unsupported-replay", "unsupported-replay", "unsupported")
    report["failure_receipts"] = [receipt]
    report["reconstruction"]["replay_outcome"] = "unsupported"
    report["reconstruction"]["unsupported_reason_refs"] = [
        ".octon/state/evidence/runs/run-fixture/failure-receipts/fr-unsupported-replay.yml"
    ]
    report["reconstruction"]["failure_receipt_ref"] = receipt["receipt_id"]
    return report


def run_fixtures() -> tuple[list[dict], list[dict], list[str]]:
    positive = []
    negative = []
    errors = []

    for name, report in (
        ("valid-history", base_report()),
        ("unsupported-history-with-receipt", make_unsupported_valid()),
    ):
        report_errors = validate_report(report)
        if report_errors:
            errors.extend([f"{name}: {item}" for item in report_errors])
        else:
            print(f"[OK] positive fixture passed: {name}")
        positive.append({"name": name, "errors": report_errors})

    negative_cases = []
    duplicate = base_report()
    duplicate["idempotency_records"].append(copy.deepcopy(duplicate["idempotency_records"][0]))
    duplicate["idempotency_records"][1]["record_id"] = "idem-duplicate"
    negative_cases.append(("duplicate-idempotency-accepted", duplicate, "duplicate idempotency key"))

    retry_exhausted = base_report()
    retry_exhausted["retry_records"][0]["attempt_counter"] = 4
    retry_exhausted["retry_records"][0]["attempt_limit"] = 3
    negative_cases.append(("retry-attempt-exceeds-limit", retry_exhausted, "retry attempt exceeds limit"))

    compensation_overclaim = base_report()
    compensation_overclaim["compensation_records"][0]["transactionality_claims"]["global_transactionality_claimed"] = True
    negative_cases.append(("compensation-global-transactionality", compensation_overclaim, "global transactionality"))

    generated_authority = base_report()
    generated_authority["source_authority"]["generated_projection_authority"] = True
    negative_cases.append(("generated-authority", generated_authority, "generated projections"))

    unsupported_missing_receipt = base_report()
    unsupported_missing_receipt["reconstruction"]["replay_outcome"] = "unsupported"
    unsupported_missing_receipt["reconstruction"]["unsupported_reason_refs"] = [
        ".octon/state/evidence/runs/run-fixture/failure-receipts/fr-unsupported.yml"
    ]
    negative_cases.append(("unsupported-replay-missing-receipt", unsupported_missing_receipt, "unsupported replay missing failure receipt"))

    live_replay_without_grant = base_report()
    live_replay_without_grant["reconstruction"]["live_side_effect_replay_requested"] = True
    negative_cases.append(("live-side-effect-replay-without-grant", live_replay_without_grant, "fresh authorization"))

    bad_placement = base_report()
    bad_placement["evidence_placement"]["retained_evidence_root"] = ".octon/generated/replay"
    negative_cases.append(("generated-evidence-placement", bad_placement, "evidence placement"))

    for name, report, expected in negative_cases:
        report_errors = validate_report(report)
        if not report_errors:
            errors.append(f"{name}: negative fixture unexpectedly passed")
        elif not any(expected in item for item in report_errors):
            errors.append(f"{name}: expected '{expected}', got {report_errors}")
        else:
            print(f"[OK] negative fixture failed closed: {name}")
        negative.append({"name": name, "expected": expected, "errors": report_errors})

    return positive, negative, errors


def write_evidence(positive: list[dict], negative: list[dict], errors: list[str]) -> None:
    if not EVIDENCE_ROOT:
        return
    EVIDENCE_ROOT.mkdir(parents=True, exist_ok=True)
    verdict = "pass" if not errors else "fail"
    receipt = EVIDENCE_ROOT / "child-specific-validator.yml"
    now = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    receipt.write_text(
        "\n".join(
            [
                "schema_version: workflow-history-replay-idempotency-compensation-validator-v1",
                "validator: .octon/framework/assurance/runtime/_ops/scripts/validate-workflow-history-replay-idempotency-compensation.sh",
                f"validated_at: {now}",
                f"verdict: {verdict}",
                f"evidence_root: {EVIDENCE_ROOT_RAW}",
                "coverage:",
                "  valid_history: true",
                "  drift_and_incomplete_rules: true",
                "  unsupported_history: true",
                "  duplicate_idempotency_keys: true",
                "  retry_limits: true",
                "  compensation_boundaries: true",
                "  failure_receipts: true",
                "  evidence_placement: true",
                "positive_fixtures:",
                *[f"  - {item['name']}" for item in positive],
                "negative_fixtures:",
                *[f"  - {item['name']}" for item in negative],
                "unresolved_errors:",
                *([f"  - {item}" for item in errors] if errors else ["  - none"]),
                "",
            ]
        ),
        encoding="utf-8",
    )
    (EVIDENCE_ROOT / "fixture-results.json").write_text(
        json.dumps(
            {"verdict": verdict, "positive": positive, "negative": negative, "errors": errors},
            indent=2,
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )


schema_errors = check_schema_shape()
for item in schema_errors:
    print(f"[ERROR] {item}")
if not schema_errors:
    print("[OK] schema shapes validated")

positive, negative, fixture_errors = run_fixtures()
write_evidence(positive, negative, schema_errors + fixture_errors)

if schema_errors or fixture_errors:
    raise SystemExit(1)
PY
status=$?
if [[ $status -ne 0 ]]; then
  errors=$((errors + 1))
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
