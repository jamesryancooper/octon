#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
MANIFEST_FILE="$OCTON_DIR/octon.yml"
EXPORT_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/export-harness.sh"
EXT_PUBLICATION_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

main() {
  echo "== Export Profile Contract Validation =="

  if [[ ! -f "$MANIFEST_FILE" ]]; then
    fail "missing file: ${MANIFEST_FILE#$ROOT_DIR/}"
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  if [[ ! -x "$EXPORT_SCRIPT" ]]; then
    fail "export-harness runner missing or not executable: ${EXPORT_SCRIPT#$ROOT_DIR/}"
  else
    pass "export-harness runner is executable"
  fi

  if [[ ! -x "$EXT_PUBLICATION_VALIDATOR" ]]; then
    fail "extension publication validator missing or not executable: ${EXT_PUBLICATION_VALIDATOR#$ROOT_DIR/}"
  else
    pass "extension publication validator is executable"
  fi

  [[ "$(yq -r '.profiles.pack_bundle.selector // ""' "$MANIFEST_FILE")" == "inputs/additive/extensions/<selected>/**" ]] && pass "pack_bundle selector is declared" || fail "pack_bundle selector must match Packet 2 contract"
  [[ "$(yq -r '.profiles.pack_bundle.include_dependency_closure // ""' "$MANIFEST_FILE")" == "true" ]] && pass "pack_bundle closure flag declared" || fail "pack_bundle.include_dependency_closure must be true"
  [[ "$(yq -r '.profiles.full_fidelity.advisory // ""' "$MANIFEST_FILE")" != "" ]] && pass "full_fidelity advisory declared" || fail "full_fidelity advisory missing"

  if yq -e '.profiles.full_fidelity.include' "$MANIFEST_FILE" >/dev/null 2>&1; then
    fail "full_fidelity must not define an include payload"
  else
    pass "full_fidelity does not define an include payload"
  fi

  if OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
    bash "$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
  then
    pass "extension publication state refresh succeeds"
  else
    fail "extension publication state refresh must succeed before export"
  fi

  if OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
    bash "$EXT_PUBLICATION_VALIDATOR" >/dev/null
  then
    pass "extension publication state is current"
  else
    fail "extension publication state must validate before export"
  fi

  local tmp_root=""
  tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-export-validate.XXXXXX")"
  trap '[[ -n "${tmp_root:-}" ]] && rm -r -f -- "$tmp_root"' EXIT

  if EXPORT_HARNESS_VALIDATE_ONLY=1 OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
    bash "$EXPORT_SCRIPT" --profile repo_snapshot --output-dir "$tmp_root/repo_snapshot" >/dev/null
  then
    pass "repo_snapshot export resolves current enabled-pack closure"
  else
    fail "repo_snapshot export must resolve current enabled-pack closure"
  fi

  if OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
    bash "$EXPORT_SCRIPT" --profile full_fidelity --output-dir "$tmp_root/full_fidelity" >/dev/null 2>&1
  then
    fail "full_fidelity export must fail closed"
  else
    pass "full_fidelity export is rejected as advisory-only"
  fi

  if OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
    bash "$EXPORT_SCRIPT" --profile pack_bundle --output-dir "$tmp_root/pack_bundle" >/dev/null 2>&1
  then
    fail "pack_bundle without pack ids must fail closed"
  else
    pass "pack_bundle requires explicit pack ids"
  fi

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
