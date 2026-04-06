#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
release_id="$(resolve_release_id "${1:-}")"
out="$(release_root "$release_id")/closure/proof-plane-coverage.yml"
mkdir -p "$(dirname "$out")"
{
  echo "schema_version: proof-plane-coverage-v1"
  echo "release_id: $release_id"
  echo "generated_at: \"$(deterministic_generated_at)\""
  echo "tuples:"
  while IFS= read -r dossier; do
    tuple_id="$(yq -r '.tuple_id' "$dossier")"
    echo "  - tuple_id: \"$tuple_id\""
    echo "    required_proof_planes:"
    yq -r '.required_proof_planes[]?' "$dossier" | sed 's/^/      - /'
  done < <(support_dossier_files)
} >"$out"
