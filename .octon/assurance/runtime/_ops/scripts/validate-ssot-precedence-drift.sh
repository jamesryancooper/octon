#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

SPEC_FILE="$OCTON_DIR/cognition/_meta/architecture/specification.md"
ASSURANCE_PRECEDENCE="$OCTON_DIR/assurance/governance/precedence.md"
ENGINE_GOVERNANCE="$OCTON_DIR/engine/governance/README.md"
CANONICAL_GOAL='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.'

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
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

require_text() {
  local file="$1"
  local text="$2"
  local message="$3"
  if grep -Fq "$text" "$file"; then
    pass "$message"
  else
    fail "$message"
  fi
}

normalize_rel() {
  local path="$1"
  if [[ "$path" == "$ROOT_DIR/"* ]]; then
    printf '%s' "${path#$ROOT_DIR/}"
  else
    printf '%s' "$path"
  fi
}

check_matrix_contract() {
  require_text \
    "$SPEC_FILE" \
    "## SSOT Precedence Matrix (Runtime, Governance, Practices)" \
    "spec declares SSOT precedence matrix section"

  require_text \
    "$SPEC_FILE" \
    "| runtime-execution | \`/.octon/engine/runtime/**\` |" \
    "spec matrix includes runtime-execution authority row"

  require_text \
    "$SPEC_FILE" \
    "MUST NOT override engine enforcement." \
    "spec matrix defines runtime non-override rule"

  require_text \
    "$SPEC_FILE" \
    "| governance-policy | \`/.octon/*/governance/**\` |" \
    "spec matrix includes governance-policy authority row"

  require_text \
    "$SPEC_FILE" \
    "MUST NOT be superseded by practices guidance." \
    "spec matrix defines governance non-supersession rule"

  require_text \
    "$SPEC_FILE" \
    "| operating-practices | \`/.octon/*/practices/**\` |" \
    "spec matrix includes operating-practices authority row"

  require_text \
    "$SPEC_FILE" \
    "MUST NOT override runtime or governance contracts." \
    "spec matrix defines practices non-override rule"
}

check_cross_doc_alignment() {
  require_text \
    "$ASSURANCE_PRECEDENCE" \
    "1. Engine runtime safety and lifecycle enforcement (\`engine/runtime/**\`)" \
    "assurance precedence row 1 aligns with runtime authority"

  require_text \
    "$ASSURANCE_PRECEDENCE" \
    "2. Capabilities runtime behavioral semantics (\`capabilities/runtime/**\`)" \
    "assurance precedence row 2 aligns with capability semantics"

  require_text \
    "$ASSURANCE_PRECEDENCE" \
    "3. Domain-local practices and helper guidance" \
    "assurance precedence row 3 aligns with practices layer"

  require_text \
    "$ASSURANCE_PRECEDENCE" \
    "Practices guidance is advisory and MUST NOT override runtime or governance contracts." \
    "assurance precedence declares practices as non-authoritative override layer"

  require_text \
    "$ENGINE_GOVERNANCE" \
    "If capability semantics conflict with engine enforcement, engine enforcement" \
    "engine governance declares runtime tie-breaker (condition)"

  require_text \
    "$ENGINE_GOVERNANCE" \
    "wins for execution." \
    "engine governance declares runtime tie-breaker (outcome)"
}

check_precedence_goal_alignment() {
  local precedence_files=(
    "$ROOT_DIR/AGENTS.md"
    "$OCTON_DIR/agency/governance/CONSTITUTION.md"
    "$OCTON_DIR/agency/governance/DELEGATION.md"
    "$OCTON_DIR/agency/governance/MEMORY.md"
    "$OCTON_DIR/agency/runtime/agents/architect/AGENT.md"
    "$OCTON_DIR/agency/runtime/agents/architect/SOUL.md"
  )
  local file

  for file in "${precedence_files[@]}"; do
    require_text \
      "$file" \
      "$CANONICAL_GOAL" \
      "precedence-layer goal alignment present in ${file#$ROOT_DIR/}"
  done

  local deprecated_framing_pattern
  deprecated_framing_pattern='(AI-native,\ human-governed|risk-tiered\ human\ governance|Simplicity\ Over\ Complexity|simplicity-first|smallest\ viable)'
  local deprecated_hits
  deprecated_hits="$(
    rg -n -i \
      "$deprecated_framing_pattern" \
      "${precedence_files[@]}" || true
  )"
  if [[ -z "$deprecated_hits" ]]; then
    pass "no deprecated framing tokens in precedence-layer goal surfaces"
  else
    fail "deprecated framing tokens detected in precedence-layer goal surfaces"
  fi
}

check_for_conflicting_wording() {
  local pattern
  local matches
  local line
  local file
  local rel

  pattern='(practices?.*(override|overrides|wins).*(runtime|governance)|(runtime|governance).*(override|overrides|wins).*practices?)'
  matches="$(
    rg -n -i \
      "$pattern" \
      "$OCTON_DIR" \
      -g "**/governance/**/*.md" \
      -g "**/practices/**/*.md" \
      -g "**/_meta/architecture/**/*.md" || true
  )"

  if [[ -z "$matches" ]]; then
    pass "no conflicting precedence wording detected"
    return
  fi

  local conflict_count=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    file="${line%%:*}"
    rel="$(normalize_rel "$file")"

    case "$rel" in
      .octon/cognition/_meta/architecture/specification.md|\
      .octon/assurance/governance/precedence.md|\
      .octon/engine/governance/README.md)
        continue
        ;;
    esac

    conflict_count=$((conflict_count + 1))
    fail "conflicting authority wording detected outside canonical contracts: $rel"
  done <<< "$matches"

  if [[ $conflict_count -eq 0 ]]; then
    pass "no conflicting precedence wording detected outside canonical contracts"
  fi
}

main() {
  echo "== SSOT Precedence Drift Validation =="

  require_file "$SPEC_FILE"
  require_file "$ASSURANCE_PRECEDENCE"
  require_file "$ENGINE_GOVERNANCE"

  if [[ ! -f "$SPEC_FILE" || ! -f "$ASSURANCE_PRECEDENCE" || ! -f "$ENGINE_GOVERNANCE" ]]; then
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  check_matrix_contract
  check_cross_doc_alignment
  check_precedence_goal_alignment
  check_for_conflicting_wording

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
