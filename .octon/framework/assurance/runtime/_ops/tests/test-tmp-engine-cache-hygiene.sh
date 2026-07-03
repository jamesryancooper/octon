#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
WRAPPER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/publication-wrapper-common.sh"
CLEANUP_WRAPPER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/cleanup-publication-validation-runs.sh"

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

assert_exists() {
  [[ -e "$1" ]] || fail "expected path to exist: $1"
}

assert_missing() {
  [[ ! -e "$1" ]] || fail "expected path to be removed: $1"
}

assert_contains() {
  local output="$1"
  local needle="$2"
  grep -Fq -- "$needle" <<<"$output" || fail "expected output to contain: $needle"
}

assert_fails() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    fail "$label should fail"
  fi
}

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-tmp-engine-cache.XXXXXX")"
trap 'rm -rf "$tmp_root"' EXIT
fixture_index=0
pass_count=0

make_fixture() {
  fixture_index=$((fixture_index + 1))
  local root="$tmp_root/fixture-$fixture_index"
  mkdir -p "$root/.octon/generated/.tmp/engine/build/runtime-crates-target/debug/incremental" \
    "$root/.octon/generated/.tmp/engine/build/runtime-crates-target/debug/.fingerprint" \
    "$root/.octon/generated/effective/runtime" \
    "$root/.octon/state/evidence/validation/analysis"
  git -C "$root" init >/dev/null
  git -C "$root" config core.excludesFile /dev/null
  printf '.octon/generated/.tmp/\n' >"$root/.gitignore"
  git -C "$root" add .gitignore
  git -C "$root" -c user.name="Octon Test" -c user.email="octon@example.invalid" commit -m "fixture" >/dev/null
  printf '%s\n' "$root"
}

run_case() {
  local label="$1"
  shift
  "$@"
  pass_count=$((pass_count + 1))
  printf '[OK] %s\n' "$label"
}

case_dry_run_preserves_stale_cache() {
  local root target stale
  root="$(make_fixture)"
  target="$root/.octon/generated/.tmp/engine/build/runtime-crates-target"
  stale="$target/debug/incremental/stale.o"
  printf 'stale\n' >"$stale"
  touch -t 202001010000 "$stale"
  (
    export OCTON_ROOT_DIR="$root"
    export OCTON_DIR_OVERRIDE="$root/.octon"
    export OCTON_PUBLICATION_SCRATCH_CLEANUP_MODE="dry-run"
    export OCTON_PUBLICATION_SCRATCH_TTL_SECONDS=1
    source "$WRAPPER"
    publication_scratch_preflight "$PUBLICATION_KERNEL_TARGET_DIR"
  )
  assert_exists "$stale"
}

case_prune_removes_only_rebuildable_cache() {
  local root target stale binary
  root="$(make_fixture)"
  target="$root/.octon/generated/.tmp/engine/build/runtime-crates-target"
  stale="$target/debug/incremental/stale.o"
  binary="$target/debug/octon"
  printf 'stale\n' >"$stale"
  printf 'kernel\n' >"$binary"
  chmod +x "$binary"
  touch -t 202001010000 "$stale"
  touch -t 202001010000 "$binary"
  (
    export OCTON_ROOT_DIR="$root"
    export OCTON_DIR_OVERRIDE="$root/.octon"
    export OCTON_PUBLICATION_SCRATCH_CLEANUP_MODE="prune"
    export OCTON_PUBLICATION_SCRATCH_TTL_SECONDS=1
    source "$WRAPPER"
    publication_scratch_preflight "$PUBLICATION_KERNEL_TARGET_DIR"
  )
  assert_missing "$stale"
  assert_exists "$binary"
}

case_refuses_target_outside_generated_tmp() {
  local root
  root="$(make_fixture)"
  (
    export OCTON_ROOT_DIR="$root"
    export OCTON_DIR_OVERRIDE="$root/.octon"
    export OCTON_PUBLICATION_KERNEL_TARGET_DIR="$root/.octon/generated/effective/runtime/bad-target"
    source "$WRAPPER"
    publication_scratch_preflight "$PUBLICATION_KERNEL_TARGET_DIR"
  ) >/dev/null 2>&1 && fail "outside generated tmp target should fail"
  return 0
}

case_tmp_budget_report_is_dry_run_measurement() {
  local root output
  root="$(make_fixture)"
  printf 'cache\n' >"$root/.octon/generated/.tmp/cache.bin"
  output="$(bash "$CLEANUP_WRAPPER" --root "$root" --tmp-budget-report)"
  assert_contains "$output" "tmp_budget_report:"
  assert_contains "$output" 'root: ".octon/generated/.tmp"'
  assert_contains "$output" 'cleanup_default: "dry-run"'
  assert_exists "$root/.octon/generated/.tmp/cache.bin"
}

case_cleanup_authorization_refuses_non_scratch() {
  local root receipt
  root="$(make_fixture)"
  receipt="$tmp_root/non-scratch-receipt.json"
  printf 'generated effective\n' >"$root/.octon/generated/effective/runtime/route-bundle.yml"
  printf 'retained evidence\n' >"$root/.octon/state/evidence/validation/analysis/manual.yml"
  assert_fails "generated effective cleanup authorization" \
    bash "$CLEANUP_WRAPPER" --root "$root" \
      --cleanup-path .octon/generated/effective/runtime/route-bundle.yml \
      --authorize "$receipt"
  assert_fails "retained evidence cleanup authorization" \
    bash "$CLEANUP_WRAPPER" --root "$root" \
      --cleanup-path .octon/state/evidence/validation/analysis/manual.yml \
      --authorize "$receipt"
}

run_case "dry-run scratch preflight preserves stale cache" case_dry_run_preserves_stale_cache
run_case "prune mode removes stale rebuildable cache only" case_prune_removes_only_rebuildable_cache
run_case "publication scratch target outside generated tmp fails closed" case_refuses_target_outside_generated_tmp
run_case "tmp budget report is dry-run measurement" case_tmp_budget_report_is_dry_run_measurement
run_case "cleanup authorization refuses non-scratch surfaces" case_cleanup_authorization_refuses_non_scratch

printf 'PASS: tmp engine cache hygiene tests completed (%s cases)\n' "$pass_count"
