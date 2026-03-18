#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_packet2_fixture_lib.sh"

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

run_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh" >/dev/null
}

case_engine_governance_reference_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh"
  chmod +x "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh"

  mkdir -p "$fixture_root/.octon/framework/engine/governance"
  cat >"$fixture_root/.octon/framework/engine/governance/raw-input-leak.md" <<'EOF'
# Invalid

Runtime policy must read `.octon/inputs/additive/extensions/example/pack.yml`.
EOF

  ! run_validator "$fixture_root"
}

main() {
  assert_success "raw-input dependency validator rejects governance references to raw inputs" case_engine_governance_reference_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
