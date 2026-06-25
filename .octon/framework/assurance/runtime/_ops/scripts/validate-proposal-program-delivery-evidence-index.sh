#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
SCHEMA_PATH="$DEFAULT_ROOT/.octon/framework/product/contracts/proposal-program-delivery-evidence-index-v1.schema.json"
RECEIPT_VALIDATOR="$SCRIPT_DIR/validate-proposal-program-delivery-receipt.sh"
INDEX_PATH=""

usage() {
  cat <<'EOF'
Usage:
  validate-proposal-program-delivery-evidence-index.sh [--index <index.yml|json>] [--root <repo-root>]

Validates proposal-program-delivery-evidence-index-v1 as a compact,
digest-bound, non-authorizing retained evidence index. The index remains
diagnostic/evidence-only and cannot replace delivery receipts, child receipts,
archive evidence, landing authorization, cleanup authorization, or lifecycle
outcomes.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="${2:-}"
      shift 2
      ;;
    --index)
      INDEX_PATH="${2:-}"
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

python3 - "$ROOT_DIR" "$INDEX_PATH" "$SCHEMA_PATH" "$RECEIPT_VALIDATOR" <<'PY'
import hashlib
import json
import pathlib
import re
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
raw_index = sys.argv[2]
schema_path = pathlib.Path(sys.argv[3]).resolve()
receipt_validator = pathlib.Path(sys.argv[4]).resolve()
errors = []

SHA_RE = re.compile(r"^sha256:[0-9a-f]{64}$")
OUTCOMES = {"blocked", "implemented", "archive-ready", "landed", "synced", "cleaned"}
EXPECTED_NON_AUTHORITY = {
    "proposal_local_files": "non-authority",
    "generated_prompts": "non-authority",
    "generated_outputs": "derived-only-non-authority",
    "dashboards": "non-authority",
    "chat_or_model_memory": "non-authority",
}
EXPECTED_POLICY_FALSE = {
    "authorizes_execution",
    "authorizes_archive",
    "authorizes_delivery",
    "authorizes_landing",
    "authorizes_cleanup",
    "satisfies_child_receipts",
    "generated_outputs_are_authority",
}
EXPECTED_OUTCOME_AUTHORITY_FALSE = {
    "index_replaces_delivery_receipt",
    "archive_evidence_claims_delivery",
    "child_delivery_required_for_sibling_progression",
    "child_delivery_claimed_by_archive_only",
}
REQUIRED_CHILD_FAMILIES = {
    ".child_receipts.implementation_run",
    ".child_receipts.implementation_conformance",
    ".child_receipts.post_implementation_drift_churn",
    ".child_receipts.packet_closeout",
    ".child_receipts.archive",
    ".child_receipts.change_closeout",
}
ALLOWED_AUTHORITY_USE = {
    "source-delivery-receipt",
    "target-owned-child-receipt-ref",
    "retained-evidence-ref",
    "workflow-evidence-ref",
    "validator-evidence-ref",
    "publisher-source-ref",
    "local-private-ref",
    "framework-source-ref",
    "derived-only-ref",
    "proposal-local-ref",
}
ALLOWED_DISCLOSURE_TIERS = {
    "retained-evidence",
    "local-private-index-only",
    "proposal-local",
    "derived-generated",
    "framework-source",
    "repo-local",
}


def fail(message):
    errors.append(message)
    print(f"[ERROR] {message}")


def ok(message):
    print(f"[OK] {message}")


def resolve_ref(ref):
    path = pathlib.Path(str(ref))
    return path if path.is_absolute() else root / path


def rel(path):
    path = pathlib.Path(path).resolve()
    try:
        return str(path.relative_to(root))
    except ValueError:
        return str(path)


def sha256(path):
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()


def load_data(path, label):
    result = subprocess.run(
        ["yq", "-o=json", ".", str(path)],
        cwd=root,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        fail(f"{label} YAML parse failed: {path}: {result.stderr.strip()}")
        return {}
    try:
        return json.loads(result.stdout or "{}")
    except json.JSONDecodeError as exc:
        fail(f"{label} JSON decode failed: {path}: {exc}")
        return {}


def require_equal(actual, expected, label):
    if actual == expected:
        ok(label)
    else:
        fail(f"{label} must be {expected!r}; found {actual!r}")


def require_bool(actual, expected, label):
    if actual is expected:
        ok(label)
    else:
        fail(f"{label} must be {expected!r}; found {actual!r}")


print("== Proposal Program Delivery Evidence Index Validation ==")

if schema_path.is_file():
    ok("evidence index schema exists")
    try:
        json.loads(schema_path.read_text())
        ok("evidence index schema JSON parses")
    except json.JSONDecodeError as exc:
        fail(f"evidence index schema JSON parse failed: {exc}")
else:
    fail(f"evidence index schema missing: {schema_path}")

if not raw_index:
    print(f"Validation summary: errors={len(errors)}")
    sys.exit(1 if errors else 0)

index_path = pathlib.Path(raw_index)
index_path = index_path if index_path.is_absolute() else root / index_path
if index_path.is_file():
    ok("evidence index exists")
else:
    fail(f"evidence index missing: {index_path}")

index = load_data(index_path, "evidence index") if index_path.is_file() else {}

require_equal(index.get("schema_version"), "proposal-program-delivery-evidence-index-v1", "schema_version")
require_equal(index.get("producer"), "generate-proposal-program-delivery-evidence-index.sh", "producer")
if index.get("index_id"):
    ok("index_id present")
else:
    fail("index_id missing")
if index.get("generated_at"):
    ok("generated_at present")
else:
    fail("generated_at missing")

source_receipt = index.get("source_receipt") or {}
source_ref = source_receipt.get("ref")
source_path = resolve_ref(source_ref) if source_ref else None
if source_ref:
    ok("source receipt ref present")
else:
    fail("source receipt ref missing")
if source_receipt.get("schema_version") == "proposal-program-delivery-receipt-v1":
    ok("source receipt schema_version declared")
else:
    fail("source receipt schema_version must be proposal-program-delivery-receipt-v1")
if not SHA_RE.match(str(source_receipt.get("sha256") or "")):
    fail("source receipt digest shape invalid")
elif source_path and source_path.is_file() and source_receipt.get("sha256") == sha256(source_path):
    ok("source receipt digest matches")
elif source_path and source_path.is_file():
    fail("source receipt digest mismatch")
else:
    fail(f"source receipt missing: {source_ref}")

receipt = {}
if source_path and source_path.is_file():
    result = subprocess.run(
        ["bash", str(receipt_validator), "--receipt", str(source_path)],
        cwd=root,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode == 0:
        ok("source delivery receipt validates")
    else:
        print(result.stdout, end="")
        print(result.stderr, end="", file=sys.stderr)
        fail("source delivery receipt validation failed")
    receipt = load_data(source_path, "source receipt")

if index.get("target_outcome") in OUTCOMES:
    ok("target_outcome is schema-valid")
else:
    fail("target_outcome is not schema-valid")
if index.get("actual_outcome") in OUTCOMES:
    ok("actual_outcome is schema-valid")
else:
    fail("actual_outcome is not schema-valid")

if receipt:
    require_equal(index.get("target_outcome"), receipt.get("target_outcome"), "target_outcome matches source receipt")
    require_equal(index.get("actual_outcome"), receipt.get("actual_outcome"), "actual_outcome matches source receipt")
    require_equal(
        (index.get("target_program") or {}).get("path"),
        ((receipt.get("target_program") or {}).get("path")),
        "target_program path matches source receipt",
    )

route = index.get("route") or {}
if route.get("change_closeout_route"):
    ok("route change_closeout_route present")
else:
    fail("route change_closeout_route missing")
if isinstance(route.get("landing_performed"), bool):
    ok("route landing_performed explicit")
else:
    fail("route landing_performed must be boolean")
if isinstance(route.get("branch_cleanup_performed"), bool):
    ok("route branch_cleanup_performed explicit")
else:
    fail("route branch_cleanup_performed must be boolean")
if isinstance(route.get("branch_deleted"), bool):
    ok("route branch_deleted explicit")
else:
    fail("route branch_deleted must be boolean")
if isinstance(route.get("final_sync_claimed"), bool):
    ok("route final_sync_claimed explicit")
else:
    fail("route final_sync_claimed must be boolean")

outcome_authority = index.get("outcome_authority") or {}
for key in EXPECTED_OUTCOME_AUTHORITY_FALSE:
    require_bool(outcome_authority.get(key), False, f"outcome authority {key}")

policy = index.get("evidence_policy") or {}
require_equal(policy.get("purpose"), "compact-retained-delivery-evidence-index", "evidence policy purpose")
require_equal(policy.get("disclosure"), "refs-digests-and-classification-only", "evidence policy disclosure")
require_bool(policy.get("raw_evidence_retained"), True, "raw evidence retained")
for key in EXPECTED_POLICY_FALSE:
    require_bool(policy.get(key), False, f"evidence policy {key}")

non_authority = index.get("non_authority_classification") or {}
for key, expected in EXPECTED_NON_AUTHORITY.items():
    require_equal(non_authority.get(key), expected, f"non-authority classification {key}")

target_policy = index.get("target_owned_evidence_policy") or {}
require_bool(target_policy.get("target_owned_receipts_required"), True, "target-owned receipts required")
require_bool(
    target_policy.get("aggregate_receipt_replaces_target_owned_receipts"),
    False,
    "aggregate receipt replaces target-owned receipts",
)

validator_results = index.get("validator_results") or []
if validator_results:
    ok("validator results present")
else:
    fail("validator_results must be non-empty")
if any(
    item.get("validator") == "validate-proposal-program-delivery-receipt.sh" and item.get("verdict") == "pass"
    for item in validator_results
    if isinstance(item, dict)
):
    ok("receipt validator pass result recorded")
else:
    fail("validator_results must include validate-proposal-program-delivery-receipt.sh pass")

records = index.get("indexed_evidence_refs") or []
if records:
    ok("indexed evidence refs present")
else:
    fail("indexed_evidence_refs must be non-empty")

source_fields = set()
source_ref_indexed = False
for record in records:
    if not isinstance(record, dict):
        fail("indexed evidence ref entry must be an object")
        continue
    ref = record.get("ref")
    role = record.get("role") or "<missing-role>"
    source_field = record.get("source_field")
    source_fields.add(str(source_field))
    digest = record.get("sha256")
    disclosure_tier = record.get("disclosure_tier")
    authority_use = record.get("authority_use")

    if ref == source_ref:
        source_ref_indexed = True
    if not ref:
        fail(f"indexed evidence ref missing ref for role {role}")
        continue
    if not source_field:
        fail(f"indexed evidence ref missing source_field: {ref}")
    if disclosure_tier in ALLOWED_DISCLOSURE_TIERS:
        ok(f"disclosure tier valid: {ref}")
    else:
        fail(f"disclosure tier invalid for {ref}: {disclosure_tier!r}")
    if authority_use in ALLOWED_AUTHORITY_USE:
        ok(f"authority use valid: {ref}")
    else:
        fail(f"authority use invalid for {ref}: {authority_use!r}")
    if not SHA_RE.match(str(digest or "")):
        fail(f"indexed ref digest shape invalid: {ref}")
        continue

    path = resolve_ref(ref)
    if not path.is_file():
        fail(f"indexed ref missing: {ref}")
        continue
    actual = sha256(path)
    if digest == actual:
        ok(f"indexed ref digest matches: {ref}")
    else:
        fail(f"indexed ref digest mismatch: {ref}")

    ref_text = str(ref)
    if ref_text.startswith(".octon/generated/") and authority_use != "derived-only-ref":
        fail(f"generated ref must be derived-only: {ref}")
    if ref_text.startswith(".octon/state/evidence/local/") and authority_use != "local-private-ref":
        fail(f"local-private evidence ref must be index-only: {ref}")
    if ref_text.startswith(".octon/inputs/") and source_field.startswith(".child_receipts."):
        if authority_use == "target-owned-child-receipt-ref":
            ok(f"child receipt remains target-owned: {ref}")
        else:
            fail(f"child receipt must remain target-owned: {ref}")
    if source_field == ".child_receipts.archive" and (authority_use != "target-owned-child-receipt-ref" or "delivery" in role):
        fail(f"archive evidence cannot claim child delivery authority: {ref}")

if source_ref_indexed:
    ok("source receipt is included in indexed refs")
else:
    fail("source receipt must be included in indexed_evidence_refs")

missing_families = sorted(REQUIRED_CHILD_FAMILIES - source_fields)
if missing_families:
    fail("missing required child receipt families in index: " + ", ".join(missing_families))
else:
    ok("all required child receipt families are indexed")

failure_behavior = set(index.get("failure_behavior") or [])
for required in {
    "fail-closed-on-source-receipt-validation-failure",
    "fail-closed-on-indexed-ref-missing",
    "fail-closed-on-indexed-ref-digest-mismatch",
    "fail-closed-on-authority-boundary-conflict",
}:
    if required in failure_behavior:
        ok(f"failure behavior includes {required}")
    else:
        fail(f"failure behavior missing {required}")

print(f"Validation summary: errors={len(errors)}")
if errors:
    sys.exit(1)
PY
