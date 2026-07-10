#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
source "$SCRIPT_DIR/validator-recovery-diagnostics.sh"

RECEIPT=""
PACKAGE=""
MODE=""
REQUIRE_PASS=0
errors=0

# Live catalogs the v2 report/routing-decision path binds against. Resolved from
# the repository root exactly like validate-architectural-review-naming.sh and
# validate-architectural-review-lens-references.sh, so v2 artifacts cross-check
# against the live method catalog and lens bank (never a fixture copy). The v2
# `method` enum is bound to naming.yml's `methods.catalog` slugs and every
# `lenses_applied` id is bound to lens-bank.yml's `lenses[].id`, so a lens-bank
# change needs no schema bump.
NAMING_CATALOG="$ROOT_DIR/.octon/framework/cognition/practices/methodology/architectural-review/naming.yml"
LENS_BANK="$ROOT_DIR/.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml"

usage() {
  cat <<'EOF'
usage:
  validate-architectural-review-receipts.sh --receipt <path> [--package <proposal-path>] [--mode <mode>] [--require-pass]

--receipt accepts any architectural-review contract artifact. Validation is routed
by the artifact's schema_version:
  * architectural-review-support-receipt-v1   -> support-receipt path (with
                                                 receipt_schema_drift guard)
  * architectural-review-report-v2 /
    architectural-review-routing-decision-v2  -> v2 path (unknown_method,
                                                 undefined_lens fail closed)
  * architectural-review-report-v1 /
    architectural-review-routing-decision-v1  -> v1 coexistence path
EOF
}

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

repo_rel() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*)
      printf '%s\n' "${path#$ROOT_DIR/}"
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

architectural_review_rerun_gate() {
  local gate="validate-architectural-review-receipts.sh --receipt $(repo_rel "$RECEIPT")"
  if [[ -n "$PACKAGE" ]]; then
    gate="$gate --package $PACKAGE"
  fi
  if [[ -n "$MODE" ]]; then
    gate="$gate --mode $MODE"
  fi
  if [[ "$REQUIRE_PASS" -eq 1 ]]; then
    gate="$gate --require-pass"
  fi
  printf '%s\n' "$gate"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt)
      shift; RECEIPT="${1:-}"
      ;;
    --package)
      shift; PACKAGE="${1:-}"
      ;;
    --mode)
      shift; MODE="${1:-}"
      ;;
    --require-pass)
      REQUIRE_PASS=1
      ;;
    *)
      usage >&2; exit 2
      ;;
  esac
  shift
done

[[ -n "$RECEIPT" ]] || { usage >&2; exit 2; }

if [[ "$RECEIPT" != /* ]]; then
  RECEIPT="$ROOT_DIR/$RECEIPT"
fi

if [[ ! -f "$RECEIPT" ]]; then
  fail "architectural review receipt exists"
  printf 'Validation summary: errors=%s\n' "$errors"
  exit 1
fi
pass "architectural review receipt exists"

if yq -e '.' "$RECEIPT" >/dev/null 2>&1; then
  pass "architectural review receipt parses as YAML"
else
  fail "architectural review receipt parses as YAML"
fi

field() {
  yq -r "$1 // \"\"" "$RECEIPT" 2>/dev/null || true
}

has_field() {
  [[ "$(yq -r "has(\"$1\")" "$RECEIPT" 2>/dev/null || echo false)" == "true" ]]
}

schema_version="$(field '.schema_version')"

# ---------------------------------------------------------------------------
# Support-receipt path (existing behavior preserved verbatim + drift guard).
# Depended on by validate-proposal-review-gate.sh and the
# pre-integration-architecture-review workflow; a conformant v1 support receipt
# must continue to pass exactly as before.
# ---------------------------------------------------------------------------
validate_support_receipt() {
  local receipt_id proposal_path packet_digest review_mode verdict unresolved_count non_authority_classification
  receipt_id="$(field '.receipt_id')"
  proposal_path="$(field '.proposal_path')"
  packet_digest="$(field '.packet_digest')"
  review_mode="$(field '.review_mode')"
  verdict="$(field '.verdict')"
  unresolved_count="$(field '.unresolved_count')"
  non_authority_classification="$(field '.non_authority_classification')"

  [[ "$schema_version" == "architectural-review-support-receipt-v1" ]] && pass "schema_version is architectural-review-support-receipt-v1" || fail "schema_version is architectural-review-support-receipt-v1"
  [[ -n "$receipt_id" ]] && pass "receipt_id present" || fail "receipt_id present"
  [[ -n "$proposal_path" ]] && pass "proposal_path present" || fail "proposal_path present"
  [[ "$packet_digest" =~ ^sha256:[0-9a-f]{64}$ ]] && pass "packet_digest explicit" || fail "packet_digest explicit"
  [[ "$review_mode" =~ ^(pre-integration-architecture-review|post-integration-architecture-review|current-state-mechanism-architecture-review|architecture-readiness-audit)$ ]] && pass "review_mode canonical" || fail "review_mode canonical"
  [[ -z "$MODE" || "$review_mode" == "$MODE" ]] && pass "review_mode matches requested mode" || fail "review_mode matches requested mode"
  [[ "$verdict" =~ ^(pass|fail|blocked|not_applicable|deferred)$ ]] && pass "verdict explicit" || fail "verdict explicit"
  [[ "$unresolved_count" =~ ^[0-9]+$ ]] && pass "unresolved_count numeric" || fail "unresolved_count numeric"
  [[ "$non_authority_classification" == "retained-evidence-only" ]] && pass "non-authority classification retained-evidence-only" || fail "non-authority classification retained-evidence-only"

  local evidence_count validator_count blocker_count coverage_count
  evidence_count="$(yq -r '(.evidence_refs // []) | length' "$RECEIPT")"
  validator_count="$(yq -r '(.validator_refs // []) | length' "$RECEIPT")"
  blocker_count="$(yq -r '(.blockers // []) | length' "$RECEIPT")"
  coverage_count="$(yq -r '(.mode_specific_coverage // {}) | length' "$RECEIPT")"

  [[ "$evidence_count" -gt 0 ]] && pass "evidence_refs non-empty" || fail "evidence_refs non-empty"
  [[ "$validator_count" -gt 0 ]] && pass "validator_refs non-empty" || fail "validator_refs non-empty"
  yq -e '.blockers | type == "!!seq"' "$RECEIPT" >/dev/null 2>&1 && pass "blockers is a list" || fail "blockers is a list"
  [[ "$coverage_count" -gt 0 ]] && pass "mode_specific_coverage non-empty" || fail "mode_specific_coverage non-empty"

  # Drift guard (NC-3 receipt_schema_drift): the support receipt never gains
  # method/lenses_applied. A v1 support receipt carrying either field is drift.
  if has_field method || has_field lenses_applied; then
    fail "receipt_schema_drift: support receipt must not carry method or lenses_applied fields"
  else
    pass "support receipt free of method/lenses_applied drift"
  fi

  if rg -qi '(^|[^[:alnum:]_])(TODO|TBD|FIXME)([^[:alnum:]_]|$)|not reviewed|not verified|not run|pending placeholder|stale packet digest' "$RECEIPT"; then
    fail "receipt contains no placeholder or stale-evidence text"
  else
    pass "receipt contains no placeholder or stale-evidence text"
  fi

  if [[ "$REQUIRE_PASS" -eq 1 ]]; then
    [[ "$verdict" == "pass" ]] && pass "required pass receipt has pass verdict" || fail "required pass receipt has pass verdict"
    [[ "$unresolved_count" == "0" ]] && pass "required pass receipt has zero unresolved items" || fail "required pass receipt has zero unresolved items"
    [[ "$blocker_count" == "0" ]] && pass "required pass receipt has no blockers" || fail "required pass receipt has no blockers"
  fi

  if [[ -n "$PACKAGE" ]]; then
    local PACKAGE_ABS current_digest
    if [[ "$PACKAGE" != /* ]]; then
      PACKAGE_ABS="$ROOT_DIR/$PACKAGE"
    else
      PACKAGE_ABS="$PACKAGE"
    fi
    if [[ -d "$PACKAGE_ABS" ]]; then
      current_digest="$(bash "$SCRIPT_DIR/validate-proposal-review-gate.sh" --package "$PACKAGE_ABS" --print-digest)"
      [[ "$packet_digest" == "$current_digest" ]] && pass "packet_digest is fresh for package" || {
        if [[ "$(yq -r '.status // ""' "$PACKAGE_ABS/proposal.yml" 2>/dev/null)" == "archived" \
          && -n "$(yq -r '.archive.original_path // ""' "$PACKAGE_ABS/proposal.yml" 2>/dev/null)" \
          && "$packet_digest" =~ ^sha256:[0-9a-f]{64}$ ]]; then
          pass "packet_digest preserved from pre-archive packet"
        else
          emit_stale_evidence_recovery_diagnostic \
            "$(repo_rel "$RECEIPT")#packet_digest" \
            "$packet_digest" \
            "$current_digest" \
            "$(repo_rel "$RECEIPT")" \
            "architectural review receipt packet_digest does not match current packet digest" \
            "$(architectural_review_rerun_gate)" \
            "rerun the $review_mode route at the next authorized stable digest boundary so the receipt records the current packet digest" \
            "packet-content-drift-after-architecture-review" \
            "$review_mode" \
            "packet_digest"
          fail "packet_digest is fresh for package"
          printf 'recorded: %s\ncurrent:  %s\n' "$packet_digest" "$current_digest" >&2
        fi
      }
    else
      fail "package path exists for digest freshness"
    fi
  fi
}

# ---------------------------------------------------------------------------
# v2 report/routing-decision path. The additive method/lenses_applied fields are
# bound to the live catalogs: method must be a naming.yml methods.catalog slug
# (NC-1 unknown_method) and every lenses_applied id must be a lens-bank.yml lens
# id (NC-2 undefined_lens). The fields are descriptive records only; they grant
# the artifact no lifecycle authority.
# ---------------------------------------------------------------------------
validate_v2_artifact() {
  pass "artifact recognized as v2 architectural-review contract: $schema_version"

  # NC-1 unknown_method: method present and in the live naming.yml catalog.
  local method
  method="$(field '.method')"
  if [[ -z "$method" ]]; then
    fail "unknown_method: v2 artifact is missing the required method field"
  elif [[ ! -f "$NAMING_CATALOG" ]] || ! yq -e '.' "$NAMING_CATALOG" >/dev/null 2>&1; then
    fail "naming catalog available for method binding: $NAMING_CATALOG"
  elif yq -e ".methods.catalog[]? | select(.slug == \"$method\")" "$NAMING_CATALOG" >/dev/null 2>&1; then
    pass "v2 method binds to live naming.yml methods.catalog: $method"
  else
    fail "unknown_method: v2 method not in live naming.yml methods.catalog: $method"
  fi

  # NC-2 undefined_lens: lenses_applied is a non-empty array whose every id is a
  # declared lens-bank.yml lens id.
  local lens_count
  lens_count="$(yq -r '(.lenses_applied // []) | length' "$RECEIPT" 2>/dev/null || echo 0)"
  if ! [[ "$lens_count" =~ ^[0-9]+$ ]] || [[ "$lens_count" -lt 1 ]]; then
    fail "undefined_lens: v2 artifact lenses_applied must be a non-empty array"
  elif [[ ! -f "$LENS_BANK" ]] || ! yq -e '.' "$LENS_BANK" >/dev/null 2>&1; then
    fail "lens bank available for lens binding: $LENS_BANK"
  else
    declare -A LENS_DEFINED=()
    local lid
    while read -r lid; do
      [[ -z "$lid" || "$lid" == "null" ]] && continue
      LENS_DEFINED["$lid"]=1
    done < <(yq -r '.lenses[].id' "$LENS_BANK" 2>/dev/null || true)

    local undefined=0 applied
    while read -r applied; do
      [[ -z "$applied" || "$applied" == "null" ]] && continue
      if [[ -z "${LENS_DEFINED[$applied]:-}" ]]; then
        fail "undefined_lens: lenses_applied id not declared in lens-bank.yml: $applied"
        undefined=$((undefined + 1))
      fi
    done < <(yq -r '.lenses_applied[]' "$RECEIPT" 2>/dev/null || true)
    [[ "$undefined" -eq 0 ]] && pass "v2 lenses_applied ids all bind to live lens-bank.yml (count=$lens_count)"
  fi
}

# ---------------------------------------------------------------------------
# v1 coexistence path. A method-agnostic v1 report/routing-decision validates
# WITHOUT the additive method/lenses_applied fields (Balanced default applies).
# ---------------------------------------------------------------------------
validate_v1_coexistence_artifact() {
  pass "artifact recognized as v1 architectural-review contract (coexistence): $schema_version"
  if has_field method || has_field lenses_applied; then
    fail "v1 coexistence artifact must not carry method/lenses_applied (those are v2-only fields)"
  else
    pass "v1 artifact validates without method/lenses_applied fields"
  fi
}

case "$schema_version" in
  architectural-review-support-receipt-v1)
    validate_support_receipt
    ;;
  architectural-review-support-receipt-*)
    # A receipt claiming to be a support receipt at a non-v1 schema_version.
    fail "receipt_schema_drift: support receipt schema_version is not architectural-review-support-receipt-v1: $schema_version"
    ;;
  architectural-review-report-v2|architectural-review-routing-decision-v2)
    validate_v2_artifact
    ;;
  architectural-review-report-v1|architectural-review-routing-decision-v1)
    validate_v1_coexistence_artifact
    ;;
  *)
    fail "artifact schema_version is a recognized architectural-review contract version: got '$schema_version'"
    ;;
esac

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]
