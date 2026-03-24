#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

SOURCE_DIR="$OCTON_DIR/framework/scaffolding/runtime/bootstrap"
MANIFEST_FILE="$SOURCE_DIR/manifest.yml"
LIVE_WRAPPER="$OCTON_DIR/framework/scaffolding/runtime/_ops/scripts/init-project.sh"
TEMPLATE_WRAPPER="$OCTON_DIR/framework/scaffolding/runtime/templates/octon/scaffolding/runtime/_ops/scripts/init-project.sh"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

has_text() {
  local text="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -Fq "$text" "$file"
  else
    grep -Fq -- "$text" "$file"
  fi
}

main() {
  local diff_output=""
  local projected_dir=""
  local projected_dir_abs=""
  local -a projected_dirs=()

  echo "== Bootstrap Projection Validation =="

  [[ -d "$SOURCE_DIR" ]] || fail "missing canonical bootstrap directory: ${SOURCE_DIR#$ROOT_DIR/}"
  [[ -f "$MANIFEST_FILE" ]] || fail "missing bootstrap manifest: ${MANIFEST_FILE#$ROOT_DIR/}"

  mapfile -t projected_dirs < <(awk '
    /^[[:space:]]*projected_roots:[[:space:]]*$/ {in_roots=1; next}
    in_roots && /^[^[:space:]]/ {in_roots=0}
    in_roots && /^[[:space:]]*-[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]*-[[:space:]]*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      gsub(/[[:space:]]+$/, "", line)
      if (length(line) > 0) print line
    }
  ' "$MANIFEST_FILE")
  if [[ ${#projected_dirs[@]} -eq 0 ]]; then
    fail "bootstrap manifest has no projected_roots entries"
  fi

  for projected_dir in "${projected_dirs[@]}"; do
    projected_dir_abs="$ROOT_DIR/$projected_dir"
    if [[ ! -d "$projected_dir_abs" ]]; then
      fail "missing projected bootstrap directory: $projected_dir"
      continue
    fi
    if diff_output="$(diff -qr "$SOURCE_DIR" "$projected_dir_abs" 2>&1)"; then
      pass "projected bootstrap directory matches canonical source: $projected_dir"
    else
      fail "projected bootstrap directory diverges from canonical source: $projected_dir"
      printf '%s\n' "$diff_output"
    fi
  done

  if has_text "scaffolding/runtime/bootstrap/init-project.sh" "$LIVE_WRAPPER"; then
    pass "live wrapper delegates to canonical bootstrap implementation"
  else
    fail "live wrapper does not delegate to canonical bootstrap implementation"
  fi

  if has_text "scaffolding/runtime/bootstrap/init-project.sh" "$TEMPLATE_WRAPPER"; then
    pass "template wrapper delegates to local canonical bootstrap implementation"
  else
    fail "template wrapper does not delegate to local canonical bootstrap implementation"
  fi

  echo "Validation summary: errors=$errors"
  if (( errors > 0 )); then
    exit 1
  fi
}

main "$@"
