#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$AGENCY_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

MANIFEST="$AGENCY_DIR/manifest.yml"
AGENTS_REG="$AGENCY_DIR/runtime/agents/registry.yml"
ASSISTANTS_REG="$AGENCY_DIR/runtime/assistants/registry.yml"
TEAMS_REG="$AGENCY_DIR/runtime/teams/registry.yml"
CANONICAL_AGENTS_FILE="$OCTON_DIR/AGENTS.md"
INSTANCE_AGENTS_FILE="$OCTON_DIR/instance/ingress/AGENTS.md"
ROOT_AGENTS_FILE="$ROOT_DIR/AGENTS.md"
ROOT_CLAUDE_FILE="$ROOT_DIR/CLAUDE.md"
CONSTITUTION_FILE="$AGENCY_DIR/governance/CONSTITUTION.md"
DELEGATION_FILE="$AGENCY_DIR/governance/DELEGATION.md"
MEMORY_FILE="$AGENCY_DIR/governance/MEMORY.md"
BOUNDARY_FILE="$AGENCY_DIR/governance/delegation-boundaries-v1.yml"
ORCHESTRATOR_AGENT_FILE="$AGENCY_DIR/runtime/agents/orchestrator/AGENT.md"
VERIFIER_AGENT_FILE="$AGENCY_DIR/runtime/agents/verifier/AGENT.md"

errors=0
warnings=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

warn() {
  echo "[WARN] $1"
  warnings=$((warnings + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    pass "found file: ${file#$ROOT_DIR/}"
  else
    fail "missing file: ${file#$ROOT_DIR/}"
  fi
}

validate_root_ingress_adapter() {
  local file_path="$1"
  local label="$2"
  local target=""

  if [[ ! -f "$file_path" && ! -L "$file_path" ]]; then
    fail "missing file: ${file_path#$ROOT_DIR/}"
    return
  fi

  pass "found file: ${file_path#$ROOT_DIR/}"

  if [[ -L "$file_path" ]]; then
    target="$(readlink "$file_path")"
    if [[ "$target" == ".octon/AGENTS.md" ]]; then
      pass "$label symlink points to .octon/AGENTS.md"
    else
      fail "$label symlink target mismatch: $target"
    fi
    return
  fi

  if cmp -s "$CANONICAL_AGENTS_FILE" "$file_path"; then
    pass "$label matches .octon/AGENTS.md"
  else
    fail "$label must be a symlink to .octon/AGENTS.md or a byte-for-byte parity copy"
  fi
}

extract_ids() {
  local file="$1"
  awk '
    /^[[:space:]]*-[[:space:]]+id:[[:space:]]*/ {
      id=$2
      sub(/^id:/, "", id)
      gsub(/"/, "", id)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
      if (id == "") {
        id=$3
        gsub(/"/, "", id)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
      }
      if (id != "") print id
    }
  ' "$file"
}

check_registry_contract_paths() {
  local registry_file="$1"
  local runtime_kind="$2"
  local contract_name="$3"
  local pair_count=0

  while IFS='|' read -r id relpath; do
    [[ -z "$id" || -z "$relpath" ]] && continue
    pair_count=$((pair_count + 1))
    local actor_dir="$AGENCY_DIR/runtime/$runtime_kind/${relpath%/}"
    local contract_file="$actor_dir/$contract_name"
    if [[ ! -d "$actor_dir" ]]; then
      fail "$runtime_kind registry entry '$id' points to missing directory: ${actor_dir#$ROOT_DIR/}"
      continue
    fi
    if [[ ! -f "$contract_file" ]]; then
      fail "$runtime_kind registry entry '$id' missing contract file: ${contract_file#$ROOT_DIR/}"
      continue
    fi
    pass "$runtime_kind/$id -> ${contract_file#$ROOT_DIR/}"
  done < <(awk '
    /^[[:space:]]*-[[:space:]]+id:[[:space:]]*/ {
      id=$2
      sub(/^id:/, "", id)
      gsub(/"/, "", id)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
      if (id == "") {
        id=$3
        gsub(/"/, "", id)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
      }
      next
    }
    /^[[:space:]]*path:[[:space:]]*/ {
      path=$2
      gsub(/"/, "", path)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", path)
      if (id != "" && path != "") {
        print id "|" path
        id=""
      }
    }
  ' "$registry_file")

  if [[ $pair_count -eq 0 ]]; then
    warn "$runtime_kind registry has no id/path entries"
  fi
}

check_unique_ids() {
  local registry_file="$1"
  local label="$2"
  local dupes
  dupes="$(extract_ids "$registry_file" | sort | uniq -d || true)"
  if [[ -n "$dupes" ]]; then
    while IFS= read -r dup; do
      [[ -z "$dup" ]] && continue
      fail "$label has duplicate id: $dup"
    done <<< "$dupes"
  else
    pass "$label IDs are unique"
  fi
}

check_assistant_aliases() {
  local dupes
  dupes="$(awk '
    /aliases:[[:space:]]*\[/ {
      line=$0
      sub(/.*\[/, "", line)
      sub(/\].*/, "", line)
      n=split(line, arr, ",")
      for (i=1; i<=n; i++) {
        alias=arr[i]
        gsub(/"/, "", alias)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", alias)
        if (alias != "") print alias
      }
    }
  ' "$ASSISTANTS_REG" | sort | uniq -d || true)"
  if [[ -n "$dupes" ]]; then
    while IFS= read -r alias; do
      [[ -z "$alias" ]] && continue
      fail "assistant alias collision: $alias"
    done <<< "$dupes"
  else
    pass "assistant aliases are unique"
  fi

  local bad_aliases
  bad_aliases="$(awk '
    /aliases:[[:space:]]*\[/ {
      line=$0
      sub(/.*\[/, "", line)
      sub(/\].*/, "", line)
      n=split(line, arr, ",")
      for (i=1; i<=n; i++) {
        alias=arr[i]
        gsub(/"/, "", alias)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", alias)
        if (alias != "" && substr(alias, 1, 1) != "@") print alias
      }
    }
  ' "$ASSISTANTS_REG" || true)"
  if [[ -n "$bad_aliases" ]]; then
    while IFS= read -r alias; do
      [[ -z "$alias" ]] && continue
      fail "assistant alias must start with '@': $alias"
    done <<< "$bad_aliases"
  else
    pass "assistant aliases use @-prefix"
  fi
}

check_manifest_and_roles() {
  grep -q '^default_agent:[[:space:]]*orchestrator' "$MANIFEST" || fail "manifest default_agent must be orchestrator"
  grep -q 'default_execution_model:[[:space:]]*"single-accountable-orchestrator"' "$MANIFEST" || fail "manifest must encode single-accountable-orchestrator execution model"
  grep -q '^default:[[:space:]]*orchestrator' "$AGENTS_REG" || fail "agents registry default must be orchestrator"

  if ! extract_ids "$AGENTS_REG" | grep -qx 'orchestrator'; then
    fail "agents registry must include orchestrator"
  else
    pass "agents registry includes orchestrator"
  fi

  if ! extract_ids "$AGENTS_REG" | grep -qx 'verifier'; then
    fail "agents registry must include verifier"
  else
    pass "agents registry includes verifier"
  fi

  local default_execution_roles
  default_execution_roles="$(grep -c 'default_execution_role:[[:space:]]*true' "$AGENTS_REG" || true)"
  if [[ "$default_execution_roles" -ne 1 ]]; then
    fail "exactly one default_execution_role must be true in agents registry"
  else
    pass "agents registry declares exactly one default execution role"
  fi

  if ! awk '
    $0 ~ /- id:[[:space:]]*orchestrator/ {in_block=1; next}
    in_block && /^  - id:/ {in_block=0}
    in_block && /default_execution_role:[[:space:]]*true/ {default_ok=1}
    in_block && /boundary_value:/ {boundary_ok=1}
    END {exit !(default_ok && boundary_ok)}
  ' "$AGENTS_REG"; then
    fail "orchestrator registry block must declare default_execution_role=true and a boundary_value"
  else
    pass "orchestrator registry block declares accountable default role"
  fi

  if ! awk '
    $0 ~ /- id:[[:space:]]*verifier/ {in_block=1; next}
    in_block && /^  - id:/ {in_block=0}
    in_block && /activation_criteria:/ {criteria_block=1}
    in_block && /boundary_value:/ {boundary_ok=1}
    in_block && criteria_block && /^[[:space:]]*-[[:space:]]*"?.+/ {criteria_count++}
    END {exit !(boundary_ok && criteria_count >= 1)}
  ' "$AGENTS_REG"; then
    fail "verifier registry block must declare boundary_value and activation_criteria"
  else
    pass "verifier registry block declares bounded activation criteria"
  fi

  if grep -q 'soul:' "$AGENTS_REG"; then
    warn "agents registry still includes optional soul fields"
  else
    pass "agents registry does not treat SOUL.md as required contract metadata"
  fi
}

check_governance_and_contracts() {
  require_file "$DELEGATION_FILE"
  require_file "$MEMORY_FILE"
  require_file "$BOUNDARY_FILE"
  require_file "$ORCHESTRATOR_AGENT_FILE"
  require_file "$VERIFIER_AGENT_FILE"

  grep -q '^## Execution Profile Governance' "$INSTANCE_AGENTS_FILE" || fail "instance ingress AGENTS.md missing execution profile governance section"
  if grep -Fq '.octon/framework/cognition/_meta/architecture/specification.md' "$INSTANCE_AGENTS_FILE"; then
    fail "instance ingress AGENTS.md must not keep cognition architecture in the minimal constitutional read set"
  else
    pass "instance ingress AGENTS.md excludes cognition architecture from the minimal read set"
  fi
  if grep -Fq '.octon/framework/cognition/governance/principles/README.md' "$INSTANCE_AGENTS_FILE"; then
    fail "instance ingress AGENTS.md must not keep cognition principles in the minimal constitutional read set"
  else
    pass "instance ingress AGENTS.md excludes cognition principles from the minimal read set"
  fi
  if grep -Fq '5. `.octon/instance/bootstrap/START.md`' "$INSTANCE_AGENTS_FILE"; then
    fail "instance ingress AGENTS.md must not keep bootstrap START in the minimal constitutional read set"
  else
    pass "instance ingress AGENTS.md keeps bootstrap START outside the minimal read set"
  fi
  if [[ -f "$CONSTITUTION_FILE" ]]; then
    grep -Fq 'Historical Agency Constitutional Shim' "$CONSTITUTION_FILE" || fail "historical CONSTITUTION.md must declare itself historical"
    grep -Fq 'no longer part of the required execution path' "$CONSTITUTION_FILE" || fail "historical CONSTITUTION.md must stay out of the required execution path"
  fi

  grep -Fq 'Profile Selection Receipt' "$DELEGATION_FILE" || fail "DELEGATION.md missing required output section: Profile Selection Receipt"
  grep -Fq 'Impact Map (code, tests, docs, contracts)' "$DELEGATION_FILE" || fail "DELEGATION.md missing required output section: Impact Map (code, tests, docs, contracts)"
  grep -Fq 'Compliance Receipt' "$DELEGATION_FILE" || fail "DELEGATION.md missing required output section: Compliance Receipt"
  grep -Fq 'Exceptions/Escalations' "$DELEGATION_FILE" || fail "DELEGATION.md missing required output section: Exceptions/Escalations"

  grep -Fq 'release_state' "$MEMORY_FILE" || fail "MEMORY.md missing release_state retention rule"
  grep -Fq 'transitional_exception_note' "$MEMORY_FILE" || fail "MEMORY.md missing transitional_exception_note retention rule"
  grep -Fq 'state/evidence/runs' "$MEMORY_FILE" || fail "MEMORY.md must keep run evidence runtime-backed"

  grep -Fq 'single accountable default execution role' "$ORCHESTRATOR_AGENT_FILE" || fail "orchestrator AGENT.md must state accountable default role"
  grep -Fq 'Profile Selection Receipt' "$ORCHESTRATOR_AGENT_FILE" || fail "orchestrator AGENT.md missing Profile Selection Receipt requirement"
  grep -Fq 'Impact Map (code, tests, docs, contracts)' "$ORCHESTRATOR_AGENT_FILE" || fail "orchestrator AGENT.md missing Impact Map requirement"
  grep -Fq 'Compliance Receipt' "$ORCHESTRATOR_AGENT_FILE" || fail "orchestrator AGENT.md missing Compliance Receipt requirement"
  grep -Fq 'Exceptions/Escalations' "$ORCHESTRATOR_AGENT_FILE" || fail "orchestrator AGENT.md missing Exceptions/Escalations requirement"
  grep -Fq 'host and model adapters' "$ORCHESTRATOR_AGENT_FILE" || fail "orchestrator AGENT.md must describe non-authoritative adapter handling"
  if grep -Fq 'SOUL.md' "$ORCHESTRATOR_AGENT_FILE"; then
    fail "orchestrator AGENT.md must not depend on SOUL.md in the kernel path"
  else
    pass "orchestrator AGENT.md excludes SOUL.md from the kernel path"
  fi

  grep -Fq 'separation of duties' "$VERIFIER_AGENT_FILE" || fail "verifier AGENT.md must justify the role through separation of duties"
  grep -Fq 'not a second default owner' "$VERIFIER_AGENT_FILE" || fail "verifier AGENT.md must reject second-owner behavior"
  if grep -Fq 'SOUL.md' "$VERIFIER_AGENT_FILE"; then
    fail "verifier AGENT.md must not depend on SOUL.md in the kernel path"
  else
    pass "verifier AGENT.md excludes SOUL.md from the kernel path"
  fi

  if awk '
    $0 ~ /boundary_id:[[:space:]]*"DB-006"/ {in_block=1; next}
    in_block && /^  - boundary_id:/ {in_block=0}
    in_block && /decision_class:[[:space:]]*"execution-profile-tie-break"/ {class_ok=1}
    in_block && /route:[[:space:]]*"escalate"/ {route_ok=1}
    END {exit !(class_ok && route_ok)}
  ' "$BOUNDARY_FILE"; then
    pass "delegation boundaries include execution-profile tie-break escalation rule"
  else
    fail "delegation-boundaries-v1.yml missing execution-profile tie-break escalation rule"
  fi
}

check_assistants_and_teams() {
  if awk '
    /^[[:space:]]*escalates_to:[[:space:]]*/ {
      value=$2
      gsub(/"/, "", value)
      if (value != "orchestrator") exit 1
    }
  ' "$ASSISTANTS_REG"; then
    pass "assistants escalate to orchestrator"
  else
    fail "all assistants must escalate to orchestrator"
  fi

  grep -q 'lead_agent:[[:space:]]*orchestrator' "$TEAMS_REG" || fail "teams registry lead_agent must be orchestrator"
  grep -q 'agents: \[orchestrator, verifier\]' "$TEAMS_REG" || fail "teams registry must keep orchestrator/verifier composition"
  grep -Fq 'orchestrator-owns' "$TEAMS_REG" || fail "teams registry must encode orchestrator-owned handoff policy"

  check_assistant_aliases
}

check_instance_ingress() {
  grep -Fq '.octon/framework/agency/runtime/agents/orchestrator/AGENT.md' "$INSTANCE_AGENTS_FILE" || fail "instance ingress must reference orchestrator execution profile"
  if grep -Fq 'runtime/agents/orchestrator/SOUL.md' "$INSTANCE_AGENTS_FILE"; then
    fail "instance ingress must not treat SOUL.md as required authority"
  else
    pass "instance ingress does not require a SOUL overlay"
  fi
  if grep -Fq 'framework/agency/governance/CONSTITUTION.md' "$INSTANCE_AGENTS_FILE"; then
    fail "instance ingress must not keep agency CONSTITUTION.md in the kernel path"
  else
    pass "instance ingress excludes agency CONSTITUTION.md from the kernel path"
  fi
}

check_deprecations() {
  [[ ! -d "$AGENCY_DIR/actors" ]] || fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/actors"
  [[ ! -d "$AGENCY_DIR/agents" ]] || fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/agents"
  [[ ! -d "$AGENCY_DIR/assistants" ]] || fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/assistants"
  [[ ! -d "$AGENCY_DIR/teams" ]] || fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/teams"
  [[ ! -f "$AGENCY_DIR/CONSTITUTION.md" ]] || fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/CONSTITUTION.md"
  [[ ! -f "$AGENCY_DIR/DELEGATION.md" ]] || fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/DELEGATION.md"
  [[ ! -f "$AGENCY_DIR/MEMORY.md" ]] || fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/MEMORY.md"
  [[ ! -d "$AGENCY_DIR/subagents" ]] || fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/subagents"
  [[ ! -f "$AGENCY_DIR/runtime/agents/orchestrator/SOUL.md" ]] || fail "orchestrator SOUL.md must be retired from the active kernel path"
  [[ ! -f "$AGENCY_DIR/runtime/agents/verifier/SOUL.md" ]] || fail "verifier SOUL.md must be retired from the active kernel path"
  [[ ! -f "$AGENCY_DIR/runtime/agents/_scaffold/template/SOUL.md" ]] || fail "agent scaffold must not generate SOUL.md by default"
  pass "deprecated agency surfaces remain removed"
}

main() {
  echo "== Agency Validation =="

  require_file "$MANIFEST"
  require_file "$AGENTS_REG"
  require_file "$ASSISTANTS_REG"
  require_file "$TEAMS_REG"
  require_file "$CANONICAL_AGENTS_FILE"
  require_file "$INSTANCE_AGENTS_FILE"

  validate_root_ingress_adapter "$ROOT_AGENTS_FILE" "repo-root AGENTS.md"
  if [[ -f "$ROOT_CLAUDE_FILE" || -L "$ROOT_CLAUDE_FILE" ]]; then
    validate_root_ingress_adapter "$ROOT_CLAUDE_FILE" "repo-root CLAUDE.md"
  else
    pass "repo-root CLAUDE.md not present"
  fi

  check_registry_contract_paths "$AGENTS_REG" "agents" "AGENT.md"
  check_registry_contract_paths "$ASSISTANTS_REG" "assistants" "assistant.md"
  check_registry_contract_paths "$TEAMS_REG" "teams" "team.md"
  check_unique_ids "$AGENTS_REG" "agents registry"
  check_unique_ids "$ASSISTANTS_REG" "assistants registry"
  check_unique_ids "$TEAMS_REG" "teams registry"

  check_manifest_and_roles
  check_governance_and_contracts
  check_assistants_and_teams
  check_instance_ingress
  check_deprecations

  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
