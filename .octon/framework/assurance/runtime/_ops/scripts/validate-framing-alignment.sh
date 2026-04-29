#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

errors=0
warnings=0

CANONICAL_GOAL='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.'
CANONICAL_GOAL_PATTERN='Enable reliable (agent )?execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve\.'
TERM_HUMAN_GOV='AI-native, '"human-governed"
TERM_RISK_TIER='risk-tiered '"human governance"
TERM_SIMPLICITY_TITLE='Simplicity '"Over Complexity"
TERM_SIMPLICITY_FIRST='simplicity-'"first"
TERM_SMALLEST='smallest '"viable"
TERM_SIMPLICITY_ID='simplicity_'"over_complexity"
TERM_QUALITY_ENGINE='Quality '"Governance Engine"
TERM_QUALITY_PATH='\.octon/'"quality/"
DEPRECATED_PATTERN="${TERM_HUMAN_GOV}|${TERM_RISK_TIER}|${TERM_SIMPLICITY_TITLE}|${TERM_SIMPLICITY_FIRST}|${TERM_SMALLEST}|${TERM_SIMPLICITY_ID}|${TERM_QUALITY_ENGINE}|${TERM_QUALITY_PATH}"
ALLOWLIST_ADR_009="$OCTON_DIR/instance/cognition/decisions/009-manifest-discovery-and-validation.md"
ALLOWLIST_TOKEN_009="${TERM_SIMPLICITY_TITLE}"
ALLOWLIST_ADR_017="$OCTON_DIR/instance/cognition/decisions/017-assurance-clean-break-migration.md"
ALLOWLIST_TOKEN_017=".octon/"'quality/'
ALLOWLIST_SUPERSEDES='Superseded by: `040-principles-charter-successor-v2026-02-24.md`'

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

has_match() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -n -m 1 "$pattern" "$file" >/dev/null 2>&1
  else
    grep -Enm 1 -- "$pattern" "$file" >/dev/null 2>&1
  fi
}

has_literal() {
  local text="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -n -F -m 1 "$text" "$file" >/dev/null 2>&1
  else
    grep -Fnm 1 -- "$text" "$file" >/dev/null 2>&1
  fi
}

search_tree() {
  local pattern="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden \
      --glob '!.git' \
      --glob '!.octon/inputs/exploratory/plans/**' \
      --glob '!.octon/framework/assurance/runtime/_ops/scripts/validate-framing-alignment.sh' \
      --glob '!.octon/framework/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh' \
      "$pattern" "$ROOT_DIR" || true
  else
    local -a candidate_files=()
    mapfile -t candidate_files < <(
      find "$ROOT_DIR" \
        \( -path '*/.git/*' -o -path "$ROOT_DIR/.octon/inputs/exploratory/plans/*" \) -prune \
        -o -type f \
        ! -name 'validate-framing-alignment.sh' \
        ! -name 'validate-ssot-precedence-drift.sh' \
        -print
    )
    if ((${#candidate_files[@]} > 0)); then
      grep -En -- "$pattern" "${candidate_files[@]}" 2>/dev/null || true
    fi
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

require_contains() {
  local file="$1"
  local pattern="$2"
  local message="$3"

  if has_match "$pattern" "$file"; then
    pass "$message"
  else
    fail "$message"
  fi
}

require_contains_literal() {
  local file="$1"
  local text="$2"
  local message="$3"

  if has_literal "$text" "$file"; then
    pass "$message"
  else
    fail "$message"
  fi
}

validate_canonical_markers() {
  require_contains "$ROOT_DIR/AGENTS.md" 'Ingress Adapter' "root AGENTS.md contains ingress-adapter framing"
  require_contains "$OCTON_DIR/AGENTS.md" 'Ingress Adapter' ".octon/AGENTS.md contains ingress-adapter framing"
  require_contains "$OCTON_DIR/README.md" 'Super-Root' ".octon/README.md contains super-root framing"
  require_contains "$OCTON_DIR/framework/cognition/governance/principles/complexity-calibration.md" 'Complexity Fitness' "complexity-calibration principle declares Complexity Fitness"
  require_contains "$OCTON_DIR/framework/cognition/governance/principles/complexity-calibration.md" 'minimal sufficient complexity' "complexity-calibration principle declares minimal sufficient complexity"
  require_contains "$OCTON_DIR/framework/assurance/governance/weights/weights.yml" 'complexity_calibration' "weights policy uses complexity_calibration id"
  require_contains "$OCTON_DIR/framework/assurance/governance/scores/scores.yml" 'complexity_calibration' "scores policy uses complexity_calibration id"
  require_contains "$OCTON_DIR/framework/assurance/governance/CHARTER.md" 'Assurance > Productivity > Integration' "assurance charter contains canonical umbrella order"
}

validate_goal_explicitness_control_points() {
  require_contains "$OCTON_DIR/instance/ingress/AGENTS.md" 'Enable reliable agent execution' "instance ingress contains canonical goal text"
  require_contains "$OCTON_DIR/framework/execution-roles/governance/DELEGATION.md" "$CANONICAL_GOAL_PATTERN" "DELEGATION.md contains canonical goal text"
  require_contains "$OCTON_DIR/framework/execution-roles/governance/MEMORY.md" "$CANONICAL_GOAL_PATTERN" "MEMORY.md contains canonical goal text"
  require_contains "$OCTON_DIR/framework/execution-roles/runtime/orchestrator/ROLE.md" "$CANONICAL_GOAL_PATTERN" "orchestrator ROLE.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/instance/bootstrap/START.md" "$CANONICAL_GOAL" ".octon/instance/bootstrap/START.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/framework/scaffolding/runtime/bootstrap/AGENTS.md" "$CANONICAL_GOAL" "bootstrap AGENTS.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/framework/scaffolding/runtime/templates/octon/START.md" "$CANONICAL_GOAL" "template octon START.md contains canonical goal text"
}

validate_deprecated_tokens() {
  local matches
  local line
  local file
  local line_no
  local snippet
  local rel

  matches="$(search_tree "$DEPRECATED_PATTERN")"
  if [[ -z "$matches" ]]; then
    pass "no deprecated framing tokens detected"
    return
  fi

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    file="${line%%:*}"
    line_no="$(printf '%s' "$line" | cut -d: -f2)"
    snippet="$(printf '%s' "$line" | cut -d: -f3-)"
    rel="$(normalize_rel "$file")"

    if [[ "$file" == "$ALLOWLIST_ADR_009" ]] && [[ "$snippet" == *"$ALLOWLIST_TOKEN_009"* ]]; then
      if has_literal "$ALLOWLIST_SUPERSEDES" "$ALLOWLIST_ADR_009"; then
        warn "allowlisted historical token retained with superseding annotation: $rel:$line_no"
        continue
      fi
      fail "allowlisted ADR missing superseding annotation: $rel:$line_no"
      continue
    fi

    if [[ "$file" == "$ALLOWLIST_ADR_017" ]] && [[ "$snippet" == *"$ALLOWLIST_TOKEN_017"* ]]; then
      if has_literal "$ALLOWLIST_SUPERSEDES" "$ALLOWLIST_ADR_017"; then
        warn "allowlisted historical token retained with superseding annotation: $rel:$line_no"
        continue
      fi
      fail "allowlisted ADR missing superseding annotation: $rel:$line_no"
      continue
    fi

    fail "deprecated framing token found: $rel:$line_no: $snippet"
  done <<< "$matches"
}

validate_active_wording_drift() {
  local purpose_file="$OCTON_DIR/framework/cognition/governance/purpose/convivial-purpose.md"
  local matches

  if command -v rg >/dev/null 2>&1; then
    matches="$(rg -n -i "five pillars|the five pillars" "$purpose_file" || true)"
  else
    matches="$(grep -Ein "five pillars|the five pillars" "$purpose_file" || true)"
  fi
  if [[ -z "$matches" ]]; then
    pass "no active five-pillar wording drift in convivial-purpose.md"
  else
    fail "active five-pillar wording drift detected in convivial-purpose.md"
  fi
}

validate_governed_autonomy_lifecycle_framing() {
  local principles="$OCTON_DIR/framework/cognition/governance/principles/principles.md"
  local charter_map="$OCTON_DIR/framework/cognition/governance/principles/charter-map.yml"
  local bootstrap="$OCTON_DIR/instance/bootstrap/START.md"
  local catalog="$OCTON_DIR/instance/bootstrap/catalog.md"
  local scope="$OCTON_DIR/instance/bootstrap/scope.md"
  local required_terms=(
    "Safe Start"
    "Safe Continuation"
    "Continuous Stewardship"
    "Connector Admission Runtime"
    "Constitutional Self-Evolution"
    "Federated Trust"
    "Local Acceptance Record"
    "run contracts"
    "execution authorization"
  )
  local term

  for term in "${required_terms[@]}"; do
    require_contains_literal "$principles" "$term" "principles charter contains governed autonomy term: $term"
    require_contains_literal "$bootstrap" "$term" "bootstrap START contains governed autonomy term: $term"
  done

  require_contains_literal "$catalog" "Safe Start" "bootstrap catalog lists Safe Start commands"
  require_contains_literal "$scope" "Connector Admission Runtime" "bootstrap scope lists Connector Admission Runtime boundary"
  require_contains_literal "$principles" "Imported proof, external attestations, generated projections, proposal packets, chat, host UI state, labels, and comments are not authority." "principles preserve imported-proof and projection non-authority"
  require_contains_literal "$bootstrap" "Imported proof and external attestations remain evidence only" "bootstrap preserves imported proof as evidence only"
  require_contains "$charter_map" 'governed_autonomy_lifecycle_surfaces:' "charter-map carries governed autonomy lifecycle mapping"
}

main() {
  echo "== Framing Alignment Validation =="
  validate_canonical_markers
  validate_goal_explicitness_control_points
  validate_active_wording_drift
  validate_governed_autonomy_lifecycle_framing
  validate_deprecated_tokens
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
