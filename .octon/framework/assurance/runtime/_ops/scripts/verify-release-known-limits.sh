#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

require_yq

release_id="$(resolve_release_id "${1:-}")"
residual_path="$(closure_report_path "$release_id" "residual-ledger.yml")"
delta_path="$(closure_report_path "$release_id" "hardening-delta.yml")"
report_path="$(closure_report_path "$release_id" "disclosure-calibration-report.yml")"
mkdir -p "$(dirname "$residual_path")"

report_status() {
  local name="$1"
  local path
  path="$(closure_report_path "$release_id" "$name")"
  if [[ -f "$path" ]]; then
    yq -r '.status // "unknown"' "$path"
  else
    echo "unknown"
  fi
}

cc01="$( [[ "$(report_status "lab-reference-integrity-report.yml")" == "pass" ]] && echo closed || echo open )"
cc02="$( [[ "$(report_status "host-authority-purity-report.yml")" == "pass" ]] && echo closed || echo open )"
if [[ "$(report_status "runtime-family-depth-report.yml")" == "pass" && "$(report_status "replay-integrity.yml")" == "pass" && "$(report_status "continuity-linkage-report.yml")" == "pass" && "$(report_status "contamination-retry-depth-report.yml")" == "pass" ]]; then
  cc03="closed"
else
  cc03="open"
fi
cc05="$( [[ "$(report_status "retirement-rationale-report.yml")" == "pass" ]] && echo closed || echo open )"
cc04="closed"

known_limits=(
  "The attainment claim remains bounded to the admitted live support universe only; no universal support claim is made outside active support-target tuples."
  "Residual persona, projection, and historical mirror surfaces remain non-authoritative and retirement-tracked."
  "Evaluator diversity and hidden-check breadth remain bounded to the currently admitted adapter and scenario set."
)

for status_id in "CC-01:$cc01:Deterministic authored-lab to dossier to admission to retained-evidence integrity remains a release hardening obligation." \
                 "CC-02:$cc02:Host workflows and adapters remain projection-only and must keep proving they do not mint authority." \
                 "CC-03:$cc03:Runtime-family depth, continuity linkage, contamination posture, retry posture, and replay integrity remain recertification-facing proof obligations." \
                 "CC-05:$cc05:Retained transitional and mirror surfaces remain subject to explicit retain-versus-retire review discipline."; do
  status_value="${status_id#*:}"
  status_value="${status_value%%:*}"
  message="${status_id##*:}"
  if [[ "$status_value" != "closed" ]]; then
    known_limits+=("$message")
  fi
done

{
  echo "schema_version: octon-residual-ledger-v1"
  echo "release_id: $release_id"
  echo "claim_critical:"
  for pair in \
    "CC-01:$cc01:lab scenario and retained evidence integrity" \
    "CC-02:$cc02:host projection authority purity" \
    "CC-03:$cc03:runtime artifact depth and replay integrity" \
    "CC-04:$cc04:disclosure calibration" \
    "CC-05:$cc05:retirement and retain-rationale discipline"; do
    issue_id="${pair%%:*}"
    rest="${pair#*:}"
    issue_status="${rest%%:*}"
    issue_summary="${rest##*:}"
    echo "  - issue_id: $issue_id"
    echo "    status: $issue_status"
    echo "    summary: $issue_summary"
  done
  echo "non_critical:"
  for pair in \
    "CS-01:open:Evidence depth should be refreshed per admitted tuple before any support widening." \
    "CS-02:open:Evaluator diversity and hidden-check breadth should continue to deepen." \
    "SR-01:open:Execution-role and ingress simplification can still reduce interpretive ambiguity." \
    "SR-02:open:Public retirement-register depth should continue to mature." \
    "SR-03:open:Residual shim and mirror rationale should remain explicit in disclosure." \
    "SR-04:open:Generated and effective operator clarity should remain explicitly non-authoritative."; do
    issue_id="${pair%%:*}"
    rest="${pair#*:}"
    issue_status="${rest%%:*}"
    issue_summary="${rest##*:}"
    echo "  - issue_id: $issue_id"
    echo "    status: $issue_status"
    echo "    disposition: retained_with_rationale"
    echo "    target_release: hardening-followup"
    echo "    summary: $issue_summary"
  done
  echo "known_limits:"
  for limit in "${known_limits[@]}"; do
    printf '  - "%s"\n' "$limit"
  done
} >"$residual_path"

{
  echo "schema_version: octon-hardening-delta-v1"
  echo "release_id: $release_id"
  echo "support_scope_change: none"
  echo "closed_claim_critical_items:"
  for pair in "CC-01:$cc01" "CC-02:$cc02" "CC-03:$cc03" "CC-04:$cc04" "CC-05:$cc05"; do
    issue_id="${pair%%:*}"
    issue_status="${pair##*:}"
    [[ "$issue_status" == "closed" ]] && echo "  - $issue_id"
  done
  echo "open_claim_strengthening_items:"
  echo "  - CS-01"
  echo "  - CS-02"
  echo "retained_transitional_surfaces:"
  echo "  - surface: \"/.octon/AGENTS.md\""
  echo "    status: retained_with_rationale"
  echo "    rationale: \"Repo-local ingress adapters remain compatibility projections only.\""
  echo "    next_review_due: 2026-06-30"
  echo "recertification_blockers: []"
} >"$delta_path"

{
  echo "schema_version: octon-disclosure-calibration-v1"
  echo "release_id: $release_id"
  echo "status: pass"
  echo "summary:"
  echo "  known_limits_count: ${#known_limits[@]}"
  echo "  support_scope_change: none"
  echo "  residual_ledger_ref: .octon/state/evidence/disclosure/releases/$release_id/closure/residual-ledger.yml"
} >"$report_path"
