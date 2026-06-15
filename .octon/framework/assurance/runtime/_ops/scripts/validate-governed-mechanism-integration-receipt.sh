#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
SCHEMA_PATH="$FRAMEWORK_DIR/product/contracts/governed-mechanism-integration-receipt-v1.schema.json"
RECEIPT_PATH=""
PACKAGE_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-governed-mechanism-integration-receipt.sh [--receipt <path>] [--package <path>]
USAGE
}

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RECEIPT_PATH="$1"
      ;;
    --package)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      PACKAGE_PATH="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

need_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] $1 is required" >&2
    exit 1
  fi
}

scalar() {
  yq -r "$1" "$RECEIPT_PATH" 2>/dev/null || true
}

package_path_variants() {
  local package_path="$1"
  printf '%s\n' "$package_path"
  if [[ "$package_path" = /* && "$package_path" == "$REPO_ROOT/"* ]]; then
    printf '%s\n' "${package_path#$REPO_ROOT/}"
  fi
}

package_abs_path() {
  local package_path="$1"
  if [[ "$package_path" = /* ]]; then
    printf '%s\n' "$package_path"
  else
    printf '%s/%s\n' "$REPO_ROOT" "$package_path"
  fi
}

receipt_matches_package_path() {
  local receipt_proposal_path="$1" package_path="$2" variant
  while IFS= read -r variant; do
    [[ "$receipt_proposal_path" == "$variant" ]] && return 0
  done < <(package_path_variants "$package_path")
  return 1
}

receipt_matches_archived_original_path() {
  local receipt_proposal_path="$1" package_path="$2" package_abs manifest status original_path
  package_abs="$(package_abs_path "$package_path")"
  manifest="$package_abs/proposal.yml"
  [[ -f "$manifest" ]] || return 1
  status="$(yq -r '.status // ""' "$manifest" 2>/dev/null || true)"
  original_path="$(yq -r '.archive.original_path // ""' "$manifest" 2>/dev/null || true)"
  [[ "$status" == "archived" && -n "$original_path" && "$original_path" != "null" && "$receipt_proposal_path" == "$original_path" ]]
}

require_scalar() {
  local path="$1" label="$2" value
  value="$(scalar "$path")"
  if [[ -n "$value" && "$value" != "null" ]]; then
    pass "$label declared"
  else
    fail "$label missing"
  fi
}

require_array_nonempty() {
  local path="$1" label="$2" count
  count="$(yq -r "($path // []) | length" "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  [[ "$count" -gt 0 ]] && pass "$label non-empty" || fail "$label must be non-empty"
}

require_classification() {
  local path="$1" expected="$2" label="$3" value
  value="$(scalar "$path")"
  [[ "$value" == "$expected" ]] && pass "$label is $expected" || fail "$label must be $expected"
}

need_tool jq
need_tool yq

echo "== Governed Mechanism Integration Receipt Validation =="

if [[ -f "$SCHEMA_PATH" ]]; then
  pass "receipt schema exists"
else
  fail "receipt schema missing: $SCHEMA_PATH"
fi

if jq -e '.' "$SCHEMA_PATH" >/dev/null 2>&1; then
  pass "receipt schema JSON parses"
else
  fail "receipt schema JSON does not parse"
fi

for token in \
  '"governed-mechanism-integration-receipt-v1"' \
  '"implemented_packet_digest"' \
  '"current_state_architecture_review_ref"' \
  '"generated_publication_refs"' \
  '"terminal_freshness_refs"' \
  '"non_authority_classification"'; do
  grep -Fq "$token" "$SCHEMA_PATH" && pass "schema token present: $token" || fail "schema token missing: $token"
done

if [[ -n "$RECEIPT_PATH" ]]; then
  if [[ -f "$RECEIPT_PATH" ]]; then
    pass "receipt file exists: $RECEIPT_PATH"
  else
    fail "receipt file missing: $RECEIPT_PATH"
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  if yq -e '.' "$RECEIPT_PATH" >/dev/null 2>&1; then
    pass "receipt YAML parses"
  else
    fail "receipt YAML does not parse"
  fi

  [[ "$(scalar '.schema_version')" == "governed-mechanism-integration-receipt-v1" ]] \
    && pass "receipt schema_version correct" \
    || fail "receipt schema_version must be governed-mechanism-integration-receipt-v1"

  require_scalar '.mechanism_id' "mechanism_id"
  require_scalar '.proposal_path' "proposal_path"
  require_scalar '.verdict' "verdict"
  require_scalar '.unresolved_items_count' "unresolved_items_count"
  require_scalar '.mechanism_profile_ref' "mechanism_profile_ref"
  require_scalar '.implemented_packet_digest' "implemented_packet_digest"
  require_scalar '.current_state_architecture_review_ref' "current_state_architecture_review_ref"
  require_scalar '.implementation_conformance_ref' "implementation_conformance_ref"
  require_scalar '.post_implementation_drift_ref' "post_implementation_drift_ref"
  require_scalar '.authority_boundary_verdict' "authority_boundary_verdict"

  case "$(scalar '.verdict')" in
    pass|fail|blocked|deferred|not_applicable)
      pass "verdict allowed"
      ;;
    *)
      fail "verdict must be pass, fail, blocked, deferred, or not_applicable"
      ;;
  esac

  if [[ "$(scalar '.implemented_packet_digest')" =~ ^sha256:0{64}$ ]]; then
    fail "implemented_packet_digest must not be the all-zero stale digest"
  elif [[ "$(scalar '.implemented_packet_digest')" =~ ^sha256:[0-9a-f]{64}$ ]]; then
    pass "implemented_packet_digest format valid"
  else
    fail "implemented_packet_digest must be sha256:<64 hex chars>"
  fi

  if [[ -n "$PACKAGE_PATH" ]]; then
    PACKAGE_ABS="$(package_abs_path "$PACKAGE_PATH")"
    RECEIPT_PROPOSAL_PATH="$(scalar '.proposal_path')"
    [[ -d "$PACKAGE_ABS" ]] && pass "package path exists" || fail "package path missing: $PACKAGE_PATH"
    if receipt_matches_package_path "$RECEIPT_PROPOSAL_PATH" "$PACKAGE_PATH"; then
      pass "proposal_path matches --package"
    elif receipt_matches_archived_original_path "$RECEIPT_PROPOSAL_PATH" "$PACKAGE_PATH"; then
      pass "proposal_path matches archived package original_path"
    else
      fail "proposal_path must match --package or archived package original_path"
    fi
  fi

  require_array_nonempty '.surface_coverage' "surface_coverage"
  require_array_nonempty '.validator_refs' "validator_refs"
  require_array_nonempty '.evidence_refs' "evidence_refs"

  require_classification '.non_authority_classification.proposal_inputs' non-authority "proposal inputs classification"
  require_classification '.non_authority_classification.generated_outputs' derived-only-non-authority "generated outputs classification"
  require_classification '.non_authority_classification.generated_prompts' non-authority "generated prompts classification"
  require_classification '.non_authority_classification.host_state' non-authority "host state classification"
  require_classification '.non_authority_classification.dashboards' non-authority "dashboards classification"
  require_classification '.non_authority_classification.chat' non-authority "chat classification"
  require_classification '.non_authority_classification.tool_state' non-authority "tool state classification"
  require_classification '.non_authority_classification.model_memory' non-authority "model memory classification"
  require_classification '.non_authority_classification.current_state_architecture_review' evidence-only "current-state architecture review classification"
  require_classification '.non_authority_classification.lifecycle_postmortem' evidence-only "lifecycle postmortem classification"
  require_classification '.mode_specific_coverage.current_state_architecture_review_role' evidence-only "current-state architecture review role"
  require_classification '.mode_specific_coverage.lifecycle_postmortem_authority' evidence-only "lifecycle postmortem authority"

  if [[ "$(scalar '.verdict')" == "pass" ]]; then
    [[ "$(scalar '.unresolved_items_count')" == "0" ]] && pass "pass verdict has zero unresolved items" || fail "pass verdict requires unresolved_items_count 0"
    blockers_count="$(yq -r '(.blockers // []) | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
    [[ "$blockers_count" == "0" ]] && pass "pass verdict has no blockers" || fail "pass verdict requires no blockers"
    [[ "$(scalar '.authority_boundary_verdict')" == "pass" ]] && pass "authority boundary verdict pass" || fail "pass verdict requires authority_boundary_verdict pass"
    require_array_nonempty '.generated_publication_refs' "generated_publication_refs"
    require_scalar '.implementation_conformance_ref' "implementation_conformance_ref"
    require_scalar '.post_implementation_drift_ref' "post_implementation_drift_ref"

    if [[ "$(scalar '.implementation_conformance_ref')" == "not-applicable" ]]; then
      fail "pass verdict requires implementation conformance ref"
    else
      pass "implementation conformance ref applicable"
    fi
    if [[ "$(scalar '.post_implementation_drift_ref')" == "not-applicable" ]]; then
      fail "pass verdict requires post-implementation drift ref"
    else
      pass "post-implementation drift ref applicable"
    fi

    if [[ "$(scalar '.mode_specific_coverage.terminal_freshness_required')" == "true" ]]; then
      require_array_nonempty '.terminal_freshness_refs' "terminal_freshness_refs"
      [[ "$(scalar '.mode_specific_coverage.terminal_freshness_status')" == "pass" ]] \
        && pass "terminal freshness status pass" \
        || fail "terminal freshness status must be pass when required"
    else
      [[ "$(scalar '.mode_specific_coverage.terminal_freshness_status')" == "not_applicable" || "$(scalar '.mode_specific_coverage.terminal_freshness_status')" == "pass" ]] \
        && pass "terminal freshness status compatible" \
        || fail "terminal freshness status must be not_applicable or pass when not required"
    fi
  fi

  while IFS= read -r status; do
    case "$status" in
      covered|not_applicable)
        pass "surface status allowed: $status"
        ;;
      *)
        fail "surface_coverage contains missing or invalid status: $status"
        ;;
    esac
  done < <(yq -r '(.surface_coverage // [])[]?.status // empty' "$RECEIPT_PATH" 2>/dev/null || true)

  if grep -Eiq 'TODO|TBD|FIXME|placeholder-marker|stale alias|stale proposal backref' "$RECEIPT_PATH"; then
    fail "receipt contains placeholder or stale marker text"
  else
    pass "receipt contains no placeholder or stale marker text"
  fi
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
