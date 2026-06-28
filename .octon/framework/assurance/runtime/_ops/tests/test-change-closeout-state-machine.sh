#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh"
CLASSIFIER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_FILES=()
declare -a CLEANUP_DIRS=()

cleanup() {
  local file dir
  for file in "${CLEANUP_FILES[@]}"; do
    [[ -n "$file" ]] && rm -f -- "$file"
  done
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -rf -- "$dir"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local label="$1"
  shift
  if "$@"; then pass "$label"; else fail "$label"; fi
}

write_receipt() {
  local file
  file="$(mktemp)"
  CLEANUP_FILES+=("$file")
  cat >"$file"
  printf '%s\n' "$file"
}

run_validator() {
  bash "$VALIDATOR" --receipt "$1" >/dev/null
}

write_state_machine_fixture() {
  local file
  file="$(mktemp)"
  CLEANUP_FILES+=("$file")
  cp "$ROOT_DIR/.octon/framework/product/contracts/change-closeout-state-machine.yml" "$file"
  printf '%s\n' "$file"
}

run_static_validator_with_state_machine() {
  CHANGE_CLOSEOUT_STATE_MACHINE_YML="$1" bash "$VALIDATOR" >/dev/null
}

digest_file() {
  shasum -a 256 "$1" | awk '{print "sha256:" $1}'
}

write_terminal_local_sink_fixture() {
  local change_id="$1"
  local landed_ref="$2"
  local dir proof receipt refs status classification manifest
  dir="$ROOT_DIR/.octon/state/evidence/local/terminal-closeout/$change_id"
  CLEANUP_DIRS+=("$dir")
  mkdir -p "$dir"
  proof="$dir/terminal-current-state-proof.yml"
  receipt="$dir/change-receipt.json"
  refs="$dir/refs.txt"
  status="$dir/status.txt"
  classification="$dir/residue-classification.yml"
  manifest="$dir/manifest.json"
  cat >"$proof" <<YAML
schema_version: lifecycle-terminal-current-state-proof-v1
proof_id: terminal-proof-$change_id
observed_at: "2026-06-15T00:00:00Z"
change_id: $change_id
lifecycle_outcome: cleaned
non_authority_classification: retained-evidence-only
final_refs:
  head_ref: $landed_ref
  main_ref: $landed_ref
  origin_main_ref: $landed_ref
  landed_ref: $landed_ref
alignment:
  head_equals_local_main: true
  local_main_equals_origin_main: true
  origin_main_contains_landed_ref: true
  local_main_contains_landed_ref: true
worktree:
  status: clean
  status_ref: .octon/state/evidence/local/terminal-closeout/$change_id/status.txt
  residue_counts:
    staged: 0
    unstaged: 0
    untracked: 0
cleanup_classifier_ref: .octon/state/evidence/local/terminal-closeout/$change_id/residue-classification.yml
validator_refs:
  - validator: fixture
    command: fixture validator
    cwd: $ROOT_DIR
    runtime: bash
    exit_code: 0
    evidence_ref: .octon/state/evidence/local/terminal-closeout/$change_id/status.txt
evidence_refs:
  - .octon/state/evidence/runs/skills/closeout-change/$change_id/change-receipt.json
YAML
  printf '{"schema_version":"change-receipt-v1","change_id":"%s","landed_ref":"%s"}\n' "$change_id" "$landed_ref" >"$receipt"
  printf 'HEAD=%s\nmain=%s\norigin/main=%s\nlanded_ref=%s\n' "$landed_ref" "$landed_ref" "$landed_ref" "$landed_ref" >"$refs"
  printf '## main...origin/main\n' >"$status"
  printf 'schema_version: change-closeout-residue-classification-v1\n' >"$classification"

  local proof_digest receipt_digest refs_digest status_digest classification_digest
  proof_digest="$(digest_file "$proof")"
  receipt_digest="$(digest_file "$receipt")"
  refs_digest="$(digest_file "$refs")"
  status_digest="$(digest_file "$status")"
  classification_digest="$(digest_file "$classification")"
  cat >"$manifest" <<JSON
{
  "schema_version": "terminal-closeout-local-evidence-v1",
  "evidence_id": "fixture-$change_id",
  "change_id": "$change_id",
  "created_at": "2026-06-15T00:00:00Z",
  "sink_root": ".octon/state/evidence/local/terminal-closeout",
  "sink_path": ".octon/state/evidence/local/terminal-closeout/$change_id",
  "disclosure_tier": "local-private",
  "non_authority_classification": "retained-evidence-only",
  "authority_boundaries": {
    "not_landing_authorization": true,
    "not_cleanup_authorization": true,
    "not_hosted_check_evidence": true,
    "not_packet_evidence": true,
    "not_archive_evidence": true,
    "not_generated_publication_evidence": true,
    "not_policy_authority": true,
    "not_mutation_authority": true
  },
  "final_refs": {
    "head_ref": "$landed_ref",
    "main_ref": "$landed_ref",
    "origin_main_ref": "$landed_ref",
    "landed_ref": "$landed_ref"
  },
  "alignment": {
    "head_equals_local_main": true,
    "local_main_equals_origin_main": true,
    "origin_main_contains_landed_ref": true,
    "local_main_contains_landed_ref": true
  },
  "source_refs": {
    "terminal_current_state_proof_ref": ".octon/state/evidence/local/terminal-closeout/$change_id/terminal-current-state-proof.yml",
    "change_receipt_ref": ".octon/state/evidence/local/terminal-closeout/$change_id/change-receipt.json"
  },
  "copied_files": [
    {"logical_name": "terminal_current_state_proof", "path": ".octon/state/evidence/local/terminal-closeout/$change_id/terminal-current-state-proof.yml", "digest": "$proof_digest"},
    {"logical_name": "change_receipt", "path": ".octon/state/evidence/local/terminal-closeout/$change_id/change-receipt.json", "digest": "$receipt_digest"},
    {"logical_name": "refs_snapshot", "path": ".octon/state/evidence/local/terminal-closeout/$change_id/refs.txt", "digest": "$refs_digest"},
    {"logical_name": "status_snapshot", "path": ".octon/state/evidence/local/terminal-closeout/$change_id/status.txt", "digest": "$status_digest"},
    {"logical_name": "residue_classification_snapshot", "path": ".octon/state/evidence/local/terminal-closeout/$change_id/residue-classification.yml", "digest": "$classification_digest"}
  ],
  "snapshots": {
    "refs_ref": ".octon/state/evidence/local/terminal-closeout/$change_id/refs.txt",
    "refs_digest": "$refs_digest",
    "status_ref": ".octon/state/evidence/local/terminal-closeout/$change_id/status.txt",
    "status_digest": "$status_digest",
    "residue_classification_ref": ".octon/state/evidence/local/terminal-closeout/$change_id/residue-classification.yml",
    "residue_classification_digest": "$classification_digest"
  },
  "terminal_current_state_proof_digest": "$proof_digest",
  "change_receipt_digest": "$receipt_digest"
}
JSON
  printf '%s %s\n' ".octon/state/evidence/local/terminal-closeout/$change_id/terminal-current-state-proof.yml" "$proof_digest"
}

case_live_repo_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_extension_lifecycle_contract_schema_fails() {
  local contract
  contract="$(write_state_machine_fixture)"
  yq -i '.schema_version = "octon-extension-lifecycle-contract-v2" | .lifecycle_id = "change-closeout"' "$contract"
  ! run_static_validator_with_state_machine "$contract"
}

case_generic_phase_loop_fails() {
  local contract
  contract="$(write_state_machine_fixture)"
  yq -i '.phase_loop = {"model_version": "phase-loop-v1", "phases": []}' "$contract"
  ! run_static_validator_with_state_machine "$contract"
}

case_route_authority_drift_fails() {
  local contract
  contract="$(write_state_machine_fixture)"
  yq -i '.relationship_to_default_work_unit.route_authority = ".octon/framework/product/contracts/change-closeout-state-machine.yml"' "$contract"
  ! run_static_validator_with_state_machine "$contract"
}

case_classifier_is_read_only() {
  local output
  output="$(bash "$CLASSIFIER" --root "$ROOT_DIR")"
  grep -Fq "detection_is_deletion_authority: false" <<<"$output"
}

case_classifier_retains_ignored_proposal_lifecycle_residue() {
  local repo output state_control_count local_retained_count
  repo="$(mktemp -d "${TMPDIR:-/tmp}/change-closeout-residue.XXXXXX")"
  CLEANUP_DIRS+=("$repo")
  git -C "$repo" init -q
  git -C "$repo" config user.email "octon@example.invalid"
  git -C "$repo" config user.name "Octon Test"
  mkdir -p \
    "$repo/.octon/state/control/execution/runs" \
    "$repo/.octon/state/continuity/runs" \
    "$repo/.octon/state/evidence/control/execution" \
    "$repo/.octon/state/evidence/external-index/runs" \
    "$repo/.octon/state/evidence/runs/skills/closeout-worktree"
  printf '%s\n' "seed" >"$repo/README.md"
  cat >"$repo/.gitignore" <<'EOF'
.octon/state/continuity/runs/archive-proposal-[0-9]*/
.octon/state/control/execution/runs/archive-proposal-[0-9]*/
.octon/state/evidence/control/execution/authority-decision-archive-proposal-[0-9]*.yml
.octon/state/evidence/external-index/runs/archive-proposal-[0-9]*.yml
.octon/state/evidence/runs/skills/closeout-worktree/*/operator-scope.md
EOF
  git -C "$repo" add README.md .gitignore
  git -C "$repo" commit -q -m "seed residue classifier repo"

  mkdir -p \
    "$repo/.octon/state/control/execution/runs/archive-proposal-12345" \
    "$repo/.octon/state/continuity/runs/archive-proposal-12345" \
    "$repo/.octon/state/evidence/runs/skills/closeout-worktree/run-12345"
  printf '%s\n' "schema_version: run-contract-v3" \
    >"$repo/.octon/state/control/execution/runs/archive-proposal-12345/run-contract.yml"
  printf '%s\n' "run_id: archive-proposal-12345" \
    >"$repo/.octon/state/continuity/runs/archive-proposal-12345/handoff.yml"
  printf '%s\n' "decision_id: decision-archive-proposal-12345" \
    >"$repo/.octon/state/evidence/control/execution/authority-decision-archive-proposal-12345.yml"
  printf '%s\n' "run_id: archive-proposal-12345" \
    >"$repo/.octon/state/evidence/external-index/runs/archive-proposal-12345.yml"
  printf '%s\n' "operator scope" \
    >"$repo/.octon/state/evidence/runs/skills/closeout-worktree/run-12345/operator-scope.md"

  output="$(bash "$CLASSIFIER" --root "$repo")"
  state_control_count="$(awk '$0 == "  - class: state-control" {getline; print $2}' <<<"$output")"
  local_retained_count="$(awk '$0 == "  - class: local_private_retained" {getline; print $2}' <<<"$output")"
  [[ "$state_control_count" == "0" ]] &&
    [[ "${local_retained_count:-0}" -ge 1 ]]
}

case_closeout_worktree_wrapper_exists() {
  local wrapper="$ROOT_DIR/.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md"
  local contract="$ROOT_DIR/.octon/framework/product/contracts/change-closeout-state-machine.yml"
  [[ -f "$wrapper" ]] &&
    grep -Fq 'singular `closeout-change` runs' "$wrapper" &&
    yq -e '.relationship_to_default_work_unit.dirty_worktree_wrapper.decomposition_rule == "partition residue into singular Change closeouts and delegate each coherent unit to closeout-change"' "$contract" >/dev/null
}

case_unspecified_closeout_defaults_to_cleaned() {
  local contract="$ROOT_DIR/.octon/framework/product/contracts/change-closeout-state-machine.yml"
  local schema="$ROOT_DIR/.octon/framework/product/contracts/change-receipt-v1.schema.json"
  yq -e '.target_lifecycle_defaults.unspecified_closeout_request == "cleaned"' "$contract" >/dev/null &&
    yq -e '.target_lifecycle_defaults.explicit_narrower_lifecycle_targets[]? | select(. == "published-branch")' "$contract" >/dev/null &&
    yq -e '.target_lifecycle_defaults.explicit_narrower_route_requests[]? | select(. == "stage-only-escalate")' "$contract" >/dev/null &&
    jq -e '.properties.target_lifecycle_outcome.default == "cleaned"' "$schema" >/dev/null
}

case_valid_completed_receipt_passes() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "valid-stateful",
  "selected_route": "direct-main",
  "target_lifecycle_outcome": "landed",
  "lifecycle_outcome": "landed",
  "outcome_intent": "direct-main-landing",
  "intent": "land a direct-main change",
  "scope": {"summary": "test"},
  "target_branch_ref": "origin/main@def0000000000000000000000000000000000000",
  "landed_ref": "def0000000000000000000000000000000000000",
  "main_alignment": {
    "local_main_ref": "def0000000000000000000000000000000000000",
    "origin_main_ref": "def0000000000000000000000000000000000000",
    "landed_ref": "def0000000000000000000000000000000000000",
    "aligned": true
  },
  "integration_method": "direct-commit",
  "integration_status": "landed",
  "publication_status": "none",
  "cleanup_status": "not_applicable",
  "validation_evidence_refs": ["validation"],
  "durable_history": {"kind": "commit", "ref": "def0000000000000000000000000000000000000"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def0000000000000000000000000000000000000"},
  "closeout_outcome": "completed",
  "stateful_closeout": {
    "state_machine_version": "change-closeout-state-machine-v1",
    "initial_inventory_ref": "evidence://inventory",
    "residue_classification_ref": "evidence://residue",
    "phase_exit_refs": ["evidence://phase/final-verification"],
    "cleanup_decision_refs": ["evidence://cleanup/not-applicable"],
    "safe_cleanup_evidence_class": "not-applicable",
    "final_verification_ref": "evidence://final"
  },
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
)"
  run_validator "$receipt"
}

case_completed_without_stateful_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "missing-stateful",
  "selected_route": "direct-main",
  "target_lifecycle_outcome": "landed",
  "lifecycle_outcome": "landed",
  "outcome_intent": "direct-main-landing",
  "intent": "bad",
  "scope": {"summary": "test"},
  "target_branch_ref": "origin/main@def0000000000000000000000000000000000000",
  "landed_ref": "def0000000000000000000000000000000000000",
  "main_alignment": {
    "local_main_ref": "def0000000000000000000000000000000000000",
    "origin_main_ref": "def0000000000000000000000000000000000000",
    "landed_ref": "def0000000000000000000000000000000000000",
    "aligned": true
  },
  "integration_method": "direct-commit",
  "integration_status": "landed",
  "publication_status": "none",
  "cleanup_status": "not_applicable",
  "validation_evidence_refs": ["validation"],
  "durable_history": {"kind": "commit", "ref": "def0000000000000000000000000000000000000"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def0000000000000000000000000000000000000"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_ready_completed_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "ready-overclaim",
  "selected_route": "branch-pr",
  "target_lifecycle_outcome": "ready",
  "lifecycle_outcome": "ready",
  "outcome_intent": "pr-ready",
  "intent": "bad",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/pr",
  "integration_status": "not_landed",
  "publication_status": "pr-ready",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validation"],
  "durable_history": {"kind": "pr", "ref": "1", "pr_url": "https://example.invalid/pr/1"},
  "rollback_handle": {"kind": "manual-instructions", "ref": "feature/pr"},
  "closeout_outcome": "completed",
  "stateful_closeout": {
    "state_machine_version": "change-closeout-state-machine-v1",
    "initial_inventory_ref": "evidence://inventory",
    "residue_classification_ref": "evidence://residue",
    "phase_exit_refs": ["evidence://phase/ready"],
    "cleanup_decision_refs": ["evidence://cleanup/pending"],
    "safe_cleanup_evidence_class": "not-applicable",
    "final_verification_ref": "evidence://final"
  },
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_detection_only_cleanup_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-cleanup",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "cleaned",
  "lifecycle_outcome": "cleaned",
  "outcome_intent": "attempt-cleaned-closeout",
  "intent": "bad cleanup",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/no-pr",
  "target_branch_ref": "origin/main@def0000000000000000000000000000000000000",
  "remote_branch_ref": "origin/feature/no-pr@def0000000000000000000000000000000000000",
  "landed_ref": "def0000000000000000000000000000000000000",
  "hosted_landing": {
    "remote": "origin",
    "target_branch": "main",
    "source_branch": "feature/no-pr",
    "source_ref": "def0000000000000000000000000000000000000",
    "target_pre_ref": "abc0000000000000000000000000000000000000",
    "target_post_ref": "def0000000000000000000000000000000000000",
    "validated_ref": "def0000000000000000000000000000000000000",
    "required_check_refs": ["route_neutral_closeout_validation@def0000000000000000000000000000000000000"],
    "provider_ruleset_ref": "route-neutral-main",
    "fast_forward_only": true
  },
  "main_alignment": {
    "local_main_ref": "def0000000000000000000000000000000000000",
    "origin_main_ref": "def0000000000000000000000000000000000000",
    "landed_ref": "def0000000000000000000000000000000000000",
    "aligned": true
  },
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "completed",
  "cleanup_evidence_refs": ["detected files"],
  "source_branch_cleanup": {"status": "completed", "local_branch": "feature/no-pr", "remote_branch": "origin/feature/no-pr"},
  "validation_evidence_refs": ["validation"],
  "durable_history": {"kind": "commit", "ref": "def0000000000000000000000000000000000000", "branch": "feature/no-pr"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def0000000000000000000000000000000000000"},
  "closeout_outcome": "completed",
  "stateful_closeout": {
    "state_machine_version": "change-closeout-state-machine-v1",
    "initial_inventory_ref": "evidence://inventory",
    "residue_classification_ref": "evidence://residue",
    "phase_exit_refs": ["evidence://phase/branch-cleanup"],
    "cleanup_decision_refs": ["evidence://cleanup/detected"],
    "safe_cleanup_evidence_class": "detection-only",
    "hosted_landing_refs": ["evidence://hosted"],
    "branch_cleanup_refs": ["evidence://branch-cleanup"],
    "final_verification_ref": "evidence://final"
  },
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_local_terminal_proof_with_digest_passes() {
  local sink proof_ref proof_digest receipt landed_ref
  landed_ref="def0000000000000000000000000000000000000"
  sink="$(write_terminal_local_sink_fixture valid-local-terminal "$landed_ref")"
  proof_ref="${sink% *}"
  proof_digest="${sink##* }"
  receipt="$(write_receipt <<JSON
{
  "schema_version": "change-receipt-v1",
  "change_id": "valid-local-terminal",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "cleaned",
  "lifecycle_outcome": "cleaned",
  "outcome_intent": "attempt-cleaned-closeout",
  "intent": "valid local terminal proof",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/no-pr",
  "target_branch_ref": "origin/main@$landed_ref",
  "remote_branch_ref": "origin/feature/no-pr@$landed_ref",
  "landing_authorization_ref": ".octon/state/evidence/runs/skills/closeout-change/fixture/landing-authorization.json",
  "landed_ref": "$landed_ref",
  "hosted_landing": {
    "remote": "origin",
    "target_branch": "main",
    "source_branch": "feature/no-pr",
    "source_ref": "$landed_ref",
    "target_pre_ref": "abc0000000000000000000000000000000000000",
    "target_post_ref": "$landed_ref",
    "validated_ref": "$landed_ref",
    "required_check_refs": ["route_neutral_closeout_validation@$landed_ref"],
    "provider_ruleset_ref": "route-neutral-main",
    "fast_forward_only": true
  },
  "main_alignment": {
    "local_main_ref": "$landed_ref",
    "origin_main_ref": "$landed_ref",
    "landed_ref": "$landed_ref",
    "aligned": true,
    "origin_fetch_evidence_ref": "evidence://fetch",
    "local_main_sync_evidence_ref": "evidence://sync",
    "origin_main_contains_landed_ref": true,
    "local_main_contains_landed_ref": true
  },
  "source_branch_integration": {
    "source_branch_ref": "feature/no-pr",
    "landed_ref": "$landed_ref",
    "origin_main_ref": "$landed_ref",
    "integrated": true,
    "evidence_refs": ["evidence://integration"]
  },
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "completed",
  "cleanup_evidence_refs": ["evidence://cleanup"],
  "source_branch_cleanup": {"status": "completed", "local_branch": "feature/no-pr", "remote_branch": "origin/feature/no-pr"},
  "terminal_current_state_proof_ref": "$proof_ref",
  "terminal_current_state_proof_digest": "$proof_digest",
  "validation_evidence_refs": ["validation"],
  "durable_history": {"kind": "commit", "ref": "$landed_ref", "branch": "feature/no-pr"},
  "rollback_handle": {"kind": "revert-commit", "ref": "$landed_ref"},
  "closeout_outcome": "completed",
  "stateful_closeout": {
    "state_machine_version": "change-closeout-state-machine-v1",
    "initial_inventory_ref": "evidence://inventory",
    "residue_classification_ref": "evidence://residue",
    "phase_exit_refs": ["evidence://phase/branch-cleanup"],
    "cleanup_decision_refs": ["evidence://cleanup/detected"],
    "safe_cleanup_evidence_class": "origin-main-containment",
    "hosted_landing_refs": ["evidence://hosted"],
    "branch_cleanup_refs": ["evidence://branch-cleanup"],
    "final_verification_ref": "evidence://final"
  },
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
)"
  run_validator "$receipt"
}

case_local_terminal_proof_without_digest_fails() {
  local sink proof_ref proof_digest receipt landed_ref
  landed_ref="def0000000000000000000000000000000000000"
  sink="$(write_terminal_local_sink_fixture missing-digest-terminal "$landed_ref")"
  proof_ref="${sink% *}"
  proof_digest="${sink##* }"
  receipt="$(write_receipt <<JSON
{
  "schema_version": "change-receipt-v1",
  "change_id": "missing-digest-terminal",
  "selected_route": "direct-main",
  "target_lifecycle_outcome": "cleaned",
  "lifecycle_outcome": "cleaned",
  "outcome_intent": "direct-main-landing",
  "intent": "bad local terminal proof",
  "scope": {"summary": "test"},
  "target_branch_ref": "origin/main@$landed_ref",
  "landed_ref": "$landed_ref",
  "main_alignment": {"local_main_ref": "$landed_ref", "origin_main_ref": "$landed_ref", "landed_ref": "$landed_ref", "aligned": true},
  "integration_method": "direct-commit",
  "integration_status": "landed",
  "publication_status": "none",
  "cleanup_status": "not_applicable",
  "terminal_current_state_proof_ref": "$proof_ref",
  "validation_evidence_refs": ["validation"],
  "durable_history": {"kind": "commit", "ref": "$landed_ref"},
  "rollback_handle": {"kind": "revert-commit", "ref": "$landed_ref"},
  "closeout_outcome": "completed",
  "stateful_closeout": {
    "state_machine_version": "change-closeout-state-machine-v1",
    "initial_inventory_ref": "evidence://inventory",
    "residue_classification_ref": "evidence://residue",
    "phase_exit_refs": ["evidence://phase/final"],
    "cleanup_decision_refs": ["evidence://cleanup/not-applicable"],
    "safe_cleanup_evidence_class": "origin-main-containment",
    "final_verification_ref": "evidence://final"
  },
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

main() {
  assert_success "state-machine validator passes live repo" case_live_repo_passes
  assert_success "extension lifecycle contract schema fails for Change closeout" case_extension_lifecycle_contract_schema_fails
  assert_success "generic phase_loop fails for Change closeout" case_generic_phase_loop_fails
  assert_success "route authority drift fails for Change closeout" case_route_authority_drift_fails
  assert_success "residue classifier is read-only" case_classifier_is_read_only
  assert_success "residue classifier retains ignored proposal lifecycle residue" case_classifier_retains_ignored_proposal_lifecycle_residue
  assert_success "closeout-worktree wrapper exists and decomposes singular changes" case_closeout_worktree_wrapper_exists
  assert_success "unspecified closeout target defaults to cleaned" case_unspecified_closeout_defaults_to_cleaned
  assert_success "valid completed receipt with stateful evidence passes" case_valid_completed_receipt_passes
  assert_success "completed receipt without stateful evidence fails" case_completed_without_stateful_fails
  assert_success "ready PR cannot claim completed closeout" case_ready_completed_fails
  assert_success "detection-only cleanup evidence fails" case_detection_only_cleanup_fails
  assert_success "local terminal proof with digest passes" case_local_terminal_proof_with_digest_passes
  assert_success "local terminal proof without digest fails" case_local_terminal_proof_without_digest_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
