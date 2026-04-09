#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

require_yq

release_id="$(resolve_release_id "${1:-}")"
report_path="$(closure_report_path "$release_id" "support-universe-evidence-depth-report.yml")"
mkdir -p "$(dirname "$report_path")"

errors=0
checked=0
parity_ok=0

normalize_list() {
  local file="$1"
  local expr="$2"
  yq -r "$expr" "$file" 2>/dev/null | awk 'NF' | LC_ALL=C sort
}

while IFS= read -r dossier; do
  [[ -n "$dossier" ]] || continue
  admission_ref="$(yq -r '.support_admission_ref // ""' "$dossier")"
  admission="$ROOT_DIR/$admission_ref"
  [[ -f "$admission" ]] || {
    errors=$((errors + 1))
    continue
  }

  dossier_scenarios="$(normalize_list "$dossier" '.required_lab_scenarios[]?')"
  admission_scenarios="$(normalize_list "$admission" '.required_lab_scenarios[]?')"
  representative_count="$(yq -r '(.representative_retained_runs // []) | length' "$dossier")"
  checked=$((checked + 1))

  if [[ "$representative_count" == "0" ]]; then
    errors=$((errors + 1))
    continue
  fi

  if [[ "$dossier_scenarios" == "$admission_scenarios" ]]; then
    parity_ok=$((parity_ok + 1))
  else
    errors=$((errors + 1))
  fi
done < <(supported_dossier_files)

status="pass"
if [[ "$errors" != "0" ]]; then
  status="fail"
fi

{
  echo "schema_version: octon-support-universe-evidence-depth-v1"
  echo "release_id: $release_id"
  echo "status: $status"
  echo "summary:"
  echo "  dossiers_checked: $checked"
  echo "  dossier_admission_parity_ok: $parity_ok"
  echo "  parity_failures: $errors"
} >"$report_path"

[[ "$errors" == "0" ]]

