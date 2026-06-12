#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
SCHEMA="$ROOT_DIR/.octon/framework/product/contracts/lifecycle-terminal-current-state-proof-v1.schema.json"

PROOF=""
SCHEMA_ONLY=0
REQUIRE_CLEANED=0
errors=0

usage() {
  cat <<'EOF'
usage:
  validate-lifecycle-terminal-current-state-proof.sh --schema-only
  validate-lifecycle-terminal-current-state-proof.sh --proof <path> [--require-cleaned]
EOF
}

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --schema-only)
      SCHEMA_ONLY=1
      ;;
    --proof)
      shift
      PROOF="${1:-}"
      ;;
    --require-cleaned)
      REQUIRE_CLEANED=1
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

if [[ "$SCHEMA_ONLY" -eq 0 && -z "$PROOF" ]]; then
  usage >&2
  exit 2
fi

if [[ -n "$PROOF" && "$PROOF" != /* ]]; then
  PROOF="$ROOT_DIR/$PROOF"
fi

if [[ -f "$SCHEMA" ]]; then
  pass "terminal current-state proof schema exists"
else
  fail "terminal current-state proof schema exists"
fi

if jq -e '.' "$SCHEMA" >/dev/null 2>&1; then
  pass "terminal current-state proof schema parses as JSON"
else
  fail "terminal current-state proof schema parses as JSON"
fi

if [[ "$SCHEMA_ONLY" -eq 1 ]]; then
  printf 'Validation summary: errors=%s\n' "$errors"
  [[ "$errors" -eq 0 ]]
  exit
fi

if [[ -f "$PROOF" ]]; then
  pass "terminal current-state proof exists"
else
  fail "terminal current-state proof exists"
  printf 'Validation summary: errors=%s\n' "$errors"
  exit 1
fi

proof_json="$(mktemp "${TMPDIR:-/tmp}/octon-terminal-proof.XXXXXX.json")"
trap 'rm -f "$proof_json"' EXIT

if yq -o=json '.' "$PROOF" >"$proof_json" 2>/dev/null; then
  pass "terminal current-state proof parses as YAML/JSON"
else
  fail "terminal current-state proof parses as YAML/JSON"
  printf 'Validation summary: errors=%s\n' "$errors"
  exit 1
fi

set +e
python3 - "$proof_json" "$REQUIRE_CLEANED" <<'PY'
import json
import re
import sys

path = sys.argv[1]
require_cleaned = sys.argv[2] == "1"
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

require(data.get("schema_version") == "lifecycle-terminal-current-state-proof-v1", "schema_version must be lifecycle-terminal-current-state-proof-v1")
for field in ["proof_id", "observed_at", "change_id", "cleanup_classifier_ref"]:
    require(is_nonempty(data.get(field)), f"{field} must be present")
require(data.get("non_authority_classification") == "retained-evidence-only", "non_authority_classification must be retained-evidence-only")
require(data.get("lifecycle_outcome") in {"landed", "cleaned", "blocked", "deferred", "escalated"}, "lifecycle_outcome must be supported")
if require_cleaned:
    require(data.get("lifecycle_outcome") == "cleaned", "lifecycle_outcome must be cleaned")

final_refs = data.get("final_refs") or {}
for field in ["head_ref", "main_ref", "origin_main_ref", "landed_ref"]:
    require(is_nonempty(final_refs.get(field)), f"final_refs.{field} must be present")

alignment = data.get("alignment") or {}
for field in ["head_equals_local_main", "local_main_equals_origin_main", "origin_main_contains_landed_ref", "local_main_contains_landed_ref"]:
    require(alignment.get(field) is True, f"alignment.{field} must be true")

worktree = data.get("worktree") or {}
require(worktree.get("status") in {"clean", "retained_classified", "dirty"}, "worktree.status must be clean, retained_classified, or dirty")
require(is_nonempty(worktree.get("status_ref")), "worktree.status_ref must be present")
require(isinstance(worktree.get("residue_counts"), dict), "worktree.residue_counts must be an object")
if data.get("lifecycle_outcome") == "cleaned":
    require(worktree.get("status") in {"clean", "retained_classified"}, "cleaned proof cannot have dirty worktree.status")

require(is_nonempty_list(data.get("validator_refs")), "validator_refs must be non-empty")
require(is_nonempty_list(data.get("evidence_refs")), "evidence_refs must be non-empty")
for index, validator in enumerate(data.get("validator_refs") or []):
    if not isinstance(validator, dict):
        fail(f"validator_refs[{index}] must be an object")
        continue
    for field in ["validator", "command", "cwd", "runtime", "evidence_ref"]:
        require(is_nonempty(validator.get(field)), f"validator_refs[{index}].{field} must be present")
    require(isinstance(validator.get("exit_code"), int), f"validator_refs[{index}].exit_code must be an integer")
    if data.get("lifecycle_outcome") == "cleaned":
        require(validator.get("exit_code") == 0, f"validator_refs[{index}].exit_code must be 0 for cleaned proof")

placeholder_pattern = re.compile(r"(^|[^A-Za-z0-9_])(TODO|TBD|FIXME)([^A-Za-z0-9_]|$)|not verified|not run|pending placeholder|stale", re.IGNORECASE)
authority_leak_pattern = re.compile(r"(chat|host state|model memory|dashboard|tool availability|generated output|raw input)\s+authority", re.IGNORECASE)
for pointer, value in walk(data):
    if isinstance(value, str) and placeholder_pattern.search(value):
        fail(f"placeholder or stale text found at {pointer}")
    if isinstance(value, str) and authority_leak_pattern.search(value):
        fail(f"non-authority boundary violation found at {pointer}")

if errors:
    for message in errors:
        print(f"[ERROR] {message}")
    print(f"Python validation summary: errors={len(errors)}")
    sys.exit(1)

print("[OK] terminal current-state proof required fields are valid")
print("Python validation summary: errors=0")
PY
python_status=$?
set -e
if [[ "$python_status" -ne 0 ]]; then
  errors=$((errors + 1))
fi

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]
