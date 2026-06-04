#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh"
CLASSIFIER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh"

pass_count=0
fail_count=0
cleanup_paths=()
fixture_root=""

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    case "$path" in
      "${TMPDIR:-/tmp}"/closeout-worktree-wrapper.*)
        [[ -d "$path" ]] && rm -r -- "$path"
        [[ -f "$path" ]] && rm -f -- "$path"
        ;;
      *)
        echo "refusing to remove unexpected cleanup path: $path" >&2
        ;;
    esac
  done
  true
}
trap cleanup EXIT

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

new_report() {
  local file
  file="$(mktemp "${TMPDIR:-/tmp}/closeout-worktree-wrapper.report.XXXXXX")"
  cleanup_paths+=("$file")
  printf '%s\n' "$file"
}

ensure_fixture_root() {
  if [[ -z "$fixture_root" ]]; then
    fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/closeout-worktree-wrapper.evidence.XXXXXX")"
    cleanup_paths+=("$fixture_root")
  fi
  mkdir -p "$fixture_root/.octon/state/evidence/runs/skills/closeout-change"
}

rewrite_fixture_json() {
  local file="$1"
  local filter="$2"
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/closeout-worktree-wrapper.rewrite.XXXXXX")"
  jq "$filter" "$file" >"$tmp"
  mv "$tmp" "$file"
}

write_closeout_change_fixture() {
  local suffix="$1"
  local receipt_dir authorization_ref cleanup_authorization_ref
  ensure_fixture_root
  receipt_dir="$(dirname "$suffix")"
  authorization_ref=".octon/state/evidence/runs/skills/closeout-change/$receipt_dir/branch-landing-authorization.json"
  cleanup_authorization_ref=".octon/state/evidence/runs/skills/closeout-change/$receipt_dir/branch-cleanup-authorization.json"
  mkdir -p "$(dirname "$fixture_root/.octon/state/evidence/runs/skills/closeout-change/$suffix")"
  cat >"$fixture_root/$authorization_ref" <<JSON
{
  "schema_version": "branch-landing-authorization-v1",
  "authorization_id": "fixture-${receipt_dir//\//-}-landing-authorization",
  "authorization_result": "approved",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "cleaned",
  "remote": "origin",
  "target_branch": "main",
  "source_branch": "fixture/source",
  "source_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "remote_source_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "target_pre_ref": "9999999999999999999999999999999999999999",
  "provider_ruleset_ref": "fixture-route-neutral-main",
  "no_pr_required": true,
  "preflight_status": "passed",
  "required_check_refs": ["ci@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
  "allow_empty_check_set": false,
  "rollback_handle": "revert fixture aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa if post-landing verification fails",
  "host_controls_not_bypassed": true,
  "runtime_safety_boundary": "fixture authorization preserves platform, sandbox, and host safety controls",
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
  cat >"$fixture_root/$cleanup_authorization_ref" <<JSON
{
  "schema_version": "branch-cleanup-authorization-v1",
  "authorization_id": "fixture-${receipt_dir//\//-}-cleanup-authorization",
  "authorization_result": "approved",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "cleaned",
  "source_branch": "fixture/source",
  "landed_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "origin_main_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "local_main_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "local_main_synced_to_origin_main": true,
  "origin_main_contains_landed_ref": true,
  "local_main_contains_landed_ref": true,
  "source_branch_contained_in_origin_main": true,
  "source_branch_protected": false,
  "open_pr_count": 0,
  "cleanup_policy_allowed": true,
  "host_controls_not_bypassed": true,
  "runtime_safety_boundary": "fixture authorization preserves platform, sandbox, and host safety controls",
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
  cat >"$fixture_root/.octon/state/evidence/runs/skills/closeout-change/$suffix" <<JSON
{
  "schema_version": "change-receipt-v1",
  "change_id": "fixture-${suffix//\//-}",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "cleaned",
  "lifecycle_outcome": "cleaned",
  "outcome_intent": "attempt-cleaned-closeout",
  "intent": "fixture completed branch closeout",
  "scope": {"summary": "fixture"},
  "source_branch_ref": "fixture/source",
  "target_branch_ref": "origin/main@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "remote_branch_ref": "origin/fixture/source@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "landing_authorization_ref": "$authorization_ref",
  "hosted_landing": {
    "remote": "origin",
    "target_branch": "main",
    "source_branch": "fixture/source",
    "source_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "target_pre_ref": "9999999999999999999999999999999999999999",
    "target_post_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "validated_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "required_check_refs": ["ci@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
    "provider_ruleset_ref": "fixture-route-neutral-main",
    "push_refspec": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:refs/heads/main",
    "fast_forward_only": true
  },
  "landing_evaluation": {
    "status": "succeeded",
    "provider_ruleset_ref": "fixture-route-neutral-main",
    "source_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "target_ref": "origin/main@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "evidence_refs": ["fixture hosted landing evidence"]
  },
  "source_branch_integration": {
    "source_branch_ref": "fixture/source",
    "source_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "landed_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "origin_main_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "integrated": true,
    "method": "fast-forward",
    "evidence_refs": ["fixture origin/main contains source branch changes"]
  },
  "landed_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "main_alignment": {
    "local_main_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "origin_main_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "landed_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aligned": true,
    "origin_fetch_evidence_ref": "fixture git fetch origin",
    "local_main_sync_evidence_ref": "fixture git switch main && git merge --ff-only origin/main",
    "origin_main_contains_landed_ref": true,
    "local_main_contains_landed_ref": true,
    "verification_ref": "fixture git merge-base --is-ancestor"
  },
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "completed",
  "cleanup_authorization_ref": "$cleanup_authorization_ref",
  "cleanup_evidence_refs": ["fixture source branch cleanup completed"],
  "source_branch_cleanup": {
    "status": "completed",
    "local_branch": "fixture/source",
    "remote_branch": "origin/fixture/source",
    "evidence_refs": ["fixture source branch cleanup completed"]
  },
  "validation_evidence_refs": ["fixture validation passed"],
  "review_waiver_refs": ["fixture no-pr waiver"],
  "durable_history": {"kind": "commit", "ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "branch": "fixture/source"},
  "rollback_handle": {"kind": "revert-commit", "ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
  "stateful_closeout": {
    "state_machine_version": "change-closeout-state-machine-v1",
    "initial_inventory_ref": "fixture-inventory",
    "residue_classification_ref": "fixture-classification",
    "phase_exit_refs": ["fixture-phase"],
    "cleanup_decision_refs": ["fixture-cleanup"],
    "safe_cleanup_evidence_class": "origin-main-containment",
    "hosted_landing_refs": ["fixture-hosted-landing"],
    "branch_cleanup_refs": ["fixture-branch-cleanup"],
    "final_verification_ref": "fixture-final-verification"
  },
  "closeout_outcome": "completed",
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
}

write_continued_closeout_change_fixture() {
  local suffix="$1"
  ensure_fixture_root
  mkdir -p "$(dirname "$fixture_root/.octon/state/evidence/runs/skills/closeout-change/$suffix")"
  cat >"$fixture_root/.octon/state/evidence/runs/skills/closeout-change/$suffix" <<JSON
{
  "schema_version": "change-receipt-v1",
  "change_id": "fixture-continued-${suffix//\//-}",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "published-branch",
  "lifecycle_outcome": "published-branch",
  "outcome_intent": "handoff-only",
  "intent": "fixture branch publication handoff",
  "scope": {"summary": "fixture continued handoff"},
  "source_branch_ref": "fixture/source",
  "remote_branch_ref": "origin/fixture/source@bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  "landing_evaluation": {
    "status": "not_attempted",
    "source_ref": "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
    "target_ref": "origin/main"
  },
  "not_landed_reason": "fixture published-branch handoff did not land on origin/main",
  "not_cleaned_reason": "fixture branch is retained for later landing or discard",
  "integration_method": "not-applicable",
  "integration_status": "not_landed",
  "publication_status": "pushed-branch",
  "cleanup_status": "deferred",
  "cleanup_evidence_refs": ["fixture source branch retained"],
  "source_branch_cleanup": {
    "status": "deferred",
    "local_branch": "fixture/source",
    "remote_branch": "origin/fixture/source",
    "blocker_reason": "fixture branch not landed",
    "evidence_refs": ["fixture source branch retained"]
  },
  "validation_evidence_refs": ["fixture validation passed"],
  "review_waiver_refs": ["fixture handoff only"],
  "durable_history": {"kind": "commit", "ref": "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", "branch": "fixture/source"},
  "rollback_handle": {"kind": "discard-branch", "ref": "fixture/source"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
}

write_repo_hygiene_cleanup_fixture() {
  local suffix="$1"
  ensure_fixture_root
  mkdir -p "$(dirname "$fixture_root/.octon/state/evidence/runs/skills/repo-hygiene-cleanup/$suffix")"
  cat >"$fixture_root/.octon/state/evidence/runs/skills/repo-hygiene-cleanup/$suffix" <<'JSON'
schema_version: repo-hygiene-cleanup-run-log-v1
route: repo-hygiene-cleanup
cleanup_outcome: delegated-cleaned
classification_ref: evidence://runs/skills/repo-hygiene-cleanup/fixture/classification.txt
authorization_ref: evidence://runs/skills/repo-hygiene-cleanup/fixture/authorization.json
deleted_paths:
  - .octon/state/control/execution/runs/publish-fixture/runtime-state.yml
retained_protected_paths: []
retained_manual_review_paths: []
JSON
}

run_validator_with_fixtures() {
  CLOSEOUT_WORKTREE_EVIDENCE_ROOT="$fixture_root" bash "$VALIDATOR" --report "$1"
}

write_valid_single_closed_report() {
  local report="$1"
  local run_id="$2"
  local receipt_suffix="$3"
  local terminal_state="${4:-git_clean_terminal}"
  local next_route="${5:-none}"
  local untracked_count="${6:-0}"

  cat >"$report" <<YAML
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: $run_id
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
worktree_terminal_state: $terminal_state
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: landed
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/$receipt_suffix
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/$receipt_suffix
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining closeout-worktree candidates after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/$receipt_suffix
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  staged: 0
  unstaged_tracked: 0
  untracked: $untracked_count
  ignored: 0
  generated_effective_output: 0
  host_projection: 0
  retained_evidence: 0
  state_control: 0
  release_version: 0
  input_surface: 0
next_route_condition: $next_route
YAML
}

new_replay_repo() {
  local repo
  repo="$(mktemp -d "${TMPDIR:-/tmp}/closeout-worktree-wrapper.replay.XXXXXX")"
  cleanup_paths+=("$repo")
  git -C "$repo" init -q
  git -C "$repo" config user.email "octon@example.invalid"
  git -C "$repo" config user.name "Octon Test"
  mkdir -p "$repo/docs" "$repo/src"
  printf '%s\n' "seed docs" >"$repo/docs/closeout.md"
  printf '%s\n' "seed runtime" >"$repo/src/runtime.txt"
  git -C "$repo" add docs/closeout.md src/runtime.txt
  git -C "$repo" commit -q -m "seed replay repo"
  printf '%s\n' "docs candidate change" >>"$repo/docs/closeout.md"
  printf '%s\n' "runtime candidate change" >>"$repo/src/runtime.txt"
  printf '%s\n' "$repo"
}

new_replay_evidence_dir() {
  local evidence_dir
  evidence_dir="$(mktemp -d "${TMPDIR:-/tmp}/closeout-worktree-wrapper.replay-evidence.XXXXXX")"
  cleanup_paths+=("$evidence_dir")
  printf '%s\n' "$evidence_dir"
}

capture_replay_inventory() {
  local repo="$1"
  local output="$2"
  git -C "$repo" status --porcelain=v1 --ignored >"$output"
}

capture_replay_classification() {
  local repo="$1"
  local output="$2"
  bash "$CLASSIFIER" --root "$repo" >"$output"
}

classification_count() {
  local classification="$1"
  local target_class="$2"
  awk -v target="$target_class" '
    $0 ~ "class: " target "$" {
      getline
      sub(/^[[:space:]]*count:[[:space:]]*/, "", $0)
      print $0
      found = 1
      exit
    }
    END {
      if (!found) {
        print "0"
      }
    }
  ' "$classification"
}

case_static_validator_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_valid_multi_candidate_report_passes() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "docs-candidate/change-receipt.json"
  write_closeout_change_fixture "runtime-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-valid
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
worktree_terminal_state: git_clean_terminal
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
        - docs/closeout-checklist.md
      exclude_paths:
        - src/runtime/kernel.rs
        - .octon/generated/effective/capabilities/routing.effective.yml
  - candidate_id: candidate-runtime
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/runtime-candidate/change-receipt.json
    boundaries:
      include_paths:
        - src/runtime/kernel.rs
      exclude_paths:
        - docs/closeout.md
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
      - docs/closeout-checklist.md
    exclude_paths:
      - src/runtime/kernel.rs
      - .octon/generated/effective/capabilities/routing.effective.yml
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: candidate-runtime remains coherent and safely separable after re-inventory
  - iteration_id: iteration-002
    pre_inventory_ref: evidence://worktree/inventory-002
    pre_classification_ref: evidence://worktree/classification-002
    selected_candidate_id: candidate-runtime
    include_paths:
      - src/runtime/kernel.rs
    exclude_paths:
      - docs/closeout.md
    closeout_change_ref: evidence://runs/skills/closeout-change/runtime-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-003
    post_classification_ref: evidence://worktree/classification-003
    next_selection_reason: no remaining closeout-worktree candidates after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
  candidate-runtime:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/runtime-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  staged: 0
  unstaged_tracked: 0
  untracked: 0
  ignored: 0
  generated_effective_output: 0
  host_projection: 0
  retained_evidence: 0
  state_control: 0
  release_version: 0
  input_surface: 0
next_route_condition: none
YAML
  run_validator_with_fixtures "$report" >/dev/null
}

case_repo_hygiene_delegated_cleanup_report_passes() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "docs-candidate/change-receipt.json"
  write_repo_hygiene_cleanup_fixture "fixture/run-log.yml"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-repo-hygiene-delegated
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
repo_hygiene_cleanup_actions_performed: false
worktree_terminal_state: git_clean_terminal
repo_hygiene_classification_ref: .octon/state/evidence/runs/skills/repo-hygiene-cleanup/fixture/classification.txt
repo_hygiene_cleanup_ref: evidence://runs/skills/repo-hygiene-cleanup/fixture/run-log.yml
repo_hygiene_cleanup_authorization_ref: .octon/state/evidence/runs/skills/repo-hygiene-cleanup/fixture/authorization.json
repo_hygiene_cleanup_outcome: delegated-cleaned
repo_hygiene_summary:
  cleanup_candidates: 0
  protected_referenced: 0
  manual_review: 0
repo_hygiene_next_route_condition: none
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths:
        - .octon/state/control/execution/runs/publish-fixture/runtime-state.yml
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths:
      - .octon/state/control/execution/runs/publish-fixture/runtime-state.yml
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: repo-hygiene residue delegated to repo-hygiene-cleanup and no candidate residue remains
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  staged: 0
  unstaged_tracked: 0
  untracked: 0
  ignored: 0
  generated_effective_output: 0
  host_projection: 0
  retained_evidence: 0
  state_control: 0
  release_version: 0
  input_surface: 0
next_route_condition: none
YAML
  run_validator_with_fixtures "$report" >/dev/null
}

case_git_clean_terminal_after_evidence_retention_candidate_passes() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "primary-candidate/change-receipt.json"
  write_closeout_change_fixture "evidence-retention-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-git-clean-after-evidence-retention
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
worktree_terminal_state: git_clean_terminal
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-primary
candidates:
  - candidate_id: candidate-primary
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/primary-candidate/change-receipt.json
    boundaries:
      include_paths:
        - src/runtime/kernel.rs
      exclude_paths:
        - .octon/state/evidence/runs/skills/closeout-change/primary-candidate
  - candidate_id: candidate-closeout-evidence-retention
    disposition: delegated
    residue_routing_class: publishable_closeout_evidence
    ownership: retained-closeout-evidence
    route_hint: closeout-change
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/evidence-retention-candidate/change-receipt.json
    boundaries:
      include_paths:
        - .octon/state/evidence/runs/skills/closeout-change/primary-candidate
      exclude_paths:
        - src/runtime/kernel.rs
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-primary
    include_paths:
      - src/runtime/kernel.rs
    exclude_paths:
      - .octon/state/evidence/runs/skills/closeout-change/primary-candidate
    closeout_change_ref: evidence://runs/skills/closeout-change/primary-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: retained closeout evidence is the only new non-ignored residue and is safely separable
  - iteration_id: iteration-002
    pre_inventory_ref: evidence://worktree/inventory-002
    pre_classification_ref: evidence://worktree/classification-002
    selected_candidate_id: candidate-closeout-evidence-retention
    include_paths:
      - .octon/state/evidence/runs/skills/closeout-change/primary-candidate
    exclude_paths:
      - src/runtime/kernel.rs
    closeout_change_ref: evidence://runs/skills/closeout-change/evidence-retention-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-003
    post_classification_ref: evidence://worktree/classification-003
    next_selection_reason: no non-ignored residue remains after evidence-retention closeout
final_candidate_dispositions:
  candidate-primary:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/primary-candidate/change-receipt.json
  candidate-closeout-evidence-retention:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/evidence-retention-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  staged: 0
  unstaged_tracked: 0
  untracked: 0
  ignored: 0
  generated_effective_output: 0
  host_projection: 0
  retained_evidence: 0
  state_control: 0
  release_version: 0
  input_surface: 0
next_route_condition: none
YAML
  run_validator_with_fixtures "$report" >/dev/null
}

case_disposition_complete_with_retained_residue_passes() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "primary-retained-report-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-disposition-complete-retained
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
worktree_terminal_state: disposition_complete_with_retained_residue
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-primary
candidates:
  - candidate_id: candidate-primary
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/primary-retained-report-candidate/change-receipt.json
    boundaries:
      include_paths:
        - src/runtime/kernel.rs
      exclude_paths:
        - .octon/state/evidence/runs/skills/closeout-change/primary-retained-report-candidate
  - candidate_id: candidate-closeout-evidence-residue
    disposition: retained
    residue_routing_class: local_private_retained
    ownership: retained-closeout-evidence
    route_hint: none
    target_lifecycle_outcome: retained
    rollback_or_discard_posture: preserve retained closeout evidence until a later governed route supersedes it
    boundaries:
      include_paths:
        - .octon/state/evidence/local/runs/skills/closeout-change/primary-retained-report-candidate
      exclude_paths:
        - src/runtime/kernel.rs
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-primary
    include_paths:
      - src/runtime/kernel.rs
    exclude_paths:
      - .octon/state/evidence/local/runs/skills/closeout-change/primary-retained-report-candidate
    closeout_change_ref: evidence://runs/skills/closeout-change/primary-retained-report-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: retained closeout evidence remains documented but Git-clean is not claimed
final_candidate_dispositions:
  candidate-primary:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/primary-retained-report-candidate/change-receipt.json
  candidate-closeout-evidence-residue:
    state: retained
    reason: closeout evidence remains retained and outside wrapper deletion authority
retained_residue:
  - candidate_id: candidate-closeout-evidence-residue
    path: .octon/state/evidence/local/runs/skills/closeout-change/primary-retained-report-candidate
    disposition: local private retained closeout evidence
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  untracked: 2
  ignored: 0
  retained_evidence: 4
next_route_condition: none
YAML
  run_validator_with_fixtures "$report" >/dev/null
}

case_git_clean_terminal_with_retained_evidence_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "primary-retained-invalid-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-git-clean-with-retained-evidence
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
worktree_terminal_state: git_clean_terminal
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-primary
candidates:
  - candidate_id: candidate-primary
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/primary-retained-invalid-candidate/change-receipt.json
    boundaries:
      include_paths:
        - src/runtime/kernel.rs
      exclude_paths:
        - .octon/state/evidence/runs/skills/closeout-change/primary-retained-invalid-candidate
  - candidate_id: candidate-closeout-evidence-residue
    disposition: retained
    ownership: retained-closeout-evidence
    route_hint: none
    target_lifecycle_outcome: retained
    rollback_or_discard_posture: preserve retained closeout evidence until a later governed route supersedes it
    boundaries:
      include_paths:
        - .octon/state/evidence/runs/skills/closeout-change/primary-retained-invalid-candidate
      exclude_paths:
        - src/runtime/kernel.rs
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-primary
    include_paths:
      - src/runtime/kernel.rs
    exclude_paths:
      - .octon/state/evidence/runs/skills/closeout-change/primary-retained-invalid-candidate
    closeout_change_ref: evidence://runs/skills/closeout-change/primary-retained-invalid-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: retained closeout evidence remains
final_candidate_dispositions:
  candidate-primary:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/primary-retained-invalid-candidate/change-receipt.json
  candidate-closeout-evidence-residue:
    state: retained
retained_residue:
  - candidate_id: candidate-closeout-evidence-residue
    path: .octon/state/evidence/runs/skills/closeout-change/primary-retained-invalid-candidate
    disposition: retained closeout evidence
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  staged: 0
  unstaged_tracked: 0
  untracked: 1
  ignored: 0
  generated_effective_output: 0
  host_projection: 0
  retained_evidence: 1
  state_control: 0
  release_version: 0
  input_surface: 0
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_retained_terminal_missing_worktree_terminal_state_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "primary-missing-terminal-state/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-missing-terminal-state
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-primary
candidates:
  - candidate_id: candidate-primary
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/primary-missing-terminal-state/change-receipt.json
    boundaries:
      include_paths:
        - src/runtime/kernel.rs
      exclude_paths:
        - .octon/state/evidence/runs/skills/closeout-change/primary-missing-terminal-state
  - candidate_id: candidate-closeout-evidence-residue
    disposition: retained
    ownership: retained-closeout-evidence
    route_hint: none
    target_lifecycle_outcome: retained
    rollback_or_discard_posture: preserve retained closeout evidence until a later governed route supersedes it
    boundaries:
      include_paths:
        - .octon/state/evidence/runs/skills/closeout-change/primary-missing-terminal-state
      exclude_paths:
        - src/runtime/kernel.rs
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-primary
    include_paths:
      - src/runtime/kernel.rs
    exclude_paths:
      - .octon/state/evidence/runs/skills/closeout-change/primary-missing-terminal-state
    closeout_change_ref: evidence://runs/skills/closeout-change/primary-missing-terminal-state/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: retained closeout evidence remains
final_candidate_dispositions:
  candidate-primary:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/primary-missing-terminal-state/change-receipt.json
  candidate-closeout-evidence-residue:
    state: retained
retained_residue:
  - candidate_id: candidate-closeout-evidence-residue
    path: .octon/state/evidence/runs/skills/closeout-change/primary-missing-terminal-state
    disposition: retained closeout evidence
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  untracked: 1
  ignored: 0
  retained_evidence: 1
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_repo_hygiene_delegated_retained_report_passes() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "docs-retained-hygiene-candidate/change-receipt.json"
  write_repo_hygiene_cleanup_fixture "fixture-retained/run-log.yml"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-repo-hygiene-delegated-retained
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
repo_hygiene_cleanup_actions_performed: false
worktree_terminal_state: nonterminal
repo_hygiene_classification_ref: .octon/state/evidence/runs/skills/repo-hygiene-cleanup/fixture-retained/classification.txt
repo_hygiene_cleanup_ref: evidence://runs/skills/repo-hygiene-cleanup/fixture-retained/run-log.yml
repo_hygiene_cleanup_authorization_ref: .octon/state/evidence/runs/skills/repo-hygiene-cleanup/fixture-retained/authorization.json
repo_hygiene_cleanup_outcome: delegated-retained
repo_hygiene_summary:
  cleanup_candidates: 0
  protected_referenced: 0
  manual_review: 1
repo_hygiene_next_route_condition: manual-review repo-hygiene residue remains retained by delegated route
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-retained-hygiene-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths:
        - .octon/state/evidence/runs/manual-review.yml
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths:
      - .octon/state/evidence/runs/manual-review.yml
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-retained-hygiene-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: delegated repo-hygiene retained manual-review residue outside wrapper cleanup authority
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-retained-hygiene-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 0
next_route_condition: delegated repo-hygiene manual-review residue remains retained
YAML
  run_validator_with_fixtures "$report" >/dev/null
}

case_repo_hygiene_unresolved_blocks_git_clean_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "docs-unresolved-hygiene-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-repo-hygiene-unresolved-git-clean
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
repo_hygiene_cleanup_actions_performed: false
worktree_terminal_state: git_clean_terminal
repo_hygiene_classification_ref: .octon/state/evidence/runs/skills/repo-hygiene-cleanup/fixture-unresolved/classification.txt
repo_hygiene_cleanup_outcome: classification-only
repo_hygiene_summary:
  cleanup_candidates: 1
  protected_referenced: 0
  manual_review: 0
repo_hygiene_next_route_condition: delegate cleanup candidate to repo-hygiene-cleanup
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-unresolved-hygiene-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-unresolved-hygiene-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: repo-hygiene cleanup candidate remains unresolved
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-unresolved-hygiene-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  staged: 0
  unstaged_tracked: 0
  untracked: 0
  ignored: 0
  generated_effective_output: 0
  host_projection: 0
  retained_evidence: 0
  state_control: 0
  release_version: 0
  input_surface: 0
next_route_condition: delegate unresolved repo-hygiene cleanup candidate
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_repo_hygiene_cleanup_actions_performed_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "docs-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-repo-hygiene-wrapper-action
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
repo_hygiene_cleanup_actions_performed: true
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 0
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_repo_hygiene_cleanup_ref_must_resolve_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "docs-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-repo-hygiene-missing-ref
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
repo_hygiene_cleanup_actions_performed: false
repo_hygiene_cleanup_ref: evidence://runs/skills/repo-hygiene-cleanup/missing/run-log.yml
repo_hygiene_cleanup_outcome: delegated-cleaned
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 0
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_first_close_then_second_blocked_passes() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "docs-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-close-then-block
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
worktree_terminal_state: nonterminal
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths:
        - src/runtime/kernel.rs
  - candidate_id: candidate-runtime
    disposition: blocked
    residue_routing_class: ambiguous
    ownership: ambiguous
    route_hint: stage-only-escalate
    target_lifecycle_outcome: blocked
    rollback_or_discard_posture: preserve-before-routing
    boundaries:
      include_paths:
        - src/runtime/kernel.rs
      exclude_paths:
        - docs/closeout.md
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths:
      - src/runtime/kernel.rs
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: candidate-runtime remained after re-inventory but has a candidate-specific ownership blocker
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
  candidate-runtime:
    state: blocked
    reason: operator must resolve ownership of src/runtime/kernel.rs before closeout-change can run
retained_residue: []
blockers:
  - candidate_id: candidate-runtime
    blocker: operator must resolve ownership of src/runtime/kernel.rs before closeout-change can run
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 0
next_route_condition: operator resolves candidate-runtime ownership blocker
YAML
  run_validator_with_fixtures "$report" >/dev/null
}

case_multiple_sets_batched_into_one_candidate_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-batched
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-batched
candidates:
  - candidate_id: candidate-batched
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/batched
    boundaries:
      include_paths:
        - docs/closeout.md
        - src/runtime/kernel.rs
      exclude_paths: []
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
next_route_condition: none
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_selected_candidate_without_boundaries_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-missing-boundaries
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: direct-main
    target_lifecycle_outcome: landed
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
next_route_condition: none
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_selected_candidate_without_closeout_change_ref_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-missing-delegation
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
next_route_condition: none
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_selected_candidate_without_delegation_or_blocker_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-selected-no-delegation-no-blocker
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: blocked
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
iterations: []
final_candidate_dispositions:
  candidate-docs:
    state: blocked
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
next_route_condition: operator resolution required
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_selected_candidate_blocked_only_by_multiple_candidates_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-partition-only-blocker
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: blocked
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths:
        - src/runtime/kernel.rs
  - candidate_id: candidate-runtime
    disposition: retained
    ownership: ambiguous
    route_hint: stage-only-escalate
    target_lifecycle_outcome: blocked
    rollback_or_discard_posture: preserve-before-routing
    boundaries:
      include_paths:
        - src/runtime/kernel.rs
      exclude_paths:
        - docs/closeout.md
iterations: []
final_candidate_dispositions:
  candidate-docs:
    state: blocked
  candidate-runtime:
    state: retained
retained_residue:
  - candidate_id: candidate-runtime
    path: src/runtime/kernel.rs
    disposition: retained-for-operator-routing
blockers:
  - candidate_id: candidate-docs
    blocker: selected candidate is blocked because multiple candidates exist
final_inventory_ref: evidence://worktree/final
next_route_condition: operator selects first candidate
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_delegated_candidate_missing_post_inventory_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-missing-post-inventory
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
    closeout_change_outcome: closed
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
next_route_condition: none
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_closed_candidate_missing_closeout_change_ref_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-closed-missing-ref
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
next_route_condition: none
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_terminal_report_with_unprocessed_candidate_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-terminal-unprocessed
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths:
        - src/runtime/kernel.rs
  - candidate_id: candidate-runtime
    disposition: retained
    ownership: ambiguous
    route_hint: stage-only-escalate
    target_lifecycle_outcome: blocked
    rollback_or_discard_posture: preserve-before-routing
    boundaries:
      include_paths:
        - src/runtime/kernel.rs
      exclude_paths:
        - docs/closeout.md
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths:
      - src/runtime/kernel.rs
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: candidate-runtime retained for operator routing
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
  candidate-runtime:
    state: retained
retained_residue:
  - candidate_id: candidate-runtime
    path: src/runtime/kernel.rs
    disposition: retained-for-operator-routing
blockers: []
final_inventory_ref: evidence://worktree/final
next_route_condition: none
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_direct_material_action_from_wrapper_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-material-action
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: true
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: direct-main
    target_lifecycle_outcome: landed
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
next_route_condition: none
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_duplicate_candidate_path_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-duplicate-path
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-a
candidates:
  - candidate_id: candidate-a
    disposition: delegated
    ownership: accepted-change
    route_hint: direct-main
    target_lifecycle_outcome: landed
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/a
    boundaries:
      include_paths:
        - src/shared.rs
      exclude_paths: []
  - candidate_id: candidate-b
    disposition: retained
    ownership: ambiguous
    route_hint: stage-only-escalate
    target_lifecycle_outcome: blocked
    rollback_or_discard_posture: preserve-before-routing
    boundaries:
      include_paths:
        - src/shared.rs
      exclude_paths: []
retained_residue:
  - candidate_id: candidate-b
    path: src/shared.rs
    disposition: ambiguous-overlap-retained
blockers:
  - candidate_id: candidate-b
    blocker: candidates overlap on src/shared.rs
final_inventory_ref: evidence://worktree/final
next_route_condition: operator scope resolution
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_retained_candidate_without_retained_residue_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-missing-retained-evidence
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
  - candidate_id: candidate-runtime
    disposition: retained
    ownership: ambiguous
    route_hint: stage-only-escalate
    target_lifecycle_outcome: blocked
    rollback_or_discard_posture: preserve-before-routing
    boundaries:
      include_paths:
        - src/runtime/kernel.rs
      exclude_paths: []
retained_residue: []
blockers:
  - candidate_id: candidate-runtime
    blocker: candidate-runtime requires operator scope resolution before mutation
final_inventory_ref: evidence://worktree/final
next_route_condition: operator scope resolution
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_ambiguous_candidate_without_blocker_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-missing-ambiguous-blocker
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
  - candidate_id: candidate-runtime
    disposition: ambiguous
    ownership: ambiguous
    route_hint: stage-only-escalate
    target_lifecycle_outcome: blocked
    rollback_or_discard_posture: preserve-before-routing
    boundaries:
      include_paths:
        - src/runtime/kernel.rs
      exclude_paths: []
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
next_route_condition: operator scope resolution
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_unresolved_candidate_with_terminal_next_route_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-terminal-unresolved
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
  - candidate_id: candidate-runtime
    disposition: retained
    ownership: ambiguous
    route_hint: stage-only-escalate
    target_lifecycle_outcome: blocked
    rollback_or_discard_posture: preserve-before-routing
    boundaries:
      include_paths:
        - src/runtime/kernel.rs
      exclude_paths: []
retained_residue:
  - candidate_id: candidate-runtime
    path: src/runtime/kernel.rs
    disposition: retained-for-operator-routing
blockers: []
final_inventory_ref: evidence://worktree/final
next_route_condition: none
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_synthetic_closeout_change_ref_fails() {
  local report
  report="$(new_report)"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-synthetic-closeout-ref
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: closeout-change://branch-no-pr/published-branch/synthetic
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths: []
    closeout_change_ref: closeout-change://branch-no-pr/published-branch/synthetic
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: closeout-change://branch-no-pr/published-branch/synthetic
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 0
next_route_condition: none
YAML
  ! bash "$VALIDATOR" --report "$report" >/dev/null
}

case_closed_candidate_with_continued_receipt_fails() {
  local report
  report="$(new_report)"
  write_continued_closeout_change_fixture "continued-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-continued-receipt-closed
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/continued-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/continued-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/continued-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 0
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_closed_candidate_with_cleaned_deferred_cleanup_fails() {
  local report receipt
  report="$(new_report)"
  write_closeout_change_fixture "cleaned-deferred-candidate/change-receipt.json"
  receipt="$fixture_root/.octon/state/evidence/runs/skills/closeout-change/cleaned-deferred-candidate/change-receipt.json"
  rewrite_fixture_json "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .cleanup_status = "deferred" | .source_branch_cleanup.status = "deferred" | .source_branch_cleanup.blocker_reason = "fixture cleanup deferred" | .source_branch_cleanup.evidence_refs = ["fixture cleanup deferred"] | .cleanup_evidence_refs = ["fixture cleanup deferred"]'
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-cleaned-deferred-cleanup
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/cleaned-deferred-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/cleaned-deferred-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/cleaned-deferred-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 0
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_git_clean_terminal_with_landed_deferred_cleanup_fails() {
  local report receipt
  report="$(new_report)"
  write_closeout_change_fixture "landed-deferred-cleanup-candidate/change-receipt.json"
  receipt="$fixture_root/.octon/state/evidence/runs/skills/closeout-change/landed-deferred-cleanup-candidate/change-receipt.json"
  rewrite_fixture_json "$receipt" '.target_lifecycle_outcome = "landed" | .lifecycle_outcome = "landed" | .outcome_intent = "attempt-landing" | .cleanup_status = "deferred" | .source_branch_cleanup.status = "deferred" | .source_branch_cleanup.blocker_reason = "fixture cleanup deferred" | .source_branch_cleanup.evidence_refs = ["fixture cleanup deferred"] | .cleanup_evidence_refs = ["fixture cleanup deferred"] | del(.cleanup_authorization_ref)'
  write_valid_single_closed_report "$report" "closeout-worktree-fixture-landed-deferred-cleanup" "landed-deferred-cleanup-candidate/change-receipt.json"
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_closed_stage_only_receipt_fails() {
  local report receipt
  report="$(new_report)"
  write_closeout_change_fixture "stage-only-closed-candidate/change-receipt.json"
  receipt="$fixture_root/.octon/state/evidence/runs/skills/closeout-change/stage-only-closed-candidate/change-receipt.json"
  rewrite_fixture_json "$receipt" '.selected_route = "stage-only-escalate" | .lifecycle_outcome = "preserved" | .target_lifecycle_outcome = "preserved" | .integration_status = "not_landed" | .publication_status = "not-published" | .cleanup_status = "not-applicable"'
  write_valid_single_closed_report "$report" "closeout-worktree-fixture-stage-only-closed" "stage-only-closed-candidate/change-receipt.json"
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_closed_branch_no_pr_missing_landing_authorization_fails() {
  local report receipt
  report="$(new_report)"
  write_closeout_change_fixture "missing-landing-authorization-candidate/change-receipt.json"
  receipt="$fixture_root/.octon/state/evidence/runs/skills/closeout-change/missing-landing-authorization-candidate/change-receipt.json"
  rewrite_fixture_json "$receipt" 'del(.landing_authorization_ref)'
  write_valid_single_closed_report "$report" "closeout-worktree-fixture-missing-landing-authorization" "missing-landing-authorization-candidate/change-receipt.json"
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_closed_branch_no_pr_missing_exact_sha_check_refs_fails() {
  local report receipt authorization
  report="$(new_report)"
  write_closeout_change_fixture "missing-exact-sha-candidate/change-receipt.json"
  receipt="$fixture_root/.octon/state/evidence/runs/skills/closeout-change/missing-exact-sha-candidate/change-receipt.json"
  authorization="$fixture_root/.octon/state/evidence/runs/skills/closeout-change/missing-exact-sha-candidate/branch-landing-authorization.json"
  rewrite_fixture_json "$receipt" '.hosted_landing.required_check_refs = ["ci"]'
  rewrite_fixture_json "$authorization" '.required_check_refs = ["ci"]'
  write_valid_single_closed_report "$report" "closeout-worktree-fixture-missing-exact-sha-checks" "missing-exact-sha-candidate/change-receipt.json"
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_nonterminal_without_unresolved_condition_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "nonterminal-without-unresolved-candidate/change-receipt.json"
  write_valid_single_closed_report "$report" "closeout-worktree-fixture-nonterminal-without-unresolved" "nonterminal-without-unresolved-candidate/change-receipt.json" "nonterminal" "continue closeout"
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_nonterminal_with_unknown_candidate_blocker_fails() {
  local report tmp
  report="$(new_report)"
  tmp="$(new_report)"
  write_closeout_change_fixture "nonterminal-unknown-blocker-candidate/change-receipt.json"
  write_valid_single_closed_report "$report" "closeout-worktree-fixture-nonterminal-unknown-blocker" "nonterminal-unknown-blocker-candidate/change-receipt.json" "nonterminal" "continue closeout"
  awk '
    $0 == "blockers: []" {
      print "blockers:"
      print "  - candidate_id: candidate-unknown"
      print "    reason: stray blocker must not satisfy nonterminal proof"
      print "    evidence_refs: [fixture-stray-blocker]"
      next
    }
    { print }
  ' "$report" >"$tmp"
  mv "$tmp" "$report"
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_retained_terminal_without_retained_candidate_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "retained-terminal-without-retained-candidate/change-receipt.json"
  write_valid_single_closed_report "$report" "closeout-worktree-fixture-retained-terminal-without-retained-candidate" "retained-terminal-without-retained-candidate/change-receipt.json" "disposition_complete_with_retained_residue" "none" "1"
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_retained_ordinary_untracked_residue_terminal_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "ordinary-retained-source-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-retained-ordinary-untracked
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
worktree_terminal_state: disposition_complete_with_retained_residue
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: landed
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/ordinary-retained-source-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths:
        - docs/local-note.md
  - candidate_id: candidate-local-note
    disposition: retained
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: none
    target_lifecycle_outcome: retained
    rollback_or_discard_posture: preserve ordinary untracked source residue
    boundaries:
      include_paths:
        - docs/local-note.md
      exclude_paths:
        - docs/closeout.md
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths:
      - docs/local-note.md
    closeout_change_ref: evidence://runs/skills/closeout-change/ordinary-retained-source-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: ordinary untracked source residue remains
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/ordinary-retained-source-candidate/change-receipt.json
  candidate-local-note:
    state: retained
retained_residue:
  - candidate_id: candidate-local-note
    path: docs/local-note.md
    disposition: retained ordinary untracked source residue
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  untracked: 1
  ignored: 0
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_raw_state_as_publishable_closeout_evidence_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "raw-state-evidence-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-raw-state-publishable-evidence
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
worktree_terminal_state: git_clean_terminal
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-raw-state
candidates:
  - candidate_id: candidate-raw-state
    disposition: delegated
    residue_routing_class: publishable_closeout_evidence
    ownership: retained-closeout-evidence
    route_hint: closeout-change
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/raw-state-evidence-candidate/change-receipt.json
    boundaries:
      include_paths:
        - .octon/state/control/execution/runs/publish-fixture/runtime-state.yml
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-raw-state
    include_paths:
      - .octon/state/control/execution/runs/publish-fixture/runtime-state.yml
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/raw-state-evidence-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after re-inventory
final_candidate_dispositions:
  candidate-raw-state:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/raw-state-evidence-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 0
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_engine_path_as_publishable_closeout_evidence_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "engine-path-evidence-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-engine-path-publishable-evidence
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
worktree_terminal_state: git_clean_terminal
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-engine-path
candidates:
  - candidate_id: candidate-engine-path
    disposition: delegated
    residue_routing_class: publishable_closeout_evidence
    ownership: retained-closeout-evidence
    route_hint: closeout-change
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/engine-path-evidence-candidate/change-receipt.json
    boundaries:
      include_paths:
        - .octon/engine/runtime-state.json
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-engine-path
    include_paths:
      - .octon/engine/runtime-state.json
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/engine-path-evidence-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after re-inventory
final_candidate_dispositions:
  candidate-engine-path:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/engine-path-evidence-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 0
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_recursive_final_evidence_publication_loop_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "recursive-final-evidence-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-recursive-final-evidence-loop
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
worktree_terminal_state: git_clean_terminal
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-final-evidence-loop
candidates:
  - candidate_id: candidate-final-evidence-loop
    disposition: delegated
    residue_routing_class: publishable_closeout_evidence
    ownership: retained-closeout-evidence
    route_hint: closeout-change
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/recursive-final-evidence-candidate/change-receipt.json
    boundaries:
      include_paths:
        - .octon/state/evidence/local/runs/skills/closeout-worktree/final/report.yml
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-final-evidence-loop
    include_paths:
      - .octon/state/evidence/local/runs/skills/closeout-worktree/final/report.yml
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/recursive-final-evidence-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after recursive final evidence publication
final_candidate_dispositions:
  candidate-final-evidence-loop:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/recursive-final-evidence-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 0
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_closeout_worktree_run_log_as_publishable_evidence_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "closeout-worktree-run-log-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-run-log-publishable-evidence
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
worktree_terminal_state: git_clean_terminal
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-run-log
candidates:
  - candidate_id: candidate-run-log
    disposition: delegated
    residue_routing_class: publishable_closeout_evidence
    ownership: retained-closeout-evidence
    route_hint: closeout-change
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/closeout-worktree-run-log-candidate/change-receipt.json
    boundaries:
      include_paths:
        - .octon/state/evidence/runs/skills/closeout-worktree/final-run/run-log.md
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-run-log
    include_paths:
      - .octon/state/evidence/runs/skills/closeout-worktree/final-run/run-log.md
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/closeout-worktree-run-log-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after closeout-worktree run-log publication
final_candidate_dispositions:
  candidate-run-log:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/closeout-worktree-run-log-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 0
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_prior_candidate_without_reconciliation_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "docs-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-missing-prior-reconciliation
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-change-closeout-state-machine
prior_candidate_reconciliation:
  prior_report_ref: .octon/state/evidence/validation/analysis/20260521T130413Z-closeout-worktree-report.yml
  candidates: []
candidates:
  - candidate_id: candidate-change-closeout-state-machine
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-change-closeout-state-machine
    include_paths:
      - docs/closeout.md
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after re-inventory
final_candidate_dispositions:
  candidate-change-closeout-state-machine:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 0
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_ignored_residue_without_foreign_coverage_fails() {
  local report
  report="$(new_report)"
  write_closeout_change_fixture "docs-candidate/change-receipt.json"
  cat >"$report" <<'YAML'
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-missing-ignored-coverage
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: published-branch
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths: []
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths: []
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining candidates after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/docs-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  ignored: 1
next_route_condition: none
YAML
  ! run_validator_with_fixtures "$report" >/dev/null
}

case_classifier_counts_multi_residue_classes() {
  local repo output
  repo="$(mktemp -d "${TMPDIR:-/tmp}/closeout-worktree-wrapper.repo.XXXXXX")"
  cleanup_paths+=("$repo")
  git -C "$repo" init -q
  git -C "$repo" config user.email "octon@example.invalid"
  git -C "$repo" config user.name "Octon Test"
  mkdir -p "$repo/src" "$repo/docs"
  printf '%s\n' "tracked" >"$repo/src/tracked.txt"
  git -C "$repo" add src/tracked.txt
  git -C "$repo" commit -q -m "seed"
  printf '%s\n' "changed" >>"$repo/src/tracked.txt"
  printf '%s\n' "staged" >"$repo/docs/staged.txt"
  git -C "$repo" add docs/staged.txt
  printf '%s\n' "untracked" >"$repo/docs/untracked.txt"

  output="$(bash "$CLASSIFIER" --root "$repo")"
  grep -A1 'class: staged' <<<"$output" | grep -Fq 'count: 1' &&
    grep -A1 'class: unstaged-tracked' <<<"$output" | grep -Fq 'count: 1' &&
    grep -A1 'class: untracked' <<<"$output" | grep -Fq 'count: 1' &&
    grep -Fq 'routing_classes:' <<<"$output" &&
    grep -A1 'class: publishable_change' <<<"$output" | grep -Fq 'count: 3'
}

case_classifier_counts_routing_classes() {
  local repo output
  repo="$(mktemp -d "${TMPDIR:-/tmp}/closeout-worktree-wrapper.routing-repo.XXXXXX")"
  cleanup_paths+=("$repo")
  git -C "$repo" init -q
  git -C "$repo" config user.email "octon@example.invalid"
  git -C "$repo" config user.name "Octon Test"
  printf '%s\n' "seed" >"$repo/README.md"
  git -C "$repo" add README.md
  git -C "$repo" commit -q -m "seed"
  mkdir -p \
    "$repo/.octon/state/evidence/runs/skills/closeout-change/run-1" \
    "$repo/.octon/state/evidence/local/run-1" \
    "$repo/.octon/state/control/execution" \
    "$repo/.octon/engine"
  printf '%s\n' "receipt" >"$repo/.octon/state/evidence/runs/skills/closeout-change/run-1/change-receipt.json"
  printf '%s\n' "local" >"$repo/.octon/state/evidence/local/run-1/transient.json"
  printf '%s\n' "control" >"$repo/.octon/state/control/execution/runtime-state.yml"
  printf '%s\n' "engine" >"$repo/.octon/engine/runtime-state.json"

  output="$(bash "$CLASSIFIER" --root "$repo")"
  grep -Fq 'routing_classes:' <<<"$output" &&
    grep -A1 'class: publishable_closeout_evidence' <<<"$output" | grep -Fq 'count: 1' &&
    grep -A1 'class: local_private_retained' <<<"$output" | grep -Fq 'count: 1' &&
    grep -A1 'class: unsafe' <<<"$output" | grep -Fq 'count: 2'
}

case_classifier_counts_ignored_unsafe_routing_classes() {
  local repo output
  repo="$(mktemp -d "${TMPDIR:-/tmp}/closeout-worktree-wrapper.ignored-routing-repo.XXXXXX")"
  cleanup_paths+=("$repo")
  git -C "$repo" init -q
  git -C "$repo" config user.email "octon@example.invalid"
  git -C "$repo" config user.name "Octon Test"
  mkdir -p "$repo/.octon/engine" "$repo/.octon/state/control"
  printf '%s\n' ".octon/engine/ignored-runtime-state.json" ".octon/state/control/ignored-runtime-state.yml" >"$repo/.gitignore"
  printf '%s\n' "seed" >"$repo/README.md"
  printf '%s\n' "keep" >"$repo/.octon/engine/.keep"
  printf '%s\n' "keep" >"$repo/.octon/state/control/.keep"
  git -C "$repo" add README.md .gitignore .octon/engine/.keep .octon/state/control/.keep
  git -C "$repo" commit -q -m "seed ignored routing repo"
  printf '%s\n' "engine" >"$repo/.octon/engine/ignored-runtime-state.json"
  printf '%s\n' "control" >"$repo/.octon/state/control/ignored-runtime-state.yml"

  output="$(bash "$CLASSIFIER" --root "$repo")"
  grep -A1 'class: ignored' <<<"$output" | grep -Fq 'count: 2' &&
    grep -A1 'class: unsafe' <<<"$output" | grep -Fq 'count: 2' &&
    grep -A1 'class: local_private_retained' <<<"$output" | grep -Fq 'count: 0'
}

case_replay_multi_candidate_loop_passes() {
  local repo evidence_dir report initial_inventory initial_classification post_inventory post_classification
  repo="$(new_replay_repo)"
  evidence_dir="$(new_replay_evidence_dir)"
  report="$(new_report)"
  initial_inventory="$evidence_dir/inventory-001.txt"
  initial_classification="$evidence_dir/classification-001.yml"
  post_inventory="$evidence_dir/inventory-002.txt"
  post_classification="$evidence_dir/classification-002.yml"

  capture_replay_inventory "$repo" "$initial_inventory"
  capture_replay_classification "$repo" "$initial_classification"
  [[ "$(classification_count "$initial_classification" "unstaged-tracked")" == "2" ]]

  write_closeout_change_fixture "replay-docs-candidate/change-receipt.json"
  git -C "$repo" add docs/closeout.md
  git -C "$repo" commit -q -m "close docs candidate"

  capture_replay_inventory "$repo" "$post_inventory"
  capture_replay_classification "$repo" "$post_classification"
  [[ "$(classification_count "$post_classification" "unstaged-tracked")" == "1" ]]
  [[ "$(classification_count "$post_classification" "ignored")" == "0" ]]

  cat >"$report" <<YAML
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-replay-loop
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
worktree_terminal_state: nonterminal
initial_inventory_ref: "file://$initial_inventory"
residue_classification_ref: "file://$initial_classification"
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: landed
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-docs-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths:
        - src/runtime.txt
  - candidate_id: candidate-runtime
    disposition: blocked
    residue_routing_class: ambiguous
    ownership: ambiguous
    route_hint: stage-only-escalate
    target_lifecycle_outcome: blocked
    rollback_or_discard_posture: preserve-before-routing
    boundaries:
      include_paths:
        - src/runtime.txt
      exclude_paths:
        - docs/closeout.md
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: "file://$initial_inventory"
    pre_classification_ref: "file://$initial_classification"
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths:
      - src/runtime.txt
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-docs-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: "file://$post_inventory"
    post_classification_ref: "file://$post_classification"
    next_selection_reason: candidate-runtime remains after re-inventory and has an ownership blocker
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-docs-candidate/change-receipt.json
  candidate-runtime:
    state: blocked
    reason: operator must resolve ownership of src/runtime.txt before closeout-change can run
retained_residue: []
blockers:
  - candidate_id: candidate-runtime
    blocker: operator must resolve ownership of src/runtime.txt before closeout-change can run
final_inventory_ref: "file://$post_inventory"
final_residue_classes:
  ignored: 0
next_route_condition: operator resolves candidate-runtime ownership blocker
YAML

  run_validator_with_fixtures "$report" >/dev/null &&
    grep -Fq 'iteration_id: iteration-001' "$report" &&
    grep -Fq 'post_inventory_ref:' "$report" &&
    grep -Fq 'candidate-runtime:' "$report"
}

case_replay_skips_reinventory_fails() {
  local repo evidence_dir report initial_inventory initial_classification
  repo="$(new_replay_repo)"
  evidence_dir="$(new_replay_evidence_dir)"
  report="$(new_report)"
  initial_inventory="$evidence_dir/inventory-001.txt"
  initial_classification="$evidence_dir/classification-001.yml"

  capture_replay_inventory "$repo" "$initial_inventory"
  capture_replay_classification "$repo" "$initial_classification"
  write_closeout_change_fixture "replay-missing-post-candidate/change-receipt.json"

  cat >"$report" <<YAML
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-replay-missing-post
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: "file://$initial_inventory"
residue_classification_ref: "file://$initial_classification"
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: landed
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-missing-post-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths:
        - src/runtime.txt
  - candidate_id: candidate-runtime
    disposition: blocked
    ownership: ambiguous
    route_hint: stage-only-escalate
    target_lifecycle_outcome: blocked
    rollback_or_discard_posture: preserve-before-routing
    boundaries:
      include_paths:
        - src/runtime.txt
      exclude_paths:
        - docs/closeout.md
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: "file://$initial_inventory"
    pre_classification_ref: "file://$initial_classification"
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths:
      - src/runtime.txt
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-missing-post-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: ""
    post_classification_ref: ""
    next_selection_reason: candidate-runtime remains after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-missing-post-candidate/change-receipt.json
  candidate-runtime:
    state: blocked
    reason: operator must resolve ownership of src/runtime.txt before closeout-change can run
retained_residue: []
blockers:
  - candidate_id: candidate-runtime
    blocker: operator must resolve ownership of src/runtime.txt before closeout-change can run
final_inventory_ref: "file://$initial_inventory"
final_residue_classes:
  ignored: 0
next_route_condition: operator resolves candidate-runtime ownership blocker
YAML

  ! run_validator_with_fixtures "$report" >/dev/null
}

case_replay_terminal_with_unprocessed_candidate_fails() {
  local repo evidence_dir report initial_inventory initial_classification
  repo="$(new_replay_repo)"
  evidence_dir="$(new_replay_evidence_dir)"
  report="$(new_report)"
  initial_inventory="$evidence_dir/inventory-001.txt"
  initial_classification="$evidence_dir/classification-001.yml"

  capture_replay_inventory "$repo" "$initial_inventory"
  capture_replay_classification "$repo" "$initial_classification"
  write_closeout_change_fixture "replay-terminal-docs-candidate/change-receipt.json"

  cat >"$report" <<YAML
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-replay-terminal-unprocessed
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: "file://$initial_inventory"
residue_classification_ref: "file://$initial_classification"
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: landed
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-terminal-docs-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths:
        - src/runtime.txt
  - candidate_id: candidate-runtime
    disposition: retained
    ownership: unrelated
    route_hint: stage-only-escalate
    target_lifecycle_outcome: retained
    rollback_or_discard_posture: preserve-before-routing
    boundaries:
      include_paths:
        - src/runtime.txt
      exclude_paths:
        - docs/closeout.md
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: "file://$initial_inventory"
    pre_classification_ref: "file://$initial_classification"
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths:
      - src/runtime.txt
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-terminal-docs-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: "file://$initial_inventory"
    post_classification_ref: "file://$initial_classification"
    next_selection_reason: no remaining candidates after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-terminal-docs-candidate/change-receipt.json
retained_residue: []
blockers: []
final_inventory_ref: "file://$initial_inventory"
final_residue_classes:
  ignored: 0
next_route_condition: none
YAML

  ! run_validator_with_fixtures "$report" >/dev/null
}

case_replay_synthetic_closeout_ref_fails() {
  local repo evidence_dir report initial_inventory initial_classification
  repo="$(new_replay_repo)"
  evidence_dir="$(new_replay_evidence_dir)"
  report="$(new_report)"
  initial_inventory="$evidence_dir/inventory-001.txt"
  initial_classification="$evidence_dir/classification-001.yml"

  capture_replay_inventory "$repo" "$initial_inventory"
  capture_replay_classification "$repo" "$initial_classification"

  cat >"$report" <<YAML
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-replay-synthetic-ref
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: "file://$initial_inventory"
residue_classification_ref: "file://$initial_classification"
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: landed
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: closeout-change://replay-docs-candidate
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths:
        - src/runtime.txt
  - candidate_id: candidate-runtime
    disposition: blocked
    ownership: ambiguous
    route_hint: stage-only-escalate
    target_lifecycle_outcome: blocked
    rollback_or_discard_posture: preserve-before-routing
    boundaries:
      include_paths:
        - src/runtime.txt
      exclude_paths:
        - docs/closeout.md
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: "file://$initial_inventory"
    pre_classification_ref: "file://$initial_classification"
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths:
      - src/runtime.txt
    closeout_change_ref: closeout-change://replay-docs-candidate
    closeout_change_outcome: closed
    post_inventory_ref: "file://$initial_inventory"
    post_classification_ref: "file://$initial_classification"
    next_selection_reason: candidate-runtime remains after re-inventory
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: closeout-change://replay-docs-candidate
  candidate-runtime:
    state: blocked
    reason: operator must resolve ownership of src/runtime.txt before closeout-change can run
retained_residue: []
blockers:
  - candidate_id: candidate-runtime
    blocker: operator must resolve ownership of src/runtime.txt before closeout-change can run
final_inventory_ref: "file://$initial_inventory"
final_residue_classes:
  ignored: 0
next_route_condition: operator resolves candidate-runtime ownership blocker
YAML

  ! run_validator_with_fixtures "$report" >/dev/null
}

case_replay_ignored_residue_without_coverage_fails() {
  local repo evidence_dir report initial_inventory initial_classification final_inventory final_classification
  repo="$(new_replay_repo)"
  evidence_dir="$(new_replay_evidence_dir)"
  report="$(new_report)"
  initial_inventory="$evidence_dir/inventory-001.txt"
  initial_classification="$evidence_dir/classification-001.yml"
  final_inventory="$evidence_dir/inventory-002.txt"
  final_classification="$evidence_dir/classification-002.yml"

  printf '%s\n' ".cache/" >"$repo/.gitignore"
  git -C "$repo" add .gitignore
  git -C "$repo" commit -q -m "add ignored residue rule"
  mkdir -p "$repo/.cache"
  printf '%s\n' "local ignored residue" >"$repo/.cache/local.log"
  capture_replay_inventory "$repo" "$initial_inventory"
  capture_replay_classification "$repo" "$initial_classification"
  [[ "$(classification_count "$initial_classification" "ignored")" == "1" ]]

  write_closeout_change_fixture "replay-ignored-docs-candidate/change-receipt.json"
  git -C "$repo" add docs/closeout.md
  git -C "$repo" commit -q -m "close docs candidate with ignored residue retained"
  capture_replay_inventory "$repo" "$final_inventory"
  capture_replay_classification "$repo" "$final_classification"
  [[ "$(classification_count "$final_classification" "ignored")" == "1" ]]

  cat >"$report" <<YAML
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-replay-missing-ignored-coverage
default_work_unit: Change
observed_change_set_count: 2
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: "file://$initial_inventory"
residue_classification_ref: "file://$initial_classification"
selected_candidate_id: candidate-docs
candidates:
  - candidate_id: candidate-docs
    disposition: delegated
    ownership: accepted-change
    route_hint: branch-no-pr
    target_lifecycle_outcome: landed
    rollback_or_discard_posture: rollback-handle-retained
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-ignored-docs-candidate/change-receipt.json
    boundaries:
      include_paths:
        - docs/closeout.md
      exclude_paths:
        - src/runtime.txt
  - candidate_id: candidate-runtime
    disposition: blocked
    ownership: ambiguous
    route_hint: stage-only-escalate
    target_lifecycle_outcome: blocked
    rollback_or_discard_posture: preserve-before-routing
    boundaries:
      include_paths:
        - src/runtime.txt
      exclude_paths:
        - docs/closeout.md
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: "file://$initial_inventory"
    pre_classification_ref: "file://$initial_classification"
    selected_candidate_id: candidate-docs
    include_paths:
      - docs/closeout.md
    exclude_paths:
      - src/runtime.txt
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-ignored-docs-candidate/change-receipt.json
    closeout_change_outcome: closed
    post_inventory_ref: "file://$final_inventory"
    post_classification_ref: "file://$final_classification"
    next_selection_reason: candidate-runtime remains after re-inventory and local ignored residue remains foreign
final_candidate_dispositions:
  candidate-docs:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-ignored-docs-candidate/change-receipt.json
  candidate-runtime:
    state: blocked
    reason: operator must resolve ownership of src/runtime.txt before closeout-change can run
retained_residue: []
blockers:
  - candidate_id: candidate-runtime
    blocker: operator must resolve ownership of src/runtime.txt before closeout-change can run
final_inventory_ref: "file://$final_inventory"
final_residue_classes:
  ignored: 1
next_route_condition: operator resolves candidate-runtime ownership blocker
YAML

  ! run_validator_with_fixtures "$report" >/dev/null
}

case_classifier_accepts_linked_detached_worktree() {
  local repo linked linked_real output
  repo="$(mktemp -d "${TMPDIR:-/tmp}/closeout-worktree-wrapper.linked-repo.XXXXXX")"
  linked="$(mktemp -d "${TMPDIR:-/tmp}/closeout-worktree-wrapper.linked-tree.XXXXXX")"
  cleanup_paths+=("$repo" "$linked")
  git -C "$repo" init -q
  git -C "$repo" config user.email "octon@example.invalid"
  git -C "$repo" config user.name "Octon Test"
  printf '%s\n' "seed" >"$repo/README.md"
  git -C "$repo" add README.md
  git -C "$repo" commit -q -m "seed linked worktree repo"
  rmdir "$linked"
  git -C "$repo" worktree add --detach "$linked" HEAD >/dev/null 2>&1
  linked_real="$(cd "$linked" && pwd -P)"
  output="$(bash "$CLASSIFIER" --root "$linked")"
  git -C "$repo" worktree remove --force "$linked" >/dev/null 2>&1
  printf '%s\n' "$output" | grep -Fq 'schema_version: change-closeout-residue-classification-v1' &&
    printf '%s\n' "$output" | grep -Fq "root: $linked_real"
}

write_lifecycle_publishable_report() {
  local report="$1"
  local include_authority="$2"
  local receipt_suffix="lifecycle-publishable-fixture/change-receipt.json"
  write_closeout_change_fixture "$receipt_suffix"

  cat >"$report" <<YAML
schema_version: closeout-worktree-report-v1
wrapper_id: closeout-worktree
run_id: closeout-worktree-fixture-lifecycle-publishable
default_work_unit: Change
observed_change_set_count: 1
read_only_classification: true
detection_is_deletion_authority: false
direct_material_actions_performed: false
initial_inventory_ref: evidence://worktree/initial
residue_classification_ref: evidence://worktree/classification
selected_candidate_id: candidate-lifecycle
candidates:
  - candidate_id: candidate-lifecycle
    disposition: delegated
    residue_routing_class: publishable_change
    ownership: completed proposal-program lifecycle closeout material
    route_hint: direct-main
    target_lifecycle_outcome: cleaned
    rollback_or_discard_posture: revert landed lifecycle closeout commit
    closeout_change_ref: evidence://runs/skills/closeout-change/$receipt_suffix
YAML
  if [[ "$include_authority" == "yes" ]]; then
    cat >>"$report" <<'YAML'
    lifecycle_closeout_authority:
      completed_program_run_id: lifecycle-proposal-program-fixture
      program_target: .octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller
      completed_program_summary_ref: .octon/state/evidence/runs/workflows/lifecycle-proposal-program-fixture/summary.md
      child_authority_preserved: true
      parent_summary_not_child_receipt: true
      local_run_state_excluded: true
      proof_refs:
        - .octon/state/evidence/validation/analysis/lifecycle-fixture-review-gate.log
        - .octon/state/evidence/validation/analysis/lifecycle-fixture-child-readiness.log
YAML
  fi
  cat >>"$report" <<YAML
    boundaries:
      include_paths:
        - .octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/
        - .octon/inputs/exploratory/proposals/.archive/architecture/token-efficiency-token-measurement-ledger/
        - .octon/generated/effective/runtime/
        - .octon/generated/proposals/
        - .octon/state/control/extensions/active.yml
        - .octon/state/evidence/validation/publication/runtime/
      exclude_paths:
        - .octon/state/control/execution/
        - .octon/state/continuity/
iterations:
  - iteration_id: iteration-001
    pre_inventory_ref: evidence://worktree/inventory-001
    pre_classification_ref: evidence://worktree/classification-001
    selected_candidate_id: candidate-lifecycle
    include_paths:
      - .octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/
      - .octon/inputs/exploratory/proposals/.archive/architecture/token-efficiency-token-measurement-ledger/
      - .octon/generated/effective/runtime/
      - .octon/generated/proposals/
      - .octon/state/control/extensions/active.yml
      - .octon/state/evidence/validation/publication/runtime/
    exclude_paths:
      - .octon/state/control/execution/
      - .octon/state/continuity/
    closeout_change_ref: evidence://runs/skills/closeout-change/$receipt_suffix
    closeout_change_outcome: closed
    post_inventory_ref: evidence://worktree/inventory-002
    post_classification_ref: evidence://worktree/classification-002
    next_selection_reason: no remaining closeout-worktree candidates after re-inventory
final_candidate_dispositions:
  candidate-lifecycle:
    state: closed
    closeout_change_ref: evidence://runs/skills/closeout-change/$receipt_suffix
retained_residue: []
blockers: []
final_inventory_ref: evidence://worktree/final
final_residue_classes:
  staged: 0
  unstaged_tracked: 0
  untracked: 0
  ignored: 0
  generated_effective_output: 0
  host_projection: 0
  retained_evidence: 0
  state_control: 0
  release_version: 0
  input_surface: 0
worktree_terminal_state: git_clean_terminal
next_route_condition: none
YAML
}

case_lifecycle_publishable_change_with_authority_passes() {
  local report
  report="$(new_report)"
  write_lifecycle_publishable_report "$report" yes
  run_validator_with_fixtures "$report" >/dev/null
}

case_lifecycle_publishable_change_without_authority_fails() {
  local report
  report="$(new_report)"
  write_lifecycle_publishable_report "$report" no
  ! run_validator_with_fixtures "$report" >/dev/null
}

main() {
  assert_success "static closeout-worktree registration and projection pass" case_static_validator_passes
  assert_success "valid multi-candidate wrapper orchestration report passes" case_valid_multi_candidate_report_passes
  assert_success "lifecycle publishable candidate with authority passes" case_lifecycle_publishable_change_with_authority_passes
  assert_success "lifecycle publishable candidate without authority fails" case_lifecycle_publishable_change_without_authority_fails
  assert_success "repo-hygiene delegated cleanup report passes" case_repo_hygiene_delegated_cleanup_report_passes
  assert_success "git-clean terminal report after evidence-retention candidate passes" case_git_clean_terminal_after_evidence_retention_candidate_passes
  assert_success "disposition-complete retained residue report passes" case_disposition_complete_with_retained_residue_passes
  assert_success "git-clean terminal with retained evidence fails" case_git_clean_terminal_with_retained_evidence_fails
  assert_success "retained terminal report missing worktree terminal state fails" case_retained_terminal_missing_worktree_terminal_state_fails
  assert_success "repo-hygiene delegated retained report passes" case_repo_hygiene_delegated_retained_report_passes
  assert_success "unresolved repo-hygiene residue blocks git-clean terminal state" case_repo_hygiene_unresolved_blocks_git_clean_fails
  assert_success "repo-hygiene cleanup action from wrapper fails" case_repo_hygiene_cleanup_actions_performed_fails
  assert_success "repo-hygiene cleanup ref must resolve" case_repo_hygiene_cleanup_ref_must_resolve_fails
  assert_success "first candidate closes and second candidate blocks with evidence" case_first_close_then_second_blocked_passes
  assert_success "multiple change sets batched into one candidate fail" case_multiple_sets_batched_into_one_candidate_fails
  assert_success "selected candidate without explicit boundaries fails" case_selected_candidate_without_boundaries_fails
  assert_success "selected candidate without closeout-change delegation fails" case_selected_candidate_without_closeout_change_ref_fails
  assert_success "selected candidate without delegation or blocker fails" case_selected_candidate_without_delegation_or_blocker_fails
  assert_success "selected candidate blocked only by multiple candidates fails" case_selected_candidate_blocked_only_by_multiple_candidates_fails
  assert_success "delegated candidate missing post-inventory fails" case_delegated_candidate_missing_post_inventory_fails
  assert_success "closed candidate missing closeout-change ref fails" case_closed_candidate_missing_closeout_change_ref_fails
  assert_success "terminal report with unprocessed candidate fails" case_terminal_report_with_unprocessed_candidate_fails
  assert_success "direct material action from wrapper fails" case_direct_material_action_from_wrapper_fails
  assert_success "duplicate candidate path fails" case_duplicate_candidate_path_fails
  assert_success "retained candidate without retained residue evidence fails" case_retained_candidate_without_retained_residue_fails
  assert_success "ambiguous candidate without blocker evidence fails" case_ambiguous_candidate_without_blocker_fails
  assert_success "unresolved candidate with terminal next route fails" case_unresolved_candidate_with_terminal_next_route_fails
  assert_success "synthetic closeout-change ref for closed candidate fails" case_synthetic_closeout_change_ref_fails
  assert_success "closed candidate with continued closeout-change receipt fails" case_closed_candidate_with_continued_receipt_fails
  assert_success "closed candidate with cleaned deferred cleanup fails" case_closed_candidate_with_cleaned_deferred_cleanup_fails
  assert_success "git-clean terminal with landed deferred cleanup fails" case_git_clean_terminal_with_landed_deferred_cleanup_fails
  assert_success "closed stage-only receipt fails" case_closed_stage_only_receipt_fails
  assert_success "closed branch-no-pr receipt missing landing authorization fails" case_closed_branch_no_pr_missing_landing_authorization_fails
  assert_success "closed branch-no-pr receipt missing exact-SHA hosted check refs fails" case_closed_branch_no_pr_missing_exact_sha_check_refs_fails
  assert_success "nonterminal report without unresolved condition fails" case_nonterminal_without_unresolved_condition_fails
  assert_success "nonterminal report with unknown-candidate blocker fails" case_nonterminal_with_unknown_candidate_blocker_fails
  assert_success "retained terminal without retained candidate evidence fails" case_retained_terminal_without_retained_candidate_fails
  assert_success "retained ordinary untracked residue terminal claim fails" case_retained_ordinary_untracked_residue_terminal_fails
  assert_success "raw state cannot be publishable closeout evidence" case_raw_state_as_publishable_closeout_evidence_fails
  assert_success "engine path cannot be publishable closeout evidence" case_engine_path_as_publishable_closeout_evidence_fails
  assert_success "recursive final evidence publication loop fails" case_recursive_final_evidence_publication_loop_fails
  assert_success "closeout-worktree run log cannot be publishable evidence" case_closeout_worktree_run_log_as_publishable_evidence_fails
  assert_success "prior candidate omitted without reconciliation fails" case_prior_candidate_without_reconciliation_fails
  assert_success "ignored residue without foreign retained evidence fails" case_ignored_residue_without_foreign_coverage_fails
  assert_success "classifier detects staged unstaged and untracked residue" case_classifier_counts_multi_residue_classes
  assert_success "classifier detects routing classes" case_classifier_counts_routing_classes
  assert_success "classifier counts ignored unsafe routing classes" case_classifier_counts_ignored_unsafe_routing_classes
  assert_success "replay multi-candidate loop validates real re-inventory" case_replay_multi_candidate_loop_passes
  assert_success "replay missing post-closeout inventory fails" case_replay_skips_reinventory_fails
  assert_success "replay terminal report with unprocessed candidate fails" case_replay_terminal_with_unprocessed_candidate_fails
  assert_success "replay synthetic closeout-change ref fails" case_replay_synthetic_closeout_ref_fails
  assert_success "replay ignored residue without retained coverage fails" case_replay_ignored_residue_without_coverage_fails
  assert_success "classifier accepts linked detached worktree roots" case_classifier_accepts_linked_detached_worktree

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
