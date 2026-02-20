#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"

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
    fail "missing file: ${file#$ROOT_DIR/}"
  else
    pass "found file: ${file#$ROOT_DIR/}"
  fi
}

require_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    fail "missing directory: ${dir#$ROOT_DIR/}"
  else
    pass "found directory: ${dir#$ROOT_DIR/}"
  fi
}

check_readme_orientation() {
  local readme="$1"
  local rel="${readme#$ROOT_DIR/}"

  if ! grep -qE '^# ' "$readme"; then
    fail "README missing title heading: $rel"
    return
  fi

  if ! grep -qE '^## ' "$readme"; then
    fail "README missing orientation sections: $rel"
    return
  fi

  pass "README orientation present: $rel"
}

check_subsystem_baseline() {
  local subsystem="$1"
  local root="$HARMONY_DIR/$subsystem"

  require_dir "$root"
  require_file "$root/README.md"
  check_readme_orientation "$root/README.md"
  require_file "$root/_meta/architecture/README.md"
}

check_runtime_baseline() {
  local root="$HARMONY_DIR/runtime"

  require_dir "$root"
  require_file "$root/README.md"
  check_readme_orientation "$root/README.md"
  require_file "$root/run"
  require_file "$root/run.cmd"

  require_dir "$root/_meta"
  require_file "$root/_meta/evidence/README.md"
  require_dir "$root/_ops"
  require_dir "$root/_ops/bin"
  require_dir "$root/_ops/state"

  require_dir "$root/config"
  require_dir "$root/crates"
  require_dir "$root/spec"
  require_dir "$root/wit"
}

check_meta_namespace_layout() {
  local meta_dir rel child name top_files child_count

  while IFS= read -r meta_dir; do
    rel="${meta_dir#$ROOT_DIR/}"
    top_files="$(find "$meta_dir" -mindepth 1 -maxdepth 1 -type f)"
    if [[ -n "$top_files" ]]; then
      fail "_meta directory contains loose files (must use namespaced subdirs): $rel"
    else
      pass "_meta directory has no loose files: $rel"
    fi

    child_count=0
    while IFS= read -r child; do
      [[ -z "$child" ]] && continue
      child_count=$((child_count + 1))
      name="$(basename "$child")"
      case "$name" in
        architecture|docs|evidence)
          pass "_meta namespace allowed: ${child#$ROOT_DIR/}"
          ;;
        *)
          fail "_meta namespace not allowed (${name}); expected one of architecture|docs|evidence: ${child#$ROOT_DIR/}"
          ;;
      esac

      if [[ ! -f "$child/README.md" ]]; then
        fail "missing namespace index: ${child#$ROOT_DIR/}/README.md"
      else
        pass "namespace index present: ${child#$ROOT_DIR/}/README.md"
      fi
    done < <(find "$meta_dir" -mindepth 1 -maxdepth 1 -type d | sort)

    if [[ $child_count -eq 0 ]]; then
      warn "_meta directory has no namespaced subdirectories: $rel"
    fi
  done < <(find "$HARMONY_DIR" -type d -name "_meta" | sort)
}

check_discovery_contracts() {
  require_file "$HARMONY_DIR/agency/manifest.yml"
  require_file "$HARMONY_DIR/agency/actors/agents/registry.yml"
  require_file "$HARMONY_DIR/agency/actors/assistants/registry.yml"
  require_file "$HARMONY_DIR/agency/actors/teams/registry.yml"
  require_file "$HARMONY_DIR/agency/governance/CONSTITUTION.md"
  require_file "$HARMONY_DIR/agency/governance/DELEGATION.md"
  require_file "$HARMONY_DIR/agency/governance/MEMORY.md"

  require_file "$HARMONY_DIR/capabilities/runtime/commands/manifest.yml"
  require_file "$HARMONY_DIR/capabilities/runtime/skills/manifest.yml"
  require_file "$HARMONY_DIR/capabilities/runtime/services/manifest.yml"
  require_file "$HARMONY_DIR/capabilities/runtime/services/manifest.runtime.yml"
  require_file "$HARMONY_DIR/capabilities/runtime/services/registry.runtime.yml"
  require_file "$HARMONY_DIR/capabilities/runtime/tools/manifest.yml"
  require_file "$HARMONY_DIR/capabilities/governance/policy/deny-by-default.v2.yml"
  require_file "$HARMONY_DIR/capabilities/practices/README.md"

  require_file "$HARMONY_DIR/orchestration/runtime/workflows/manifest.yml"
  require_file "$HARMONY_DIR/orchestration/runtime/workflows/registry.yml"
  require_file "$HARMONY_DIR/orchestration/runtime/missions/registry.yml"
  require_file "$HARMONY_DIR/orchestration/governance/incidents.md"

  require_file "$HARMONY_DIR/assurance/governance/CHARTER.md"
  require_file "$HARMONY_DIR/assurance/governance/weights/weights.yml"
  require_file "$HARMONY_DIR/assurance/governance/scores/scores.yml"
  require_file "$HARMONY_DIR/assurance/runtime/_ops/scripts/compute-assurance-score.sh"
  require_file "$HARMONY_DIR/assurance/runtime/_ops/scripts/assurance-gate.sh"
  require_file "$HARMONY_DIR/assurance/practices/complete.md"
  require_file "$HARMONY_DIR/assurance/practices/session-exit.md"
}

check_expected_internals() {
  require_dir "$HARMONY_DIR/agency/actors"
  require_dir "$HARMONY_DIR/agency/actors/agents"
  require_dir "$HARMONY_DIR/agency/actors/assistants"
  require_dir "$HARMONY_DIR/agency/actors/teams"
  require_dir "$HARMONY_DIR/agency/governance"

  require_dir "$HARMONY_DIR/capabilities/runtime"
  require_dir "$HARMONY_DIR/capabilities/runtime/skills"
  require_dir "$HARMONY_DIR/capabilities/runtime/commands"
  require_dir "$HARMONY_DIR/capabilities/runtime/tools"
  require_dir "$HARMONY_DIR/capabilities/runtime/services"
  require_dir "$HARMONY_DIR/capabilities/governance"
  require_dir "$HARMONY_DIR/capabilities/practices"

  require_dir "$HARMONY_DIR/cognition/principles"
  require_dir "$HARMONY_DIR/cognition/methodology"
  require_dir "$HARMONY_DIR/cognition/context"
  require_dir "$HARMONY_DIR/cognition/decisions"
  require_dir "$HARMONY_DIR/cognition/analyses"

  require_dir "$HARMONY_DIR/orchestration/runtime/workflows"
  require_dir "$HARMONY_DIR/orchestration/runtime/missions"
  require_dir "$HARMONY_DIR/orchestration/runtime"
  require_dir "$HARMONY_DIR/orchestration/governance"
  require_dir "$HARMONY_DIR/orchestration/practices"

  require_dir "$HARMONY_DIR/assurance/runtime"
  require_dir "$HARMONY_DIR/assurance/runtime/_ops"
  require_dir "$HARMONY_DIR/assurance/runtime/trust"
  require_dir "$HARMONY_DIR/assurance/governance"
  require_dir "$HARMONY_DIR/assurance/practices"
  require_dir "$HARMONY_DIR/assurance/practices/standards"

  require_dir "$HARMONY_DIR/scaffolding/patterns"
  require_dir "$HARMONY_DIR/scaffolding/templates"
  require_dir "$HARMONY_DIR/scaffolding/prompts"
  require_dir "$HARMONY_DIR/scaffolding/examples"

  require_file "$HARMONY_DIR/assurance/practices/complete.md"
  require_file "$HARMONY_DIR/assurance/practices/session-exit.md"

  require_file "$HARMONY_DIR/continuity/log.md"
  require_file "$HARMONY_DIR/continuity/tasks.json"
  require_file "$HARMONY_DIR/continuity/entities.json"
  require_file "$HARMONY_DIR/continuity/next.md"

  require_dir "$HARMONY_DIR/ideation/scratchpad"
  require_dir "$HARMONY_DIR/ideation/projects"

  require_dir "$HARMONY_DIR/output/reports"
  require_dir "$HARMONY_DIR/output/drafts"
  require_dir "$HARMONY_DIR/output/artifacts"
}

check_deprecated_capabilities_paths() {
  local deprecated
  deprecated=(
    "$HARMONY_DIR/capabilities/commands"
    "$HARMONY_DIR/capabilities/skills"
    "$HARMONY_DIR/capabilities/tools"
    "$HARMONY_DIR/capabilities/services"
    "$HARMONY_DIR/capabilities/_ops/policy"
  )

  local path rel
  for path in "${deprecated[@]}"; do
    rel="${path#$ROOT_DIR/}"
    if [[ -e "$path" ]]; then
      fail "deprecated capabilities path exists: $rel"
    else
      pass "deprecated capabilities path removed: $rel"
    fi
  done
}

check_deprecated_orchestration_paths() {
  local deprecated
  deprecated=(
    "$HARMONY_DIR/orchestration/workflows"
    "$HARMONY_DIR/orchestration/missions"
    "$HARMONY_DIR/orchestration/incidents.md"
    "$HARMONY_DIR/orchestration/incident-response.md"
  )

  local path rel
  for path in "${deprecated[@]}"; do
    rel="${path#$ROOT_DIR/}"
    if [[ -e "$path" ]]; then
      fail "deprecated orchestration path exists: $rel"
    else
      pass "deprecated orchestration path removed: $rel"
    fi
  done
}

check_deprecated_assurance_paths() {
  local deprecated
  deprecated=(
    "$HARMONY_DIR/assurance/CHARTER.md"
    "$HARMONY_DIR/assurance/DOCTRINE.md"
    "$HARMONY_DIR/assurance/CHANGELOG.md"
    "$HARMONY_DIR/assurance/complete.md"
    "$HARMONY_DIR/assurance/session-exit.md"
    "$HARMONY_DIR/assurance/standards"
    "$HARMONY_DIR/assurance/trust"
    "$HARMONY_DIR/assurance/_ops/scripts"
    "$HARMONY_DIR/assurance/_ops/state"
  )

  local path rel
  for path in "${deprecated[@]}"; do
    rel="${path#$ROOT_DIR/}"
    if [[ -e "$path" ]]; then
      fail "deprecated assurance path exists: $rel"
    else
      pass "deprecated assurance path removed: $rel"
    fi
  done
}

check_alignment_guardrail() {
  local script="$SCRIPT_DIR/validate-audit-subsystem-health-alignment.sh"
  if [[ ! -f "$script" ]]; then
    fail "missing alignment validator script: ${script#$ROOT_DIR/}"
    return
  fi
  if bash "$script" --static-only; then
    pass "audit-subsystem-health alignment guardrail (static) passed"
  else
    fail "audit-subsystem-health alignment guardrail (static) failed"
  fi
}

main() {
  echo "== Harness Structure Validation =="

  local subsystems
  subsystems=(agency capabilities cognition orchestration scaffolding assurance continuity ideation output)
  local subsystem
  for subsystem in "${subsystems[@]}"; do
    check_subsystem_baseline "$subsystem"
  done

  check_runtime_baseline
  check_meta_namespace_layout
  check_discovery_contracts
  check_expected_internals
  check_deprecated_orchestration_paths
  check_deprecated_capabilities_paths
  check_deprecated_assurance_paths
  check_alignment_guardrail

  echo
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
