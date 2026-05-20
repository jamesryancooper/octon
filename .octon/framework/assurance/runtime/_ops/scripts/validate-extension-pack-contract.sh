#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../../orchestration/runtime/_ops/scripts/extensions-common.sh"

extensions_common_init "${BASH_SOURCE[0]}"

PACKS_DIR="$OCTON_DIR/inputs/additive/extensions"
errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

main() {
  echo "== Extension Pack Contract Validation =="

  [[ -d "$PACKS_DIR" ]] && pass "inputs/additive/extensions directory exists" || {
    fail "missing directory: ${PACKS_DIR#$ROOT_DIR/}"
    echo "Validation summary: errors=$errors"
    exit 1
  }

  local entry name pack_dir manifest pack_id source_id
  declare -A seen_pack_ids=()

  while IFS= read -r entry; do
    name="$(basename "$entry")"
    if ext_is_reserved_extension_input_entry "$name"; then
      continue
    fi

    if [[ -d "$entry" ]]; then
      manifest="$entry/pack.yml"
      if [[ ! -f "$manifest" ]]; then
        fail "missing pack manifest: ${manifest#$ROOT_DIR/}"
        continue
      fi
      pack_id="$(yq -r '.pack_id // ""' "$manifest")"
      source_id="$(yq -r '.provenance.source_id // ""' "$manifest")"
      if [[ -z "$pack_id" ]]; then
        fail "pack contract invalid for $name: missing-pack-id"
        continue
      fi
      if [[ -n "${seen_pack_ids["$pack_id"]:-}" ]]; then
        fail "duplicate pack_id detected: $pack_id"
        continue
      fi
      seen_pack_ids["$pack_id"]="1"
      if ext_validate_pack_contract "$name" "$source_id" 0; then
        pass "pack contract valid: $name"
      else
        fail "pack contract invalid for $name: $EXT_LAST_ERROR_REASON"
      fi
    else
      fail "unexpected non-directory entry under inputs/additive/extensions: ${entry#$ROOT_DIR/}"
    fi
  done < <(find "$PACKS_DIR" -mindepth 1 -maxdepth 1 -print | sort)

  while IFS=$'\t' read -r pack_id source_id; do
    [[ -n "$pack_id" ]] || continue
    [[ -f "$(ext_pack_manifest_abs "$pack_id")" ]] && pass "selection entry resolves to pack manifest: $pack_id" || fail "selection entry missing pack manifest: $pack_id"
    ext_source_exists "$source_id" && pass "selection entry source declared: $pack_id/$source_id" || fail "selection entry source undeclared: $pack_id/$source_id"
  done < <(yq -r '.selection.enabled[]? | [.pack_id, .source_id] | @tsv' "$EXTENSIONS_MANIFEST" 2>/dev/null || true)

  while IFS=$'\t' read -r pack_id source_id; do
    [[ -n "$pack_id" ]] || continue
    [[ -f "$(ext_pack_manifest_abs "$pack_id")" ]] && pass "disabled entry resolves to pack manifest: $pack_id" || fail "disabled entry missing pack manifest: $pack_id"
    ext_source_exists "$source_id" && pass "disabled entry source declared: $pack_id/$source_id" || fail "disabled entry source undeclared: $pack_id/$source_id"
  done < <(yq -r '.selection.disabled[]? | [.pack_id, .source_id] | @tsv' "$EXTENSIONS_MANIFEST" 2>/dev/null || true)

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
