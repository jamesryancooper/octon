#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$SCRIPT_DIR/../scripts/validate-mission-plan-compiler.sh"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)}"

"$VALIDATOR" --root "$ROOT_DIR" "$@"

tmp="$(mktemp -d)"
trap 'rm -r -f "$tmp"' EXIT

cat > "$tmp/plan-node.json" <<'EOF'
{"schema_version":"plan-node-v1","node_id":"bad-node","plan_id":"plan-demo","node_type":"action_slice_candidate","title":"Bad node","purpose":"Invalid direct execution","scope":["octon"],"non_scope":[],"expected_output":"side effect","acceptance_criteria":["bad"],"evidence_requirements":[],"dependencies":[],"risks":[],"assumptions":[],"decision_points":[],"predicted_acp":"ACP-1","reversibility":"reversible","approval_requirement":{"required":false,"approval_ref":null,"blocking_before_compile":false},"support_target_tuple_refs":["support-target://repo-shell/local-readwrite"],"readiness_state":"ready","decomposition_status":"stopped","compiled_artifact_refs":{},"execution_boundary":{"direct_execution_allowed":true,"compiles_to_action_slice_candidate_only":false,"run_contract_required":false,"context_pack_required":false,"execution_authorization_required":false}}
EOF

if "$VALIDATOR" --root "$ROOT_DIR" --fixture-dir "$tmp" >/tmp/octon-mission-plan-compiler-negative.out 2>&1; then
  echo "[ERROR] validator accepted PlanNode direct execution bypass fixture" >&2
  cat /tmp/octon-mission-plan-compiler-negative.out >&2
  exit 1
fi

grep -q "PlanNode fixture blocks direct execution and non-bypass" /tmp/octon-mission-plan-compiler-negative.out

echo "[OK] Mission Plan Compiler negative direct-execution control failed closed."
