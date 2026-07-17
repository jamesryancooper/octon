#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
FIXTURES="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/fixtures/change-route-selection/solo-route-selection.yml"
POLICY="$ROOT_DIR/.octon/framework/product/contracts/default-work-unit.yml"

fact() { yq -r ".cases[$1].facts.$2 // false" "$FIXTURES"; }

select_route() {
  local i="$1"
  if [[ "$(fact "$i" change_identity_resolved)" != true ]]; then echo stage-only-escalate; return; fi
  if [[ "$(fact "$i" requested_hosted_no_pr_landing)" == true ]]; then echo stage-only-escalate; return; fi
  if [[ "$(fact "$i" explicit_operator_pr_request)" == true || "$(fact "$i" hosted_review_required)" == true || "$(fact "$i" external_signoff_required)" == true || "$(fact "$i" release_automation_requires_pr)" == true || "$(fact "$i" existing_pr_context)" == true ]]; then
    echo branch-pr
    return
  fi
  echo branch-no-pr
}

yq -e '.containment_state == "SI-00"' "$FIXTURES" >/dev/null
! yq -e '.routes[].route_id | select(. == "direct-main")' "$POLICY" >/dev/null 2>&1

count="$(yq -r '.cases | length' "$FIXTURES")"
for ((i=0; i<count; i++)); do
  expected="$(yq -r ".cases[$i].expected_route" "$FIXTURES")"
  actual="$(select_route "$i")"
  [[ "$actual" == "$expected" ]] || { echo "FAIL: case $i expected $expected got $actual" >&2; exit 1; }
done

echo "PASS: solo routing never selects direct-main"
