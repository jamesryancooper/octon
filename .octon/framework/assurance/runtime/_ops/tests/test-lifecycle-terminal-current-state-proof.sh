#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-terminal-current-state-proof.sh"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    [[ -f "$path" ]] && rm -f -- "$path"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

new_file() {
  local file
  file="$(mktemp "${TMPDIR:-/tmp}/octon-terminal-proof-test.XXXXXX")"
  cleanup_paths+=("$file")
  printf '%s\n' "$file"
}

write_valid_proof() {
  local file="$1"
  cat >"$file" <<'YAML'
schema_version: lifecycle-terminal-current-state-proof-v1
proof_id: terminal-proof-fixture
observed_at: "2026-06-12T00:00:00Z"
change_id: change-fixture
lifecycle_outcome: cleaned
non_authority_classification: retained-evidence-only
final_refs:
  head_ref: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  main_ref: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  origin_main_ref: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  landed_ref: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
alignment:
  head_equals_local_main: true
  local_main_equals_origin_main: true
  origin_main_contains_landed_ref: true
  local_main_contains_landed_ref: true
worktree:
  status: clean
  status_ref: evidence://validation/git-status.log
  residue_counts:
    staged: 0
    unstaged: 0
    untracked: 0
cleanup_classifier_ref: evidence://validation/residue-classifier.log
validator_refs:
  - validator: validate-proposal-lifecycle-terminal-freshness
    command: bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal fixture --run-registry-check
    cwd: /repo
    runtime: bash
    exit_code: 0
    evidence_ref: evidence://validation/terminal-freshness.log
evidence_refs:
  - evidence://runs/skills/closeout-change/fixture/structured-receipt.yml
YAML
}

assert_success() {
  local label="$1"
  shift
  if "$@"; then pass "$label"; else fail "$label"; fi
}

assert_failure() {
  local label="$1"
  shift
  if "$@"; then fail "$label"; else pass "$label"; fi
}

assert_success "schema-only validation passes" "$VALIDATOR" --schema-only

valid="$(new_file)"
write_valid_proof "$valid"
assert_success "valid terminal proof passes" "$VALIDATOR" --proof "$valid" --require-cleaned

dirty="$(new_file)"
write_valid_proof "$dirty"
yq -i '.worktree.status = "dirty"' "$dirty"
assert_failure "dirty worktree cleaned claim fails" "$VALIDATOR" --proof "$dirty" --require-cleaned

placeholder="$(new_file)"
write_valid_proof "$placeholder"
yq -i '.evidence_refs += ["TBD evidence"]' "$placeholder"
assert_failure "placeholder text fails" "$VALIDATOR" --proof "$placeholder" --require-cleaned

authority_leak="$(new_file)"
write_valid_proof "$authority_leak"
yq -i '.evidence_refs += ["chat authority approved this closeout"]' "$authority_leak"
assert_failure "non-authority leakage fails" "$VALIDATOR" --proof "$authority_leak" --require-cleaned

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ "$fail_count" -eq 0 ]]
