#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
CONFORMANCE_VALIDATOR="$SCRIPT_DIR/validate-proposal-implementation-conformance.sh"

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
  validate-proposal-post-implementation-drift.sh --package <path>
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
REVIEW="$PROPOSAL_DIR/support/post-implementation-drift-churn-review.md"
REGISTRY="$ROOT_DIR/.octon/generated/proposals/registry.yml"
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

if yq -e '.' "$MANIFEST" >/dev/null 2>&1; then
  pass "proposal manifest parses"
else
  fail "proposal manifest parses"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

proposal_kind="$(yq -r '.proposal_kind // ""' "$MANIFEST")"
proposal_id="$(yq -r '.proposal_id // ""' "$MANIFEST")"
status="$(yq -r '.status // ""' "$MANIFEST")"
archive_disposition="$(yq -r '.archive.disposition // ""' "$MANIFEST")"
promotion_scope="$(yq -r '.promotion_scope // ""' "$MANIFEST")"
proposal_rel="${PROPOSAL_DIR#$ROOT_DIR/}"

case "$PROPOSAL_DIR" in
  */.octon/inputs/exploratory/proposals/.archive/*)
    legacy_archive=1
    ;;
esac

case "$proposal_kind" in
  policy|architecture|migration|design) pass "proposal kind supports post-implementation drift/churn gate" ;;
  *) fail "proposal kind supports post-implementation drift/churn gate" ;;
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
    pass "drift/churn review includes section: $section"
  else
    fail "drift/churn review includes section: $section"
  fi
}

receipt_contains_placeholder() {
  grep -Eiq '(^|[^[:alnum:]_])(TODO|TBD|FIXME)([^[:alnum:]_]|$)|not reviewed|not verified|not run|structural scaffold|pending' "$REVIEW"
}

if [[ "$requires_pass" -eq 1 ]]; then
  if [[ -f "$CONFORMANCE_VALIDATOR" ]]; then
    if bash "$CONFORMANCE_VALIDATOR" --package "$PROPOSAL_PATH"; then
      pass "implementation conformance gate passes before drift/churn"
    else
      fail "implementation conformance gate passes before drift/churn"
    fi
  else
    fail "implementation conformance validator exists before drift/churn"
  fi
fi

if [[ -f "$REVIEW" ]]; then
  pass "post-implementation drift/churn review exists"

  verdict="$(extract_field "verdict")"
  unresolved_items_count="$(extract_field "unresolved_items_count")"

  if [[ "$verdict" =~ ^(pass|fail)$ ]]; then
    pass "drift/churn verdict is explicit"
  else
    fail "drift/churn verdict is explicit"
  fi

  if [[ "$unresolved_items_count" =~ ^[0-9]+$ ]]; then
    pass "unresolved item count is numeric"
  else
    fail "unresolved item count is numeric"
  fi

  for section in \
    "Blockers" \
    "Checked Evidence" \
    "Backreference Scan" \
    "Naming Drift" \
    "Generated Projection Freshness" \
    "Manifest And Schema Validity" \
    "Repo-Local Projection Boundaries" \
    "Target Family Boundaries" \
    "Churn Review" \
    "Validators Run" \
    "Exclusions" \
    "Final Closeout Recommendation"; do
    require_section "$section"
  done

  if [[ "$requires_pass" -eq 1 ]]; then
    [[ "$verdict" == "pass" ]] && pass "drift/churn gate passes for implemented lifecycle status" || fail "drift/churn gate passes for implemented lifecycle status"
    [[ "$unresolved_items_count" == "0" ]] && pass "no unresolved items for implemented lifecycle status" || fail "no unresolved items for implemented lifecycle status"
    if receipt_contains_placeholder; then
      fail "passing drift/churn receipt contains no scaffold placeholders"
    else
      pass "passing drift/churn receipt contains no scaffold placeholders"
    fi
    if grep -Eiq 'validate-[a-z0-9-]+\.sh|alignment-check\.sh|generate-proposal-registry\.sh' "$REVIEW"; then
      pass "drift/churn receipt records validators run"
    else
      fail "drift/churn receipt records validators run"
    fi
  fi
else
  if [[ "$requires_receipt" -eq 1 ]]; then
    fail "post-implementation drift/churn review exists"
  elif [[ "$legacy_archive" -eq 1 ]]; then
    warn "legacy archived proposal has no post-implementation drift/churn review"
  else
    warn "post-implementation drift/churn review is not required before implementation"
  fi
fi

subtype_manifest="$PROPOSAL_DIR/${proposal_kind}-proposal.yml"
if [[ -f "$subtype_manifest" ]]; then
  if yq -e '.' "$subtype_manifest" >/dev/null 2>&1; then
    pass "subtype manifest parses"
  else
    fail "subtype manifest parses"
  fi
else
  fail "subtype manifest exists"
fi

if [[ -f "$REGISTRY" ]]; then
  if yq -e '.' "$REGISTRY" >/dev/null 2>&1; then
    pass "proposal registry parses"
  else
    fail "proposal registry parses"
  fi

  if [[ "$status" == "archived" ]]; then
    registry_bucket="archived"
  else
    registry_bucket="active"
  fi
  if yq -e ".${registry_bucket}[]? | select(.id == \"$proposal_id\" and .kind == \"$proposal_kind\" and .path == \"$proposal_rel\")" "$REGISTRY" >/dev/null 2>&1; then
    pass "proposal registry contains current packet entry"
  else
    if [[ "$requires_pass" -eq 1 ]]; then
      fail "proposal registry contains current packet entry"
    else
      warn "proposal registry does not contain current packet entry"
    fi
  fi
else
  if [[ "$requires_pass" -eq 1 ]]; then
    fail "proposal registry exists"
  else
    warn "proposal registry missing"
  fi
fi

saw_octon=0
saw_non_octon=0
saw_github=0
while IFS= read -r target; do
  [[ -n "$target" ]] || continue
  if [[ "$target" == .octon/* ]]; then
    saw_octon=1
  else
    saw_non_octon=1
  fi
  if [[ "$target" == .github/* ]]; then
    saw_github=1
  fi
done < <(yq -r '.promotion_targets[]?' "$MANIFEST")

if [[ "$promotion_scope" == "octon-internal" && "$saw_non_octon" -eq 1 ]]; then
  if [[ "$legacy_archive" -eq 1 || "$status" == "archived" ]]; then
    warn "legacy archived octon-internal proposal has non-.octon promotion targets"
  else
    fail "octon-internal proposal targets stay under .octon/"
  fi
elif [[ "$promotion_scope" == "repo-local" && "$saw_octon" -eq 1 ]]; then
  if [[ "$legacy_archive" -eq 1 || "$status" == "archived" ]]; then
    warn "legacy archived repo-local proposal has .octon promotion targets"
  else
    fail "repo-local proposal targets stay outside .octon/"
  fi
elif [[ "$saw_octon" -eq 1 && "$saw_non_octon" -eq 1 && "$status" != "archived" ]]; then
  fail "active proposal avoids mixed target families"
else
  pass "promotion target scope is coherent"
fi

if [[ "$saw_github" -eq 1 && "$promotion_scope" == "octon-internal" && "$status" != "archived" ]]; then
  fail ".github/** remains repo-local projection scope"
else
  pass ".github/** projection boundary is coherent"
fi

scan_target() {
  local target_abs="$1"
  local pattern="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -n -i -e "$pattern" "$target_abs" 2>/dev/null || true
  else
    grep -R -n -i -E "$pattern" "$target_abs" 2>/dev/null || true
  fi
}

exclusions_text=""
if [[ -f "$REVIEW" ]]; then
  exclusions_text="$(grep -i -A12 '^## Exclusions' "$REVIEW" 2>/dev/null || true)"
fi

while IFS= read -r target; do
  [[ -n "$target" ]] || continue
  target_abs="$ROOT_DIR/$target"
  if [[ ! -e "$target_abs" ]]; then
    if [[ "$requires_pass" -eq 1 ]]; then
      fail "promotion target exists for drift scan: $target"
    else
      warn "promotion target not present for drift scan: $target"
    fi
    continue
  fi

  proposal_backrefs="$(scan_target "$target_abs" "\\.octon/inputs/exploratory/proposals/(\\.archive/)?[a-z0-9-]+/${proposal_id}")"
  if [[ -n "$proposal_backrefs" ]]; then
    if [[ "$requires_pass" -eq 1 ]]; then
      fail "promotion target has no active proposal backreferences: $target"
    else
      warn "promotion target has proposal backreferences: $target"
    fi
    printf '%s\n' "$proposal_backrefs"
  else
    pass "promotion target has no active proposal backreferences: $target"
  fi

  naming_hits="$(scan_target "$target_abs" 'Work Package')"
  stale_naming_hits="$(printf '%s\n' "$naming_hits" | grep -Eiv 'legacy|historical|compatib|deprecated|migration|archive|archived|superseded|alias|shim|backward|backwards' || true)"
  if [[ -n "$stale_naming_hits" ]]; then
    if grep -Eiq 'work package|naming drift' <<<"$exclusions_text"; then
      warn "Work Package naming conflict excluded by receipt: $target"
    elif [[ "$requires_pass" -eq 1 ]]; then
      fail "no stale Work Package/Change naming conflict in promoted target: $target"
      printf '%s\n' "$stale_naming_hits"
    else
      warn "possible Work Package/Change naming conflict in promoted target: $target"
    fi
  else
    pass "no stale Work Package/Change naming conflict in promoted target: $target"
  fi
done < <(yq -r '.promotion_targets[]?' "$MANIFEST")

echo "Validation summary: errors=$errors warnings=$warnings"
[[ $errors -eq 0 ]]
