#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
REGISTRY="$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-remediation/registry/contract-registry-receipt.yml"

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
    fail "yq is required for registry validation"
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

require_file() {
  local raw="$1"
  local resolved
  resolved="$(resolve_repo_path "$raw")"
  if [[ -f "$resolved" ]]; then
    pass "found file ${raw}"
  else
    fail "missing file ${raw}"
  fi
}

require_path_kind() {
  local raw="$1"
  local kind="$2"
  local resolved
  resolved="$(resolve_repo_path "$raw")"
  case "$kind" in
    file)
      [[ -f "$resolved" ]] && pass "registry path resolves as file: $raw" || fail "registry path must resolve as file: $raw"
      ;;
    dir)
      [[ -d "$resolved" ]] && pass "registry path resolves as directory: $raw" || fail "registry path must resolve as directory: $raw"
      ;;
    *)
      [[ -e "$resolved" ]] && pass "registry path resolves: $raw" || fail "registry path must resolve: $raw"
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

main() {
  echo "== Architecture Contract Registry Validation =="

  require_yq
  require_file "$REGISTRY"
  require_file "$RECEIPT"

  if [[ "$(yq -r '.schema_version // ""' "$REGISTRY")" == "architecture-contract-registry-v2" ]]; then
    pass "contract registry schema version is current"
  else
    fail "contract registry schema version must be architecture-contract-registry-v2"
  fi

  if [[ "$(yq -r '.schema_version // ""' "$RECEIPT")" == "architecture-contract-registry-receipt-v1" ]]; then
    pass "registry receipt schema version is current"
  else
    fail "registry receipt schema version must be architecture-contract-registry-receipt-v1"
  fi

  while IFS=$'\t' read -r id query expected_path path_kind; do
    [[ -n "$id" ]] || continue
    local actual_path
    actual_path="$(yq -r "$query // \"\"" "$REGISTRY")"
    if [[ "$actual_path" == "$expected_path" ]]; then
      pass "$id matches canonical registry path"
    else
      fail "$id must resolve to $expected_path (found $actual_path)"
      continue
    fi
    require_path_kind "$expected_path" "$path_kind"
  done < <(yq -r '.registry_queries[] | [.id, .query, .expected_path, .path_kind] | @tsv' "$RECEIPT")

  while IFS= read -r blocking_check; do
    [[ -n "$blocking_check" ]] || continue
    if yq -e ".execution.blocking_checks[] | select(. == \"$blocking_check\")" "$REGISTRY" >/dev/null 2>&1; then
      pass "blocking check registered: $blocking_check"
    else
      fail "missing blocking check in registry: $blocking_check"
    fi
  done < <(yq -r '.required_blocking_checks[]? // ""' "$RECEIPT")

  while IFS= read -r doc_ref; do
    [[ -n "$doc_ref" ]] || continue
    require_file "$doc_ref"
  done < <(yq -r '.required_doc_surfaces[]? // ""' "$RECEIPT")

  while IFS= read -r doc_ref; do
    [[ -n "$doc_ref" ]] || continue
    local resolved_doc
    resolved_doc="$(resolve_repo_path "$doc_ref")"
    while IFS= read -r required_text; do
      [[ -n "$required_text" ]] || continue
      if has_text "$required_text" "$resolved_doc"; then
        pass "$doc_ref contains: $required_text"
      else
        fail "$doc_ref must contain: $required_text"
      fi
    done < <(yq -r ".doc_assertions[] | select(.doc_ref == \"$doc_ref\") | .required_text[]? // \"\"" "$RECEIPT")
  done < <(yq -r '.doc_assertions[]?.doc_ref // ""' "$RECEIPT")

  while IFS= read -r validator_receipt; do
    [[ -n "$validator_receipt" ]] || continue
    require_file "$validator_receipt"
  done < <(yq -r '.validator_receipts[]? // ""' "$RECEIPT")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
