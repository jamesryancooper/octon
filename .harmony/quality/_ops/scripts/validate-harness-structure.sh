#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
QUALITY_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
HARMONY_DIR="$(cd -- "$QUALITY_DIR/.." && pwd)"
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

check_discovery_contracts() {
  require_file "$HARMONY_DIR/agency/manifest.yml"
  require_file "$HARMONY_DIR/agency/agents/registry.yml"
  require_file "$HARMONY_DIR/agency/assistants/registry.yml"
  require_file "$HARMONY_DIR/agency/teams/registry.yml"

  require_file "$HARMONY_DIR/capabilities/commands/manifest.yml"
  require_file "$HARMONY_DIR/capabilities/skills/manifest.yml"
  require_file "$HARMONY_DIR/capabilities/services/manifest.yml"
  require_file "$HARMONY_DIR/capabilities/tools/manifest.yml"

  require_file "$HARMONY_DIR/orchestration/workflows/manifest.yml"
  require_file "$HARMONY_DIR/orchestration/workflows/registry.yml"
}

check_expected_internals() {
  require_dir "$HARMONY_DIR/agency/agents"
  require_dir "$HARMONY_DIR/agency/assistants"
  require_dir "$HARMONY_DIR/agency/teams"

  require_dir "$HARMONY_DIR/capabilities/skills"
  require_dir "$HARMONY_DIR/capabilities/commands"
  require_dir "$HARMONY_DIR/capabilities/tools"
  require_dir "$HARMONY_DIR/capabilities/services"

  require_dir "$HARMONY_DIR/cognition/principles"
  require_dir "$HARMONY_DIR/cognition/methodology"
  require_dir "$HARMONY_DIR/cognition/context"
  require_dir "$HARMONY_DIR/cognition/decisions"
  require_dir "$HARMONY_DIR/cognition/analyses"

  require_dir "$HARMONY_DIR/orchestration/workflows"
  require_dir "$HARMONY_DIR/orchestration/missions"

  require_dir "$HARMONY_DIR/scaffolding/patterns"
  require_dir "$HARMONY_DIR/scaffolding/templates"
  require_dir "$HARMONY_DIR/scaffolding/prompts"
  require_dir "$HARMONY_DIR/scaffolding/examples"

  require_file "$HARMONY_DIR/quality/complete.md"
  require_file "$HARMONY_DIR/quality/session-exit.md"

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

main() {
  echo "== Harness Structure Validation =="

  local subsystems
  subsystems=(agency capabilities cognition orchestration scaffolding quality continuity ideation output)
  local subsystem
  for subsystem in "${subsystems[@]}"; do
    check_subsystem_baseline "$subsystem"
  done

  check_discovery_contracts
  check_expected_internals

  echo
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
