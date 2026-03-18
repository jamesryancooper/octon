#!/usr/bin/env bash

surface_common_init() {
  local caller_script="$1"
  SURFACE_LABEL="${2:-surface}"
  SURFACE_SCRIPT_DIR="$(cd -- "$(dirname -- "$caller_script")" && pwd)"
  if [[ -n "${OCTON_DIR_OVERRIDE:-}" ]]; then
    OCTON_DIR="$OCTON_DIR_OVERRIDE"
    ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
    RUNTIME_DIR="$OCTON_DIR/orchestration/runtime"
    SURFACE_DIR="$RUNTIME_DIR/$SURFACE_LABEL"
  else
    SURFACE_DIR="$(cd -- "$SURFACE_SCRIPT_DIR/../.." && pwd)"
    RUNTIME_DIR="$(cd -- "$SURFACE_DIR/.." && pwd)"
    ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"
    OCTON_DIR="$(cd -- "$ORCHESTRATION_DIR/.." && pwd)"
    ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
  fi
  errors=0
  warnings=0
}

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

info() {
  echo "[INFO] $1"
}

surface_rel() {
  printf '%s' "${SURFACE_DIR#$ROOT_DIR/}/$1"
}

require_file_rel() {
  local rel="$1"
  local path="$SURFACE_DIR/$rel"
  if [[ ! -f "$path" ]]; then
    fail "missing file: $(surface_rel "$rel")"
  else
    pass "found file: $(surface_rel "$rel")"
  fi
}

require_dir_rel() {
  local rel="$1"
  local path="$SURFACE_DIR/$rel"
  if [[ ! -d "$path" ]]; then
    fail "missing directory: $(surface_rel "$rel")"
  else
    pass "found directory: $(surface_rel "$rel")"
  fi
}

surface_has_any_marker() {
  local rel
  for rel in "$@"; do
    if [[ -e "$SURFACE_DIR/$rel" ]]; then
      return 0
    fi
  done
  return 1
}

surface_skip_not_promoted() {
  info "surface '$SURFACE_LABEL' is not promoted yet; validator hook is grounded but skipped."
  exit 0
}

finish_surface_validation() {
  local label="${1:-$SURFACE_LABEL}"
  echo
  echo "${label} validation summary: errors=$errors warnings=$warnings"
  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi
}
