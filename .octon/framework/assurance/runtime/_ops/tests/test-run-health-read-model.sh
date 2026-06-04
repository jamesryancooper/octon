#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
GENERATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh"
FIXTURE_ROOT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/fixtures/run-health-read-model"
SCHEMA_PATH="$ROOT_DIR/.octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json"

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

create_fixture_repo() {
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/run-health-read-model.XXXXXX")"
  cleanup_dirs+=("$tmp")
  cp -R "$FIXTURE_ROOT" "$tmp/fixtures"
  mkdir -p "$tmp/.octon/framework/engine/runtime/spec"
  cp "$SCHEMA_PATH" "$tmp/.octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json"
  printf '%s\n' "$tmp"
}

fixture_output_root() {
  printf '%s\n' "$1/.octon/generated/cognition/projections/materialized/runs"
}

fixture_evidence_root() {
  printf '%s\n' "$1/.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health"
}

run_fixture_generator() {
  local repo_root="$1"
  local output_root evidence_root
  output_root="$(fixture_output_root "$repo_root")"
  evidence_root="$(fixture_evidence_root "$repo_root")"
  OCTON_DIR_OVERRIDE="$repo_root/.octon" \
    OCTON_ROOT_DIR="$repo_root" \
    OCTON_RUN_HEALTH_GENERATED_AT="2026-04-24T00:00:00Z" \
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

case_all_runs_pruning_records_pruned_paths() {
  local tmp output_root evidence_root stale_path
  tmp="$(create_fixture_repo)"
  run_fixture_generator "$tmp"
  output_root="$(fixture_output_root "$tmp")"
  evidence_root="$(fixture_evidence_root "$tmp")"
  mkdir -p "$tmp/.octon/state/control/execution/runs/healthy"
  cp -R "$tmp/fixtures/sources/healthy/control/." "$tmp/.octon/state/control/execution/runs/healthy/"
  mkdir -p "$tmp/.octon/generated/effective/runtime" "$tmp/.octon/generated/effective/capabilities" "$tmp/.octon/generated/effective/governance"
  cp "$tmp/fixtures/effective/route-bundle.yml" "$tmp/.octon/generated/effective/runtime/route-bundle.yml"
  cp "$tmp/fixtures/effective/pack-routes.effective.yml" "$tmp/.octon/generated/effective/capabilities/pack-routes.effective.yml"
  cat <<'EOF' >"$tmp/.octon/generated/effective/governance/support-envelope-reconciliation.yml"
schema_version: support-envelope-reconciliation-result-v1
status: fixture
EOF
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

main() {
  assert_success "fixture statuses validate" case_fixture_statuses_validate
  assert_success "generation receipt includes published paths and index" case_generation_receipt_includes_published_paths_and_index
  assert_success "generation receipt includes compact manifest" case_generation_receipt_includes_compact_manifest
  assert_success "non-authority mutation fails closed" case_non_authority_mutation_fails
  assert_success "source digest mutation fails closed" case_digest_mutation_fails
  assert_success "generation receipt invalid published paths fail closed" case_generation_receipt_invalid_published_paths_fail
  assert_success "compact manifest receipt digest mutation fails closed" case_compact_manifest_receipt_digest_mutation_fails
  assert_success "compact manifest source digest mutation fails closed" case_compact_manifest_source_digest_mutation_fails
  assert_success "all-runs pruning records pruned paths" case_all_runs_pruning_records_pruned_paths

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
