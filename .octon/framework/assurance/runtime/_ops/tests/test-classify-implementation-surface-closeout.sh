#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
CLASSIFIER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/classify-implementation-surface-closeout.sh"

pass_count=0
fail_count=0
cleanup_dirs=()
cleanup_files=()

cleanup() {
  local dir file
  for dir in "${cleanup_dirs[@]}"; do
    case "$dir" in
      "${TMPDIR:-/tmp}"/implementation-surface-classifier.*)
        [[ -d "$dir" ]] && rm -r -- "$dir"
        ;;
      *)
        echo "refusing to remove unexpected cleanup dir: $dir" >&2
        ;;
    esac
  done
  for file in "${cleanup_files[@]}"; do
    case "$file" in
      "${TMPDIR:-/tmp}"/implementation-surface-output.*)
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

new_output_file() {
  local file
  file="$(mktemp "${TMPDIR:-/tmp}/implementation-surface-output.XXXXXX")"
  cleanup_files+=("$file")
  printf '%s\n' "$file"
}

new_fixture_repo() {
  local root
  root="$(mktemp -d "${TMPDIR:-/tmp}/implementation-surface-classifier.XXXXXX")"
  cleanup_dirs+=("$root")
  mkdir -p "$root/.octon/framework/tool" "$root/.octon/state/control" "$root/.octon/generated/effective" "$root/.octon/inputs/example"
  printf 'base\n' >"$root/.octon/framework/tool/file.txt"
  printf 'base\n' >"$root/.octon/framework/tool/delete-me.txt"
  printf 'state\n' >"$root/.octon/state/control/run.yml"
  printf 'generated\n' >"$root/.octon/generated/effective/out.yml"
  printf 'input\n' >"$root/.octon/inputs/example/raw.yml"
  git -C "$root" init -q
  git -C "$root" config user.email "octon-test@example.invalid"
  git -C "$root" config user.name "Octon Test"
  git -C "$root" add .
  git -C "$root" commit -qm base
  git -C "$root" update-ref refs/remotes/origin/main HEAD
  printf '%s\n' "$root"
}

run_classifier() {
  local root="$1"
  local output="$2"
  bash "$CLASSIFIER" \
    --source-root "$root" \
    --base-ref origin/main \
    --include .octon/framework \
    --exclude .octon/state \
    --exclude .octon/generated \
    --exclude .octon/inputs \
    --format yaml >"$output"
}

case_authorizes_clean_replayable_change() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  printf 'changed\n' >"$root/.octon/framework/tool/file.txt"
  run_classifier "$root" "$output"
  assert_contains "$output" 'candidate_verdict: "pass"' &&
    assert_contains "$output" 'candidate_authorized: true' &&
    assert_contains "$output" 'target_owned_path_count: 1' &&
    assert_contains "$output" '.octon/framework/tool/file.txt'
}

case_reports_noop_when_current_base_already_matches_source() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  git -C "$root" checkout -qb stale-source
  git -C "$root" checkout -q main
  printf 'integrated\n' >"$root/.octon/framework/tool/integrated.txt"
  git -C "$root" add .octon/framework/tool/integrated.txt
  git -C "$root" commit -qm integrated
  git -C "$root" update-ref refs/remotes/origin/main HEAD
  git -C "$root" checkout -q stale-source
  printf 'integrated\n' >"$root/.octon/framework/tool/integrated.txt"
  run_classifier "$root" "$output"
  assert_contains "$output" 'candidate_verdict: "noop"' &&
    assert_contains "$output" 'candidate_noop: true' &&
    assert_contains "$output" 'already_integrated_path_count: 1'
}

case_blocks_untracked_file_that_overlaps_current_base() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  git -C "$root" checkout -qb stale-source
  git -C "$root" checkout -q main
  printf 'origin\n' >"$root/.octon/framework/tool/new-current.txt"
  git -C "$root" add .octon/framework/tool/new-current.txt
  git -C "$root" commit -qm origin-new
  git -C "$root" update-ref refs/remotes/origin/main HEAD
  git -C "$root" checkout -q stale-source
  printf 'dirty\n' >"$root/.octon/framework/tool/new-current.txt"
  run_classifier "$root" "$output"
  assert_contains "$output" 'candidate_verdict: "blocked"' &&
    assert_contains "$output" 'untracked_tracked_on_current_base_path_count: 1' &&
    assert_contains "$output" '.octon/framework/tool/new-current.txt'
}

case_blocks_deletion_without_explicit_proof() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  rm "$root/.octon/framework/tool/delete-me.txt"
  run_classifier "$root" "$output"
  assert_contains "$output" 'candidate_verdict: "blocked"' &&
    assert_contains "$output" 'deletion_candidate_path_count: 1' &&
    assert_contains "$output" '.octon/framework/tool/delete-me.txt'
}

case_blocks_stale_conflicting_change() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  git -C "$root" checkout -qb stale-source
  git -C "$root" checkout -q main
  printf 'origin-change\n' >"$root/.octon/framework/tool/file.txt"
  git -C "$root" add .octon/framework/tool/file.txt
  git -C "$root" commit -qm origin-change
  git -C "$root" update-ref refs/remotes/origin/main HEAD
  git -C "$root" checkout -q stale-source
  printf 'dirty-change\n' >"$root/.octon/framework/tool/file.txt"
  run_classifier "$root" "$output"
  assert_contains "$output" 'candidate_verdict: "blocked"' &&
    assert_contains "$output" 'stale_or_superseded_path_count: 1' &&
    assert_contains "$output" '.octon/framework/tool/file.txt'
}

case_excludes_state_generated_and_inputs_from_candidate_boundary() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  printf 'state dirty\n' >"$root/.octon/state/control/run.yml"
  printf 'generated dirty\n' >"$root/.octon/generated/effective/out.yml"
  printf 'input dirty\n' >"$root/.octon/inputs/example/raw.yml"
  printf 'changed\n' >"$root/.octon/framework/tool/file.txt"
  run_classifier "$root" "$output"
  assert_contains "$output" 'candidate_verdict: "pass"' &&
    assert_contains "$output" 'target_owned_path_count: 1' &&
    assert_contains "$output" 'foreign_or_unrelated_residue_path_count: 3'
}

case_refined_boundary_can_skip_foreign_scan_explicitly() {
  local root output
  root="$(new_fixture_repo)"
  output="$(new_output_file)"
  printf 'state dirty\n' >"$root/.octon/state/control/run.yml"
  printf 'changed\n' >"$root/.octon/framework/tool/file.txt"
  bash "$CLASSIFIER" \
    --source-root "$root" \
    --base-ref origin/main \
    --include .octon/framework/tool/file.txt \
    --exclude .octon/state \
    --exclude .octon/generated \
    --exclude .octon/inputs \
    --foreign-scan none \
    --format yaml >"$output"
  assert_contains "$output" 'candidate_verdict: "pass"' &&
    assert_contains "$output" 'foreign_scan: "none"' &&
    assert_contains "$output" 'foreign_or_unrelated_residue_path_count: 0' &&
    assert_contains "$output" 'foreign scan skipped for refined exact-boundary proof'
}

assert_success "authorizes clean replayable implementation change" case_authorizes_clean_replayable_change
assert_success "reports already-integrated no-op candidate" case_reports_noop_when_current_base_already_matches_source
assert_success "blocks untracked files tracked on current base when content differs" case_blocks_untracked_file_that_overlaps_current_base
assert_success "blocks deletions without explicit proof" case_blocks_deletion_without_explicit_proof
assert_success "blocks stale conflicting changes" case_blocks_stale_conflicting_change
assert_success "excludes state generated and inputs from implementation candidate" case_excludes_state_generated_and_inputs_from_candidate_boundary
assert_success "supports explicit refined-boundary foreign scan skip" case_refined_boundary_can_skip_foreign_scan_explicitly

echo "$pass_count passed, $fail_count failed"
[[ "$fail_count" -eq 0 ]]
