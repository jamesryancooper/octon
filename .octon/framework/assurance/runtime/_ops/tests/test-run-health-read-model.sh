#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
GENERATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh"
FIXTURE_ROOT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/fixtures/run-health-read-model"
SCHEMA_PATH="$ROOT_DIR/.octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json"
GENERATED_RUN_HEALTH_REF=".octon/generated/cognition/projections/materialized/runs"

pass_count=0
fail_count=0
cleanup_dirs=()

cleanup() {
  local dir
  for dir in "${cleanup_dirs[@]}"; do
    case "$dir" in
      "${TMPDIR:-/tmp}"/run-health-read-model.*)
        [[ -d "$dir" ]] && rm -r -- "$dir"
        ;;
      *)
        echo "refusing to remove unexpected cleanup path: $dir" >&2
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

generated_run_health_status_for_root() {
  local root="$1"
  git -C "$root" status --porcelain -- "$GENERATED_RUN_HEALTH_REF" 2>/dev/null || true
}

assert_generated_run_health_status_unchanged() {
  local before="$1"
  [[ "$(generated_run_health_status_for_root "$ROOT_DIR")" == "$before" ]]
}

create_fixture_repo() {
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/run-health-read-model.XXXXXX")"
  cleanup_dirs+=("$tmp")
  cp -R "$FIXTURE_ROOT" "$tmp/fixtures"
  mkdir -p "$tmp/.octon/framework/engine/runtime/spec"
  mkdir -p "$tmp/.octon/framework/assurance/runtime/_ops/scripts"
  cp "$SCHEMA_PATH" "$tmp/.octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json"
  cp "$GENERATOR" "$tmp/.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh"
  printf '%s\n' "$tmp"
}

fixture_output_root() {
  printf '%s\n' "$1/.octon/generated/cognition/projections/materialized/runs"
}

fixture_evidence_root() {
  printf '%s\n' "$1/.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health"
}

run_fixture_generator() {
  run_fixture_generator_at "$1" "2026-04-24T00:00:00Z"
}

run_fixture_generator_at() {
  local repo_root="$1"
  local generated_at="$2"
  local output_root evidence_root
  output_root="$(fixture_output_root "$repo_root")"
  evidence_root="$(fixture_evidence_root "$repo_root")"
  OCTON_DIR_OVERRIDE="$repo_root/.octon" \
    OCTON_ROOT_DIR="$repo_root" \
    OCTON_RUN_HEALTH_GENERATED_AT="$generated_at" \
    bash "$GENERATOR" \
      --fixtures-root "$repo_root/fixtures" \
      --output-root "$output_root" \
      --evidence-root "$evidence_root" >/dev/null
}

run_fixture_validator() {
  local repo_root="$1"
  local output_root evidence_root
  output_root="$(fixture_output_root "$repo_root")"
  evidence_root="$(fixture_evidence_root "$repo_root")"
  OCTON_DIR_OVERRIDE="$repo_root/.octon" \
    OCTON_ROOT_DIR="$repo_root" \
    bash "$VALIDATOR" \
      --no-live \
      --fixtures-root "$repo_root/fixtures" \
      --fixture-output-root "$output_root" \
      --evidence-root "$evidence_root" >/dev/null
}

stage_live_fixture_run() {
  local repo_root="$1"
  local run_id="$2"
  mkdir -p "$repo_root/.octon/state/control/execution/runs/$run_id"
  cp -R "$repo_root/fixtures/sources/$run_id/control/." "$repo_root/.octon/state/control/execution/runs/$run_id/"
}

stage_live_effective_fixture_outputs() {
  local repo_root="$1"
  mkdir -p "$repo_root/.octon/generated/effective/runtime"
  mkdir -p "$repo_root/.octon/generated/effective/capabilities"
  mkdir -p "$repo_root/.octon/generated/effective/governance"
  cp "$repo_root/fixtures/effective/route-bundle.yml" "$repo_root/.octon/generated/effective/runtime/route-bundle.yml"
  cp "$repo_root/fixtures/effective/pack-routes.effective.yml" "$repo_root/.octon/generated/effective/capabilities/pack-routes.effective.yml"
  cat <<'EOF' >"$repo_root/.octon/generated/effective/governance/support-envelope-reconciliation.yml"
schema_version: support-envelope-reconciliation-result-v1
status: fixture
EOF
}

case_fixture_statuses_validate() {
  local tmp
  tmp="$(create_fixture_repo)"
  run_fixture_generator "$tmp"
  run_fixture_validator "$tmp"
}

case_generation_receipt_includes_published_paths_and_index() {
  local tmp receipt
  tmp="$(create_fixture_repo)"
  run_fixture_generator "$tmp"
  receipt="$(fixture_evidence_root "$tmp")/generation.yml"
  yq -e '.published_paths[] | select(. == ".octon/generated/cognition/projections/materialized/runs/index.yml")' "$receipt" >/dev/null
  yq -e '.published_paths[] | select(. == ".octon/generated/cognition/projections/materialized/runs/healthy/health.yml")' "$receipt" >/dev/null
}

case_generation_receipt_includes_compact_manifest() {
  local tmp receipt compact_ref compact_file
  tmp="$(create_fixture_repo)"
  run_fixture_generator "$tmp"
  receipt="$(fixture_evidence_root "$tmp")/generation.yml"
  compact_ref=".octon/generated/cognition/projections/materialized/runs/run-health-compact-manifest.yml"
  compact_file="$tmp/$compact_ref"
  yq -e ".published_paths[] | select(. == \"$compact_ref\")" "$receipt" >/dev/null
  [[ "$(yq -r '.compact_manifest_ref // ""' "$receipt")" == "$compact_ref" ]]
  yq -e '.compact_manifest_digest | test("^sha256:[0-9a-f]{64}$")' "$receipt" >/dev/null
  yq -e '.schema_version == "run-health-compact-manifest-v1"' "$compact_file" >/dev/null
  yq -e '.consumer.forbidden_consumers[] | select(. == "runtime")' "$compact_file" >/dev/null
  yq -e '.failure_behavior.fail_closed_on[] | select(. == "source-digest-mismatch")' "$compact_file" >/dev/null
  yq -e '.validation.failing_slice_count > 0' "$compact_file" >/dev/null
}

case_non_authority_mutation_fails() {
  local tmp
  tmp="$(create_fixture_repo)"
  run_fixture_generator "$tmp"
  yq -i '.authority.may_authorize = true' "$(fixture_output_root "$tmp")/healthy/health.yml"
  ! run_fixture_validator "$tmp"
}

case_digest_mutation_fails() {
  local tmp
  tmp="$(create_fixture_repo)"
  run_fixture_generator "$tmp"
  local first_key
  first_key="$(yq -r '.source_digests | keys | .[0]' "$(fixture_output_root "$tmp")/healthy/health.yml")"
  first_key="$first_key" yq -i '.source_digests[strenv(first_key)].digest = "sha256:0000000000000000000000000000000000000000000000000000000000000000"' "$(fixture_output_root "$tmp")/healthy/health.yml"
  ! run_fixture_validator "$tmp"
}

case_generation_receipt_invalid_published_paths_fail() {
  local tmp receipt
  tmp="$(create_fixture_repo)"
  run_fixture_generator "$tmp"
  receipt="$(fixture_evidence_root "$tmp")/generation.yml"
  yq -i '.published_paths[0] = "/tmp/not-allowed.yml"' "$receipt"
  ! run_fixture_validator "$tmp"
}

case_compact_manifest_receipt_digest_mutation_fails() {
  local tmp receipt
  tmp="$(create_fixture_repo)"
  run_fixture_generator "$tmp"
  receipt="$(fixture_evidence_root "$tmp")/generation.yml"
  yq -i '.compact_manifest_digest = "sha256:0000000000000000000000000000000000000000000000000000000000000000"' "$receipt"
  ! run_fixture_validator "$tmp"
}

case_compact_manifest_source_digest_mutation_fails() {
  local tmp compact_file
  tmp="$(create_fixture_repo)"
  run_fixture_generator "$tmp"
  compact_file="$(fixture_output_root "$tmp")/run-health-compact-manifest.yml"
  yq -i '.source_digests[0].sha256 = "sha256:0000000000000000000000000000000000000000000000000000000000000000"' "$compact_file"
  ! run_fixture_validator "$tmp"
}

case_noop_generation_keeps_existing_projection_bytes() {
  local tmp output_root evidence_root before
  tmp="$(create_fixture_repo)"
  run_fixture_generator_at "$tmp" "2026-04-24T00:00:00Z"
  output_root="$(fixture_output_root "$tmp")"
  evidence_root="$(fixture_evidence_root "$tmp")"
  before="$tmp/before-noop"
  mkdir -p "$before"
  cp "$output_root/healthy/health.yml" "$before/healthy.health.yml"
  cp "$output_root/index.yml" "$before/index.yml"
  cp "$output_root/run-health-compact-manifest.yml" "$before/run-health-compact-manifest.yml"
  cp "$evidence_root/generation.yml" "$before/generation.yml"

  run_fixture_generator_at "$tmp" "2026-04-25T00:00:00Z"

  cmp "$before/healthy.health.yml" "$output_root/healthy/health.yml" >/dev/null
  cmp "$before/index.yml" "$output_root/index.yml" >/dev/null
  cmp "$before/run-health-compact-manifest.yml" "$output_root/run-health-compact-manifest.yml" >/dev/null
  cmp "$before/generation.yml" "$evidence_root/generation.yml" >/dev/null
}

case_incremental_run_generation_preserves_unrelated_health_projection() {
  local tmp output_root evidence_root before_blocked
  tmp="$(create_fixture_repo)"
  run_fixture_generator_at "$tmp" "2026-04-24T00:00:00Z"
  stage_live_fixture_run "$tmp" "healthy"
  stage_live_fixture_run "$tmp" "blocked"
  stage_live_effective_fixture_outputs "$tmp"
  output_root="$(fixture_output_root "$tmp")"
  evidence_root="$(fixture_evidence_root "$tmp")"

  OCTON_DIR_OVERRIDE="$tmp/.octon" \
    OCTON_ROOT_DIR="$tmp" \
    OCTON_RUN_HEALTH_GENERATED_AT="2026-04-24T00:00:00Z" \
    bash "$GENERATOR" \
      --all-runs \
      --output-root "$output_root" \
      --evidence-root "$evidence_root" >/dev/null

  before_blocked="$tmp/blocked.health.before.yml"
  cp "$output_root/blocked/health.yml" "$before_blocked"
  yq -i '.drift_status = "out-of-sync"' "$tmp/.octon/state/control/execution/runs/healthy/runtime-state.yml"

  OCTON_DIR_OVERRIDE="$tmp/.octon" \
    OCTON_ROOT_DIR="$tmp" \
    OCTON_RUN_HEALTH_GENERATED_AT="2026-04-25T00:00:00Z" \
    bash "$GENERATOR" \
      --run-id healthy \
      --output-root "$output_root" \
      --evidence-root "$evidence_root" >/dev/null

  cmp "$before_blocked" "$output_root/blocked/health.yml" >/dev/null
  yq -e '.runs[] | select(.run_id == "blocked")' "$output_root/index.yml" >/dev/null
  yq -e '.run_health[] | select(.run_id == "blocked")' "$output_root/run-health-compact-manifest.yml" >/dev/null
  OCTON_DIR_OVERRIDE="$tmp/.octon" \
    OCTON_ROOT_DIR="$tmp" \
    bash "$VALIDATOR" \
      --health-root "$output_root" \
      --evidence-root "$evidence_root" \
      --no-fixtures >/dev/null
}

case_all_runs_pruning_records_pruned_paths() {
  local tmp output_root evidence_root stale_path
  tmp="$(create_fixture_repo)"
  run_fixture_generator "$tmp"
  output_root="$(fixture_output_root "$tmp")"
  evidence_root="$(fixture_evidence_root "$tmp")"
  stage_live_fixture_run "$tmp" "healthy"
  stage_live_effective_fixture_outputs "$tmp"
  stale_path="$output_root/stale-run/health.yml"
  mkdir -p "${stale_path%/*}"
  cat <<'EOF' >"$stale_path"
schema_version: run-health-read-model-v1
EOF
  OCTON_DIR_OVERRIDE="$tmp/.octon" \
    OCTON_ROOT_DIR="$tmp" \
    OCTON_RUN_HEALTH_GENERATED_AT="2026-04-24T00:00:00Z" \
    bash "$GENERATOR" \
      --all-runs \
      --output-root "$output_root" \
      --evidence-root "$evidence_root" >/dev/null
  yq -e '.pruned_paths[] | select(. == ".octon/generated/cognition/projections/materialized/runs/stale-run/health.yml")' "$evidence_root/generation.yml" >/dev/null
}

case_tracked_generated_run_health_mutation_is_detectable() {
  local tmp before after
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/run-health-read-model.XXXXXX")"
  cleanup_dirs+=("$tmp")
  mkdir -p "$tmp/$GENERATED_RUN_HEALTH_REF/fixture-run"
  printf 'baseline\n' >"$tmp/$GENERATED_RUN_HEALTH_REF/fixture-run/health.yml"
  git -C "$tmp" init -q
  git -C "$tmp" config user.email "octon-test@example.invalid"
  git -C "$tmp" config user.name "Octon Test"
  git -C "$tmp" add .
  git -C "$tmp" commit -qm generated-run-health-baseline
  before="$(generated_run_health_status_for_root "$tmp")"
  printf 'changed\n' >"$tmp/$GENERATED_RUN_HEALTH_REF/fixture-run/health.yml"
  after="$(generated_run_health_status_for_root "$tmp")"
  [[ -z "$before" ]] &&
    [[ "$after" == *" $GENERATED_RUN_HEALTH_REF/fixture-run/health.yml"* ]]
}

main() {
  local generated_run_health_status_before
  generated_run_health_status_before="$(generated_run_health_status_for_root "$ROOT_DIR")"
  assert_success "fixture statuses validate" case_fixture_statuses_validate
  assert_success "generation receipt includes published paths and index" case_generation_receipt_includes_published_paths_and_index
  assert_success "generation receipt includes compact manifest" case_generation_receipt_includes_compact_manifest
  assert_success "non-authority mutation fails closed" case_non_authority_mutation_fails
  assert_success "source digest mutation fails closed" case_digest_mutation_fails
  assert_success "generation receipt invalid published paths fail closed" case_generation_receipt_invalid_published_paths_fail
  assert_success "compact manifest receipt digest mutation fails closed" case_compact_manifest_receipt_digest_mutation_fails
  assert_success "compact manifest source digest mutation fails closed" case_compact_manifest_source_digest_mutation_fails
  assert_success "no-op generation keeps existing projection bytes" case_noop_generation_keeps_existing_projection_bytes
  assert_success "incremental run generation preserves unrelated health projection" case_incremental_run_generation_preserves_unrelated_health_projection
  assert_success "all-runs pruning records pruned paths" case_all_runs_pruning_records_pruned_paths
  assert_success "tracked generated run-health mutation is detectable" case_tracked_generated_run_health_mutation_is_detectable
  assert_success "tracked generated run-health projections are unchanged" assert_generated_run_health_status_unchanged "$generated_run_health_status_before"

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
