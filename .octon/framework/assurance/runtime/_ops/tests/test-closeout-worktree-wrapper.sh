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
  ensure_fixture_root
  mkdir -p "$(dirname "$fixture_root/.octon/state/evidence/runs/skills/closeout-change/$suffix")"
  cat >"$fixture_root/.octon/state/evidence/runs/skills/closeout-change/$suffix" <<JSON
{
  "schema_version": "change-receipt-v1",
  "change_id": "fixture-${suffix//\//-}",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "landed",
  "lifecycle_outcome": "landed",
  "outcome_intent": "attempt-landing",
  "intent": "fixture completed branch closeout",
  "scope": {"summary": "fixture"},
  "source_branch_ref": "fixture/source",
  "target_branch_ref": "origin/main@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "remote_branch_ref": "origin/fixture/source@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
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
  "cleanup_status": "deferred",
  "cleanup_evidence_refs": ["fixture cleanup deferred with blocker evidence"],
  "source_branch_cleanup": {
    "status": "deferred",
    "local_branch": "fixture/source",
    "remote_branch": "origin/fixture/source",
    "blocker_reason": "fixture keeps source branch for review",
    "evidence_refs": ["fixture cleanup deferred with blocker evidence"]
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

run_validator_with_fixtures() {
  CLOSEOUT_WORKTREE_EVIDENCE_ROOT="$fixture_root" bash "$VALIDATOR" --report "$1"
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
        - docs/closeout-checklist.md
      exclude_paths:
        - src/runtime/kernel.rs
        - .octon/generated/effective/capabilities/routing.effective.yml
  - candidate_id: candidate-runtime
    disposition: delegated
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
  ignored: 0
next_route_condition: none
YAML
  run_validator_with_fixtures "$report" >/dev/null
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
      exclude_paths:
        - src/runtime/kernel.rs
  - candidate_id: candidate-runtime
    disposition: blocked
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
    grep -A1 'class: untracked' <<<"$output" | grep -Fq 'count: 1'
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
    closeout_change_ref: evidence://runs/skills/closeout-change/replay-docs-candidate/change-receipt.json
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

main() {
  assert_success "static closeout-worktree registration and projection pass" case_static_validator_passes
  assert_success "valid multi-candidate wrapper orchestration report passes" case_valid_multi_candidate_report_passes
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
  assert_success "prior candidate omitted without reconciliation fails" case_prior_candidate_without_reconciliation_fails
  assert_success "ignored residue without foreign retained evidence fails" case_ignored_residue_without_foreign_coverage_fails
  assert_success "classifier detects staged unstaged and untracked residue" case_classifier_counts_multi_residue_classes
  assert_success "replay multi-candidate loop validates real re-inventory" case_replay_multi_candidate_loop_passes
  assert_success "replay missing post-closeout inventory fails" case_replay_skips_reinventory_fails
  assert_success "replay terminal report with unprocessed candidate fails" case_replay_terminal_with_unprocessed_candidate_fails
  assert_success "replay synthetic closeout-change ref fails" case_replay_synthetic_closeout_ref_fails
  assert_success "replay ignored residue without retained coverage fails" case_replay_ignored_residue_without_coverage_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
