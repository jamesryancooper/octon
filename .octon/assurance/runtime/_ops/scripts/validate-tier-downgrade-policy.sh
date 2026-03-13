#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

AUTO_TIER_DOC="$OCTON_DIR/cognition/practices/methodology/auto-tier-assignment.md"
RISK_TIERS_DOC="$OCTON_DIR/cognition/practices/methodology/risk-tiers.md"
CI_GATES_DOC="$OCTON_DIR/cognition/practices/methodology/ci-cd-quality-gates.md"

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

require_pattern() {
  local file="$1"
  local pattern="$2"
  local description="$3"
  if rg -n "$pattern" "$file" >/dev/null; then
    pass "$description"
  else
    fail "$description (pattern not found in ${file#$ROOT_DIR/})"
  fi
}

forbid_pattern() {
  local file="$1"
  local pattern="$2"
  local description="$3"
  if rg -n "$pattern" "$file" >/dev/null; then
    fail "$description (forbidden pattern present in ${file#$ROOT_DIR/})"
  else
    pass "$description"
  fi
}

check_auto_tier_t3_block() {
  local seen allowed_false allowed_true reason_text

  read -r seen allowed_false allowed_true reason_text < <(
    awk '
      BEGIN { in_block=0; seen=0; allowed_false=0; allowed_true=0; reason_text=0 }
      /^[[:space:]]*t3_to_t1:[[:space:]]*$/ {
        in_block=1
        seen=1
        next
      }
      in_block && /^[[:space:]]*command:[[:space:]]*/ { in_block=0 }
      in_block && /^[[:space:]]*t[0-9]_to_t[0-9]:[[:space:]]*$/ { in_block=0 }
      in_block && /^[[:space:]]*allowed:[[:space:]]*false([[:space:]]|$)/ { allowed_false=1 }
      in_block && /^[[:space:]]*allowed:[[:space:]]*true([[:space:]]|$)/ { allowed_true=1 }
      in_block && /Direct T3->T1 downgrade is not allowed/ { reason_text=1 }
      END { print seen, allowed_false, allowed_true, reason_text }
    ' "$AUTO_TIER_DOC"
  )

  if [[ "${seen:-0}" == "1" ]]; then
    pass "auto-tier policy defines t3_to_t1 block"
  else
    fail "auto-tier policy missing t3_to_t1 block"
  fi

  if [[ "${allowed_false:-0}" == "1" ]]; then
    pass "auto-tier policy forbids direct T3->T1 downgrade (allowed=false)"
  else
    fail "auto-tier policy missing allowed=false in t3_to_t1 block"
  fi

  if [[ "${allowed_true:-0}" == "1" ]]; then
    fail "auto-tier policy contains allowed=true in t3_to_t1 block"
  else
    pass "auto-tier policy does not allow direct T3->T1 downgrade"
  fi

  if [[ "${reason_text:-0}" == "1" ]]; then
    pass "auto-tier policy includes explicit direct-downgrade prohibition rationale"
  else
    warn "auto-tier policy t3_to_t1 block has no explicit prohibition rationale text"
  fi
}

main() {
  echo "== Tier Downgrade Policy Validation =="

  require_file "$AUTO_TIER_DOC"
  require_file "$RISK_TIERS_DOC"
  require_file "$CI_GATES_DOC"

  check_auto_tier_t3_block

  require_pattern \
    "$AUTO_TIER_DOC" \
    "prohibited_when_path_matches" \
    "auto-tier policy defines prohibited path guardrail list for T3 downgrades"
  require_pattern \
    "$AUTO_TIER_DOC" \
    "\\.octon/\\*\\*/governance/\\*\\*" \
    "auto-tier policy guards governance path downgrades"
  require_pattern \
    "$AUTO_TIER_DOC" \
    "\\.octon/cognition/practices/methodology/\\*\\*" \
    "auto-tier policy guards methodology path downgrades"

  require_pattern \
    "$RISK_TIERS_DOC" \
    "from_t3_to_t1:[[:space:]]*false" \
    "risk-tiers policy marks T3->T1 downgrade as prohibited"
  require_pattern \
    "$RISK_TIERS_DOC" \
    "Direct T3->T1 downgrades are prohibited" \
    "risk-tiers policy states direct T3->T1 downgrade prohibition"

  require_pattern \
    "$CI_GATES_DOC" \
    "T3[[:space:]]*→[[:space:]]*T1[[:space:]]*\\|[[:space:]]*No[[:space:]]*\\|" \
    "CI gate override table marks T3->T1 as not allowed"
  forbid_pattern \
    "$CI_GATES_DOC" \
    "T3[[:space:]]*→[[:space:]]*T1[[:space:]]*\\|[[:space:]]*Yes[[:space:]]*\\|" \
    "CI gate override table does not allow T3->T1 direct downgrade"

  echo
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
