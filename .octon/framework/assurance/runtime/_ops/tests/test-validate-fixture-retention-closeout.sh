#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
RECEIPT_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-fixture-retention-closeout-receipt.sh"
WORKFLOW_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-fixture-retention-closeout-workflow.sh"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fixture-retention-test.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

pass_count=0
fail_count=0

pass() { echo "[OK] $1"; pass_count=$((pass_count + 1)); }
fail() { echo "[ERROR] $1"; fail_count=$((fail_count + 1)); }

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] $1 is required" >&2
    exit 1
  fi
}

expect_pass() {
  local description="$1"
  shift
  if "$@" >"$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.log" 2>&1; then
    pass "$description"
  else
    cat "$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.log"
    fail "$description"
  fi
}

expect_fail() {
  local description="$1"
  shift
  if "$@" >"$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.log" 2>&1; then
    cat "$TMP_DIR/${description//[^A-Za-z0-9_.-]/_}.log"
    fail "$description unexpectedly passed"
  else
    pass "$description rejected"
  fi
}

digest_file_lines() {
  local file="$1"
  if [[ -s "$file" ]]; then
    LC_ALL=C sort "$file" | shasum -a 256 | awk '{print "sha256:" $1}'
  else
    printf '' | shasum -a 256 | awk '{print "sha256:" $1}'
  fi
}

yaml_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

yaml_array() {
  local file="$1" indent="$2"
  if [[ ! -s "$file" ]]; then
    printf '%s[]\n' "$indent"
    return
  fi
  while IFS= read -r value; do
    printf '%s- ' "$indent"
    yaml_quote "$value"
    printf '\n'
  done <"$file"
}

state_entry() {
  local state_id="$1"
  cat <<YAML
  - state_id: $state_id
    input_refs:
      - .octon/inputs/exploratory/proposals/policy/example-retention-fixture/proposal.yml
    validator_command_refs:
      - validate-fixture-retention-closeout-receipt.sh
    output_evidence_refs:
      - .octon/state/evidence/runs/workflows/fixture-retention-closeout-test/reports/$state_id-report.md
      - .octon/state/evidence/runs/workflows/fixture-retention-closeout-test/stages/$state_id/outcome.json
    state_verdict: pass
    retry_count: 0
    resume_cursor: complete
YAML
}

write_fixture_repo() {
  local repo="$1"
  mkdir -p "$repo"
  git -C "$repo" init -q
  mkdir -p \
    "$repo/.octon/inputs/exploratory/proposals/policy/example-retention-fixture/support" \
    "$repo/.octon/generated/proposals/artifacts/policy/example-retention-fixture" \
    "$repo/.octon/state/evidence/runs/workflows/example-terminal-closeout"
  cat >"$repo/.octon/inputs/exploratory/proposals/policy/example-retention-fixture/proposal.yml" <<'YAML'
schema_version: proposal-v1
proposal_id: example-retention-fixture
title: Example Retention Fixture
summary: Temporary fixture for generic route validation.
proposal_kind: policy
promotion_scope: octon-internal
promotion_targets:
  - docs/example-policy.md
status: implemented
lifecycle:
  temporary: true
  exit_expectation: remove after validation is no longer needed
related_proposals: []
YAML
  printf 'implementation conformance\n' >"$repo/.octon/inputs/exploratory/proposals/policy/example-retention-fixture/support/implementation-conformance-review.md"
  printf 'proposal closeout prose\n' >"$repo/.octon/inputs/exploratory/proposals/policy/example-retention-fixture/support/proposal-closeout.md"
  printf 'generated artifact\n' >"$repo/.octon/generated/proposals/artifacts/policy/example-retention-fixture/proposal-artifact-index.yml"
  printf 'terminal receipt\n' >"$repo/.octon/state/evidence/runs/workflows/example-terminal-closeout/terminal-receipt.yml"
}

write_valid_receipt() {
  local repo="$1"
  local receipt="$repo/.octon/state/evidence/runs/workflows/fixture-retention-closeout-test/retention-receipt.yml"
  local rows="$TMP_DIR/status-rows.txt"
  local paths="$TMP_DIR/status-paths.txt"
  mkdir -p "$(dirname "$receipt")"
  : >"$rows"
  : >"$paths"
  git -C "$repo" status --porcelain=v1 --untracked-files=all -- \
    .octon/inputs/exploratory/proposals/policy/example-retention-fixture \
    .octon/generated/proposals/artifacts/policy/example-retention-fixture \
    .octon/state/evidence/validation/proposals/example-retention-fixture |
    while IFS= read -r line; do
      [[ ${#line} -ge 4 ]] || continue
      status="${line:0:2}"
      status="${status// /}"
      path="${line:3}"
      path="${path%/}"
      printf '%s\t%s\n' "$status" "$path" >>"$rows"
      printf '%s\n' "$path" >>"$paths"
    done
  sort -u -o "$rows" "$rows"
  sort -u -o "$paths" "$paths"
  path_digest="$(digest_file_lines "$paths")"
  status_digest="$(digest_file_lines "$rows")"
  {
    cat <<YAML
schema_version: fixture-retention-closeout-receipt-v1
route_id: fixture-retention-closeout
retention_run_id: fixture-retention-closeout-test
retained_at: "2026-06-14T00:00:00Z"
retention_verdict: retained
fixture:
  proposal_id: example-retention-fixture
  proposal_kind: policy
  path: .octon/inputs/exploratory/proposals/policy/example-retention-fixture
  status: implemented
  temporary_lifecycle: true
  promotion_targets:
    - docs/example-policy.md
purpose: terminal-closeout-genericity-validation-fixture
owner_scope: terminal-closeout-route-repair
used_as_evidence_for:
  - terminal-closeout-genericity-validation-fixture
evidence_refs:
  - .octon/state/evidence/runs/workflows/example-terminal-closeout/terminal-receipt.yml
fixture_scope:
  roots:
    - .octon/inputs/exploratory/proposals/policy/example-retention-fixture
    - .octon/generated/proposals/artifacts/policy/example-retention-fixture
    - .octon/state/evidence/validation/proposals/example-retention-fixture
retained_paths:
YAML
    yaml_array "$paths" "  "
    cat <<YAML
retained_status_entries:
YAML
    while IFS=$'\t' read -r status path; do
      printf '  - status: '
      yaml_quote "$status"
      printf '\n    path: '
      yaml_quote "$path"
      printf '\n'
    done <"$rows"
    cat <<YAML
retained_path_set_digest: "$path_digest"
git_status_digest: "$status_digest"
source_digests:
  - path: .octon/inputs/exploratory/proposals/policy/example-retention-fixture/proposal.yml
    digest: sha256:0000000000000000000000000000000000000000000000000000000000000000
generated_artifact_refs:
  - path: .octon/generated/proposals/artifacts/policy/example-retention-fixture/proposal-artifact-index.yml
    authority: derived-only-non-authority
freshness:
  mode: current-git-status-and-source-digest-bound
  status: fresh
validation_refs:
  - .octon/state/evidence/runs/workflows/fixture-retention-closeout-test/stage-logs/fixture-retention-receipt-validation.log
terminal_worktree_hygiene_consumption:
  allowed: true
  exact_path_set_match_required: true
  current_digest_match_required: true
  schema_route_version_match_required: true
  purpose_owner_scope_match_required: true
  all_retained_paths_inside_declared_scope_required: true
  unrelated_residue_coverage_forbidden: true
  nonblocking_only_for_unrelated_packet_terminal_readiness: true
  target_packet_evidence_authority: false
  purpose: terminal-closeout-genericity-validation-fixture
  owner_scope: terminal-closeout-route-repair
  does_not_authorize:
    - archive-ready-claim
    - cleaned-claim
    - archive-relocation
    - proposal-status-mutation
    - generated-publication-edit
    - git-mutation
    - repo-hygiene-deletion
    - target-packet-implementation-evidence
    - target-packet-conformance-evidence
    - target-packet-drift-evidence
authority_boundaries:
  archive_relocation: false
  proposal_status_mutation: false
  generated_publication_edit: false
  git_mutation: false
  residue_deletion: false
  repo_hygiene_deletion_authority: false
  target_packet_evidence_authority: false
blocker:
  class: none
  detail: no blocker
  failing_evidence_ref: not-applicable
  next_canonical_route: not-applicable
state_ledger:
$(state_entry resolve-fixture-identity)
$(state_entry bind-retention-scope)
$(state_entry verify-retained-evidence)
$(state_entry classify-retained-path-set)
$(state_entry emit-retention-receipt)
YAML
  } >"$receipt"
  printf '%s\n' ".octon/state/evidence/runs/workflows/fixture-retention-closeout-test/retention-receipt.yml"
}

mutate_receipt_expect_fail() {
  local description="$1" expression="$2" repo="$3" receipt_rel="$4" target
  target="$repo/.octon/state/evidence/runs/workflows/fixture-retention-closeout-test-${description//[^A-Za-z0-9_.-]/_}/retention-receipt.yml"
  mkdir -p "$(dirname "$target")"
  cp "$repo/$receipt_rel" "$target"
  yq -i "$expression" "$target"
  expect_fail "$description" env OCTON_ROOT_DIR="$repo" bash "$RECEIPT_VALIDATOR" --receipt "${target#"$repo"/}"
}

require_tool git
require_tool jq
require_tool yq

fixture_repo="$TMP_DIR/repo"
write_fixture_repo "$fixture_repo"
receipt_rel="$(write_valid_receipt "$fixture_repo")"

expect_pass "workflow validator" bash "$WORKFLOW_VALIDATOR"
expect_pass "valid fixture retention receipt" env OCTON_ROOT_DIR="$fixture_repo" bash "$RECEIPT_VALIDATOR" --receipt "$receipt_rel"
expect_pass "valid fixture retention consumption JSON" env OCTON_ROOT_DIR="$fixture_repo" bash "$RECEIPT_VALIDATOR" --receipt "$receipt_rel" --emit-consumption-json

mutate_receipt_expect_fail "route version mismatch" '.route_id = "proposal-program-delivery"' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "owner scope mismatch" '.terminal_worktree_hygiene_consumption.owner_scope = "other-owner"' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "path set digest mismatch" '.retained_path_set_digest = "sha256:1111111111111111111111111111111111111111111111111111111111111111"' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "git status digest mismatch" '.git_status_digest = "sha256:2222222222222222222222222222222222222222222222222222222222222222"' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "unrelated path covered" '.retained_status_entries += [{"status": "??", "path": "unrelated.txt"}] | .retained_paths += ["unrelated.txt"]' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "generated artifact used as authority" '.generated_artifact_refs[0].authority = "authority"' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "generated artifact used as source evidence" '.evidence_refs[0] = ".octon/generated/proposals/artifacts/policy/example-retention-fixture/proposal-artifact-index.yml"' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "parent summary substituted for evidence" '.evidence_refs[0] = ".octon/inputs/exploratory/proposals/policy/example-retention-fixture/support/proposal-closeout.md"' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "archive-ready overclaim" '.claimed_outcome = "archive-ready"' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "cleaned overclaim" '.claimed_outcome = "cleaned"' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "archive ready authorization omitted" '.terminal_worktree_hygiene_consumption.does_not_authorize = ["cleaned-claim"]' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "target packet evidence authority" '.authority_boundaries.target_packet_evidence_authority = true' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "missing stage report" 'del(.state_ledger[0].output_evidence_refs[0])' "$fixture_repo" "$receipt_rel"
mutate_receipt_expect_fail "missing retained evidence refs" '.evidence_refs = []' "$fixture_repo" "$receipt_rel"

echo "Test summary: passed=$pass_count failed=$fail_count"
[[ "$fail_count" -eq 0 ]]
