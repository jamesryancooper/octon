#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
MANIFEST_FILE="$OCTON_DIR/scaffolding/runtime/bootstrap/manifest.yml"
SOURCE_DIR="$OCTON_DIR/scaffolding/runtime/bootstrap"

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "[ERROR] Missing bootstrap manifest: $MANIFEST_FILE" >&2
  exit 1
fi

mapfile -t projection_targets < <(awk '
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
if [[ ${#projection_targets[@]} -eq 0 ]]; then
  echo "[ERROR] Bootstrap manifest has no projected_roots entries: $MANIFEST_FILE" >&2
  exit 1
fi

for target_rel in "${projection_targets[@]}"; do
  target_abs="$ROOT_DIR/$target_rel"
  mkdir -p "$target_abs"
  find "$target_abs" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  cp -R "$SOURCE_DIR"/. "$target_abs"/
  echo "[OK] Synced bootstrap projection: ${target_abs#$ROOT_DIR/}"
done
