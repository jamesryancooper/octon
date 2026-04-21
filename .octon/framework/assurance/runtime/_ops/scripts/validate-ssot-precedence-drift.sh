#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

SPEC_FILE="$OCTON_DIR/framework/cognition/_meta/architecture/specification.md"
ASSURANCE_PRECEDENCE="$OCTON_DIR/framework/assurance/governance/precedence.md"
ENGINE_GOVERNANCE="$OCTON_DIR/framework/engine/governance/README.md"
CANONICAL_GOAL_PATTERN='Enable reliable (agent )?execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve\.'

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

search_files_pattern() {
  local pattern="$1"
  shift
  if command -v rg >/dev/null 2>&1; then
    rg -n -i "$pattern" "$@" || true
  else
    grep -Ein -- "$pattern" "$@" || true
  fi
}

search_octon_docs_pattern() {
  local pattern="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -n -i \
      "$pattern" \
      "$OCTON_DIR" \
      -g "**/governance/**/*.md" \
      -g "**/practices/**/*.md" \
      -g "**/_meta/architecture/**/*.md" || true
  else
    local -a md_files=()
    mapfile -t md_files < <(
      find "$OCTON_DIR" -type f -name '*.md' | grep -E '/(governance|practices|_meta/architecture)/'
    )
    if ((${#md_files[@]} == 0)); then
      return 0
    fi
    grep -Ein -- "$pattern" "${md_files[@]}" || true
  fi
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
  if grep -Fq -- "$text" "$file"; then
    pass "$message"
  else
    fail "$message"
  fi
}

require_pattern() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if grep -Eq "$pattern" "$file"; then
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
    "The machine-readable source of truth for topology, authority families," \
    "spec declares the contract registry as machine-readable structural ssot"

  require_text \
    "$SPEC_FILE" \
    "Structural interpretation flows through the contract registry rather than" \
    "spec routes structural interpretation through the contract registry"

  require_text \
    "$SPEC_FILE" \
    "through repeated hand-maintained path matrices." \
    "spec forbids repeated hand-maintained path matrices as structural ssot"

  require_text \
    "$SPEC_FILE" \
    "- \`path_families\`: canonical steady-state path families, authority classes," \
    "spec enumerates path family registry ownership"

  require_text \
    "$SPEC_FILE" \
    "- \`publication_metadata\`: runtime-facing and operator-facing publication rules" \
    "spec enumerates publication metadata registry ownership"

  require_text \
    "$SPEC_FILE" \
    "- \`doc_targets\`: steady-state roles for active authoritative docs" \
    "spec enumerates doc target registry ownership"

  require_text \
    "$SPEC_FILE" \
    "- \`runtime_authorization_coverage\`: runtime boundary, side-effect inventory," \
    "spec enumerates runtime authorization coverage registry ownership"

  require_text \
    "$SPEC_FILE" \
    "These docs are registry-backed. They must not carry:" \
    "spec declares active docs as registry-backed"

  require_text \
    "$SPEC_FILE" \
    "- full hand-maintained canonical path matrices" \
    "spec forbids hand-maintained canonical path matrices in active docs"
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
    "$OCTON_DIR/AGENTS.md"
    "$OCTON_DIR/framework/execution-roles/governance/DELEGATION.md"
    "$OCTON_DIR/framework/execution-roles/governance/MEMORY.md"
    "$OCTON_DIR/framework/execution-roles/runtime/orchestrator/ROLE.md"
  )
  local file

  for file in "${precedence_files[@]}"; do
    require_pattern \
      "$file" \
      "$CANONICAL_GOAL_PATTERN" \
      "precedence-layer goal alignment present in ${file#$ROOT_DIR/}"
  done

  local deprecated_framing_pattern
  deprecated_framing_pattern='(AI-native,\ human-governed|risk-tiered\ human\ governance|Simplicity\ Over\ Complexity|simplicity-first|smallest\ viable)'
  local deprecated_hits
  deprecated_hits="$(search_files_pattern "$deprecated_framing_pattern" "${precedence_files[@]}")"
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
  matches="$(search_octon_docs_pattern "$pattern")"

  if [[ -z "$matches" ]]; then
    pass "no conflicting precedence wording detected"
    return
  fi

  local conflict_count=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    file="${line%%:*}"
    rel="$(normalize_rel "$file")"

    if [[ "$(basename "$rel")" == "CHARTER.md" && "$rel" == *"/framework/cognition/governance/"* ]]; then
      continue
    fi

    case "$rel" in
      .octon/framework/cognition/_meta/architecture/specification.md|\
      .octon/framework/assurance/governance/precedence.md|\
      .octon/framework/engine/governance/README.md)
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
