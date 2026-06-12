#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-correction-branch-aggregate-receipt.sh"

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
  file="$(mktemp "${TMPDIR:-/tmp}/octon-correction-aggregate-test.XXXXXX")"
  cleanup_paths+=("$file")
  printf '%s\n' "$file"
}

write_valid_receipt() {
  local file="$1"
  cat >"$file" <<'YAML'
schema_version: lifecycle-correction-branch-aggregate-receipt-v1
receipt_id: correction-aggregate-fixture
primary_change_id: primary-change-fixture
primary_landing_ref: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
final_landed_ref: bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
rollback_handle: revert bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb if terminal checks fail
local_main_sync_proof_ref: evidence://validation/local-main-sync.log
unresolved_count: 0
non_authority_classification: retained-evidence-only
evidence_refs:
  - evidence://runs/skills/closeout-change/fixture/structured-receipt.yml
validator_refs:
  - validator: validate-change-closeout-lifecycle-alignment
    command: bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt fixture.json
    runtime: bash
    exit_code: 0
    evidence_ref: evidence://validation/change-closeout.log
correction_branches:
  - branch_name: chore/fix-terminal-freshness
    source_ref: refs/heads/chore/fix-terminal-freshness@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    commit_ref: bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
    landing_authorization_ref: evidence://runs/skills/closeout-change/fixture/branch-landing-authorization.json
    branch_cleanup_authorization_ref: evidence://runs/skills/closeout-change/fixture/branch-cleanup-authorization.json
    validation_refs:
      - evidence://validation/terminal-freshness.log
    generated_refresh_refs:
      - .octon/generated/proposals/registry.yml
    publication_refresh_refs:
      - .octon/generated/effective/capabilities/routing.effective.yml
    cleanup_outcome: completed
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
write_valid_receipt "$valid"
assert_success "valid aggregate receipt passes" "$VALIDATOR" --receipt "$valid" --require-pass

missing_branch="$(new_file)"
write_valid_receipt "$missing_branch"
yq -i 'del(.correction_branches)' "$missing_branch"
assert_failure "missing correction branch fails" "$VALIDATOR" --receipt "$missing_branch" --require-pass

placeholder="$(new_file)"
write_valid_receipt "$placeholder"
yq -i '.evidence_refs += ["TODO add evidence"]' "$placeholder"
assert_failure "placeholder text fails" "$VALIDATOR" --receipt "$placeholder" --require-pass

pr_metadata="$(new_file)"
write_valid_receipt "$pr_metadata"
yq -i '.correction_branches[0].pr_url = "https://example.invalid/pull/1"' "$pr_metadata"
assert_failure "PR metadata fails" "$VALIDATOR" --receipt "$pr_metadata" --require-pass

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ "$fail_count" -eq 0 ]]
