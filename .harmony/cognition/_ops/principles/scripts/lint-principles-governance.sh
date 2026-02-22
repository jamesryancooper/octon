#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
cd "$ROOT_DIR"

PRINCIPLES_DIR="${PRINCIPLES_DIR_OVERRIDE:-.harmony/cognition/governance/principles}"
REFERENCE_LINT="${REFERENCE_LINT_OVERRIDE:-.harmony/cognition/_ops/principles/scripts/reference-lint.sh}"

declare -i failures=0

if [[ ! -d "$PRINCIPLES_DIR" ]]; then
  echo "[missing-dir] principles directory not found: $PRINCIPLES_DIR"
  exit 1
fi

sha256_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
    return
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
    return
  fi
  return 1
}

check_immutable_principles_charter() {
  local charter="$PRINCIPLES_DIR/principles.md"
  local expected_hash="b2d61746507843b74575189a71e47c680f1109f79973d13a4344fa248ac69647"
  local actual_hash=""

  if [[ ! -f "$charter" ]]; then
    echo "[immutable-charter] missing immutable charter: $charter"
    failures+=1
    return
  fi

  if ! rg -q -i '^status:[[:space:]]*binding$' "$charter"; then
    echo "[immutable-charter] charter must declare 'status: Binding'."
    failures+=1
  fi

  if ! rg -q '^mutability:[[:space:]]*immutable$' "$charter"; then
    echo "[immutable-charter] charter must declare 'mutability: immutable'."
    failures+=1
  fi

  if ! rg -q '^agent_editable:[[:space:]]*false$' "$charter"; then
    echo "[immutable-charter] charter must declare 'agent_editable: false'."
    failures+=1
  fi

  if ! rg -q '^risk_tier:[[:space:]]*critical$' "$charter"; then
    echo "[immutable-charter] charter must declare 'risk_tier: critical'."
    failures+=1
  fi

  if ! rg -q '^change_policy:[[:space:]]*supersede-only$' "$charter"; then
    echo "[immutable-charter] charter must declare 'change_policy: supersede-only'."
    failures+=1
  fi

  if ! actual_hash="$(sha256_file "$charter")"; then
    echo "[immutable-charter] unable to compute sha256 for $charter"
    failures+=1
    return
  fi

  if [[ "$actual_hash" != "$expected_hash" ]]; then
    echo "[immutable-charter] checksum mismatch for $charter"
    echo "[immutable-charter] expected: $expected_hash"
    echo "[immutable-charter] actual:   $actual_hash"
    echo "[immutable-charter] charter is immutable; create a versioned successor plus ADR instead of editing it."
    failures+=1
  fi
}

check_forbidden_terms() {
  local file=""
  local line=""
  local pattern=""

  local -a forbidden=(
    '\bHITL\b'
    'hard checkpoint'
    'must approve'
    'authorization checkpoint'
    'hitl-checkpoints\.md'
  )

  while IFS= read -r file; do
    for pattern in "${forbidden[@]}"; do
      while IFS= read -r line; do
        if [[ "$line" =~ [Dd]eprecated || "$line" =~ [Nn]o[[:space:]]+longer || "$line" =~ [Rr]emoved ]]; then
          continue
        fi
        echo "[forbidden-term] $file: $line"
        failures+=1
      done < <(rg -n -i "$pattern" "$file" || true)
    done
  done < <(find "$PRINCIPLES_DIR" -type f -name '*.md' | sort)
}

check_pr_only_runtime_gating() {
  local raw_hits filtered_hits

  raw_hits="$(rg -n -i '\b(must|required|requires)\b[^\n]{0,120}\bPR\b' "$PRINCIPLES_DIR" --glob '*.md' || true)"

  filtered_hits="$(printf '%s\n' "$raw_hits" | rg -i -v 'if a PR exists|projection|receipt|acp|promot|guidance' || true)"
  if [[ -n "$filtered_hits" ]]; then
    echo "[pr-only-gating] Found PR-only normative language without ACP/receipt equivalence:"
    printf '%s\n' "$filtered_hits"
    failures+=1
  fi
}

check_human_approval_runtime_dependency() {
  local pattern negation_pattern raw_hits hits

  pattern='require[sd]?(ing)?[^[:cntrl:]\n]{0,80}human approval|must[^[:cntrl:]\n]{0,80}be[^[:cntrl:]\n]{0,40}approved[^[:cntrl:]\n]{0,40}by[^[:cntrl:]\n]{0,20}human|block[^[:cntrl:]\n]{0,80}until[^[:cntrl:]\n]{0,40}approved'
  negation_pattern='does not require[^[:cntrl:]\n]{0,80}human approval|do not require[^[:cntrl:]\n]{0,80}human approval|not[^[:cntrl:]\n]{0,40}human approval|no[^[:cntrl:]\n]{0,40}human[^[:cntrl:]\n]{0,20}approval|not[^[:cntrl:]\n]{0,40}default runtime gate|optional review'

  raw_hits="$(rg -n -i "$pattern" "$PRINCIPLES_DIR" --glob '*.md' || true)"
  hits="$(printf '%s\n' "$raw_hits" | rg -i -v "$negation_pattern" || true)"
  if [[ -n "$hits" ]]; then
    echo "[runtime-human-gate] Found runtime dependency on human approval language:"
    printf '%s\n' "$hits"
    failures+=1
  fi
}

check_arbitration_ssot_drift() {
  local arbitration_doc="$PRINCIPLES_DIR/arbitration-and-precedence.md"
  local duplicate

  duplicate="$(rg -n '^##[[:space:]]+Arbitration and Precedence' "$PRINCIPLES_DIR" --glob '*.md' --glob '!**/arbitration-and-precedence.md' || true)"
  if [[ -n "$duplicate" ]]; then
    echo "[arbitration-drift] duplicate 'Arbitration and Precedence' section outside SSOT:"
    printf '%s\n' "$duplicate"
    failures+=1
  fi

  if [[ ! -f "$arbitration_doc" ]]; then
    echo "[arbitration-drift] missing arbitration SSOT: $arbitration_doc"
    failures+=1
  fi
}

check_stale_migration_phrasing() {
  local acp_doc="$PRINCIPLES_DIR/autonomous-control-points.md"
  local stale_hits

  if [[ ! -f "$acp_doc" ]]; then
    echo "[stale-migration] missing ACP principle file: $acp_doc"
    failures+=1
    return
  fi

  if ! rg -q '## Historical Note \(Non-Normative\)' "$acp_doc"; then
    echo "[stale-migration] ACP historical note heading missing."
    failures+=1
  fi

  stale_hits="$(rg -n -i 'manual runtime checkpoint|manual review gate|human-on-the-loop' "$PRINCIPLES_DIR" --glob '*.md' --glob '!**/autonomous-control-points.md' || true)"
  if [[ -n "$stale_hits" ]]; then
    echo "[stale-migration] stale migration phrasing found outside ACP historical note:"
    printf '%s\n' "$stale_hits"
    failures+=1
  fi
}

check_arbitration_pointer_standardization() {
  local legacy
  local file
  local pointer='See \[Arbitration and Precedence\]\(\./arbitration-and-precedence\.md\) \(SSOT\) for conflict resolution\.'
  local -a required=(
    "$PRINCIPLES_DIR/autonomous-control-points.md"
    "$PRINCIPLES_DIR/deny-by-default.md"
    "$PRINCIPLES_DIR/determinism.md"
    "$PRINCIPLES_DIR/guardrails.md"
    "$PRINCIPLES_DIR/no-silent-apply.md"
    "$PRINCIPLES_DIR/observability-as-a-contract.md"
    "$PRINCIPLES_DIR/ownership-and-boundaries.md"
    "$PRINCIPLES_DIR/reversibility.md"
    "$PRINCIPLES_DIR/small-diffs-trunk-based.md"
  )

  legacy="$(rg -n 'If this principle conflicts with another, apply|normative arbitration rules live only in the|This section is informational only' "$PRINCIPLES_DIR" --glob '*.md' || true)"
  if [[ -n "$legacy" ]]; then
    echo "[arbitration-pointer] legacy arbitration boilerplate detected:"
    printf '%s\n' "$legacy"
    failures+=1
  fi

  for file in "${required[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "[arbitration-pointer] missing required principle file: $file"
      failures+=1
      continue
    fi
    if ! rg -q "$pointer" "$file"; then
      echo "[arbitration-pointer] missing standardized arbitration pointer: $file"
      failures+=1
    fi
  done
}

check_contraction_finalize_glossary() {
  local glossary=".harmony/cognition/governance/controls/ra-acp-glossary.md"

  if [[ ! -f "$glossary" ]]; then
    echo "[glossary-contraction] missing glossary: $glossary"
    failures+=1
    return
  fi

  if ! rg -q '`finalize`' "$glossary"; then
    echo "[glossary-contraction] glossary must define `finalize`."
    failures+=1
  fi

  if ! rg -q '`contraction`:[^[:cntrl:]\n]{0,120}alias' "$glossary"; then
    echo "[glossary-contraction] glossary must define `contraction` as alias semantics."
    failures+=1
  fi
}

check_waiver_exception_ssot_links() {
  local file
  local references_pattern='waivers-and-exceptions\.md'
  local terms_pattern='\bwaiver(s)?\b|\bexception(s)?\b'
  local -a required=(
    "$PRINCIPLES_DIR/accessibility-baseline.md"
    "$PRINCIPLES_DIR/guardrails.md"
    "$PRINCIPLES_DIR/security-and-privacy-baseline.md"
    "$PRINCIPLES_DIR/small-diffs-trunk-based.md"
    "$PRINCIPLES_DIR/deny-by-default.md"
    "$PRINCIPLES_DIR/autonomous-control-points.md"
  )

  for file in "${required[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "[waiver-exception-ssot] missing required principle file: $file"
      failures+=1
      continue
    fi
    if ! rg -q -i "$terms_pattern" "$file"; then
      continue
    fi
    if ! rg -q "$references_pattern" "$file"; then
      echo "[waiver-exception-ssot] $file uses waiver/exception language without SSOT reference"
      failures+=1
    fi
  done
}

check_canonical_matrix_links() {
  local file count
  local -a required=(
    "$PRINCIPLES_DIR/autonomous-control-points.md"
    "$PRINCIPLES_DIR/documentation-is-code.md"
    "$PRINCIPLES_DIR/observability-as-a-contract.md"
    "$PRINCIPLES_DIR/contract-first.md"
  )

  for file in "${required[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "[canonical-matrix] missing required principle file: $file"
      failures+=1
      continue
    fi
    count="$(rg -c 'ra-acp-promotion-inputs-matrix\.md' "$file" || true)"
    if [[ "$count" -ne 1 ]]; then
      echo "[canonical-matrix] $file must include exactly one matrix link; found $count"
      failures+=1
    fi
  done
}

check_canonical_glossary_links() {
  local file count
  local -a required=(
    "$PRINCIPLES_DIR/autonomous-control-points.md"
    "$PRINCIPLES_DIR/deny-by-default.md"
    "$PRINCIPLES_DIR/documentation-is-code.md"
    "$PRINCIPLES_DIR/observability-as-a-contract.md"
    "$PRINCIPLES_DIR/contract-first.md"
    "$PRINCIPLES_DIR/no-silent-apply.md"
    "$PRINCIPLES_DIR/ownership-and-boundaries.md"
    "$PRINCIPLES_DIR/determinism.md"
    "$PRINCIPLES_DIR/determinism-and-provenance.md"
  )

  for file in "${required[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "[canonical-glossary] missing required principle file: $file"
      failures+=1
      continue
    fi
    count="$(rg -c 'ra-acp-glossary\.md' "$file" || true)"
    if [[ "$count" -lt 1 ]]; then
      echo "[canonical-glossary] $file must reference RA/ACP glossary."
      failures+=1
    fi
  done
}

check_risk_mapping_reference() {
  local file
  local -a required=(
    "$PRINCIPLES_DIR/autonomous-control-points.md"
    "$PRINCIPLES_DIR/observability-as-a-contract.md"
  )

  for file in "${required[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "[risk-mapping] missing required principle file: $file"
      failures+=1
      continue
    fi
    if ! rg -q 'acp\.risk_tier_mapping|risk tier to ACP mapping is policy-canonical' "$file"; then
      echo "[risk-mapping] $file must reference policy-canonical risk tier mapping."
      failures+=1
    fi
  done

  local redeclared
  redeclared="$(rg -n '\|[[:space:]]*Risk tier[[:space:]]*\|[[:space:]]*ACP level[[:space:]]*\|' "$PRINCIPLES_DIR" --glob '*.md' || true)"
  if [[ -n "$redeclared" ]]; then
    echo "[risk-mapping] Risk tier to ACP table is re-declared outside canonical matrix:"
    printf '%s\n' "$redeclared"
    failures+=1
  fi
}

if [[ ! -x "$REFERENCE_LINT" ]]; then
  echo "[missing-script] reference lint script is missing or not executable: $REFERENCE_LINT"
  failures+=1
else
  if ! PRINCIPLES_DIR_OVERRIDE="$PRINCIPLES_DIR" "$REFERENCE_LINT"; then
    failures+=1
  fi
fi

check_canonical_matrix_links
check_canonical_glossary_links
check_risk_mapping_reference
check_forbidden_terms
check_pr_only_runtime_gating
check_human_approval_runtime_dependency
check_arbitration_ssot_drift
check_waiver_exception_ssot_links
check_stale_migration_phrasing
check_arbitration_pointer_standardization
check_contraction_finalize_glossary
check_immutable_principles_charter

if [[ "$failures" -gt 0 ]]; then
  echo "Principles governance lint failed with $failures issue(s)."
  exit 1
fi

echo "Principles governance lint passed."
