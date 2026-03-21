#!/usr/bin/env bash
# test-validate-continuity-memory.sh - Regression tests for continuity validation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../.." && pwd)"
VALIDATE_SCRIPT=".octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh"

pass_count=0
fail_count=0

declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r "$dir"
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
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

assert_failure_contains() {
  local name="$1"
  local needle="$2"
  shift 2

  local output=""
  local rc=0
  output="$("$@" 2>&1)" || rc=$?

  if (( rc != 0 )) && grep -Fq "$needle" <<<"$output"; then
    pass "$name"
    return 0
  fi

  fail "$name"
  echo "  expected failure containing: $needle" >&2
  echo "  exit code: $rc" >&2
  echo "  output:" >&2
  echo "$output" >&2
  return 1
}

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/continuity-validation.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/state/continuity/schemas" \
    "$fixture_root/.octon/instance/locality" \
    "$fixture_root/.octon/state/control/locality" \
    "$fixture_root/.octon/state/continuity/repo" \
    "$fixture_root/.octon/state/continuity/scopes/octon-harness" \
    "$fixture_root/.octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01" \
    "$fixture_root/.octon/state/evidence/runs"

  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh"
  cp "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/state/continuity/schemas/decision-record.schema.json" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/state/continuity/schemas/decision-record.schema.json"

  cat > "$fixture_root/.octon/state/continuity/repo/tasks.json" <<'EOF'
{
  "schema_version": "1.2",
  "goal": "Keep continuity validation green.",
  "tasks": [
    {
      "id": "continuity-check",
      "description": "Verify continuity files.",
      "status": "in_progress",
      "owner": "@architect",
      "blockers": [],
      "acceptance_criteria": [
        "Validator passes"
      ],
      "knowledge_links": {
        "specs": [
          ".octon/framework/cognition/_meta/architecture/state/continuity/continuity-plane.md"
        ],
        "contracts": [
          ".octon/framework/cognition/_meta/architecture/state/continuity/schemas/decision-record.schema.json"
        ],
        "decisions": [
          "dec-20260308-weekly-freshness-audit-allow-01"
        ],
        "evidence": [
          ".octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/decision.json"
        ]
      }
    }
  ]
}
EOF

  cat > "$fixture_root/.octon/state/continuity/repo/entities.json" <<'EOF'
{
  "schema_version": "1.1",
  "description": "Continuity entities for validator tests.",
  "entities": {
    "continuity-memory": {
      "type": "domain",
      "status": "in_progress",
      "last_modified": "2026-03-08",
      "owner": "@architect",
      "related_tasks": [
        "continuity-check"
      ],
      "knowledge_links": {
        "specs": [
          ".octon/framework/cognition/_meta/architecture/state/continuity/continuity-plane.md"
        ],
        "contracts": [
          ".octon/framework/cognition/_meta/architecture/state/continuity/schemas/decision-record.schema.json"
        ],
        "decisions": [
          "dec-20260308-weekly-freshness-audit-allow-01"
        ],
        "evidence": [
          ".octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/decision.json"
        ]
      }
    }
  }
}
EOF

  cat > "$fixture_root/.octon/state/continuity/repo/next.md" <<'EOF'
# Next

## Current

- continuity-check: verify the continuity validator passes.
EOF

  cat > "$fixture_root/.octon/instance/locality/registry.yml" <<'EOF'
schema_version: "octon-locality-registry-v1"
scopes:
  - scope_id: "octon-harness"
    manifest_path: ".octon/instance/locality/scopes/octon-harness/scope.yml"
EOF

  cat > "$fixture_root/.octon/state/control/locality/quarantine.yml" <<'EOF'
schema_version: "octon-locality-quarantine-state-v2"
updated_at: "2026-03-19T00:00:00Z"
records: []
EOF

  cat > "$fixture_root/.octon/state/continuity/scopes/octon-harness/tasks.json" <<'EOF'
{
  "schema_version": "1.2",
  "goal": "Track scope-local work for the octon-harness scope.",
  "tasks": []
}
EOF

  cat > "$fixture_root/.octon/state/continuity/scopes/octon-harness/entities.json" <<'EOF'
{
  "schema_version": "1.1",
  "description": "Tracks state of scope-local entities relevant to octon-harness continuity planning",
  "entities": {}
}
EOF

  cat > "$fixture_root/.octon/state/continuity/scopes/octon-harness/next.md" <<'EOF'
---
title: Scope Next Actions
description: Immediate actionable steps for the octon-harness scope.
scope_id: "octon-harness"
---

# Scope Next Actions

## Current

## Backlog
EOF

  cat > "$fixture_root/.octon/state/continuity/scopes/octon-harness/log.md" <<'EOF'
---
title: Scope Progress Log
description: Chronological record of scope-local session work and decisions.
mutability: append-only
scope_id: "octon-harness"
---

# Scope Progress Log
EOF

  cat > "$fixture_root/.octon/state/evidence/decisions/repo/README.md" <<'EOF'
# Continuity Decisions

Routing, authority, and prerequisite decision evidence.
EOF

  cat > "$fixture_root/.octon/state/evidence/decisions/repo/retention.json" <<'EOF'
{
  "schema_version": "1.0",
  "default_action": "retain",
  "classes": [
    {
      "id": "governance_evidence",
      "description": "Decision evidence.",
      "match_prefixes": [
        "dec-"
      ],
      "retention_days": 365,
      "action_after_retention": "archive"
    }
  ],
  "always_keep_files": [
    "README.md",
    "retention.json"
  ]
}
EOF

  cat > "$fixture_root/.octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/decision.json" <<'EOF'
{
  "decision_id": "dec-20260308-weekly-freshness-audit-allow-01",
  "outcome": "allow",
  "surface": "automations",
  "action": "launch-workflow",
  "actor": "weekly-freshness-audit",
  "decided_at": "2026-03-08T18:04:00Z",
  "reason_codes": [
    "target-resolved"
  ],
  "summary": "Automation launch admitted after routing checks passed.",
  "run_id": "run-20260308-audit-continuous-01"
}
EOF

  cat > "$fixture_root/.octon/state/evidence/runs/README.md" <<'EOF'
# Continuity Runs

Execution receipts, digests, and related run evidence.
EOF

  cat > "$fixture_root/.octon/state/evidence/runs/retention.json" <<'EOF'
{
  "schema_version": "1.0",
  "default_action": "retain",
  "classes": [
    {
      "id": "governance_evidence",
      "description": "Audit and policy evidence.",
      "match_prefixes": [
        "audit",
        "docs-gate-",
        "runtime-acp",
        "runtime-soft-delete-",
        "runtime-agent-quorum-",
        "snippet-emit-"
      ],
      "retention_days": 365,
      "action_after_retention": "archive"
    },
    {
      "id": "operational_debug",
      "description": "Short-lived local validation and debugging runs.",
      "match_prefixes": [
        "debug-",
        "run-"
      ],
      "retention_days": 30,
      "action_after_retention": "prune"
    },
    {
      "id": "scratch",
      "description": "Temporary scratch runs and throwaway experiments.",
      "match_prefixes": [
        "tmp-"
      ],
      "retention_days": 7,
      "action_after_retention": "prune"
    }
  ],
  "always_keep_files": [
    "README.md",
    "retention.json"
  ]
}
EOF

  printf '%s\n' "$fixture_root"
}

run_validator_in_fixture() {
  local fixture_root="$1"
  (
    cd "$fixture_root"
    bash "$VALIDATE_SCRIPT"
  )
}

case_valid_fixture_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  run_validator_in_fixture "$fixture_root"
}

case_missing_decision_json_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  rm "$fixture_root/.octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/decision.json"
  run_validator_in_fixture "$fixture_root"
}

case_invalid_outcome_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  jq '.outcome = "deny"' \
    "$fixture_root/.octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/decision.json" \
    > "$fixture_root/.octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/decision.tmp"
  mv \
    "$fixture_root/.octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/decision.tmp" \
    "$fixture_root/.octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/decision.json"
  run_validator_in_fixture "$fixture_root"
}

case_block_outcome_with_run_id_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  jq '.outcome = "block"' \
    "$fixture_root/.octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/decision.json" \
    > "$fixture_root/.octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/decision.tmp"
  mv \
    "$fixture_root/.octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/decision.tmp" \
    "$fixture_root/.octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/decision.json"
  run_validator_in_fixture "$fixture_root"
}

case_stray_file_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  touch "$fixture_root/.octon/state/evidence/decisions/repo/dec-20260308-weekly-freshness-audit-allow-01/extra.txt"
  run_validator_in_fixture "$fixture_root"
}

case_undeclared_scope_continuity_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  mkdir -p "$fixture_root/.octon/state/continuity/scopes/rogue"
  cat > "$fixture_root/.octon/state/continuity/scopes/rogue/tasks.json" <<'EOF'
{
  "schema_version": "1.2",
  "goal": "rogue",
  "tasks": []
}
EOF
  cat > "$fixture_root/.octon/state/continuity/scopes/rogue/entities.json" <<'EOF'
{
  "schema_version": "1.1",
  "description": "rogue",
  "entities": {}
}
EOF
  cat > "$fixture_root/.octon/state/continuity/scopes/rogue/next.md" <<'EOF'
# Next

## Current
EOF
  cat > "$fixture_root/.octon/state/continuity/scopes/rogue/log.md" <<'EOF'
# Log
EOF
  run_validator_in_fixture "$fixture_root"
}

case_malformed_scope_continuity_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  jq '.schema_version = "1.0"' \
    "$fixture_root/.octon/state/continuity/scopes/octon-harness/tasks.json" \
    > "$fixture_root/.octon/state/continuity/scopes/octon-harness/tasks.tmp"
  mv \
    "$fixture_root/.octon/state/continuity/scopes/octon-harness/tasks.tmp" \
    "$fixture_root/.octon/state/continuity/scopes/octon-harness/tasks.json"
  run_validator_in_fixture "$fixture_root"
}

case_quarantined_scope_continuity_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  cat > "$fixture_root/.octon/state/control/locality/quarantine.yml" <<'EOF'
schema_version: "octon-locality-quarantine-state-v2"
updated_at: "2026-03-19T00:00:00Z"
records:
  - scope_id: "octon-harness"
    manifest_path: ".octon/instance/locality/scopes/octon-harness/scope.yml"
    reason_code: "fixture-quarantine"
EOF
  run_validator_in_fixture "$fixture_root"
}

main() {
  assert_success \
    "continuity validator accepts a valid decision evidence fixture" \
    case_valid_fixture_passes

  assert_failure_contains \
    "continuity validator rejects missing decision.json" \
    "decision directory missing decision.json" \
    case_missing_decision_json_fails

  assert_failure_contains \
    "continuity validator rejects invalid decision outcomes" \
    "decision record missing required root fields" \
    case_invalid_outcome_fails

  assert_failure_contains \
    "continuity validator rejects run_id on blocked decisions" \
    "decision record run_id is only allowed when outcome=allow" \
    case_block_outcome_with_run_id_fails

  assert_failure_contains \
    "continuity validator rejects stray files in decision directories" \
    "decision directory contains unsupported files" \
    case_stray_file_fails

  assert_failure_contains \
    "continuity validator rejects undeclared scope continuity" \
    "undeclared scope continuity directory present" \
    case_undeclared_scope_continuity_fails

  assert_failure_contains \
    "continuity validator rejects malformed scope continuity tasks" \
    "tasks.json root contract mismatch" \
    case_malformed_scope_continuity_fails

  assert_failure_contains \
    "continuity validator rejects quarantined scope continuity" \
    "scope continuity is invalid for quarantined scope" \
    case_quarantined_scope_continuity_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"

  if [[ "$fail_count" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
