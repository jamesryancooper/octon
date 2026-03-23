#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-alignment-profile-registry.sh"

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

create_fixture() {
  local fixture_root
  fixture_root="$(mktemp -d)"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.octon/framework/assurance/runtime/contracts" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.github/workflows"

  cat >"$fixture_root/.octon/framework/assurance/runtime/contracts/alignment-profiles.yml" <<'EOF'
schema_version: "alignment-profiles-v1"
profiles:
  - id: "demo"
    label: "Demo profile"
    entrypoint: "run_demo"
    required_paths:
      - ".octon/framework/assurance/runtime/_ops/scripts/demo.sh"
    dry_run_safe: true
    consumers:
      - "local"
      - "ci"
EOF

  cat >"$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh" <<'EOF'
#!/usr/bin/env bash
run_demo() {
  :
}
EOF

  cat >"$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/demo.sh" <<'EOF'
#!/usr/bin/env bash
:
EOF

  cat >"$fixture_root/.github/workflows/alignment-check.yml" <<'EOF'
name: Alignment Check
on:
  workflow_dispatch:
    inputs:
      profile:
        description: Alignment profile to run
        required: true
        default: all
        type: string
jobs:
  run:
    runs-on: ubuntu-latest
    steps:
      - name: Run alignment-check
        run: |
          args=(--profile "$PROFILE")
          bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh "${args[@]}"
EOF

  printf '%s\n' "$fixture_root"
}

run_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    ALIGNMENT_REGISTRY_FILE="$fixture_root/.octon/framework/assurance/runtime/contracts/alignment-profiles.yml" \
    ALIGNMENT_RUNNER_FILE="$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh" \
    ALIGNMENT_WORKFLOW_FILE="$fixture_root/.github/workflows/alignment-check.yml" \
    bash "$VALIDATOR" >/dev/null
}

case_live_repo_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_missing_required_path_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  rm "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/demo.sh"
  ! run_validator "$fixture_root"
}

case_retired_root_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's#\.octon/framework/assurance/runtime/_ops/scripts/demo\.sh#\.octon/agency/_ops/scripts/demo.sh#' \
    "$fixture_root/.octon/framework/assurance/runtime/contracts/alignment-profiles.yml"
  ! run_validator "$fixture_root"
}

case_choice_input_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/type: string/type: choice\n        options:\n          - demo/' \
    "$fixture_root/.github/workflows/alignment-check.yml"
  ! run_validator "$fixture_root"
}

main() {
  assert_success "alignment profile registry validator passes on live repo" case_live_repo_passes
  assert_success "alignment profile registry validator fails on missing required path" case_missing_required_path_fails
  assert_success "alignment profile registry validator fails on retired root reference" case_retired_root_fails
  assert_success "alignment profile registry validator fails on workflow choice duplication" case_choice_input_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
