#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
SCHEMA="$ROOT_DIR/.octon/framework/product/contracts/lifecycle-correction-branch-aggregate-receipt-v1.schema.json"

RECEIPT=""
SCHEMA_ONLY=0
REQUIRE_PASS=0
errors=0

usage() {
  cat <<'EOF'
usage:
  validate-lifecycle-correction-branch-aggregate-receipt.sh --schema-only
  validate-lifecycle-correction-branch-aggregate-receipt.sh --receipt <path> [--require-pass]
EOF
}

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --schema-only)
      SCHEMA_ONLY=1
      ;;
    --receipt)
      shift
      RECEIPT="${1:-}"
      ;;
    --require-pass)
      REQUIRE_PASS=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ "$SCHEMA_ONLY" -eq 0 && -z "$RECEIPT" ]]; then
  usage >&2
  exit 2
fi

if [[ -n "$RECEIPT" && "$RECEIPT" != /* ]]; then
  RECEIPT="$ROOT_DIR/$RECEIPT"
fi

if [[ -f "$SCHEMA" ]]; then
  pass "correction aggregate receipt schema exists"
else
  fail "correction aggregate receipt schema exists"
fi

if jq -e '.' "$SCHEMA" >/dev/null 2>&1; then
  pass "correction aggregate receipt schema parses as JSON"
else
  fail "correction aggregate receipt schema parses as JSON"
fi

if [[ "$SCHEMA_ONLY" -eq 1 ]]; then
  printf 'Validation summary: errors=%s\n' "$errors"
  [[ "$errors" -eq 0 ]]
  exit
fi

if [[ -f "$RECEIPT" ]]; then
  pass "correction aggregate receipt exists"
else
  fail "correction aggregate receipt exists"
  printf 'Validation summary: errors=%s\n' "$errors"
  exit 1
fi

receipt_json="$(mktemp "${TMPDIR:-/tmp}/octon-correction-aggregate.XXXXXX.json")"
trap 'rm -f "$receipt_json"' EXIT

if yq -o=json '.' "$RECEIPT" >"$receipt_json" 2>/dev/null; then
  pass "correction aggregate receipt parses as YAML/JSON"
else
  fail "correction aggregate receipt parses as YAML/JSON"
  printf 'Validation summary: errors=%s\n' "$errors"
  exit 1
fi

set +e
python3 - "$receipt_json" "$REQUIRE_PASS" <<'PY'
import json
import re
import sys

path = sys.argv[1]
require_pass = sys.argv[2] == "1"
errors = []

def fail(message):
    errors.append(message)

def require(condition, message):
    if not condition:
        fail(message)

def is_nonempty(value):
    return isinstance(value, str) and bool(value.strip())

def is_nonempty_list(value):
    return isinstance(value, list) and len(value) > 0

def walk(value, path="$"):
    if isinstance(value, dict):
        for key, child in value.items():
            yield f"{path}.{key}", key
            yield from walk(child, f"{path}.{key}")
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from walk(child, f"{path}[{index}]")
    elif isinstance(value, str):
        yield path, value

with open(path, "r", encoding="utf-8") as handle:
    data = json.load(handle)

require(data.get("schema_version") == "lifecycle-correction-branch-aggregate-receipt-v1", "schema_version must be lifecycle-correction-branch-aggregate-receipt-v1")
for field in ["receipt_id", "primary_change_id", "primary_landing_ref", "final_landed_ref", "rollback_handle", "local_main_sync_proof_ref"]:
    require(is_nonempty(data.get(field)), f"{field} must be present")
require(data.get("non_authority_classification") == "retained-evidence-only", "non_authority_classification must be retained-evidence-only")
require(isinstance(data.get("unresolved_count"), int) and data.get("unresolved_count") >= 0, "unresolved_count must be a non-negative integer")
require(is_nonempty_list(data.get("evidence_refs")), "evidence_refs must be non-empty")
require(is_nonempty_list(data.get("validator_refs")), "validator_refs must be non-empty")

branches = data.get("correction_branches")
require(is_nonempty_list(branches), "correction_branches must be non-empty")
if isinstance(branches, list):
    for index, branch in enumerate(branches):
        if not isinstance(branch, dict):
            fail(f"correction_branches[{index}] must be an object")
            continue
        for field in ["branch_name", "source_ref", "commit_ref", "landing_authorization_ref", "branch_cleanup_authorization_ref"]:
            require(is_nonempty(branch.get(field)), f"correction_branches[{index}].{field} must be present")
        require(is_nonempty_list(branch.get("validation_refs")), f"correction_branches[{index}].validation_refs must be non-empty")
        require(branch.get("cleanup_outcome") in {"completed", "deferred", "not_applicable"}, f"correction_branches[{index}].cleanup_outcome must be completed, deferred, or not_applicable")

for index, validator in enumerate(data.get("validator_refs") or []):
    if not isinstance(validator, dict):
        fail(f"validator_refs[{index}] must be an object")
        continue
    for field in ["validator", "command", "evidence_ref"]:
        require(is_nonempty(validator.get(field)), f"validator_refs[{index}].{field} must be present")
    require(isinstance(validator.get("exit_code"), int), f"validator_refs[{index}].exit_code must be an integer")
    if require_pass:
        require(validator.get("exit_code") == 0, f"validator_refs[{index}].exit_code must be 0 for a passing receipt")

placeholder_pattern = re.compile(r"(^|[^A-Za-z0-9_])(TODO|TBD|FIXME)([^A-Za-z0-9_]|$)|not verified|not run|pending placeholder|stale", re.IGNORECASE)
pr_metadata_key_pattern = re.compile(r"^(pr_url|pr_number|pull_request|github_pr|github_pull_request)$", re.IGNORECASE)
for pointer, value in walk(data):
    if isinstance(value, str) and placeholder_pattern.search(value):
        fail(f"placeholder or stale text found at {pointer}")
    if pointer.count(".") > 0 and pr_metadata_key_pattern.search(str(value)):
        fail(f"PR metadata key is forbidden in correction aggregate receipts: {pointer}.{value}")

if require_pass:
    require(data.get("unresolved_count") == 0, "unresolved_count must be 0 for a passing receipt")

if errors:
    for message in errors:
        print(f"[ERROR] {message}")
    print(f"Python validation summary: errors={len(errors)}")
    sys.exit(1)

print("[OK] correction aggregate receipt required fields are valid")
print("Python validation summary: errors=0")
PY
python_status=$?
set -e
if [[ "$python_status" -ne 0 ]]; then
  errors=$((errors + 1))
fi

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]
