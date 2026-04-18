#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
release_id="$(resolve_release_id "${1:-}")"
out="$(release_root "$release_id")/closure/claim-drift-report.yml"
mkdir -p "$(dirname "$out")"
pattern="$(forbidden_phrase_pattern)"
search_paths=(
  "$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
  "$OCTON_DIR/instance/governance/closure/closure-summary.yml"
  "$OCTON_DIR/state/evidence/disclosure/runs"
)
if command -v rg >/dev/null 2>&1; then
  matches="$(rg -n -i -- "$pattern" "${search_paths[@]}" || true)"
else
  matches="$(grep -RinE -- "$pattern" "${search_paths[@]}" || true)"
fi
status="pass"
[[ -z "$matches" ]] || status="fail"
{
  echo "schema_version: octon-claim-drift-report-v1"
  echo "release_id: $release_id"
  echo "generated_at: \"$(deterministic_generated_at)\""
  echo "status: $status"
  echo "findings:"
  if [[ -n "$matches" ]]; then
    printf '%s\n' "$matches" | sed 's/^/  - "/; s/$/"/'
  fi
} >"$out"
