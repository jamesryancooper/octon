#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
EVIDENCE_ROOT=""

usage() {
  cat <<'EOF'
Usage: validate-agent-node-model-call-contract.sh [--evidence-root <path>]

Validates Agent Node v1 and Model Call Receipt v1 contract placement, schema
strength, policy binding, positive fixtures, negative controls, and context
fixture generation.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --evidence-root)
      EVIDENCE_ROOT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

rel() {
  local path="$1"
  printf '%s\n' "${path#$ROOT_DIR/}"
}

require_tool() {
  if command -v "$1" >/dev/null 2>&1; then
    pass "$1 available"
  else
    fail "$1 is required"
  fi
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "present: $(rel "$path")"
  else
    fail "missing: $(rel "$path")"
  fi
}

require_text() {
  local text="$1"
  local file="$2"
  local label="$3"
  if rg -Fq -- "$text" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

echo "== Agent Node Model Call Contract Validation =="

require_tool python3
require_tool jq
require_tool yq
require_tool rg
require_tool shasum

AGENT_SPEC="$OCTON_DIR/framework/engine/runtime/spec/agent-node-v1.md"
AGENT_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/agent-node-v1.schema.json"
MODEL_SPEC="$OCTON_DIR/framework/engine/runtime/spec/model-call-receipt-v1.md"
MODEL_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/model-call-receipt-v1.schema.json"
AGENT_MIRROR="$OCTON_DIR/framework/constitution/contracts/runtime/agent-node-v1.schema.json"
MODEL_MIRROR="$OCTON_DIR/framework/constitution/contracts/runtime/model-call-receipt-v1.schema.json"
FAMILY="$OCTON_DIR/framework/constitution/contracts/runtime/family.yml"
README="$OCTON_DIR/framework/constitution/contracts/runtime/README.md"
POLICY="$OCTON_DIR/instance/governance/policies/model-call-routing.yml"
POLICY_README="$OCTON_DIR/instance/governance/policies/README.md"

for file in \
  "$AGENT_SPEC" \
  "$AGENT_SCHEMA" \
  "$MODEL_SPEC" \
  "$MODEL_SCHEMA" \
  "$AGENT_MIRROR" \
  "$MODEL_MIRROR" \
  "$FAMILY" \
  "$README" \
  "$POLICY" \
  "$POLICY_README"; do
  require_file "$file"
done

if [[ $errors -eq 0 ]]; then
  require_text "does not authorize execution" "$AGENT_SPEC" "agent node spec rejects authorization authority"
  require_text "does not own workflow state" "$AGENT_SPEC" "agent node spec rejects workflow-state ownership"
  require_text "retained cost/usage" "$MODEL_SPEC" "model-call receipt spec requires retained cost/usage evidence"
  require_text "probabilistic model output" "$MODEL_SPEC" "model-call receipt spec rejects universal probabilistic replay"
  require_text "model-call-routing.yml" "$AGENT_SCHEMA" "agent-node schema binds model-call policy"
  require_text "model-call-routing.yml" "$MODEL_SCHEMA" "model-call receipt schema binds model-call policy"
  require_text "agent-node-v1.schema.json" "$AGENT_MIRROR" "constitutional mirror references agent-node runtime schema"
  require_text "model-call-receipt-v1.schema.json" "$MODEL_MIRROR" "constitutional mirror references model-call runtime schema"
fi

if [[ $errors -eq 0 ]]; then
  yq -e '.workflow_statechart_task_harness.agent_node_model_call.agent_node.schema_ref == ".octon/framework/constitution/contracts/runtime/agent-node-v1.schema.json"' "$FAMILY" >/dev/null \
    && pass "runtime family registers agent-node schema" \
    || fail "runtime family registers agent-node schema"
  yq -e '.workflow_statechart_task_harness.agent_node_model_call.model_call_receipt.schema_ref == ".octon/framework/constitution/contracts/runtime/model-call-receipt-v1.schema.json"' "$FAMILY" >/dev/null \
    && pass "runtime family registers model-call receipt schema" \
    || fail "runtime family registers model-call receipt schema"
  yq -e '.workflow_statechart_task_harness.agent_node_model_call.model_call_policy_ref == ".octon/instance/governance/policies/model-call-routing.yml"' "$FAMILY" >/dev/null \
    && pass "runtime family registers model-call policy" \
    || fail "runtime family registers model-call policy"
  yq -e '.schema_version == "model-call-routing-policy-v1" and .default_route == "deny" and .admissibility_requirements.context_pack_receipt_required == true and .admissibility_requirements.retained_cost_usage_receipt_required == true' "$POLICY" >/dev/null \
    && pass "model-call routing policy is fail-closed and receipt-bound" \
    || fail "model-call routing policy is fail-closed and receipt-bound"
  yq -e '.non_authority_boundaries.model_output_is_policy_authority == false and .non_authority_boundaries.model_call_policy_admits_connectors == false and .non_authority_boundaries.universal_probabilistic_replay_guaranteed == false' "$POLICY" >/dev/null \
    && pass "model-call policy preserves non-authority exclusions" \
    || fail "model-call policy preserves non-authority exclusions"
fi

if [[ $errors -eq 0 ]]; then
  input_root_pattern='inputs/exploratory/'"proposals"
  proposal_id_pattern='agent-node-model-call'"-contract"
  proposal_path_pattern="\\.octon/$input_root_pattern(/[^/]+)?/$proposal_id_pattern"
  if rg -n "$input_root_pattern|$proposal_path_pattern" \
    "$AGENT_SPEC" \
    "$AGENT_SCHEMA" \
    "$MODEL_SPEC" \
    "$MODEL_SCHEMA" \
    "$AGENT_MIRROR" \
    "$MODEL_MIRROR" \
    "$FAMILY" \
    "$README" \
    "$POLICY" \
    "$POLICY_README" \
    "$0" >/tmp/agent-node-contract-backrefs.$$ 2>/dev/null; then
    fail "durable targets must not depend on proposal-local paths or ids"
    cat /tmp/agent-node-contract-backrefs.$$
  else
    pass "durable targets avoid proposal-local paths and ids"
  fi
  rm -f /tmp/agent-node-contract-backrefs.$$
fi

if [[ -z "$EVIDENCE_ROOT" ]]; then
  EVIDENCE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agent-node-model-call.XXXXXX")"
  cleanup_evidence_root=1
else
  cleanup_evidence_root=0
  mkdir -p "$ROOT_DIR/$EVIDENCE_ROOT" 2>/dev/null || mkdir -p "$EVIDENCE_ROOT"
fi

python3 - "$ROOT_DIR" "$EVIDENCE_ROOT" <<'PY'
import copy
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

import jsonschema

ROOT = Path(sys.argv[1])
raw_evidence = Path(sys.argv[2])
if not raw_evidence.is_absolute():
    EVIDENCE = ROOT / raw_evidence
else:
    EVIDENCE = raw_evidence
EVIDENCE.mkdir(parents=True, exist_ok=True)

AGENT_SCHEMA = ROOT / ".octon/framework/engine/runtime/spec/agent-node-v1.schema.json"
MODEL_SCHEMA = ROOT / ".octon/framework/engine/runtime/spec/model-call-receipt-v1.schema.json"

def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()

def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))

def write_json(path: Path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")

def sha_file(path: Path) -> str:
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

def validate(schema, instance, label):
    jsonschema.Draft202012Validator.check_schema(schema)
    jsonschema.Draft202012Validator(schema).validate(instance)
    print(f"[OK] schema fixture passes: {label}")

def expect_fail(schema, instance, label):
    try:
        jsonschema.Draft202012Validator(schema).validate(instance)
    except jsonschema.ValidationError:
        print(f"[OK] negative fixture fails: {label}")
        return
    raise SystemExit(f"[ERROR] negative fixture unexpectedly passed: {label}")

agent_schema = read_json(AGENT_SCHEMA)
model_schema = read_json(MODEL_SCHEMA)

run_id = "run-agent-node-model-call-fixture"
base_evidence = ".octon/state/evidence/runs/run-agent-node-model-call-fixture"

agent = {
    "schema_version": "agent-node-v1",
    "agent_node_id": "agent-node-demo",
    "run_id": run_id,
    "run_root_ref": ".octon/state/control/execution/runs/run-agent-node-model-call-fixture",
    "harness_ref": ".octon/state/control/execution/runs/run-agent-node-model-call-fixture/harness/agent-node-demo.json",
    "workflow_state_ref": ".octon/state/control/execution/runs/run-agent-node-model-call-fixture/runtime-state.yml",
    "statechart_ref": ".octon/framework/engine/runtime/spec/workflow-statechart-v1.md",
    "model_call_policy_ref": ".octon/instance/governance/policies/model-call-routing.yml",
    "model_call_receipt_refs": [f"{base_evidence}/receipts/model-calls/model-call-demo.json"],
    "input_refs": [".octon/framework/engine/runtime/spec/context-pack-builder-v1.md"],
    "output_schema_ref": ".octon/framework/engine/runtime/spec/model-call-receipt-v1.schema.json",
    "output_validation_evidence_refs": [f"{base_evidence}/assurance/model-call-demo-output-validation.json"],
    "context_binding": {
        "context_pack_ref": f"{base_evidence}/context/context-pack.json",
        "context_pack_receipt_ref": f"{base_evidence}/context/context-pack-receipt.json",
        "model_visible_context_ref": f"{base_evidence}/context/model-visible-context.json",
        "model_visible_context_sha256": "sha256:" + ("a" * 64),
    },
    "tool_allowlist_refs": [".octon/instance/governance/capability-packs/repo.yml"],
    "connector_refs": [".octon/instance/governance/connectors/registry.yml"],
    "budget_refs": {
        "context_budget_ref": ".octon/instance/governance/policies/context-packing.yml",
        "token_budget_ref": ".octon/instance/governance/policies/execution-budgets.yml",
        "cost_budget_ref": ".octon/instance/governance/policies/execution-budgets.yml",
        "retry_budget_ref": ".octon/framework/constitution/contracts/runtime/retry-record-v1.schema.json",
    },
    "timeout_policy": {"timeout_seconds": 60, "timeout_route": "stage_only"},
    "retry_policy": {
        "max_attempts": 1,
        "attempts_consumed": 0,
        "retryable_failure_classes": ["transient-provider-error"],
        "retry_exhaustion_route": "deny",
    },
    "fallback_policy": {
        "fallback_allowed": True,
        "max_fallback_attempts": 1,
        "fallback_attempts_consumed": 0,
        "fallback_requires_budget": True,
        "fallback_violation_route": "deny",
    },
    "revocation_policy": {"revocation_ref_required": True, "revoked_route": "deny"},
    "terminal_state": "succeeded",
    "fail_closed_policy": {"default_route": "deny", "reason_code_refs": ["FCR-004", "FCR-013"]},
    "retained_evidence_refs": [f"{base_evidence}/receipts/model-calls/model-call-demo.json"],
    "authority_boundary": {
        "agent_node_authorizes_execution": False,
        "agent_node_owns_workflow_state": False,
        "agent_node_may_transition_workflow": False,
        "agent_node_may_schedule_work": False,
        "agent_node_may_queue_work": False,
        "agent_node_mints_grants": False,
        "agent_node_consumes_effect_tokens": False,
        "agent_node_mutates_policy": False,
        "agent_node_widens_support_claims": False,
        "agent_node_admits_connectors": False,
        "agent_node_closes_run": False,
    },
    "forbidden_authority_claims": [],
    "created_at": "2026-05-15T00:00:00Z",
}

model = {
    "schema_version": "model-call-receipt-v1",
    "receipt_id": "model-call-demo",
    "run_id": run_id,
    "agent_node_ref": f"{base_evidence}/agent-nodes/agent-node-demo.json",
    "request_id": "request-demo",
    "model_adapter_ref": ".octon/framework/engine/runtime/adapters/model/repo-local-governed.yml",
    "model_tier": "repo-local-governed",
    "support_target_tuple_ref": "tuple://repo-local-governed/repo-consequential/reference-owned/english-primary/repo-shell",
    "model_routing_policy_ref": ".octon/instance/governance/policies/model-call-routing.yml",
    "model_eligibility": {
        "decision": "eligible",
        "adapter_declared": True,
        "support_tuple_declared": True,
        "capability_pack_posture_ref": ".octon/instance/governance/capability-packs/repo.yml",
        "reason_codes": [],
    },
    "context_pack_ref": f"{base_evidence}/context/context-pack.json",
    "context_pack_receipt_ref": f"{base_evidence}/context/context-pack-receipt.json",
    "model_visible_context_ref": f"{base_evidence}/context/model-visible-context.json",
    "model_visible_context_sha256": "sha256:" + ("a" * 64),
    "input_schema_ref": ".octon/framework/engine/runtime/spec/context-pack-receipt-v1.schema.json",
    "output_schema_ref": ".octon/framework/engine/runtime/spec/model-call-receipt-v1.schema.json",
    "output_validation_result": {
        "schema_ref": ".octon/framework/engine/runtime/spec/model-call-receipt-v1.schema.json",
        "validation_status": "valid",
        "validator_ref": ".octon/framework/assurance/runtime/_ops/scripts/validate-agent-node-model-call-contract.sh",
        "retained_validation_ref": f"{base_evidence}/assurance/model-call-demo-output-validation.json",
    },
    "context_budget": {"limit": 400000, "used": 1200, "unit": "bytes", "within_budget": True},
    "token_budget": {"limit": 100000, "used": 400, "unit": "tokens", "within_budget": True},
    "retry_budget": {"limit": 1, "used": 0, "unit": "attempts", "within_budget": True},
    "cost_budget": {
        "limit_estimated_cost_usd": 1.0,
        "observed_or_estimated_cost_usd": 0.01,
        "within_budget": True,
        "cost_evidence_ref": f"{base_evidence}/receipts/model-calls/model-call-demo-cost-usage.json",
    },
    "fallback_policy": {
        "fallback_allowed": True,
        "fallback_attempts_used": 0,
        "fallback_attempts_max": 1,
        "fallback_requires_budget": True,
        "fallback_route": "stage_only",
    },
    "budget_decision": {
        "decision": "allow",
        "context_within_budget": True,
        "tokens_within_budget": True,
        "cost_within_budget": True,
        "retry_within_budget": True,
        "fallback_within_budget": True,
        "missing_cost_evidence_route": "stage_only",
    },
    "retained_cost_usage_receipt_refs": [f"{base_evidence}/receipts/model-calls/model-call-demo-cost-usage.json"],
    "terminal_outcome": {"state": "succeeded", "reason_codes": []},
    "replay_envelope": {
        "context_pack_ref": f"{base_evidence}/context/context-pack.json",
        "model_visible_context_ref": f"{base_evidence}/context/model-visible-context.json",
        "routing_policy_ref": ".octon/instance/governance/policies/model-call-routing.yml",
        "budget_receipt_refs": [f"{base_evidence}/receipts/model-calls/model-call-demo-budget.json"],
        "cost_usage_receipt_refs": [f"{base_evidence}/receipts/model-calls/model-call-demo-cost-usage.json"],
        "output_validation_ref": f"{base_evidence}/assurance/model-call-demo-output-validation.json",
        "probabilistic_output_replay_guaranteed": False,
    },
    "authority_boundary": {
        "model_output_authorizes_execution": False,
        "model_output_owns_workflow_state": False,
        "model_output_may_transition_workflow": False,
        "model_output_mints_grants": False,
        "model_output_consumes_effect_tokens": False,
        "model_output_mutates_policy": False,
        "model_output_widens_support_claims": False,
        "model_output_admits_connectors": False,
        "model_output_closes_run": False,
    },
    "forbidden_authority_claims": [],
    "evidence_refs": [f"{base_evidence}/receipts/model-calls/model-call-demo.json"],
    "timestamps": {
        "requested_at": "2026-05-15T00:00:00Z",
        "completed_at": "2026-05-15T00:00:01Z",
    },
}

validate(agent_schema, agent, "agent-node positive")
validate(model_schema, model, "model-call receipt positive")

negative_agent_cases = []
case = copy.deepcopy(agent)
del case["harness_ref"]
negative_agent_cases.append(("agent-node missing harness binding", case))
case = copy.deepcopy(agent)
case["workflow_state_ref"] = ".octon/generated/cognition/projections/materialized/workflow.yml"
negative_agent_cases.append(("agent-node generated workflow authority", case))
case = copy.deepcopy(agent)
case["authority_boundary"]["agent_node_may_transition_workflow"] = True
negative_agent_cases.append(("agent-node transition authority claim", case))
case = copy.deepcopy(agent)
case["forbidden_authority_claims"] = ["agent-owned closeout"]
negative_agent_cases.append(("agent-node forbidden authority claim", case))

for label, fixture in negative_agent_cases:
    expect_fail(agent_schema, fixture, label)

negative_model_cases = []
case = copy.deepcopy(model)
del case["context_pack_receipt_ref"]
negative_model_cases.append(("model-call missing context receipt", case))
case = copy.deepcopy(model)
case["model_routing_policy_ref"] = ".octon/instance/governance/policies/execution-budgets.yml"
negative_model_cases.append(("model-call wrong routing policy", case))
case = copy.deepcopy(model)
case["retained_cost_usage_receipt_refs"] = []
negative_model_cases.append(("model-call missing retained cost usage receipt", case))
case = copy.deepcopy(model)
case["model_visible_context_ref"] = ".octon/inputs/raw/context.json"
negative_model_cases.append(("model-call raw input context authority", case))
case = copy.deepcopy(model)
case["authority_boundary"]["model_output_closes_run"] = True
negative_model_cases.append(("model-call closeout authority claim", case))
case = copy.deepcopy(model)
case["replay_envelope"]["probabilistic_output_replay_guaranteed"] = True
negative_model_cases.append(("model-call universal replay claim", case))

for label, fixture in negative_model_cases:
    expect_fail(model_schema, fixture, label)

fixture_dir = EVIDENCE / "fixtures" / "agent-node-model-call"
write_json(fixture_dir / "agent-node-positive.json", agent)
write_json(fixture_dir / "model-call-receipt-positive.json", model)

context_dir = EVIDENCE / "fixtures" / "context-pack-positive"
context_dir.mkdir(parents=True, exist_ok=True)
model_visible = {
    "schema_version": "model-visible-context-v1",
    "serialization_format": "context-pack-builder-v1/model-visible-context-json",
    "run_id": run_id,
    "context_pack_id": "context-pack-agent-node-model-call",
    "context_policy_ref": ".octon/instance/governance/policies/context-packing.yml",
    "builder_version": "context-pack-builder-v1",
    "sources": [
        {
            "path": ".octon/framework/engine/runtime/spec/agent-node-v1.md",
            "authority_label": "authoritative",
            "inclusion_mode": "digest-only"
        }
    ],
    "source_manifest": [".octon/framework/engine/runtime/spec/agent-node-v1.md"],
    "omission_manifest": [],
    "redaction_manifest": [],
    "freshness": {"freshness_status": "valid"},
    "replay_pointers": []
}
model_visible_path = context_dir / "model-visible-context.json"
write_json(model_visible_path, model_visible)
model_hash = sha_file(model_visible_path)
(context_dir / "model-visible-context.sha256").write_text(model_hash + "\n", encoding="utf-8")

source_ref = ".octon/framework/engine/runtime/spec/agent-node-v1.md"
source_sha = sha_file(ROOT / source_ref)
source_manifest_path = context_dir / "source-manifest.json"
omissions_path = context_dir / "omissions.json"
redactions_path = context_dir / "redactions.json"
invalidation_path = context_dir / "invalidation-events.json"
write_json(source_manifest_path, [{"path": source_ref, "sha256": source_sha}])
write_json(omissions_path, [])
write_json(redactions_path, [])
write_json(invalidation_path, [])

pack = {
    "schema_version": "context-pack-v1",
    "context_pack_id": "context-pack-agent-node-model-call",
    "run_id": run_id,
    "context_policy_ref": ".octon/instance/governance/policies/context-packing.yml",
    "model_visible_context_ref": rel(model_visible_path),
    "model_visible_context_sha256": model_hash,
    "authority_sources": [
        {
            "path": source_ref,
            "authority_label": "authoritative",
            "inclusion_mode": "digest-only",
            "bytes_included": 0,
            "sha256": source_sha
        }
    ],
    "derived_sources": [],
    "non_authoritative_inputs": [],
    "omissions": [],
    "budget": {
        "max_prompt_bytes": 400000,
        "max_estimated_input_tokens": 100000
    },
    "freshness": {
        "generated_at": "2026-05-15T00:00:00Z",
        "fresh_until": "2099-01-01T00:00:00Z"
    },
    "generated_at": "2026-05-15T00:00:00Z"
}
pack_path = context_dir / "context-pack.json"
write_json(pack_path, pack)
pack_sha = sha_file(pack_path)

receipt = {
    "schema_version": "context-pack-receipt-v1",
    "receipt_id": "context-pack-receipt-agent-node-model-call",
    "context_pack_id": "context-pack-agent-node-model-call",
    "context_pack_ref": rel(pack_path),
    "context_pack_sha256": pack_sha,
    "run_id": run_id,
    "request_id": run_id,
    "builder_spec_ref": ".octon/framework/engine/runtime/spec/context-pack-builder-v1.md",
    "builder_version": "context-pack-builder-v1",
    "context_policy_ref": ".octon/instance/governance/policies/context-packing.yml",
    "model_visible_context_sha256": model_hash,
    "model_visible_context_ref": rel(model_visible_path),
    "source_manifest_ref": rel(source_manifest_path),
    "omissions_ref": rel(omissions_path),
    "redactions_ref": rel(redactions_path),
    "invalidation_events_ref": rel(invalidation_path),
    "built_at": "2026-05-15T00:00:00Z",
    "freshness": {
        "generated_at": "2026-05-15T00:00:00Z",
        "valid_until": "2099-01-01T00:00:00Z",
        "freshness_status": "valid"
    },
    "validity_state": "valid",
    "invalidation_state": "not_invalidated",
    "verification_status": "valid",
    "authority_boundary": {
        "authorize_execution_ref": ".octon/framework/engine/runtime/spec/execution-authorization-v1.md",
        "subordinate_to_authorize_execution": True
    },
    "request_binding": {
        "request_id": run_id,
        "target_id": "agent-node-model-call-fixture",
        "action_type": "validation",
        "workflow_mode": "role-mediated",
        "risk_tier": "repo-consequential",
        "support_target_tuple_ref": "tuple://repo-local-governed/repo-consequential/reference-owned/english-primary/repo-shell",
        "requires_context_evidence": True,
        "boundary_sensitive": False,
        "consequential": True
    },
    "source_summary": {
        "authority_source_count": 1,
        "evidence_source_count": 0,
        "derived_source_count": 0,
        "non_authoritative_source_count": 0,
        "required_source_count": 1,
        "failed_required_source_count": 0
    },
    "sources": [
        {
            "source_ref": source_ref,
            "source_kind": "constitutional-kernel",
            "authority_label": "authoritative",
            "required": True,
            "sha256": source_sha,
            "verification_status": "valid",
            "freshness_status": "valid"
        }
    ],
    "omissions": [],
    "failure_policy": {
        "missing_required_context_route": "DENY",
        "stale_required_context_route": "DENY",
        "invalid_required_context_route": "DENY",
        "unverifiable_required_context_route": "STAGE_ONLY",
        "reason_codes": ["FCR-004", "FCR-013"]
    },
    "replay_reconstruction_refs": [rel(model_visible_path), rel(context_dir / "model-visible-context.sha256")]
}
write_json(context_dir / "context-pack-receipt.json", receipt)

print(f"[OK] retained schema fixtures written: {rel(fixture_dir)}")
print(f"[OK] context-pack positive fixture written: {rel(context_dir)}")
PY

if [[ $errors -eq 0 ]]; then
  echo "[OK] python schema and fixture validation completed"
fi

if [[ "${cleanup_evidence_root:-0}" == "1" ]]; then
  rm -r "$EVIDENCE_ROOT"
fi

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
