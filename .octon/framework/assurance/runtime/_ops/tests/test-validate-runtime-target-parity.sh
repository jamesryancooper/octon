#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-target-parity.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r -f -- "$dir"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

case_live_repo_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_hardcoded_workflow_target_fails() {
  local fixture_root workflow_file
  fixture_root="$(mktemp -d)"
  CLEANUP_DIRS+=("$fixture_root")
  workflow_file="$fixture_root/runtime-binaries.yml"
  cp "$REPO_ROOT/.github/workflows/runtime-binaries.yml" "$workflow_file"
  perl -0pi -e 's/fromJSON\(needs\.plan_matrix\.outputs\.build_matrix\)/{"include":[{"id":"linux-x64","target_binary":"octon-linux-x64"}]}/' "$workflow_file"

  RUNTIME_BINARIES_WORKFLOW_FILE="$workflow_file" bash "$VALIDATOR" >/dev/null 2>&1 && return 1 || return 0
}

case_strict_packaging_blocks_source_fallback() {
  local fixture_root fake_bin run_file targets_file
  fixture_root="$(mktemp -d)"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p "$fixture_root/.octon/framework/engine/runtime" "$fixture_root/bin"
  run_file="$fixture_root/.octon/framework/engine/runtime/run"
  targets_file="$fixture_root/.octon/framework/engine/runtime/release-targets.yml"
  fake_bin="$fixture_root/bin/cargo"

  cp "$REPO_ROOT/.octon/framework/engine/runtime/run" "$run_file"
  cp "$REPO_ROOT/.octon/framework/engine/runtime/release-targets.yml" "$targets_file"
  chmod +x "$run_file"

  cat >"$fake_bin" <<'EOF'
#!/usr/bin/env bash
exit 99
EOF
  chmod +x "$fake_bin"

  local strict_exit fallback_exit

  set +e
  PATH="$fixture_root/bin:$PATH" OCTON_RUNTIME_STRICT_PACKAGING=1 "$run_file" tool noop >/dev/null 2>&1
  strict_exit=$?

  PATH="$fixture_root/bin:$PATH" OCTON_RUNTIME_PREFER_SOURCE=1 "$run_file" tool noop >/dev/null 2>&1
  fallback_exit=$?
  set -e

  [[ "$strict_exit" -ne 0 && "$strict_exit" -ne 99 && "$fallback_exit" -eq 99 ]]
}

main() {
  assert_success "runtime target parity validator passes on live repo" case_live_repo_passes
  assert_success "runtime target parity validator fails on hardcoded workflow targets" case_hardcoded_workflow_target_fails
  assert_success "strict packaging blocks source fallback while local mode still falls back" case_strict_packaging_blocks_source_fallback

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
