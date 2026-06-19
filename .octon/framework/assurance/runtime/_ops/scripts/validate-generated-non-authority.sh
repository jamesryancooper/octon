#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-remediation/registry/generated-non-authority-scan.yml"
PROPOSAL_PACKET_DELIVERY_WORKFLOW="$OCTON_DIR/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/workflow.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_yq() {
  if command -v yq >/dev/null 2>&1; then
    pass "yq available"
  else
    fail "yq is required for generated non-authority validation"
    exit 1
  fi
}

resolve_repo_path() {
  local raw="$1"
  case "$raw" in
    /.octon/*|/.github/*)
      printf '%s/%s\n' "$ROOT_DIR" "${raw#/}"
      ;;
    .octon/*|.github/*)
      printf '%s/%s\n' "$ROOT_DIR" "$raw"
      ;;
    *)
      printf '%s\n' "$raw"
      ;;
  esac
}

has_text() {
  local text="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -Fq -- "$text" "$file"
  else
    grep -Fq -- "$text" "$file"
  fi
}

is_allowed_file() {
  local candidate="$1"
  while IFS= read -r allowed; do
    [[ -n "$allowed" ]] || continue
    if [[ "$candidate" == "$(resolve_repo_path "$allowed")" ]]; then
      return 0
    fi
  done < <(yq -r '.allowed_reference_files[]? // ""' "$RECEIPT")
  return 1
}

assert_receipt_scope_is_non_authority() {
  local ref
  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    case "$ref" in
      .octon/inputs/*|/.octon/inputs/*)
        fail "generated non-authority scan root must not depend on proposal-local inputs: $ref"
        ;;
      .octon/generated/*|/.octon/generated/*)
        fail "generated non-authority scan root must not treat generated output as authority root: $ref"
        ;;
      *)
        pass "scan root is authority-safe: $ref"
        ;;
    esac
  done < <(yq -r '.scan_roots[]? // ""' "$RECEIPT")

  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    case "$ref" in
      .octon/inputs/*|/.octon/inputs/*)
        fail "allowed generated read-model reference cannot be proposal-local input: $ref"
        ;;
      .octon/generated/*|/.octon/generated/*)
        fail "allowed generated read-model reference cannot be generated output authority: $ref"
        ;;
    esac
  done < <(yq -r '.allowed_reference_files[]? // ""' "$RECEIPT")
}

assert_delivery_workflow_classifies_generated_freshness() {
  if [[ ! -f "$PROPOSAL_PACKET_DELIVERY_WORKFLOW" ]]; then
    fail "proposal-packet delivery workflow missing for generated freshness classification"
    return 0
  fi
  local token
  for token in \
    "generated_freshness_scope_detection" \
    "generated_freshness_not_in_scope" \
    "generated_input_scope_detected_and_owner_routed" \
    "generated_refresh_needed_but_not_authorized" \
    "generated_output_present_but_stale" \
    "generated_output_fresh_but_non_authoritative" \
    "proposal_local_or_parent_evidence_satisfies_generated_freshness: false" \
    "generated_output_authorizes_closeout_or_archive: false"; do
    if has_text "$token" "$PROPOSAL_PACKET_DELIVERY_WORKFLOW"; then
      pass "proposal-packet delivery workflow declares: $token"
    else
      fail "proposal-packet delivery workflow must declare: $token"
    fi
  done
}

main() {
  echo "== Generated Non-Authority Validation =="

  require_yq
  [[ -f "$RECEIPT" ]] && pass "generated non-authority receipt present" || { fail "missing receipt $RECEIPT"; echo "Validation summary: errors=$errors"; exit 1; }

  if [[ "$(yq -r '.schema_version // ""' "$RECEIPT")" == "generated-non-authority-scan-v1" ]]; then
    pass "generated non-authority receipt schema is current"
  else
    fail "generated non-authority receipt schema must be generated-non-authority-scan-v1"
  fi

  assert_receipt_scope_is_non_authority
  assert_delivery_workflow_classifies_generated_freshness

  while IFS= read -r doc_ref; do
    [[ -n "$doc_ref" ]] || continue
    local resolved_doc
    resolved_doc="$(resolve_repo_path "$doc_ref")"
    if [[ -f "$resolved_doc" ]]; then
      pass "rule reference present: $doc_ref"
    else
      fail "missing rule reference: $doc_ref"
      continue
    fi
    while IFS= read -r required_text; do
      [[ -n "$required_text" ]] || continue
      if has_text "$required_text" "$resolved_doc"; then
        pass "$doc_ref contains: $required_text"
      else
        fail "$doc_ref must contain: $required_text"
      fi
    done < <(yq -r ".required_rule_refs[] | select(.doc_ref == \"$doc_ref\") | .required_text[]? // \"\"" "$RECEIPT")
  done < <(yq -r '.required_rule_refs[]?.doc_ref // ""' "$RECEIPT")

  while IFS= read -r pattern; do
    [[ -n "$pattern" ]] || continue
    while IFS=: read -r file _rest; do
      [[ -n "$file" ]] || continue
      if is_allowed_file "$file"; then
        pass "allowed generated read-model reference: ${file#$ROOT_DIR/}"
      else
        fail "forbidden generated read-model dependency: ${file#$ROOT_DIR/}"
      fi
    done < <(
      while IFS= read -r scan_root; do
        [[ -n "$scan_root" ]] || continue
        local resolved_root
        resolved_root="$(resolve_repo_path "$scan_root")"
        if [[ -e "$resolved_root" ]]; then
          if command -v rg >/dev/null 2>&1; then
            rg -n -F -- "$pattern" "$resolved_root" || true
          else
            grep -RFn -- "$pattern" "$resolved_root" || true
          fi
        fi
      done < <(yq -r '.scan_roots[]? // ""' "$RECEIPT")
    )
  done < <(yq -r '.scan_patterns[]? // ""' "$RECEIPT")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
