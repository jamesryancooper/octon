#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

errors=0
warnings=0

CANONICAL_GOAL='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.'
TERM_HUMAN_GOV='AI-native, '"human-governed"
TERM_RISK_TIER='risk-tiered '"human governance"
TERM_SIMPLICITY_TITLE='Simplicity '"Over Complexity"
TERM_SIMPLICITY_FIRST='simplicity-'"first"
TERM_SMALLEST='smallest '"viable"
TERM_SIMPLICITY_ID='simplicity_'"over_complexity"
TERM_QUALITY_ENGINE='Quality '"Governance Engine"
TERM_QUALITY_PATH='\.octon/'"quality/"
DEPRECATED_PATTERN="${TERM_HUMAN_GOV}|${TERM_RISK_TIER}|${TERM_SIMPLICITY_TITLE}|${TERM_SIMPLICITY_FIRST}|${TERM_SMALLEST}|${TERM_SIMPLICITY_ID}|${TERM_QUALITY_ENGINE}|${TERM_QUALITY_PATH}"
ALLOWLIST_ADR_009="$OCTON_DIR/cognition/runtime/decisions/009-manifest-discovery-and-validation.md"
ALLOWLIST_TOKEN_009="${TERM_SIMPLICITY_TITLE}"
ALLOWLIST_ADR_017="$OCTON_DIR/cognition/runtime/decisions/017-assurance-clean-break-migration.md"
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

  if rg -n -m 1 "$pattern" "$file" >/dev/null 2>&1; then
    pass "$message"
  else
    fail "$message"
  fi
}

require_contains_literal() {
  local file="$1"
  local text="$2"
  local message="$3"

  if rg -n -F -m 1 "$text" "$file" >/dev/null 2>&1; then
    pass "$message"
  else
    fail "$message"
  fi
}

validate_canonical_markers() {
  require_contains "$ROOT_DIR/AGENTS.md" 'agent-first' "root AGENTS.md contains agent-first framing"
  require_contains "$OCTON_DIR/AGENTS.md" 'agent-first' ".octon/AGENTS.md contains agent-first framing"
  require_contains "$OCTON_DIR/README.md" 'system-governed' ".octon/README.md contains system-governed framing"
  require_contains "$OCTON_DIR/cognition/governance/principles/complexity-calibration.md" 'Complexity Fitness' "complexity-calibration principle declares Complexity Fitness"
  require_contains "$OCTON_DIR/cognition/governance/principles/complexity-calibration.md" 'minimal sufficient complexity' "complexity-calibration principle declares minimal sufficient complexity"
  require_contains "$OCTON_DIR/assurance/governance/weights/weights.yml" 'complexity_calibration' "weights policy uses complexity_calibration id"
  require_contains "$OCTON_DIR/assurance/governance/scores/scores.yml" 'complexity_calibration' "scores policy uses complexity_calibration id"
  require_contains "$OCTON_DIR/assurance/governance/CHARTER.md" 'Assurance > Productivity > Integration' "assurance charter contains canonical umbrella order"
}

validate_goal_explicitness_control_points() {
  require_contains_literal "$ROOT_DIR/AGENTS.md" "$CANONICAL_GOAL" "root AGENTS.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/AGENTS.md" "$CANONICAL_GOAL" ".octon/AGENTS.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/agency/governance/CONSTITUTION.md" "$CANONICAL_GOAL" "CONSTITUTION.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/agency/governance/DELEGATION.md" "$CANONICAL_GOAL" "DELEGATION.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/agency/governance/MEMORY.md" "$CANONICAL_GOAL" "MEMORY.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/agency/runtime/agents/architect/AGENT.md" "$CANONICAL_GOAL" "architect AGENT.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/agency/runtime/agents/architect/SOUL.md" "$CANONICAL_GOAL" "architect SOUL.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/README.md" "$CANONICAL_GOAL" ".octon/README.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/START.md" "$CANONICAL_GOAL" ".octon/START.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/scaffolding/runtime/bootstrap/AGENTS.md" "$CANONICAL_GOAL" "bootstrap AGENTS.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/scaffolding/runtime/templates/octon/START.md" "$CANONICAL_GOAL" "template octon START.md contains canonical goal text"
  require_contains_literal "$OCTON_DIR/scaffolding/runtime/templates/octon/continuity/tasks.json" "$CANONICAL_GOAL" "template continuity tasks goal defaults to canonical goal text"
}

validate_deprecated_tokens() {
  local matches
  local line
  local file
  local line_no
  local snippet
  local rel

  matches="$(
    rg -n --hidden \
      --glob '!.git' \
      --glob '!.octon/output/plans/**' \
      --glob '!.octon/assurance/runtime/_ops/scripts/validate-framing-alignment.sh' \
      --glob '!.octon/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh' \
      "$DEPRECATED_PATTERN" "$ROOT_DIR" || true
  )"
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
      if rg -n -F "$ALLOWLIST_SUPERSEDES" "$ALLOWLIST_ADR_009" >/dev/null 2>&1; then
        warn "allowlisted historical token retained with superseding annotation: $rel:$line_no"
        continue
      fi
      fail "allowlisted ADR missing superseding annotation: $rel:$line_no"
      continue
    fi

    if [[ "$file" == "$ALLOWLIST_ADR_017" ]] && [[ "$snippet" == *"$ALLOWLIST_TOKEN_017"* ]]; then
      if rg -n -F "$ALLOWLIST_SUPERSEDES" "$ALLOWLIST_ADR_017" >/dev/null 2>&1; then
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
  local purpose_file="$OCTON_DIR/cognition/governance/purpose/convivial-purpose.md"
  local matches

  matches="$(rg -n -i "five pillars|the five pillars" "$purpose_file" || true)"
  if [[ -z "$matches" ]]; then
    pass "no active five-pillar wording drift in convivial-purpose.md"
  else
    fail "active five-pillar wording drift detected in convivial-purpose.md"
  fi
}

main() {
  echo "== Framing Alignment Validation =="
  validate_canonical_markers
  validate_goal_explicitness_control_points
  validate_active_wording_drift
  validate_deprecated_tokens
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
