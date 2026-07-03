#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
if [[ -n "${OCTON_DIR_OVERRIDE:-}" ]]; then
  OCTON_DIR="$(cd -- "$OCTON_DIR_OVERRIDE" && pwd)"
  ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
elif [[ -n "${OCTON_ROOT_DIR:-}" ]]; then
  ROOT_DIR="$(cd -- "$OCTON_ROOT_DIR" && pwd)"
  OCTON_DIR="$ROOT_DIR/.octon"
else
  OCTON_DIR="$DEFAULT_OCTON_DIR"
  ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
fi

source "$SCRIPT_DIR/generator-idempotency-common.sh"

SCHEMA="$OCTON_DIR/framework/product/contracts/receipt-fanout-compaction-v1.schema.json"
POINTER=""
SCHEMA_ONLY=0
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-receipt-fanout-compaction.sh --pointer <compact-pointer-path>
  validate-receipt-fanout-compaction.sh --schema-only
USAGE
}

pass() { printf '[OK] %s\n' "$1"; }
fail() {
  printf '[ERROR] %s\n' "$1"
  errors=$((errors + 1))
}

resolve_repo_path() {
  local raw="$1"
  case "$raw" in
    /.octon/*) printf '%s/%s\n' "$ROOT_DIR" "${raw#/}" ;;
    .octon/*) printf '%s/%s\n' "$ROOT_DIR" "$raw" ;;
    *) printf '%s\n' "$raw" ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pointer)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      POINTER="$1"
      ;;
    --schema-only)
      SCHEMA_ONLY=1
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

require_tool() {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    pass "$tool available"
  else
    fail "$tool available"
  fi
}

require_schema() {
  if [[ -f "$SCHEMA" ]]; then
    pass "receipt compaction schema exists"
  else
    fail "receipt compaction schema exists"
    return 0
  fi
  if python3 -m json.tool "$SCHEMA" >/dev/null 2>&1; then
    pass "receipt compaction schema parses as JSON"
  else
    fail "receipt compaction schema parses as JSON"
  fi
}

require_pointer_bool_false() {
  local expr="$1" label="$2"
  local value
  value="$(yq -r "$expr" "$POINTER" 2>/dev/null || true)"
  if [[ "$value" == "false" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

validate_pointer() {
  local receipt_rel receipt_abs expected_receipt_sha actual_receipt_sha expected_content_sha actual_content_sha

  if [[ -z "$POINTER" ]]; then
    fail "pointer path supplied"
    return 0
  fi
  POINTER="$(resolve_repo_path "$POINTER")"
  if [[ -f "$POINTER" ]]; then
    pass "compact receipt pointer exists"
  else
    fail "compact receipt pointer exists"
    return 0
  fi
  if yq -e '.' "$POINTER" >/dev/null 2>&1; then
    pass "compact receipt pointer parses as YAML"
  else
    fail "compact receipt pointer parses as YAML"
    return 0
  fi

  [[ "$(yq -r '.schema_version // ""' "$POINTER")" == "octon-compact-receipt-pointer-v1" ]] \
    && pass "compact receipt pointer schema current" \
    || fail "compact receipt pointer schema current"
  [[ "$(yq -r '.non_authority_classification // ""' "$POINTER")" == "retained-evidence-index" ]] \
    && pass "compact pointer is retained evidence index" \
    || fail "compact pointer is retained evidence index"
  [[ "$(yq -r '.retained_full_receipt // ""' "$POINTER")" == "true" ]] \
    && pass "pointer declares retained full receipt" \
    || fail "pointer declares retained full receipt"

  require_pointer_bool_false '.authority_boundaries.replaces_full_receipt' "pointer does not replace full receipt"
  require_pointer_bool_false '.authority_boundaries.authorizes_cleanup' "pointer does not authorize cleanup"
  require_pointer_bool_false '.authority_boundaries.satisfies_freshness_without_receipt' "pointer cannot satisfy freshness without receipt"
  require_pointer_bool_false '.authority_boundaries.generated_output_authority' "pointer is not generated output authority"

  receipt_rel="$(yq -r '.receipt_path // ""' "$POINTER")"
  case "$receipt_rel" in
    .octon/state/evidence/validation/*/by-digest/*/*.yml)
      pass "receipt path is content-addressed under retained validation evidence"
      ;;
    *)
      fail "receipt path is content-addressed under retained validation evidence"
      ;;
  esac
  receipt_abs="$(resolve_repo_path "$receipt_rel")"
  [[ -f "$receipt_abs" ]] && pass "retained full receipt exists" || {
    fail "retained full receipt exists"
    return 0
  }

  expected_receipt_sha="$(yq -r '.receipt_sha256 // ""' "$POINTER")"
  actual_receipt_sha="$(octon_churn_sha256_file "$receipt_abs")"
  [[ "$expected_receipt_sha" == "$actual_receipt_sha" ]] \
    && pass "retained full receipt digest matches pointer" \
    || fail "retained full receipt digest matches pointer"

  expected_content_sha="$(yq -r '.receipt_content_sha256 // ""' "$POINTER")"
  actual_content_sha="$(octon_churn_receipt_normalized_digest_file "$receipt_abs")"
  [[ "$expected_content_sha" == "$actual_content_sha" ]] \
    && pass "normalized receipt content digest matches pointer" \
    || fail "normalized receipt content digest matches pointer"

  case "$receipt_rel" in
    *"${expected_content_sha#sha256:}.yml")
      pass "receipt path embeds normalized content digest"
      ;;
    *)
      fail "receipt path embeds normalized content digest"
      ;;
  esac
}

require_tool yq
require_tool python3
require_schema
if [[ "$SCHEMA_ONLY" -eq 0 ]]; then
  validate_pointer
fi

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]
