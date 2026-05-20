#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
ADDITIVE_ARCHIVE="$OCTON_DIR/inputs/additive/.archive"
RECEIPT_ROOT="$OCTON_DIR/state/evidence/validation/inputs/archive-retention"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

rel_path() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*) printf '%s\n' "${path#$ROOT_DIR/}" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

meaningful_archive_entries() {
  find "$ADDITIVE_ARCHIVE" -mindepth 1 -maxdepth 1 \
    ! -name '.gitkeep' \
    ! -name '.DS_Store' \
    ! -name 'README.md' \
    -print | sort
}

receipt_for_archive_id() {
  local archive_id="$1"
  local candidate
  for candidate in \
    "$RECEIPT_ROOT/$archive_id.yml" \
    "$RECEIPT_ROOT/$archive_id.yaml" \
    "$RECEIPT_ROOT/$archive_id.md"; do
    [[ -f "$candidate" ]] && { printf '%s\n' "$candidate"; return 0; }
  done
  return 1
}

validate_receipt() {
  local archive_id="$1"
  local receipt="$2"

  if [[ "$receipt" == *.md ]]; then
    if rg -Fq -- "$archive_id" "$receipt" && rg -Fq -- "non-authoritative" "$receipt"; then
      pass "archive retention markdown receipt documents non-authority: $archive_id"
    else
      fail "archive markdown receipt must name archive id and non-authority: $(rel_path "$receipt")"
    fi
    return
  fi

  if [[ "$(yq -r '.schema_version // ""' "$receipt")" == "octon-input-archive-retention-v1" ]]; then
    pass "archive retention receipt schema current: $archive_id"
  else
    fail "archive retention receipt schema must be octon-input-archive-retention-v1: $(rel_path "$receipt")"
  fi
  if [[ "$(yq -r '.archive_id // ""' "$receipt")" == "$archive_id" ]]; then
    pass "archive retention receipt id matches: $archive_id"
  else
    fail "archive retention receipt archive_id mismatch: $(rel_path "$receipt")"
  fi
  if [[ "$(yq -r '.authority_mode // ""' "$receipt")" == "non_authoritative" ]]; then
    pass "archive retention receipt is non_authoritative: $archive_id"
  else
    fail "archive retention receipt authority_mode must be non_authoritative: $(rel_path "$receipt")"
  fi
  if [[ "$(yq -r '.retention_justification // ""' "$receipt")" != "" ]]; then
    pass "archive retention receipt has justification: $archive_id"
  else
    fail "archive retention receipt needs retention_justification: $(rel_path "$receipt")"
  fi
}

main() {
  echo "== Input Archive Retention Validation =="

  if [[ ! -d "$ADDITIVE_ARCHIVE" ]]; then
    fail "missing additive archive root: $(rel_path "$ADDITIVE_ARCHIVE")"
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  local entry archive_id receipt found=0
  while IFS= read -r entry; do
    [[ -n "$entry" ]] || continue
    found=1
    archive_id="$(basename "$entry")"
    if receipt="$(receipt_for_archive_id "$archive_id")"; then
      pass "archive retention receipt present: $archive_id"
      validate_receipt "$archive_id" "$receipt"
    else
      fail "missing archive retention receipt for $(rel_path "$entry")"
    fi
  done < <(meaningful_archive_entries)

  if [[ "$found" -eq 0 ]]; then
    pass "no retained additive archive payloads require receipts"
  fi

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
