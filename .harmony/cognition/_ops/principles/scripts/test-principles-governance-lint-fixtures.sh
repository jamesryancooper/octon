#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
cd "$ROOT_DIR"

PRINCIPLES_DIR=".harmony/cognition/governance/principles"
LINT_SCRIPT=".harmony/cognition/_ops/principles/scripts/lint-principles-governance.sh"

if [[ ! -x "$LINT_SCRIPT" ]]; then
  echo "[fail] missing lint script: $LINT_SCRIPT"
  exit 1
fi

declare -a temp_files=()

cleanup() {
  local file
  for file in "${temp_files[@]}"; do
    rm -f "$file"
  done
}
trap cleanup EXIT

assert_lint_fails_with_fixture() {
  local name="$1"
  local body="$2"
  local fixture_file lint_output

  fixture_file="$(mktemp "$PRINCIPLES_DIR/.governance-lint-fixture-${name}.XXXX.md")"
  temp_files+=("$fixture_file")

  cat >"$fixture_file" <<EOF
---
title: Governance Lint Fixture ${name}
description: Temporary fixture for governance lint failure testing.
status: Draft
---

# Fixture ${name}

${body}
EOF

  set +e
  lint_output="$("$LINT_SCRIPT" 2>&1)"
  local rc=$?
  set -e

  if [[ "$rc" -eq 0 ]]; then
    echo "[fail] expected governance lint to fail for fixture: $name"
    echo "$lint_output"
    exit 1
  fi
}

# Baseline should pass without fixtures.
"$LINT_SCRIPT" >/dev/null

assert_lint_fails_with_fixture "stale-reference" \
  "Legacy path: .harmony/cognition/principles/pillars/trust.md"

assert_lint_fails_with_fixture "pr-only-gate" \
  "A promotion MUST be in a PR before it can proceed."

assert_lint_fails_with_fixture "human-gate" \
  "Promotion must be approved by human before runtime completion."

assert_lint_fails_with_fixture "hitl-term" \
  "HITL checkpoint policy applies here."

echo "Principles governance lint fixture tests passed."
