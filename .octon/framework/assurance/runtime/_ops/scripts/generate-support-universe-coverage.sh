#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
release_id="$(resolve_release_id "${1:-}")"
out="$(release_root "$release_id")/closure/support-universe-coverage.yml"
mkdir -p "$(dirname "$out")"
supported="$(find "$SUPPORT_DOSSIER_ROOT" -name dossier.yml -print | while read -r f; do yq -r 'select(.status == "supported") | .tuple_id' "$f"; done | awk 'NF')"
stage_only="$(find "$SUPPORT_DOSSIER_ROOT" -name dossier.yml -print | while read -r f; do yq -r 'select(.status == "stage_only") | .tuple_id' "$f"; done | awk 'NF')"
{
  echo "schema_version: support-universe-coverage-v2"
  echo "release_id: $release_id"
  echo "generated_at: \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\""
  echo "surfaces:"
  printf '%s\n' "$supported" | sed 's/^/  - /'
  echo "stage_only_surfaces:"
  printf '%s\n' "$stage_only" | sed 's/^/  - /'
} >"$out"

