#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-github-action-pins.sh"

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

case_mutable_ref_fails() {
  local fixture_root workflow_file policy_file
  fixture_root="$(mktemp -d)"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p "$fixture_root/.github/workflows"
  workflow_file="$fixture_root/.github/workflows/ai-review-gate.yml"
  policy_file="$fixture_root/policy.yml"

  cat >"$workflow_file" <<'EOF'
name: AI Review Gate
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
EOF

cat >"$policy_file" <<'EOF'
schema_version: "github-action-pin-policy-v1"
allow_local_actions: true
pin_comment_style: "append-semver-comment"
disallowed_ref_patterns:
  - "^v[0-9]+(\\.[0-9]+)?(\\.[0-9]+)?$"
  - "^stable$"
  - "^main$"
  - "^master$"
workflow_globs:
  - ".github/workflows/ai-review-gate.yml"
EOF

  OCTON_ROOT_DIR="$fixture_root" GITHUB_ACTION_PIN_POLICY_FILE="$policy_file" bash "$VALIDATOR" >/dev/null 2>&1 && return 1 || return 0
}

main() {
  assert_success "GitHub Action pin validator passes on live repo" case_live_repo_passes
  assert_success "GitHub Action pin validator fails on mutable refs" case_mutable_ref_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
