#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
cd "$ROOT_DIR"

SYNC_SCRIPT=".octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh"
HAS_RG=0

if command -v rg >/dev/null 2>&1; then
  HAS_RG=1
fi

if [[ ! -f "$SYNC_SCRIPT" ]]; then
  echo "[fail] missing sync script: $SYNC_SCRIPT"
  exit 1
fi

matches_pattern() {
  local pattern="$1"
  local file="$2"

  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -q -- "$pattern" "$file"
  else
    grep -Eq -- "$pattern" "$file"
  fi
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if ! matches_pattern "$pattern" "$file"; then
    echo "[fail] $label"
    echo "file: $file"
    exit 1
  fi
}

assert_not_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if matches_pattern "$pattern" "$file"; then
    echo "[fail] $label"
    echo "file: $file"
    exit 1
  fi
}

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/runtime-artifacts-fixtures.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT

fixture_cognition="$tmp_dir/cognition"
fixture_state="$tmp_dir/state"
mkdir -p "$fixture_cognition/runtime/evaluations/digests"
mkdir -p "$fixture_cognition/runtime/evaluations/actions"
mkdir -p "$fixture_state/state/evidence/validation/analysis"

cat >"$fixture_cognition/runtime/evaluations/digests/README.md" <<'EOF'
# Fixture Digests
EOF

cat >"$fixture_cognition/runtime/evaluations/digests/template-weekly-digest.md" <<'EOF'
---
title: Template
---
EOF

cat >"$fixture_cognition/runtime/evaluations/digests/2026-W08-weekly-scorecard.md" <<'EOF'
---
title: Weekly Digest W08
week: 2026-W08
digest_date: 2026-02-22
status: yellow
actions:
  - id: ACTION-2026-W08-01
    owner: runtime-maintainer
    due_date: 2026-02-27
    status: open
    summary: Refresh weekly digest cadence
    evidence: /.octon/framework/cognition/practices/operations/weekly-evaluations.md
  - id: ACTION-2026-W08-02
    owner: runtime-maintainer
    due_date: 2026-02-26
    status: closed
    summary: Close completed action
    evidence: ticket://closed
---

# Weekly Digest W08
EOF

cat >"$fixture_cognition/runtime/evaluations/digests/2026-W09-weekly-scorecard.md" <<'EOF'
---
title: Weekly Digest W09
week: 2026-W09
digest_date: 2026-03-01
status: green
actions:
  - id: ACTION-2026-W09-03
    owner: ""
    status: in_progress
    summary: Tune parser coverage
    evidence: fixture://digest-2
---

# Weekly Digest W09
EOF

if COGNITION_DIR_OVERRIDE="$fixture_cognition" OUTPUT_DIR_OVERRIDE="$fixture_state" bash "$SYNC_SCRIPT" --target evaluations >/dev/null; then
  :
else
  echo "[fail] target-selective evaluations generation failed"
  exit 1
fi

digest_index="$fixture_cognition/runtime/evaluations/digests/index.yml"
open_actions="$fixture_cognition/runtime/evaluations/actions/open-actions.yml"

assert_contains "$digest_index" 'id: 2026-W08-weekly-scorecard' "digest index missing W08 record"
assert_contains "$digest_index" 'id: 2026-W09-weekly-scorecard' "digest index missing W09 record"
assert_contains "$digest_index" 'digest_date: 2026-03-01' "digest index missing digest_date extraction"

assert_contains "$open_actions" 'ACTION-2026-W08-01' "open-actions missing open action from first digest"
assert_contains "$open_actions" 'ACTION-2026-W09-03' "open-actions missing open action from second digest"
assert_not_contains "$open_actions" 'ACTION-2026-W08-02' "closed action should not be included in open-actions"
assert_contains "$open_actions" 'owner: "unassigned"' "missing owner default should become unassigned"
assert_contains "$open_actions" 'due_date: "tbd"' "missing due_date default should become tbd"

if COGNITION_DIR_OVERRIDE="$fixture_cognition" OUTPUT_DIR_OVERRIDE="$fixture_output" bash "$SYNC_SCRIPT" --target evaluations --check >/dev/null; then
  :
else
  echo "[fail] target-selective --check should pass after generation"
  exit 1
fi

if COGNITION_DIR_OVERRIDE="$fixture_cognition" OUTPUT_DIR_OVERRIDE="$fixture_output" bash "$SYNC_SCRIPT" --target unknown-target >/dev/null 2>"$tmp_dir/unknown-target.err"; then
  echo "[fail] unknown --target should fail"
  exit 1
fi
assert_contains "$tmp_dir/unknown-target.err" 'Unknown target selector' "unknown target should emit selector error"

echo "Sync runtime artifacts fixture tests passed."
