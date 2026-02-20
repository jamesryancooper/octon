#!/usr/bin/env bash
# test-deny-by-default-runtime.sh - Runtime regression and smoke checks for deny-by-default.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SERVICES_ROOT="$CAPABILITIES_DIR/services"
SERVICES_MANIFEST="$SERVICES_ROOT/manifest.yml"
POLICY_V2_FILE="$CAPABILITIES_DIR/_ops/policy/deny-by-default.v2.yml"
ENFORCER_SCRIPT="$SERVICES_ROOT/_ops/scripts/enforce-deny-by-default.sh"
AGENT_ENTRYPOINT="$SERVICES_ROOT/execution/agent/impl/agent.sh"

if [[ ! -f "$ENFORCER_SCRIPT" ]]; then
  echo "Missing runtime enforcer script: $ENFORCER_SCRIPT" >&2
  exit 1
fi

if [[ ! -f "$SERVICES_MANIFEST" ]]; then
  echo "Missing services manifest: $SERVICES_MANIFEST" >&2
  exit 1
fi

if [[ ! -f "$AGENT_ENTRYPOINT" ]]; then
  echo "Missing agent entrypoint: $AGENT_ENTRYPOINT" >&2
  exit 1
fi

fail_count=0
pass_count=0

test_pass() {
  local name="$1"
  echo "PASS: $name"
  pass_count=$((pass_count + 1))
}

test_fail() {
  local name="$1"
  local message="$2"
  echo "FAIL: $name -- $message" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local name="$1"
  shift
  local output
  if output="$("$@" 2>&1)"; then
    test_pass "$name"
  else
    test_fail "$name" "$output"
  fi
}

assert_failure_contains() {
  local name="$1"
  local pattern="$2"
  shift 2
  local output
  if output="$("$@" 2>&1)"; then
    test_fail "$name" "expected failure containing '$pattern' but command succeeded"
    return
  fi
  if [[ "$output" == *"$pattern"* ]]; then
    test_pass "$name"
  else
    test_fail "$name" "expected pattern '$pattern', got: $output"
  fi
}

run_split_parser_regression_test() {
  assert_success \
    "split parser keeps scoped tokens under errexit" \
    bash -euo pipefail -c "
      source '$ENFORCER_SCRIPT'
      mapfile -t tokens < <(harmony_ddb_split_allowed_tools 'Read Bash(bash) Write(../../_ops/state/runs/*)')
      [[ \${#tokens[@]} -eq 3 ]]
      [[ \"\${tokens[0]}\" == 'Read' ]]
      [[ \"\${tokens[1]}\" == 'Bash(bash)' ]]
      [[ \"\${tokens[2]}\" == 'Write(../../_ops/state/runs/*)' ]]
    "

  assert_success \
    "split parser preserves whitespace inside scoped command token" \
    bash -euo pipefail -c "
      source '$ENFORCER_SCRIPT'
      mapfile -t tokens < <(harmony_ddb_split_allowed_tools 'Read Bash(bash .harmony/capabilities/services/governance/guard/impl/guard.sh *)')
      [[ \${#tokens[@]} -eq 2 ]]
      [[ \"\${tokens[1]}\" == 'Bash(bash .harmony/capabilities/services/governance/guard/impl/guard.sh *)' ]]
    "
}

active_shell_rows() {
  awk '
    /^services:/ {in_services=1; next}
    in_services && /^[[:space:]]*- id:/ {
      if (id != "" && iface == "shell" && status == "active") {
        print id "\t" path
      }
      id=$3
      gsub(/["'\'' ]/, "", id)
      path=""
      iface=""
      status=""
      next
    }
    in_services && /^[[:space:]]*path:/ {
      path=$2
      gsub(/["'\'' ]/, "", path)
      next
    }
    in_services && /^[[:space:]]*interface_type:/ {
      iface=$2
      gsub(/["'\'' ]/, "", iface)
      next
    }
    in_services && /^[[:space:]]*status:/ {
      status=$2
      gsub(/["'\'' ]/, "", status)
      next
    }
    END {
      if (id != "" && iface == "shell" && status == "active") {
        print id "\t" path
      }
    }
  ' "$SERVICES_MANIFEST"
}

service_entrypoint() {
  local service_path="$1"
  local service_md="$SERVICES_ROOT/$service_path/SERVICE.md"
  awk '
    /^[[:space:]]*entrypoint:/ {
      line=$0
      sub(/^[[:space:]]*entrypoint:[[:space:]]*/, "", line)
      gsub(/["'\'' ]/, "", line)
      print line
      exit
    }
  ' "$service_md"
}

run_active_shell_enforcement_smoke_test() {
  local row
  while IFS=$'\t' read -r service_id service_path; do
    [[ -z "$service_id" ]] && continue
    local entrypoint_rel
    entrypoint_rel="$(service_entrypoint "$service_path")"
    local entrypoint_abs="$SERVICES_ROOT/$service_path/$entrypoint_rel"

    if [[ ! -f "$entrypoint_abs" ]]; then
      test_fail "active shell $service_id entrypoint exists" "missing $entrypoint_abs"
      continue
    fi

    assert_success \
      "active shell $service_id passes runtime policy preflight" \
      bash -euo pipefail -c "
        source '$ENFORCER_SCRIPT'
        harmony_enforce_service_policy '$service_id' '$entrypoint_abs'
      "
  done < <(active_shell_rows)
}

kill_switch_state_dir() {
  awk '
    /^[[:space:]]*kill_switch:/ {in_kill=1; next}
    in_kill && /^[[:space:]]*state_dir:/ {
      line=$0
      sub(/^[[:space:]]*state_dir:[[:space:]]*/, "", line)
      gsub(/["'\'' ]/, "", line)
      print line
      exit
    }
    in_kill && /^[[:space:]]*[a-z_]+:/ && $1 != "state_dir:" && $1 != "fail_closed:" {
      in_kill=0
    }
  ' "$POLICY_V2_FILE"
}

run_agent_only_required_deny_tests() {
  local guard_entrypoint="$SERVICES_ROOT/governance/guard/impl/guard.sh"

  assert_failure_contains \
    "medium tier requires review agent id" \
    "requires review agent" \
    bash -euo pipefail -c "
      source '$ENFORCER_SCRIPT'
      HARMONY_AGENT_ID=agent-a \\
      HARMONY_AGENT_IDS='agent-a,agent-b' \\
      HARMONY_RISK_TIER=medium \\
      HARMONY_ROLLBACK_PLAN_ID=rb-1 \\
      harmony_enforce_service_policy 'guard' '$guard_entrypoint'
    "

  assert_failure_contains \
    "high tier requires quorum token" \
    "requires quorum token" \
    bash -euo pipefail -c "
      source '$ENFORCER_SCRIPT'
      HARMONY_AGENT_ID=agent-a \\
      HARMONY_AGENT_IDS='agent-a,agent-b' \\
      HARMONY_REVIEW_AGENT_ID=agent-b \\
      HARMONY_RISK_TIER=high \\
      HARMONY_ROLLBACK_PLAN_ID=rb-1 \\
      harmony_enforce_service_policy 'guard' '$guard_entrypoint'
    "

  local ks_dir ks_record
  ks_dir="$(kill_switch_state_dir)"
  mkdir -p "$ks_dir"
  ks_record="$ks_dir/test-runtime-kill-switch.yml"
  cat > "$ks_record" <<'EOF'
id: "test-runtime-kill-switch"
scope: "global"
state: "active"
owner: "runtime-test"
reason: "kill switch runtime regression"
created: "2026-01-01"
expires: "2099-12-31"
EOF

  assert_failure_contains \
    "kill switch blocks agent-only execution" \
    "kill-switch is active" \
    bash -euo pipefail -c "
      source '$ENFORCER_SCRIPT'
      HARMONY_AGENT_ID=agent-a \\
      HARMONY_AGENT_IDS='agent-a' \\
      HARMONY_RISK_TIER=low \\
      harmony_enforce_service_policy 'guard' '$guard_entrypoint'
    "

  rm -f "$ks_record"
}

run_acp_gate_tests() {
  local guard_entrypoint="$SERVICES_ROOT/governance/guard/impl/guard.sh"
  local receipt_run_id="runtime-acp-receipt-${RANDOM:-0}-$$"

  assert_success \
    "acp stage phase allows execution" \
    bash -euo pipefail -c "
      source '$ENFORCER_SCRIPT'
      HARMONY_AGENT_ID=agent-a \\
      HARMONY_AGENT_IDS='agent-a' \\
      HARMONY_RISK_TIER=low \\
      HARMONY_OPERATION_PHASE=stage \\
      harmony_enforce_service_policy 'guard' '$guard_entrypoint'
    "

  assert_failure_contains \
    "acp promote phase blocks promotion on stage-only decision" \
    "promotion blocked" \
    bash -euo pipefail -c "
      source '$ENFORCER_SCRIPT'
      HARMONY_AGENT_ID=agent-a \\
      HARMONY_AGENT_IDS='agent-a' \\
      HARMONY_RISK_TIER=low \\
      HARMONY_POLICY_PROFILE=refactor \\
      HARMONY_OPERATION_CLASS=git.commit \\
      HARMONY_OPERATION_PHASE=promote \\
      HARMONY_RUN_ID='$receipt_run_id' \\
      harmony_enforce_service_policy 'guard' '$guard_entrypoint'
    "

  assert_success \
    "acp guard temp files are cleaned by default" \
    bash -euo pipefail -c "
      request_file='.harmony/capabilities/_ops/state/.tmp/acp/$receipt_run_id-guard-request.json'
      decision_file='.harmony/capabilities/_ops/state/.tmp/acp/$receipt_run_id-guard-decision.json'
      [[ ! -e \"\$request_file\" ]]
      [[ ! -e \"\$decision_file\" ]]
    "

  assert_success \
    "acp receipt validates against policy contract" \
    bash -euo pipefail -c "
      receipt='.harmony/continuity/runs/$receipt_run_id/receipt.latest.json'
      [[ -f \"\$receipt\" ]]
      .harmony/capabilities/_ops/scripts/run-harmony-policy.sh receipt-validate --policy '$POLICY_V2_FILE' --receipt \"\$receipt\" >/dev/null
    "

  assert_success \
    "acp digest mirrors receipt metadata" \
    bash -euo pipefail -c "
      receipt='.harmony/continuity/runs/$receipt_run_id/receipt.latest.json'
      digest='.harmony/continuity/runs/$receipt_run_id/digest.latest.md'
      [[ -f \"\$receipt\" ]]
      [[ -f \"\$digest\" ]]
      op_class=\"\$(jq -r '.operation.class // \"\"' \"\$receipt\")\"
      decision=\"\$(jq -r '.decision // \"\"' \"\$receipt\")\"
      [[ -n \"\$op_class\" ]]
      [[ -n \"\$decision\" ]]
      grep -F -- \"- Operation Class: \" \"\$digest\" >/dev/null
      grep -F -- \"- Decision: \" \"\$digest\" >/dev/null
      grep -F -- \"\$op_class\" \"\$digest\" >/dev/null
      grep -F -- \"\$decision\" \"\$digest\" >/dev/null
    "

  assert_success \
    "acp receipts append decision log" \
    bash -euo pipefail -c "
      [[ -s '.harmony/capabilities/_ops/state/logs/acp-decisions.jsonl' ]]
    "
}

run_service_wrapper_budget_metering_tests() {
  local guard_entrypoint="$SERVICES_ROOT/governance/guard/impl/guard.sh"
  local budget_run_id="runtime-acp-budget-${RANDOM:-0}-$$"

  assert_failure_contains \
    "service wrapper auto-meters counters when caller omits them" \
    "promotion blocked" \
    bash -euo pipefail -c "
      source '$ENFORCER_SCRIPT'
      target_file='.harmony/cognition/principles/README.md'
      backup_file=\"\$(mktemp \"\${TMPDIR:-/tmp}/acp-budget-meter.XXXXXX\")\"
      cleanup() {
        cp \"\$backup_file\" \"\$target_file\"
        rm -f \"\$backup_file\"
      }
      trap cleanup EXIT
      cp \"\$target_file\" \"\$backup_file\"

      i=1
      while [[ \$i -le 1800 ]]; do
        printf 'budget metering regression line %04d\n' \"\$i\" >> \"\$target_file\"
        i=\$((i + 1))
      done

      evidence_json=\"\$(jq -cn '[{type:\"diff\",ref:\"artifact://diff\",sha256:\"hash-diff\"}]')\"
      HARMONY_AGENT_ID=agent-a \\
      HARMONY_AGENT_IDS='agent-a' \\
      HARMONY_RISK_TIER=low \\
      HARMONY_POLICY_PROFILE=refactor \\
      HARMONY_OPERATION_CLASS=service.execute \\
      HARMONY_OPERATION_PHASE=promote \\
      HARMONY_RUN_ID='$budget_run_id' \\
      HARMONY_ACP_EVIDENCE_JSON=\"\$evidence_json\" \\
      HARMONY_ACP_COUNTERS_JSON='' \\
      harmony_enforce_service_policy 'guard' '$guard_entrypoint'
    "

  assert_success \
    "service wrapper budget metering emits ACP_BUDGET_EXCEEDED with measured counters" \
    bash -euo pipefail -c "
      receipt='.harmony/continuity/runs/$budget_run_id/receipt.latest.json'
      [[ -f \"\$receipt\" ]]
      jq -e '.reason_codes | index(\"ACP_BUDGET_EXCEEDED\") != null' \"\$receipt\" >/dev/null
      jq -e '.decision == \"STAGE_ONLY\" or .decision == \"DENY\"' \"\$receipt\" >/dev/null
      jq -e '.counters[\"repo.max_loc_delta\"] > 1500' \"\$receipt\" >/dev/null
      jq -e '.counters[\"repo.git_diff_unknown\"] == 0' \"\$receipt\" >/dev/null
    "
}

run_acp_breaker_action_tests() {
  local guard_entrypoint="$SERVICES_ROOT/governance/guard/impl/guard.sh"
  local breaker_run_id="runtime-acp-breaker-${RANDOM:-0}-$$"
  local ks_dir
  ks_dir="$(kill_switch_state_dir)"

  assert_failure_contains \
    "acp breaker blocks wrapper promotion and keeps staged output" \
    "promotion blocked" \
    bash -euo pipefail -c "
      source '$ENFORCER_SCRIPT'
      target_json=\"\$(jq -cn '{branch:\"feature/runtime-breaker\"}')\"
      evidence_json=\"\$(jq -cn '[{type:\"diff\",ref:\"artifact://diff\",sha256:\"hash-diff\"},{type:\"tests\",ref:\"artifact://tests\",sha256:\"hash-tests\"}]')\"
      signals_json=\"\$(jq -cn '[\"ci.failed\"]')\"
      HARMONY_AGENT_ID=agent-a \\
      HARMONY_AGENT_IDS='agent-a' \\
      HARMONY_RISK_TIER=low \\
      HARMONY_POLICY_PROFILE=refactor \\
      HARMONY_OPERATION_CLASS=git.merge \\
      HARMONY_OPERATION_PHASE=promote \\
      HARMONY_RUN_ID='$breaker_run_id' \\
      HARMONY_ACP_TARGET_JSON=\"\$target_json\" \\
      HARMONY_ACP_EVIDENCE_JSON=\"\$evidence_json\" \\
      HARMONY_ACP_SIGNALS_JSON=\"\$signals_json\" \\
      harmony_enforce_service_policy 'guard' '$guard_entrypoint'
    "

  assert_success \
    "acp breaker writes rollback action artifact in wrapper path" \
    bash -euo pipefail -c "
      rollback_log='.harmony/continuity/runs/$breaker_run_id/rollback/rollback-attempt.txt'
      [[ -f \"\$rollback_log\" ]]
      grep -F 'breaker-actions=' \"\$rollback_log\" >/dev/null
    "

  assert_success \
    "acp breaker trips kill-switch in wrapper path" \
    bash -euo pipefail -c "
      ks_dir='$ks_dir'
      run_id='$breaker_run_id'
      ks_file=''
      for file in \"\$ks_dir\"/*.yml \"\$ks_dir\"/*.yaml \"\$ks_dir\"/*.json; do
        [[ -e \"\$file\" ]] || continue
        incident=\"\$(jq -r '.incident_id // empty' \"\$file\" 2>/dev/null || true)\"
        state=\"\$(jq -r '.state // empty' \"\$file\" 2>/dev/null || true)\"
        if [[ \"\$incident\" == \"\$run_id\" && \"\$state\" == 'active' ]]; then
          ks_file=\"\$file\"
          break
        fi
      done
      [[ -n \"\$ks_file\" ]]
      rm -f \"\$ks_file\"
    "
}

run_agent_quorum_independence_tests() {
  local run_stage_only="runtime-agent-quorum-stage-${RANDOM:-0}-$$"
  local run_allow="runtime-agent-quorum-allow-${RANDOM:-0}-$$"

  assert_success \
    "agent ACP-2 promote degrades to stage-only without independent attestations" \
    bash -euo pipefail -c "
      payload=\"\$(jq -cn --arg run_id '$run_stage_only' --arg plan '.harmony/cognition/principles/autonomous-control-points.md' '
        {
          mode:\"execute\",
          runId:\$run_id,
          planPath:\$plan,
          dryRun:false,
          operationClass:\"git.merge\",
          phase:\"promote\",
          profile:\"operate\",
          target:{branch:\"main\"}
        }')\"
      output=\"\$(printf '%s' \"\$payload\" | HARMONY_AGENT_ID='agent-proposer' '$AGENT_ENTRYPOINT')\"
      [[ \"\$(jq -r '.result.decision' <<<\"\$output\")\" == 'STAGE_ONLY' ]]
      printf '%s\n' \"\$output\" | grep -F 'ACP_QUORUM_MISSING' >/dev/null
    "

  assert_success \
    "agent ACP-2 promote allows with external verifier and recovery attestations" \
    bash -euo pipefail -c "
      attestation_dir='.harmony/continuity/runs/$run_allow/attestations'
      mkdir -p \"\$attestation_dir\"
      jq -n '{
        role:\"verifier\",
        actor_id:\"agent-verifier\",
        signature:\"sig-verifier\"
      }' > \"\$attestation_dir/verifier.attestation.json\"
      jq -n '{
        role:\"recovery\",
        actor_id:\"agent-recovery\",
        signature:\"sig-recovery\"
      }' > \"\$attestation_dir/recovery.attestation.json\"

      payload=\"\$(jq -cn --arg run_id '$run_allow' --arg plan '.harmony/cognition/principles/autonomous-control-points.md' '
        {
          mode:\"execute\",
          runId:\$run_id,
          planPath:\$plan,
          dryRun:false,
          operationClass:\"git.merge\",
          phase:\"promote\",
          profile:\"operate\",
          target:{branch:\"main\"}
        }')\"
      output=\"\$(printf '%s' \"\$payload\" | HARMONY_AGENT_ID='agent-proposer' '$AGENT_ENTRYPOINT')\"
      [[ \"\$(jq -r '.result.decision' <<<\"\$output\")\" == 'ALLOW' ]]
    "
}

main() {
  run_split_parser_regression_test
  run_active_shell_enforcement_smoke_test
  run_agent_only_required_deny_tests
  run_acp_gate_tests
  run_service_wrapper_budget_metering_tests
  run_acp_breaker_action_tests
  run_agent_quorum_independence_tests

  echo ""
  echo "Runtime deny-by-default tests complete: $pass_count passed, $fail_count failed"

  if (( fail_count > 0 )); then
    exit 1
  fi
}

main "$@"
