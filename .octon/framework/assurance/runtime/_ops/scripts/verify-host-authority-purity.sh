#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

require_yq

release_id="$(resolve_release_id "${1:-}")"
report_path="$(closure_report_path "$release_id" "host-authority-purity-report.yml")"
mkdir -p "$(dirname "$report_path")"

errors=0
workflow_checks=0
host_adapters_checked=0
runs_checked=0

bash "$SCRIPT_DIR/verify-host-adapter-projection-parity.sh" || errors=$((errors + 1))

has_pattern() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -n "$pattern" "$file" >/dev/null 2>&1
  else
    grep -E -n "$pattern" "$file" >/dev/null 2>&1
  fi
}

while IFS= read -r workflow; do
  [[ -n "$workflow" ]] || continue
  workflow_checks=$((workflow_checks + 1))
  if has_pattern 'issue_comment|pull_request_review_comment|github\.event\.comment|github\.event\.label' "$workflow"; then
    errors=$((errors + 1))
  fi
done < <(printf '%s\n' \
  "$ROOT_DIR/.github/workflows/pr-autonomy-policy.yml" \
  "$ROOT_DIR/.github/workflows/validate-unified-execution-completion.yml" \
  "$ROOT_DIR/.github/workflows/closure-validator-sufficiency.yml" \
  "$ROOT_DIR/.github/workflows/closure-certification.yml" \
  "$ROOT_DIR/.github/workflows/uec-drift-watch.yml")

while IFS= read -r contract_ref; do
  [[ -n "$contract_ref" ]] || continue
  host_adapters_checked=$((host_adapters_checked + 1))
  contract_path="$ROOT_DIR/$contract_ref"
  boundary_text="$(yq -r '.non_authoritative_boundaries[]?' "$contract_path" | tr '\n' ' ')"
  [[ "$boundary_text" == *authority* ]] || errors=$((errors + 1))
done < <(yq -r '.host_adapters[].contract_ref' "$SUPPORT_TARGETS_DECLARATION")

while IFS= read -r run_id; do
  [[ -n "$run_id" ]] || continue
  runs_checked=$((runs_checked + 1))
  decision_ref="$(yq -r '.authority_refs.decision_artifact // ""' "$(run_card_path "$run_id")")"
  [[ -n "$decision_ref" && -f "$ROOT_DIR/$decision_ref" ]] || errors=$((errors + 1))

  grant_ref="$(yq -r '.authority_refs.grant_bundle // ""' "$(run_card_path "$run_id")")"
  if admission_value_for_run "$run_id" '.required_authority_artifacts[]?' | grep -E 'grant-bundle|approval-grant' >/dev/null 2>&1; then
    grant_required="1"
  else
    grant_required="0"
  fi
  if [[ "$grant_required" != "0" ]]; then
    [[ -n "$grant_ref" && -f "$ROOT_DIR/$grant_ref" ]] || errors=$((errors + 1))
  fi
done < <(representative_run_ids)

status="pass"
if [[ "$errors" != "0" ]]; then
  status="fail"
fi

{
  echo "schema_version: octon-host-authority-purity-v1"
  echo "release_id: $release_id"
  echo "status: $status"
  echo "summary:"
  echo "  workflows_checked: $workflow_checks"
  echo "  host_adapters_checked: $host_adapters_checked"
  echo "  representative_runs_checked: $runs_checked"
  echo "  violations: $errors"
  echo "generated_at: \"$(deterministic_generated_at)\""
} >"$report_path"

[[ "$errors" == "0" ]]
