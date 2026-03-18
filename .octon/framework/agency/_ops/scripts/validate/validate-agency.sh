#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
ROOT_DIR="$(cd -- "$AGENCY_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$ROOT_DIR/.." && pwd)"

MANIFEST="$AGENCY_DIR/manifest.yml"
AGENTS_REG="$AGENCY_DIR/runtime/agents/registry.yml"
ASSISTANTS_REG="$AGENCY_DIR/runtime/assistants/registry.yml"
TEAMS_REG="$AGENCY_DIR/runtime/teams/registry.yml"
CANONICAL_AGENTS_FILE="$ROOT_DIR/AGENTS.md"
ROOT_AGENTS_FILE="$REPO_ROOT/AGENTS.md"
CONSTITUTION_FILE="$AGENCY_DIR/governance/CONSTITUTION.md"
DELEGATION_FILE="$AGENCY_DIR/governance/DELEGATION.md"
MEMORY_FILE="$AGENCY_DIR/governance/MEMORY.md"
BOUNDARY_FILE="$AGENCY_DIR/governance/delegation-boundaries-v1.yml"
ARCHITECT_AGENT_FILE="$AGENCY_DIR/runtime/agents/architect/AGENT.md"
ARCHITECT_SOUL_FILE="$AGENCY_DIR/runtime/agents/architect/SOUL.md"

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
  if [[ ! -f "$file" ]]; then
    fail "missing file: $file"
  else
    pass "found file: ${file#$ROOT_DIR/}"
  fi
}

extract_id_path_pairs() {
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
  ' "$file"
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

check_registry_paths() {
  local registry_file="$1"
  local kind="$2"
  local contract_file="$3"

  local pair_count=0
  while IFS='|' read -r id relpath; do
    [[ -z "$id" || -z "$relpath" ]] && continue
    relpath="${relpath%/}"
    pair_count=$((pair_count + 1))

    local actor_dir="$AGENCY_DIR/runtime/$kind/$relpath"
    local actor_file="$actor_dir/$contract_file"

    if [[ ! -d "$actor_dir" ]]; then
      fail "$kind registry entry '$id' points to missing directory: $actor_dir"
      continue
    fi

    if [[ ! -f "$actor_file" ]]; then
      fail "$kind registry entry '$id' missing contract file: $actor_file"
      continue
    fi

    pass "$kind/$id -> ${actor_file#$ROOT_DIR/}"
  done < <(extract_id_path_pairs "$registry_file")

  if [[ $pair_count -eq 0 ]]; then
    warn "$kind registry has no id/path entries"
  fi
}

check_agent_filename_capitalization() {
  local legacy_files
  legacy_files="$(find "$AGENCY_DIR/runtime/agents" -type f -name 'agent.md' | sort || true)"

  if [[ -n "$legacy_files" ]]; then
    while IFS= read -r file; do
      [[ -z "$file" ]] && continue
      fail "legacy lowercase agent contract filename detected: ${file#$ROOT_DIR/}"
    done <<< "$legacy_files"
  else
    pass "agent contract filenames are capitalized (AGENT.md)"
  fi
}

check_agent_contract_layers() {
  local pair_count=0
  while IFS='|' read -r id relpath; do
    [[ -z "$id" || -z "$relpath" ]] && continue
    relpath="${relpath%/}"
    pair_count=$((pair_count + 1))

    local agent_dir="$AGENCY_DIR/runtime/agents/$relpath"
    local agent_file="$agent_dir/AGENT.md"
    local soul_file="$agent_dir/SOUL.md"

    if [[ ! -f "$agent_file" ]]; then
      fail "agent '$id' missing AGENT.md: $agent_file"
      continue
    fi

    if [[ ! -f "$soul_file" ]]; then
      fail "agent '$id' missing SOUL.md: $soul_file"
      continue
    fi

    if ! grep -q '^## Contract Scope' "$agent_file"; then
      fail "agent '$id' AGENT.md missing '## Contract Scope' section"
    fi

    if ! grep -q '^## Contract Scope' "$soul_file"; then
      fail "agent '$id' SOUL.md missing '## Contract Scope' section"
    fi

    if ! grep -q '^## Philosophy' "$soul_file"; then
      fail "agent '$id' SOUL.md missing '## Philosophy' section"
    fi

    if ! grep -q '\./SOUL\.md' "$agent_file"; then
      fail "agent '$id' AGENT.md must reference ./SOUL.md"
    fi

    if ! grep -q '\./AGENT\.md' "$soul_file"; then
      fail "agent '$id' SOUL.md must reference ./AGENT.md"
    fi

    if ! grep -q 'CONSTITUTION\.md' "$agent_file"; then
      fail "agent '$id' AGENT.md must reference CONSTITUTION.md"
    fi

    if ! grep -q 'DELEGATION\.md' "$agent_file"; then
      fail "agent '$id' AGENT.md must reference DELEGATION.md"
    fi

    if ! grep -q 'MEMORY\.md' "$agent_file"; then
      fail "agent '$id' AGENT.md must reference MEMORY.md"
    fi

    if ! grep -q 'CONSTITUTION\.md' "$soul_file"; then
      fail "agent '$id' SOUL.md must reference CONSTITUTION.md"
    fi

    if ! grep -q 'DELEGATION\.md' "$soul_file"; then
      fail "agent '$id' SOUL.md must reference DELEGATION.md"
    fi

    if ! grep -q 'MEMORY\.md' "$soul_file"; then
      fail "agent '$id' SOUL.md must reference MEMORY.md"
    fi

    pass "agents/$id contract layering validated (AGENT.md + SOUL.md)"
  done < <(extract_id_path_pairs "$AGENTS_REG")

  if [[ $pair_count -eq 0 ]]; then
    warn "agents registry has no id/path entries for contract layering checks"
  fi
}

check_cross_agent_contracts() {
  if ! grep -q '^## Contract Scope' "$CONSTITUTION_FILE"; then
    fail "CONSTITUTION.md missing '## Contract Scope' section"
  fi
  if ! grep -q '^## Authority and Precedence' "$CONSTITUTION_FILE"; then
    fail "CONSTITUTION.md missing '## Authority and Precedence' section"
  fi
  if ! grep -q '^## Non-Negotiables' "$CONSTITUTION_FILE"; then
    fail "CONSTITUTION.md missing '## Non-Negotiables' section"
  fi
  if ! grep -q '^## Conscience' "$CONSTITUTION_FILE"; then
    fail "CONSTITUTION.md missing '## Conscience' section"
  fi
  if ! grep -q '^### Decision Rubric' "$CONSTITUTION_FILE"; then
    fail "CONSTITUTION.md missing '### Decision Rubric' section"
  fi
  if ! grep -q '^### Red Lines' "$CONSTITUTION_FILE"; then
    fail "CONSTITUTION.md missing '### Red Lines' section"
  fi

  if ! grep -q '^## Contract Scope' "$DELEGATION_FILE"; then
    fail "DELEGATION.md missing '## Contract Scope' section"
  fi
  if ! grep -q '^## Delegation Packet Requirements' "$DELEGATION_FILE"; then
    fail "DELEGATION.md missing '## Delegation Packet Requirements' section"
  fi
  if ! grep -q '^## Authority Boundaries' "$DELEGATION_FILE"; then
    fail "DELEGATION.md missing '## Authority Boundaries' section"
  fi
  if ! grep -q '^## Escalation Triggers' "$DELEGATION_FILE"; then
    fail "DELEGATION.md missing '## Escalation Triggers' section"
  fi

  if ! grep -q '^## Contract Scope' "$MEMORY_FILE"; then
    fail "MEMORY.md missing '## Contract Scope' section"
  fi
  if ! grep -q '^## Memory Classes' "$MEMORY_FILE"; then
    fail "MEMORY.md missing '## Memory Classes' section"
  fi
  if ! grep -q '^## Retention and Placement' "$MEMORY_FILE"; then
    fail "MEMORY.md missing '## Retention and Placement' section"
  fi
  if ! grep -q '^## Privacy and Safety Constraints' "$MEMORY_FILE"; then
    fail "MEMORY.md missing '## Privacy and Safety Constraints' section"
  fi

  pass "cross-agent contracts validated (CONSTITUTION.md + DELEGATION.md + MEMORY.md)"
}

check_main_branch_deletion_policy() {
  if grep -q 'No deletion of `main` branch' "$CONSTITUTION_FILE"; then
    pass "constitution declares non-deletable main branch red line"
  else
    fail "CONSTITUTION.md missing non-deletable main branch red line"
  fi

  if grep -q 'delete protected branch `main`' "$DELEGATION_FILE"; then
    pass "delegation contract escalates delete-main requests"
  else
    fail "DELEGATION.md missing delete-main escalation trigger"
  fi

  if awk '
    $0 ~ /boundary_id:[[:space:]]*"DB-005"/ {in_block=1; next}
    in_block && /^  - boundary_id:/ {in_block=0}
    in_block && /decision_class:[[:space:]]*"protected-branch-main-deletion"/ {class_ok=1}
    in_block && /condition:[[:space:]]*"requested action deletes local or remote branch named main"/ {condition_ok=1}
    in_block && /route:[[:space:]]*"block"/ {route_ok=1}
    END {exit !(class_ok && condition_ok && route_ok)}
  ' "$BOUNDARY_FILE"; then
    pass "delegation boundaries block main-branch deletion requests"
  else
    fail "delegation-boundaries-v1.yml missing DB-005 block rule for main-branch deletion"
  fi
}

check_execution_profile_governance_contract() {
  if [[ ! -f "$CANONICAL_AGENTS_FILE" ]]; then
    fail "missing file: $CANONICAL_AGENTS_FILE"
  else
    pass "found file: ${CANONICAL_AGENTS_FILE#$ROOT_DIR/}"
  fi

  if [[ ! -f "$ROOT_AGENTS_FILE" && ! -L "$ROOT_AGENTS_FILE" ]]; then
    fail "missing file: $ROOT_AGENTS_FILE"
  else
    pass "found file: ${ROOT_AGENTS_FILE#$REPO_ROOT/}"
  fi

  if [[ -L "$ROOT_AGENTS_FILE" ]]; then
    local target
    target="$(readlink "$ROOT_AGENTS_FILE")"
    if [[ "$target" == ".octon/AGENTS.md" ]]; then
      pass "root AGENTS.md symlink points to .octon/AGENTS.md"
    else
      fail "root AGENTS.md symlink target mismatch: $target"
    fi
  elif cmp -s "$CANONICAL_AGENTS_FILE" "$ROOT_AGENTS_FILE"; then
    pass "root AGENTS.md matches .octon/AGENTS.md"
  else
    fail "root AGENTS.md diverges from .octon/AGENTS.md"
  fi

  if ! grep -q '^## Execution Profile Governance (Required)' "$CANONICAL_AGENTS_FILE"; then
    fail ".octon/AGENTS.md missing '## Execution Profile Governance (Required)' section"
  fi
  if ! grep -Fq 'change_profile' "$CANONICAL_AGENTS_FILE"; then
    fail ".octon/AGENTS.md missing change_profile governance key"
  fi
  if ! grep -Fq 'release_state' "$CANONICAL_AGENTS_FILE"; then
    fail ".octon/AGENTS.md missing release_state governance key"
  fi
  if ! grep -Fq 'transitional_exception_note' "$CANONICAL_AGENTS_FILE"; then
    fail ".octon/AGENTS.md missing transitional_exception_note governance key"
  fi
  if ! grep -Fq 'Profile Selection Receipt' "$CANONICAL_AGENTS_FILE"; then
    fail ".octon/AGENTS.md missing required section: Profile Selection Receipt"
  fi
  if ! grep -Fq 'Implementation Plan' "$CANONICAL_AGENTS_FILE"; then
    fail ".octon/AGENTS.md missing required section: Implementation Plan"
  fi
  if ! grep -Fq 'Impact Map (code, tests, docs, contracts)' "$CANONICAL_AGENTS_FILE"; then
    fail ".octon/AGENTS.md missing required section: Impact Map (code, tests, docs, contracts)"
  fi
  if ! grep -Fq 'Compliance Receipt' "$CANONICAL_AGENTS_FILE"; then
    fail ".octon/AGENTS.md missing required section: Compliance Receipt"
  fi
  if ! grep -Fq 'Exceptions/Escalations' "$CANONICAL_AGENTS_FILE"; then
    fail ".octon/AGENTS.md missing required section: Exceptions/Escalations"
  fi

  if ! grep -q '^## Execution Profile Governance' "$CONSTITUTION_FILE"; then
    fail "CONSTITUTION.md missing execution profile governance section"
  fi
  if ! grep -Fq 'change_profile' "$CONSTITUTION_FILE"; then
    fail "CONSTITUTION.md missing change_profile rule"
  fi
  if ! grep -Fq 'tie-break' "$CONSTITUTION_FILE"; then
    fail "CONSTITUTION.md missing profile tie-break rule"
  fi

  if ! grep -Fq 'change_profile' "$DELEGATION_FILE"; then
    fail "DELEGATION.md missing change_profile delegation packet requirement"
  fi
  if ! grep -Fq 'profile tie-break ambiguity' "$DELEGATION_FILE"; then
    fail "DELEGATION.md missing profile tie-break escalation trigger"
  fi
  if ! grep -Fq 'Profile Selection Receipt' "$DELEGATION_FILE"; then
    fail "DELEGATION.md missing required output section: Profile Selection Receipt"
  fi
  if ! grep -Fq 'Impact Map (code, tests, docs, contracts)' "$DELEGATION_FILE"; then
    fail "DELEGATION.md missing required output section: Impact Map (code, tests, docs, contracts)"
  fi
  if ! grep -Fq 'Compliance Receipt' "$DELEGATION_FILE"; then
    fail "DELEGATION.md missing required output section: Compliance Receipt"
  fi
  if ! grep -Fq 'Exceptions/Escalations' "$DELEGATION_FILE"; then
    fail "DELEGATION.md missing required output section: Exceptions/Escalations"
  fi

  if ! grep -Fq 'change_profile' "$MEMORY_FILE"; then
    fail "MEMORY.md missing change_profile retention requirement"
  fi
  if ! grep -Fq 'release_state' "$MEMORY_FILE"; then
    fail "MEMORY.md missing release_state retention requirement"
  fi
  if ! grep -Fq 'transitional_exception_note' "$MEMORY_FILE"; then
    fail "MEMORY.md missing transitional_exception_note retention requirement"
  fi

  if [[ ! -f "$ARCHITECT_AGENT_FILE" ]]; then
    fail "missing file: $ARCHITECT_AGENT_FILE"
  else
    pass "found file: ${ARCHITECT_AGENT_FILE#$ROOT_DIR/}"
  fi
  if [[ ! -f "$ARCHITECT_SOUL_FILE" ]]; then
    fail "missing file: $ARCHITECT_SOUL_FILE"
  else
    pass "found file: ${ARCHITECT_SOUL_FILE#$ROOT_DIR/}"
  fi
  if ! grep -Fq 'change_profile' "$ARCHITECT_AGENT_FILE"; then
    fail "architect AGENT.md missing change_profile requirement"
  fi
  if ! grep -Fq 'Profile Selection Receipt' "$ARCHITECT_AGENT_FILE"; then
    fail "architect AGENT.md missing required section: Profile Selection Receipt"
  fi
  if ! grep -Fq 'Impact Map (code, tests, docs, contracts)' "$ARCHITECT_AGENT_FILE"; then
    fail "architect AGENT.md missing required section: Impact Map (code, tests, docs, contracts)"
  fi
  if ! grep -Fq 'Compliance Receipt' "$ARCHITECT_AGENT_FILE"; then
    fail "architect AGENT.md missing required section: Compliance Receipt"
  fi
  if ! grep -Fq 'Exceptions/Escalations' "$ARCHITECT_AGENT_FILE"; then
    fail "architect AGENT.md missing required section: Exceptions/Escalations"
  fi
  if ! grep -Fq 'profile-selection tie-break ambiguity' "$ARCHITECT_SOUL_FILE"; then
    fail "architect SOUL.md missing profile tie-break ambiguity escalation stance"
  fi

  if ! grep -Fq 'execution-profile-governance' "$AGENTS_REG"; then
    fail "agents registry missing execution-profile-governance capability flag"
  fi

  if awk '
    $0 ~ /boundary_id:[[:space:]]*"DB-006"/ {in_block=1; next}
    in_block && /^  - boundary_id:/ {in_block=0}
    in_block && /decision_class:[[:space:]]*"execution-profile-tie-break"/ {class_ok=1}
    in_block && /condition:/ && /atomic/ && /transitional/ {condition_ok=1}
    in_block && /route:[[:space:]]*"escalate"/ {route_ok=1}
    END {exit !(class_ok && condition_ok && route_ok)}
  ' "$BOUNDARY_FILE"; then
    pass "delegation boundaries include DB-006 execution-profile tie-break escalation rule"
  else
    fail "delegation-boundaries-v1.yml missing DB-006 execution-profile tie-break escalation rule"
  fi

  pass "execution-profile governance contract validated"
}

check_agent_registry_contract_fields() {
  local row_count=0
  while IFS='|' read -r id contract soul; do
    [[ -z "$id" ]] && continue
    row_count=$((row_count + 1))

    if [[ -z "$contract" ]]; then
      fail "agents registry entry '$id' missing required field: contract"
      continue
    fi

    if [[ -z "$soul" ]]; then
      fail "agents registry entry '$id' missing required field: soul"
      continue
    fi

    if [[ "$contract" != "AGENT.md" ]]; then
      fail "agents registry entry '$id' contract must be AGENT.md (found: $contract)"
    fi

    if [[ "$soul" != "SOUL.md" ]]; then
      fail "agents registry entry '$id' soul must be SOUL.md (found: $soul)"
    fi

    pass "agents/$id registry contract fields validated"
  done < <(
    awk '
      /^[[:space:]]*-[[:space:]]+id:[[:space:]]*/ {
        if (in_block == 1) {
          print id "|" contract "|" soul
        }
        in_block=1
        id=$2
        sub(/^id:/, "", id)
        gsub(/"/, "", id)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
        if (id == "") {
          id=$3
          gsub(/"/, "", id)
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
        }
        contract=""
        soul=""
        next
      }
      in_block == 1 && /^[[:space:]]*contract:[[:space:]]*/ {
        contract=$2
        gsub(/"/, "", contract)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", contract)
        next
      }
      in_block == 1 && /^[[:space:]]*soul:[[:space:]]*/ {
        soul=$2
        gsub(/"/, "", soul)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", soul)
        next
      }
      END {
        if (in_block == 1) {
          print id "|" contract "|" soul
        }
      }
    ' "$AGENTS_REG"
  )

  if [[ $row_count -eq 0 ]]; then
    warn "agents registry has no entries for contract field validation"
  fi
}

check_unique_ids() {
  local registry_file="$1"
  local label="$2"

  local dupes
  dupes="$(extract_ids "$registry_file" | sort | uniq -d || true)"

  if [[ -n "$dupes" ]]; then
    while IFS= read -r d; do
      [[ -z "$d" ]] && continue
      fail "$label has duplicate id: $d"
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
        a=arr[i]
        gsub(/"/, "", a)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", a)
        if (a != "") print a
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
        a=arr[i]
        gsub(/"/, "", a)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", a)
        if (a != "" && substr(a,1,1) != "@") print a
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

check_manifest_links() {
  grep -q 'agents:\s*"runtime/agents/registry.yml"' "$MANIFEST" || fail "manifest missing agents registry link"
  grep -q 'assistants:\s*"runtime/assistants/registry.yml"' "$MANIFEST" || fail "manifest missing assistants registry link"
  grep -q 'teams:\s*"runtime/teams/registry.yml"' "$MANIFEST" || fail "manifest missing teams registry link"

  local default_agent
  default_agent="$(awk '/^default_agent:\s*/ {print $2}' "$MANIFEST" | tr -d '"')"
  if [[ -z "$default_agent" || "$default_agent" == "null" ]]; then
    fail "manifest default_agent is not set"
    return
  fi

  if ! extract_ids "$AGENTS_REG" | grep -qx "$default_agent"; then
    fail "manifest default_agent '$default_agent' not found in agents registry"
  else
    pass "manifest default_agent resolves to agents registry"
  fi
}

check_deprecations() {
  if [[ -d "$AGENCY_DIR/actors" ]]; then
    fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/actors"
  else
    pass "deprecated actors surface removed"
  fi

  if [[ -d "$AGENCY_DIR/agents" ]]; then
    fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/agents"
  else
    pass "deprecated root agency/agents path removed"
  fi

  if [[ -d "$AGENCY_DIR/assistants" ]]; then
    fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/assistants"
  else
    pass "deprecated root agency/assistants path removed"
  fi

  if [[ -d "$AGENCY_DIR/teams" ]]; then
    fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/teams"
  else
    pass "deprecated root agency/teams path removed"
  fi

  if [[ -f "$AGENCY_DIR/CONSTITUTION.md" ]]; then
    fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/CONSTITUTION.md"
  else
    pass "deprecated root governance/CONSTITUTION.md path removed"
  fi

  if [[ -f "$AGENCY_DIR/DELEGATION.md" ]]; then
    fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/DELEGATION.md"
  else
    pass "deprecated root governance/DELEGATION.md path removed"
  fi

  if [[ -f "$AGENCY_DIR/MEMORY.md" ]]; then
    fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/MEMORY.md"
  else
    pass "deprecated root governance/MEMORY.md path removed"
  fi

  if [[ -d "$AGENCY_DIR/subagents" ]]; then
    fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/subagents"
  else
    pass "deprecated subagents path removed"
  fi

  if grep -q 'agency/subagents/' "$ROOT_DIR/octon.yml"; then
    fail "octon.yml still exports deprecated agency/subagents path"
  else
    pass "octon.yml portable paths do not include deprecated subagents"
  fi

  if grep -q 'agency/actors/' "$ROOT_DIR/octon.yml"; then
    fail "octon.yml still exports deprecated agency/actors path"
  else
    pass "octon.yml portable paths do not include deprecated agency/actors path"
  fi

  if grep -q 'agency/agents/' "$ROOT_DIR/octon.yml"; then
    fail "octon.yml still exports deprecated agency/agents path"
  else
    pass "octon.yml portable paths do not include deprecated agency/agents path"
  fi

  if grep -q 'agency/assistants/' "$ROOT_DIR/octon.yml"; then
    fail "octon.yml still exports deprecated agency/assistants path"
  else
    pass "octon.yml portable paths do not include deprecated agency/assistants path"
  fi

  if grep -q 'agency/teams/' "$ROOT_DIR/octon.yml"; then
    fail "octon.yml still exports deprecated agency/teams path"
  else
    pass "octon.yml portable paths do not include deprecated agency/teams path"
  fi

  if grep -q 'agency/CONSTITUTION.md' "$ROOT_DIR/octon.yml"; then
    fail "octon.yml still exports deprecated agency/CONSTITUTION.md path"
  else
    pass "octon.yml portable paths do not include deprecated agency/CONSTITUTION.md path"
  fi

  if grep -q 'agency/DELEGATION.md' "$ROOT_DIR/octon.yml"; then
    fail "octon.yml still exports deprecated agency/DELEGATION.md path"
  else
    pass "octon.yml portable paths do not include deprecated agency/DELEGATION.md path"
  fi

  if grep -q 'agency/MEMORY.md' "$ROOT_DIR/octon.yml"; then
    fail "octon.yml still exports deprecated agency/MEMORY.md path"
  else
    pass "octon.yml portable paths do not include deprecated agency/MEMORY.md path"
  fi
}

main() {
  echo "== Agency Validation =="

  require_file "$MANIFEST"
  require_file "$AGENTS_REG"
  require_file "$ASSISTANTS_REG"
  require_file "$TEAMS_REG"
  require_file "$CONSTITUTION_FILE"
  require_file "$DELEGATION_FILE"
  require_file "$MEMORY_FILE"
  require_file "$BOUNDARY_FILE"

  check_manifest_links
  check_cross_agent_contracts
  check_main_branch_deletion_policy
  check_execution_profile_governance_contract

  check_unique_ids "$AGENTS_REG" "agents registry"
  check_unique_ids "$ASSISTANTS_REG" "assistants registry"
  check_unique_ids "$TEAMS_REG" "teams registry"

  check_registry_paths "$AGENTS_REG" "agents" "AGENT.md"
  check_registry_paths "$ASSISTANTS_REG" "assistants" "assistant.md"
  check_registry_paths "$TEAMS_REG" "teams" "team.md"
  check_agent_registry_contract_fields
  check_agent_filename_capitalization
  check_agent_contract_layers

  check_assistant_aliases
  check_deprecations

  echo ""
  echo "Validation summary: errors=$errors warnings=$warnings"

  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
