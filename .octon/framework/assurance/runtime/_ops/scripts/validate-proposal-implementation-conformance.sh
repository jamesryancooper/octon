#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
READINESS_VALIDATOR="$SCRIPT_DIR/validate-proposal-implementation-readiness.sh"

PROPOSAL_PATH=""
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

usage() {
  cat <<'EOF'
usage:
  validate-proposal-implementation-conformance.sh --package <path>
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      PROPOSAL_PATH="$1"
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -n "$PROPOSAL_PATH" ]] || { usage >&2; exit 2; }

if [[ "$PROPOSAL_PATH" = /* ]]; then
  PROPOSAL_DIR="$PROPOSAL_PATH"
else
  PROPOSAL_DIR="$ROOT_DIR/$PROPOSAL_PATH"
fi

MANIFEST="$PROPOSAL_DIR/proposal.yml"
REVIEW="$PROPOSAL_DIR/support/implementation-conformance-review.md"
legacy_archive=0

if [[ ! -d "$PROPOSAL_DIR" ]]; then
  fail "proposal packet exists"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  fail "proposal manifest exists"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

if ! yq -e '.' "$MANIFEST" >/dev/null 2>&1; then
  fail "proposal manifest parses"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi
pass "proposal manifest parses"

proposal_kind="$(yq -r '.proposal_kind // ""' "$MANIFEST")"
proposal_id="$(yq -r '.proposal_id // ""' "$MANIFEST")"
status="$(yq -r '.status // ""' "$MANIFEST")"
archive_disposition="$(yq -r '.archive.disposition // ""' "$MANIFEST")"

case "$PROPOSAL_DIR" in
  */.octon/inputs/exploratory/proposals/.archive/*)
    legacy_archive=1
    ;;
esac

case "$proposal_kind" in
  policy|architecture|migration|design) pass "proposal kind supports implementation-conformance gate" ;;
  *) fail "proposal kind supports implementation-conformance gate" ;;
esac

requires_receipt=0
requires_pass=0
case "$status" in
  implemented)
    if [[ "$legacy_archive" -eq 1 && ! -f "$REVIEW" ]]; then
      true
    else
      requires_receipt=1
      requires_pass=1
    fi
    ;;
  archived)
    if [[ "$archive_disposition" == "implemented" ]]; then
      if [[ "$legacy_archive" -eq 1 && ! -f "$REVIEW" ]]; then
        true
      else
        requires_receipt=1
        requires_pass=1
      fi
    elif [[ -f "$REVIEW" ]]; then
      requires_receipt=1
    fi
    ;;
  *)
    if [[ -f "$REVIEW" ]]; then
      requires_receipt=1
    fi
    ;;
esac

extract_field() {
  local field="$1"
  [[ -f "$REVIEW" ]] || return 0
  grep -E -i "^[[:space:]-]*${field}[[:space:]]*:" "$REVIEW" \
    | head -n 1 \
    | sed -E 's/^[^:]+:[[:space:]]*`?([^`[:space:]]+).*/\1/' \
    | tr '[:upper:]' '[:lower:]' || true
}

require_section() {
  local section="$1"
  if grep -Fqi "$section" "$REVIEW"; then
    pass "conformance review includes section: $section"
  else
    fail "conformance review includes section: $section"
  fi
}

receipt_contains_placeholder() {
  grep -Eiq '(^|[^[:alnum:]_])(TODO|TBD|FIXME)([^[:alnum:]_]|$)|not reviewed|not verified|not run|structural scaffold|pending' "$REVIEW"
}

if [[ "$requires_pass" -eq 1 ]]; then
  if [[ -f "$READINESS_VALIDATOR" ]]; then
    if bash "$READINESS_VALIDATOR" --package "$PROPOSAL_PATH"; then
      pass "implementation-grade completeness gate passes before conformance"
    else
      fail "implementation-grade completeness gate passes before conformance"
    fi
  else
    fail "implementation-grade completeness validator exists before conformance"
  fi
fi

if [[ -f "$REVIEW" ]]; then
  pass "implementation conformance review exists"

  verdict="$(extract_field "verdict")"
  unresolved_items_count="$(extract_field "unresolved_items_count")"

  if [[ "$verdict" =~ ^(pass|fail)$ ]]; then
    pass "conformance verdict is explicit"
  else
    fail "conformance verdict is explicit"
  fi

  if [[ "$unresolved_items_count" =~ ^[0-9]+$ ]]; then
    pass "unresolved item count is numeric"
  else
    fail "unresolved item count is numeric"
  fi

  for section in \
    "Blockers" \
    "Checked Evidence" \
    "Promotion Target Coverage" \
    "Implementation Map Coverage" \
    "Validator Coverage" \
    "Generated Output Coverage" \
    "Rollback Coverage" \
    "Downstream Reference Coverage" \
    "Exclusions" \
    "Final Closeout Recommendation"; do
    require_section "$section"
  done

  if [[ "$requires_pass" -eq 1 ]]; then
    [[ "$verdict" == "pass" ]] && pass "conformance gate passes for implemented lifecycle status" || fail "conformance gate passes for implemented lifecycle status"
    [[ "$unresolved_items_count" == "0" ]] && pass "no unresolved items for implemented lifecycle status" || fail "no unresolved items for implemented lifecycle status"
    if receipt_contains_placeholder; then
      fail "passing conformance receipt contains no scaffold placeholders"
    else
      pass "passing conformance receipt contains no scaffold placeholders"
    fi
    if grep -Eiq 'validate-[a-z0-9-]+\.sh|alignment-check\.sh' "$REVIEW"; then
      pass "conformance receipt records validators run"
    else
      fail "conformance receipt records validators run"
    fi
  fi
else
  if [[ "$requires_receipt" -eq 1 ]]; then
    fail "implementation conformance review exists"
  elif [[ "$legacy_archive" -eq 1 ]]; then
    warn "legacy archived proposal has no implementation conformance review"
  else
    warn "post-implementation conformance review is not required before implementation"
  fi
fi

if yq -e '.promotion_targets | type == "!!seq" and length > 0' "$MANIFEST" >/dev/null 2>&1; then
  pass "promotion targets are present"
else
  fail "promotion targets are present"
fi

target_count=0
missing_targets=0
while IFS= read -r target; do
  [[ -n "$target" ]] || continue
  target_count=$((target_count + 1))
  target_abs="$ROOT_DIR/$target"
  if [[ -e "$target_abs" ]]; then
    pass "promotion target exists: $target"
  else
    missing_targets=$((missing_targets + 1))
    if [[ "$requires_pass" -eq 1 ]]; then
      fail "promotion target exists: $target"
    else
      warn "promotion target not present yet: $target"
    fi
  fi
done < <(yq -r '.promotion_targets[]?' "$MANIFEST")

impl_map="$PROPOSAL_DIR/implementation/implementation-map.md"
if [[ "$proposal_kind" == "policy" && "$requires_pass" -eq 1 ]]; then
  [[ -f "$impl_map" ]] && pass "policy implementation map exists" || fail "policy implementation map exists"
elif [[ "$proposal_kind" == "policy" && -f "$impl_map" ]]; then
  pass "policy implementation map exists"
fi

if [[ -f "$impl_map" ]]; then
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    if grep -Fq "$target" "$impl_map"; then
      pass "implementation map covers promotion target: $target"
    else
      if [[ "$requires_pass" -eq 1 ]]; then
        fail "implementation map covers promotion target: $target"
      else
        warn "implementation map omits promotion target: $target"
      fi
    fi
  done < <(yq -r '.promotion_targets[]?' "$MANIFEST")
fi

if [[ "$requires_pass" -eq 1 && -f "$REVIEW" ]]; then
  for required_term in \
    "Promotion Target Coverage" \
    "Implementation Map Coverage" \
    "Validator Coverage" \
    "Generated Output Coverage" \
    "Rollback Coverage" \
    "Downstream Reference Coverage"; do
    if grep -Fqi "$required_term" "$REVIEW"; then
      pass "conformance receipt covers $required_term"
    else
      fail "conformance receipt covers $required_term"
    fi
  done
fi

echo "Validation summary: errors=$errors warnings=$warnings"
[[ $errors -eq 0 ]]
