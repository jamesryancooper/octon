#!/usr/bin/env bash
# test-deny-by-default-runtime.sh - Runtime regression and smoke checks for deny-by-default.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SERVICES_ROOT="$CAPABILITIES_DIR/services"
SERVICES_MANIFEST="$SERVICES_ROOT/manifest.yml"
POLICY_V2_FILE="$CAPABILITIES_DIR/_ops/policy/deny-by-default.v2.yml"
ENFORCER_SCRIPT="$SERVICES_ROOT/_ops/scripts/enforce-deny-by-default.sh"

if [[ ! -f "$ENFORCER_SCRIPT" ]]; then
  echo "Missing runtime enforcer script: $ENFORCER_SCRIPT" >&2
  exit 1
fi

if [[ ! -f "$SERVICES_MANIFEST" ]]; then
  echo "Missing services manifest: $SERVICES_MANIFEST" >&2
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

main() {
  run_split_parser_regression_test
  run_active_shell_enforcement_smoke_test
  run_agent_only_required_deny_tests

  echo ""
  echo "Runtime deny-by-default tests complete: $pass_count passed, $fail_count failed"

  if (( fail_count > 0 )); then
    exit 1
  fi
}

main "$@"
