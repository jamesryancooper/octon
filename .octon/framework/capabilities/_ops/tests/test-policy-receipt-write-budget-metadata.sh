#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CAPABILITIES_DIR="$(cd "$OPS_DIR/.." && pwd)"
OCTON_DIR="$(cd "$CAPABILITIES_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"

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
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/policy-receipt-budget.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.octon/framework/capabilities/_ops/scripts" \
    "$fixture_root/.octon/framework/capabilities/governance/policy"

  cp "$REPO_ROOT/.octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh" \
    "$fixture_root/.octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh"
  cp "$REPO_ROOT/.octon/framework/capabilities/governance/policy/deny-by-default.v2.yml" \
    "$fixture_root/.octon/framework/capabilities/governance/policy/deny-by-default.v2.yml"

  chmod +x "$fixture_root/.octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh"

  printf '%s\n' "$fixture_root"
}

case_receipt_includes_budget_metadata() {
  local fixture_root request_file decision_file
  fixture_root="$(create_fixture)"
  request_file="$fixture_root/request.json"
  decision_file="$fixture_root/decision.json"

  cat >"$request_file" <<'EOF'
{
  "run_id": "tool-budget-metadata",
  "actor": { "id": "tester", "type": "system" },
  "profile": "refactor",
  "intent_ref": { "id": "intent://test/example", "version": "1.0.0" },
  "boundary_id": "service",
  "boundary_set_version": "v1",
  "workflow_mode": "autonomous",
  "capability_classification": "execution-role-ready",
  "budget_rule_id": "workflow-stage-openai",
  "budget_reason_codes": ["EXECUTION_BUDGET_WARN_THRESHOLD_EXCEEDED"],
  "cost_evidence_path": ".octon/state/evidence/runs/tool-budget-metadata/cost.json",
  "instruction_layers": [
    {
      "layer_id": "developer",
      "source": "AGENTS.md",
      "sha256": "0000000000000000000000000000000000000000000000000000000000000000",
      "bytes": 1,
      "visibility": "full"
    }
  ],
  "context_acquisition": {
    "file_reads": 0,
    "search_queries": 0,
    "commands": 1,
    "subagent_spawns": 0,
    "duration_ms": 0
  },
  "context_overhead_ratio": 0,
  "operation": {
    "class": "service.execute",
    "target": {
      "workflow_mode": "autonomous",
      "capability_classification": "execution-role-ready"
    }
  },
  "phase": "promote"
}
EOF

  cat >"$decision_file" <<'EOF'
{
  "decision": "ALLOW",
  "effective_acp": "ACP-1",
  "reason_codes": ["ACP_ALLOW_POLICY_PASS"],
  "remediation": "No additional remediation required."
}
EOF

  (
    cd "$fixture_root"
    bash .octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh \
      --policy .octon/framework/capabilities/governance/policy/deny-by-default.v2.yml \
      --request "$request_file" \
      --decision "$decision_file"
  )

  jq -e '.budget_rule_id == "workflow-stage-openai"' \
    "$fixture_root/.octon/state/evidence/runs/tool-budget-metadata/receipt.latest.json" >/dev/null
  jq -e '.budget_reason_codes | index("EXECUTION_BUDGET_WARN_THRESHOLD_EXCEEDED") != null' \
    "$fixture_root/.octon/state/evidence/runs/tool-budget-metadata/receipt.latest.json" >/dev/null
  jq -e '.cost_evidence_path == ".octon/state/evidence/runs/tool-budget-metadata/cost.json"' \
    "$fixture_root/.octon/state/evidence/runs/tool-budget-metadata/receipt.latest.json" >/dev/null
}

main() {
  assert_success \
    "policy receipt writer emits budget metadata when request provides it" \
    case_receipt_includes_budget_metadata

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
