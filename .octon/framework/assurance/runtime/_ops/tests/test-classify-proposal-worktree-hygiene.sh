#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
CLASSIFIER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh"

pass_count=0
fail_count=0
cleanup_dirs=()
cleanup_files=()

cleanup() {
  set +u
  local dir
  for dir in "${cleanup_dirs[@]}"; do
    case "$dir" in
      "${TMPDIR:-/tmp}"/proposal-worktree-hygiene.*)
        [[ -d "$dir" ]] && rm -r -- "$dir"
        ;;
      *)
        echo "refusing to remove unexpected cleanup path: $dir" >&2
        ;;
    esac
  done
  local file
  for file in "${cleanup_files[@]}"; do
    case "$file" in
      "${TMPDIR:-/tmp}"/proposal-worktree-hygiene-output.*)
        [[ -f "$file" ]] && rm -f -- "$file"
        ;;
      *)
        echo "refusing to remove unexpected cleanup file: $file" >&2
        ;;
    esac
  done
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

assert_contains() {
  local file="$1"
  local pattern="$2"
  grep -Fq -- "$pattern" "$file"
}

new_fixture_repo() {
  local root target
  root="$(mktemp -d "${TMPDIR:-/tmp}/proposal-worktree-hygiene.XXXXXX")"
  cleanup_dirs+=("$root")
  target=".octon/inputs/exploratory/proposals/architecture/fixture-packet"
  mkdir -p "$root/.octon/framework/assurance/runtime/_ops/scripts"
  mkdir -p "$root/$target/support" "$root/$target/resources"
  mkdir -p \
    "$root/.octon/generated/effective/capabilities" \
    "$root/.octon/generated/effective/extensions" \
    "$root/.octon/generated/effective/extensions/published/fixture-pack/bundled-first-party/skills/fixture-projection-skill"
  cp "$CLASSIFIER" "$root/.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh"
  cat >"$root/$target/proposal.yml" <<'YAML'
schema_version: "proposal-v1"
proposal_id: "fixture-packet"
title: "Fixture packet"
summary: "Fixture packet."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/example.md"
status: "implemented"
related_proposals: []
YAML
  cat >"$root/$target/resources/child-packet-index.yml" <<'YAML'
schema_version: "octon-proposal-program-child-registry-v2"
execution_mode: "gated-parallel"
default_child_lifecycle_id: "proposal-packet"
children:
  - child_id: "fixture-child"
    path: ".octon/inputs/exploratory/proposals/architecture/fixture-child"
    required: true
    deferred: false
    dependencies: []
    write_scopes:
      - ".octon/framework/child-scope.md"
YAML
  mkdir -p "$root/.octon/inputs/exploratory/proposals/architecture/fixture-child"
  cat >"$root/.octon/inputs/exploratory/proposals/architecture/fixture-child/proposal.yml" <<'YAML'
schema_version: "proposal-v1"
proposal_id: "fixture-child"
title: "Fixture child"
summary: "Fixture child."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/child-target.md"
status: "implemented"
related_proposals: []
YAML
  mkdir -p "$root/.octon/framework"
  printf 'baseline\n' >"$root/.octon/framework/example.md"
  printf 'baseline\n' >"$root/.octon/framework/child-scope.md"
  printf 'baseline\n' >"$root/.octon/framework/child-target.md"
  printf 'baseline\n' >"$root/unrelated.md"
  cat >"$root/.octon/generated/effective/capabilities/routing.effective.yml" <<'YAML'
routing_candidates:
  - effective_id: "extension.skill.fixture-pack.fixture-projection-skill"
    status: "active"
    capability_kind: "skill"
    capability_id: "fixture-projection-skill"
    host_adapters:
      - "codex"
YAML
  cat >"$root/.octon/generated/effective/capabilities/artifact-map.yml" <<'YAML'
artifacts:
  - effective_id: "extension.skill.fixture-pack.fixture-projection-skill"
    source_kind: "extension-export"
    extension_pack_id: "fixture-pack"
    extension_source_id: "bundled-first-party"
    capability_id: "fixture-projection-skill"
YAML
  cat >"$root/.octon/generated/effective/extensions/catalog.effective.yml" <<'YAML'
packs:
  - pack_id: "fixture-pack"
    source_id: "bundled-first-party"
    routing_exports:
      commands: []
      skills:
        - capability_id: "fixture-projection-skill"
          projection_source_path: ".octon/generated/effective/extensions/published/fixture-pack/bundled-first-party/skills/fixture-projection-skill"
YAML
  cat >"$root/.octon/generated/effective/extensions/published/fixture-pack/bundled-first-party/skills/fixture-projection-skill/SKILL.md" <<'MARKDOWN'
---
name: fixture-projection-skill
description: Fixture projection skill.
---

# Fixture Projection Skill
MARKDOWN
  git -C "$root" init -q
  git -C "$root" config user.email "octon-test@example.invalid"
  git -C "$root" config user.name "Octon Test"
  git -C "$root" add .
  git -C "$root" commit -qm baseline
  printf '%s\n' "$root"
}

new_output_file() {
  local file
  file="$(mktemp "${TMPDIR:-/tmp}/proposal-worktree-hygiene-output.XXXXXX")"
  cleanup_files+=("$file")
  printf '%s\n' "$file"
}

run_classifier_for_target() {
  local root="$1"
  local lifecycle="$2"
  local output="$3"
  local target="$4"
  OCTON_ROOT_DIR="$root" bash "$root/.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh" \
    --target "$target" \
    --lifecycle "$lifecycle" \
    --run-id "run-1" \
    --format yaml >"$output"
}

run_classifier() {
  run_classifier_for_target \
    "$1" \
    "$2" \
    "$3" \
    ".octon/inputs/exploratory/proposals/architecture/fixture-packet"
}

case_owned_run_paths_do_not_block() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  mkdir -p "$root/.octon/state/control/execution/runs/run-1" "$root/.octon/state/evidence/runs/workflows/run-1"
  printf 'checkpoint\n' >"$root/.octon/state/control/execution/runs/run-1/checkpoint.yml"
  printf 'summary\n' >"$root/.octon/state/evidence/runs/workflows/run-1/summary.md"
  run_classifier "$root" proposal-packet "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_owned_path_count: 2" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_declared_in_scope_paths_do_not_block() {
  local root output target
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  target="$root/.octon/inputs/exploratory/proposals/architecture/fixture-packet"
  printf 'closeout\n' >"$target/support/proposal-closeout.md"
  printf 'changed\n' >"$root/.octon/framework/example.md"
  run_classifier "$root" proposal-packet "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_in_scope_path_count: 2" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_unrelated_tracked_path_blocks() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  printf 'changed\n' >"$root/unrelated.md"
  run_classifier "$root" proposal-packet "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "blocked"' &&
    assert_contains "$output" 'worktree_hygiene_blocker_class: "worktree-hygiene-blocked"' &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 1"
}

case_unrelated_untracked_path_blocks() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  printf 'scratch\n' >"$root/scratch.tmp"
  run_classifier "$root" proposal-packet "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "blocked"' &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 1"
}

case_mixed_paths_count_all_buckets() {
  local root output target
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  target="$root/.octon/inputs/exploratory/proposals/architecture/fixture-packet"
  mkdir -p "$root/.octon/state/control/execution/runs/run-1"
  printf 'checkpoint\n' >"$root/.octon/state/control/execution/runs/run-1/checkpoint.yml"
  printf 'closeout\n' >"$target/support/proposal-closeout.md"
  printf 'scratch\n' >"$root/scratch.tmp"
  run_classifier "$root" proposal-packet "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "blocked"' &&
    assert_contains "$output" "worktree_hygiene_owned_path_count: 1" &&
    assert_contains "$output" "worktree_hygiene_in_scope_path_count: 1" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 1"
}

case_program_child_scope_is_in_scope() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  printf 'changed\n' >"$root/.octon/framework/child-scope.md"
  printf 'changed\n' >"$root/.octon/framework/child-target.md"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_in_scope_path_count: 2" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_program_child_archived_manifest_scope_is_in_scope() {
  local root output archive_dir
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  git -C "$root" rm -qr .octon/inputs/exploratory/proposals/architecture/fixture-child
  archive_dir="$root/.octon/inputs/exploratory/proposals/.archive/architecture/fixture-child"
  mkdir -p "$archive_dir" "$root/.octon/framework"
  cat >"$archive_dir/proposal.yml" <<'YAML'
schema_version: "proposal-v1"
proposal_id: "fixture-child"
title: "Fixture child"
summary: "Fixture child."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/archived-child-target.md"
status: "archived"
archive:
  archived_at: "2026-06-03"
  archived_from_status: "implemented"
  disposition: "implemented"
  original_path: ".octon/inputs/exploratory/proposals/architecture/fixture-child"
  promotion_evidence:
    - ".octon/framework/archived-child-target.md"
related_proposals: []
YAML
  printf 'baseline\n' >"$root/.octon/framework/archived-child-target.md"
  git -C "$root" add .
  git -C "$root" commit -qm archived-child-baseline
  printf 'changed\n' >"$root/.octon/framework/archived-child-target.md"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_in_scope_path_count: 1" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_program_checkpoint_scope_applies_to_child_target() {
  local root output run_dir
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  run_dir="$root/.octon/state/control/execution/runs/run-1"
  mkdir -p "$run_dir"
  cat >"$run_dir/program-lifecycle-checkpoint.yml" <<'YAML'
target: ".octon/inputs/exploratory/proposals/architecture/fixture-packet"
YAML
  printf 'changed\n' >"$root/.octon/framework/child-scope.md"
  printf 'changed\n' >"$root/.octon/framework/child-target.md"
  run_classifier_for_target \
    "$root" \
    proposal-program \
    "$output" \
    ".octon/inputs/exploratory/proposals/architecture/fixture-child"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_in_scope_path_count: 2" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_program_checkpoint_scope_applies_to_archived_child_target() {
  local root output run_dir archive_dir
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  run_dir="$root/.octon/state/control/execution/runs/run-1"
  mkdir -p "$run_dir"
  cat >"$run_dir/program-lifecycle-checkpoint.yml" <<'YAML'
target: ".octon/inputs/exploratory/proposals/architecture/fixture-packet"
YAML
  git -C "$root" rm -qr .octon/inputs/exploratory/proposals/architecture/fixture-child
  archive_dir="$root/.octon/inputs/exploratory/proposals/.archive/architecture/fixture-child"
  mkdir -p "$archive_dir"
  cat >"$archive_dir/proposal.yml" <<'YAML'
schema_version: "proposal-v1"
proposal_id: "fixture-child"
title: "Fixture child"
summary: "Fixture child."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/child-target.md"
status: "archived"
archive:
  archived_at: "2026-06-03"
  archived_from_status: "implemented"
  disposition: "implemented"
  original_path: ".octon/inputs/exploratory/proposals/architecture/fixture-child"
  promotion_evidence:
    - ".octon/framework/child-target.md"
related_proposals: []
YAML
  git -C "$root" add .
  git -C "$root" commit -qm archived-child-baseline
  printf 'changed\n' >"$root/.octon/framework/child-scope.md"
  printf 'changed\n' >"$root/.octon/framework/child-target.md"
  run_classifier_for_target \
    "$root" \
    proposal-program \
    "$output" \
    ".octon/inputs/exploratory/proposals/.archive/architecture/fixture-child"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_in_scope_path_count: 2" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_program_checkpoint_scope_applies_to_packet_child_target() {
  local root output run_dir
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  run_dir="$root/.octon/state/control/execution/runs/run-1"
  mkdir -p "$run_dir"
  cat >"$run_dir/program-lifecycle-checkpoint.yml" <<'YAML'
target: ".octon/inputs/exploratory/proposals/architecture/fixture-packet"
YAML
  printf 'changed\n' >"$root/.octon/framework/child-scope.md"
  printf 'changed\n' >"$root/.octon/framework/child-target.md"
  run_classifier_for_target \
    "$root" \
    proposal-packet \
    "$output" \
    ".octon/inputs/exploratory/proposals/architecture/fixture-child"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_in_scope_path_count: 2" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_current_program_run_derived_artifacts_do_not_block() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  mkdir -p \
    "$root/.octon/state/control/execution/runs/run-1-fixture-child-workflow" \
    "$root/.octon/state/continuity/runs/run-1-fixture-child-workflow" \
    "$root/.octon/state/evidence/control/execution" \
    "$root/.octon/state/evidence/external-index/runs"
  printf 'events\n' >"$root/.octon/state/control/execution/runs/run-1-fixture-child-workflow/events.ndjson"
  printf 'handoff\n' >"$root/.octon/state/continuity/runs/run-1-fixture-child-workflow/handoff.yml"
  printf 'decision\n' >"$root/.octon/state/evidence/control/execution/authority-decision-run-1-fixture-child-workflow.yml"
  printf 'index\n' >"$root/.octon/state/evidence/external-index/runs/run-1-fixture-child-workflow.yml"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_owned_path_count: 4" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_current_program_run_closeout_packet_evidence_does_not_block() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  mkdir -p "$root/.octon/state/evidence/runs/skills/closeout-packet/run-1-fixture-child"
  printf 'hygiene\n' >"$root/.octon/state/evidence/runs/skills/closeout-packet/run-1-fixture-child/worktree-hygiene.yml"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_owned_path_count: 1" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_current_program_run_lifecycle_closeout_packet_evidence_does_not_block() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  mkdir -p "$root/.octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/run-1-fixture-child"
  printf 'hygiene\n' >"$root/.octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/run-1-fixture-child/worktree-hygiene.yml"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_owned_path_count: 1" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_target_lifecycle_closeout_packet_evidence_does_not_block() {
  local root output evidence_dir
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  evidence_dir="$root/.octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/fixture-packet/20260604T000000Z"
  mkdir -p "$evidence_dir"
  printf 'hygiene\n' >"$evidence_dir/worktree-hygiene.yml"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_owned_path_count: 1" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_other_lifecycle_closeout_packet_evidence_still_blocks() {
  local root output evidence_dir
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  evidence_dir="$root/.octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/other-packet/20260604T000000Z"
  mkdir -p "$evidence_dir"
  printf 'hygiene\n' >"$evidence_dir/worktree-hygiene.yml"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "blocked"' &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 1"
}

case_current_program_run_repo_hygiene_cleanup_evidence_does_not_block() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  mkdir -p "$root/.octon/state/evidence/runs/skills/repo-hygiene-cleanup/run-1"
  printf 'cleanup\n' >"$root/.octon/state/evidence/runs/skills/repo-hygiene-cleanup/run-1/summary.yml"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_owned_path_count: 1" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_same_scope_repo_hygiene_cleanup_receipts_without_checkpoint_do_not_block() {
  local root output evidence_dir
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  evidence_dir="$root/.octon/state/evidence/runs/skills/repo-hygiene-cleanup/lifecycle-proposal-program-1234-abcd-cleanup-lifecycle-residue-20260610T000000Z"
  mkdir -p "$evidence_dir"
  cat >"$evidence_dir/receipt.yml" <<'YAML'
schema_version: repo-hygiene-cleanup-publishable-receipt-v1
run_id: lifecycle-proposal-program-1234-abcd-cleanup-lifecycle-residue-20260610T000000Z
parent_run_id: lifecycle-proposal-program-1234-abcd
delegated_from_route: cleanup-lifecycle-residue
target: .octon/inputs/exploratory/proposals/architecture/fixture-packet
cleanup_outcome: deleted_authorized_cleanup_candidates
YAML
  cat >"$evidence_dir/cleanup-authorization.json" <<'JSON'
{"authorization_result":"approved","authorized_paths":[]}
JSON
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_owned_path_count: 2" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_same_scope_repo_hygiene_cleanup_receipts_with_parent_run_checkpoint_do_not_block() {
  local root output evidence_dir run_dir
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  run_dir="$root/.octon/state/control/execution/runs/lifecycle-proposal-program-1234-abcd"
  mkdir -p "$run_dir"
  cat >"$run_dir/program-lifecycle-checkpoint.yml" <<'YAML'
target: ".octon/inputs/exploratory/proposals/architecture/fixture-packet"
YAML
  evidence_dir="$root/.octon/state/evidence/runs/skills/repo-hygiene-cleanup/lifecycle-proposal-program-1234-abcd-cleanup-lifecycle-residue-20260610T000000Z"
  mkdir -p "$evidence_dir"
  cat >"$evidence_dir/receipt.yml" <<'YAML'
schema_version: repo-hygiene-cleanup-summary-v1
run_id: lifecycle-proposal-program-1234-abcd-cleanup-lifecycle-residue-20260610T000000Z
parent_run_id: lifecycle-proposal-program-1234-abcd
route_id: cleanup-lifecycle-residue
deleted_count: 0
blocker: none
YAML
  cat >"$evidence_dir/cleanup-authorization.json" <<'JSON'
{"authorization_result":"approved","authorized_paths":[]}
JSON
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_owned_path_count: 3" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_same_scope_repo_hygiene_cleanup_receipts_with_retained_workflow_checkpoint_do_not_block() {
  local root output evidence_dir workflow_dir
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  workflow_dir="$root/.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1234-abcd"
  mkdir -p "$workflow_dir"
  cat >"$workflow_dir/program-lifecycle-checkpoint.yml" <<'YAML'
target: ".octon/inputs/exploratory/proposals/architecture/fixture-packet"
YAML
  evidence_dir="$root/.octon/state/evidence/runs/skills/repo-hygiene-cleanup/lifecycle-proposal-program-1234-abcd-cleanup-lifecycle-residue-20260610T000000Z"
  mkdir -p "$evidence_dir"
  cat >"$evidence_dir/receipt.yml" <<'YAML'
schema_version: repo-hygiene-cleanup-receipt-v1
run_id: lifecycle-proposal-program-1234-abcd
parent_route: cleanup-lifecycle-residue
deleted_count: 0
blocker: none
YAML
  cat >"$evidence_dir/cleanup-authorization.json" <<'JSON'
{"authorization_result":"approved","authorized_paths":[]}
JSON
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_owned_path_count: 3" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_same_scope_lifecycle_runs_do_not_block() {
  local root output run_dir
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  run_dir="$root/.octon/state/control/execution/runs/lifecycle-proposal-program-1234-abcd"
  mkdir -p "$run_dir"
  cat >"$run_dir/program-lifecycle-checkpoint.yml" <<'YAML'
target: ".octon/inputs/exploratory/proposals/architecture/fixture-packet"
YAML
  printf 'events\n' >"$run_dir/program-events.ndjson"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_owned_path_count: 2" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_same_scope_lifecycle_evidence_runs_do_not_block() {
  local root output run_dir run_id
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  run_id="lifecycle-proposal-program-1234-abcd"
  run_dir="$root/.octon/state/control/execution/runs/$run_id"
  mkdir -p \
    "$run_dir" \
    "$root/.octon/state/continuity/runs/$run_id-child-attempt" \
    "$root/.octon/state/evidence/control/execution" \
    "$root/.octon/state/evidence/runs/workflows/$run_id/parent" \
    "$root/.octon/state/evidence/external-index/runs" \
    "$root/.octon/state/evidence/runs/skills/closeout-packet/$run_id-child"
  cat >"$run_dir/program-lifecycle-checkpoint.yml" <<'YAML'
target: ".octon/inputs/exploratory/proposals/architecture/fixture-packet"
YAML
  printf 'handoff\n' >"$root/.octon/state/continuity/runs/$run_id-child-attempt/handoff.yml"
  printf 'decision\n' >"$root/.octon/state/evidence/control/execution/authority-decision-$run_id-child-attempt.yml"
  printf 'grant\n' >"$root/.octon/state/evidence/control/execution/authority-grant-bundle-$run_id-child-attempt.yml"
  printf 'summary\n' >"$root/.octon/state/evidence/runs/workflows/$run_id/parent/summary.yml"
  printf 'index\n' >"$root/.octon/state/evidence/external-index/runs/$run_id-child-attempt.yml"
  printf 'hygiene\n' >"$root/.octon/state/evidence/runs/skills/closeout-packet/$run_id-child/worktree-hygiene.yml"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_owned_path_count: 7" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_same_program_lifecycle_artifacts_do_not_block_packet_child_target() {
  local root output run_dir prior_run_id prior_run_dir
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  run_dir="$root/.octon/state/control/execution/runs/run-1"
  prior_run_id="lifecycle-proposal-program-1234-abcd"
  prior_run_dir="$root/.octon/state/control/execution/runs/$prior_run_id"
  mkdir -p "$run_dir" "$prior_run_dir"
  cat >"$run_dir/program-lifecycle-checkpoint.yml" <<'YAML'
target: ".octon/inputs/exploratory/proposals/architecture/fixture-packet"
YAML
  cat >"$prior_run_dir/program-lifecycle-checkpoint.yml" <<'YAML'
target: ".octon/inputs/exploratory/proposals/architecture/fixture-packet"
YAML
  printf 'events\n' >"$prior_run_dir/program-events.ndjson"
  run_classifier_for_target \
    "$root" \
    proposal-packet \
    "$output" \
    ".octon/inputs/exploratory/proposals/architecture/fixture-child"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_program_generated_projection_scope_does_not_block() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  mkdir -p \
    "$root/.octon/generated/effective/extensions" \
    "$root/.octon/generated/proposals" \
    "$root/.octon/state/control/extensions" \
    "$root/.octon/state/evidence/decisions/repo/capabilities"
  printf 'catalog\n' >"$root/.octon/generated/effective/extensions/catalog.effective.yml"
  printf 'registry\n' >"$root/.octon/generated/proposals/registry.yml"
  printf 'active\n' >"$root/.octon/state/control/extensions/active.yml"
  printf 'decision\n' >"$root/.octon/state/evidence/decisions/repo/capabilities/acp-decisions.jsonl"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_in_scope_path_count: 4" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_program_generated_projection_scope_applies_to_packet_child_target() {
  local root output run_dir
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  run_dir="$root/.octon/state/control/execution/runs/run-1"
  mkdir -p \
    "$run_dir" \
    "$root/.octon/generated/effective/extensions" \
    "$root/.octon/generated/proposals" \
    "$root/.octon/state/control/extensions" \
    "$root/.octon/state/evidence/decisions/repo/capabilities"
  cat >"$run_dir/program-lifecycle-checkpoint.yml" <<'YAML'
target: ".octon/inputs/exploratory/proposals/architecture/fixture-packet"
YAML
  printf 'catalog\n' >"$root/.octon/generated/effective/extensions/catalog.effective.yml"
  printf 'registry\n' >"$root/.octon/generated/proposals/registry.yml"
  printf 'active\n' >"$root/.octon/state/control/extensions/active.yml"
  printf 'decision\n' >"$root/.octon/state/evidence/decisions/repo/capabilities/acp-decisions.jsonl"
  run_classifier_for_target \
    "$root" \
    proposal-packet \
    "$output" \
    ".octon/inputs/exploratory/proposals/architecture/fixture-child"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_program_retained_evidence_scope_does_not_block() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  mkdir -p \
    "$root/.octon/state/evidence/runs/skills/closeout-change/fixture-change" \
    "$root/.octon/state/evidence/validation/publication/extensions"
  printf 'receipt\n' >"$root/.octon/state/evidence/runs/skills/closeout-change/fixture-change/change-receipt.json"
  printf 'validation\n' >"$root/.octon/state/evidence/validation/publication/extensions/fixture.yml"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_in_scope_path_count: 2" &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0"
}

case_program_host_projection_mirror_does_not_block() {
  local root output projected_skill
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  projected_skill="$root/.codex/skills/fixture-projection-skill"
  mkdir -p "$projected_skill"
  cp \
    "$root/.octon/generated/effective/extensions/published/fixture-pack/bundled-first-party/skills/fixture-projection-skill/SKILL.md" \
    "$projected_skill/SKILL.md"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0" &&
    assert_contains "$output" 'path: ".codex/skills/fixture-projection-skill/SKILL.md"'
}

case_program_host_projection_drift_blocks() {
  local root output projected_skill
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  projected_skill="$root/.codex/skills/fixture-projection-skill"
  mkdir -p "$projected_skill"
  printf 'drifted\n' >"$projected_skill/SKILL.md"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "blocked"' &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 1" &&
    assert_contains "$output" 'path: ".codex/skills/fixture-projection-skill/SKILL.md"'
}

case_local_os_metadata_does_not_block() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  mkdir -p "$root/.octon/inputs/exploratory/proposals/fixture-local"
  printf 'metadata\n' >"$root/.octon/inputs/exploratory/proposals/fixture-local/.DS_Store"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "pass"' &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 0" &&
    assert_contains "$output" 'path: ".octon/inputs/exploratory/proposals/fixture-local/.DS_Store"'
}

case_untracked_raw_input_file_still_blocks() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  printf 'draft\n' >"$root/.octon/inputs/exploratory/proposals/scratch.md"
  run_classifier "$root" proposal-program "$output"
  assert_contains "$output" 'worktree_hygiene_verdict: "blocked"' &&
    assert_contains "$output" "worktree_hygiene_foreign_path_count: 1" &&
    assert_contains "$output" 'path: ".octon/inputs/exploratory/proposals/scratch.md"'
}

main() {
  assert_success "owned current-run control and evidence paths do not block" case_owned_run_paths_do_not_block
  assert_success "target support and promotion targets are in scope" case_declared_in_scope_paths_do_not_block
  assert_success "unrelated tracked dirty file blocks" case_unrelated_tracked_path_blocks
  assert_success "unrelated untracked file blocks" case_unrelated_untracked_path_blocks
  assert_success "mixed paths produce accurate bucket counts" case_mixed_paths_count_all_buckets
  assert_success "program child write scopes and promotion targets are in scope" case_program_child_scope_is_in_scope
  assert_success "program archived child promotion targets are in scope" case_program_child_archived_manifest_scope_is_in_scope
  assert_success "program checkpoint scope applies to child target" case_program_checkpoint_scope_applies_to_child_target
  assert_success "program checkpoint scope applies to archived child target" case_program_checkpoint_scope_applies_to_archived_child_target
  assert_success "program checkpoint scope applies to packet child target" case_program_checkpoint_scope_applies_to_packet_child_target
  assert_success "current program run-derived artifacts do not block" case_current_program_run_derived_artifacts_do_not_block
  assert_success "current program run closeout-packet evidence does not block" case_current_program_run_closeout_packet_evidence_does_not_block
  assert_success "current program run lifecycle closeout-packet evidence does not block" case_current_program_run_lifecycle_closeout_packet_evidence_does_not_block
  assert_success "target lifecycle closeout-packet evidence does not block" case_target_lifecycle_closeout_packet_evidence_does_not_block
  assert_success "other lifecycle closeout-packet evidence still blocks" case_other_lifecycle_closeout_packet_evidence_still_blocks
  assert_success "current program run repo-hygiene cleanup evidence does not block" case_current_program_run_repo_hygiene_cleanup_evidence_does_not_block
  assert_success "same-scope repo-hygiene cleanup receipts without checkpoint do not block" case_same_scope_repo_hygiene_cleanup_receipts_without_checkpoint_do_not_block
  assert_success "same-scope repo-hygiene cleanup receipts with parent run checkpoint do not block" case_same_scope_repo_hygiene_cleanup_receipts_with_parent_run_checkpoint_do_not_block
  assert_success "same-scope repo-hygiene cleanup receipts with retained workflow checkpoint do not block" case_same_scope_repo_hygiene_cleanup_receipts_with_retained_workflow_checkpoint_do_not_block
  assert_success "same-scope lifecycle run artifacts do not block" case_same_scope_lifecycle_runs_do_not_block
  assert_success "same-scope lifecycle evidence artifacts do not block" case_same_scope_lifecycle_evidence_runs_do_not_block
  assert_success "same program lifecycle artifacts do not block packet child target" case_same_program_lifecycle_artifacts_do_not_block_packet_child_target
  assert_success "program generated projections do not block" case_program_generated_projection_scope_does_not_block
  assert_success "program generated projection scope applies to packet child target" case_program_generated_projection_scope_applies_to_packet_child_target
  assert_success "program retained evidence does not block" case_program_retained_evidence_scope_does_not_block
  assert_success "program host projection mirrors do not block" case_program_host_projection_mirror_does_not_block
  assert_success "program host projection drift still blocks" case_program_host_projection_drift_blocks
  assert_success "local OS metadata does not block" case_local_os_metadata_does_not_block
  assert_success "untracked raw input files still block" case_untracked_raw_input_file_still_blocks

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
