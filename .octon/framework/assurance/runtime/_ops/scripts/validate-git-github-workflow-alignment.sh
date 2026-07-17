#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"

POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml"
STANDARDS="$OCTON_DIR/framework/execution-roles/practices/standards/commit-pr-standards.json"
WORKFLOW="$OCTON_DIR/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md"
PLAYBOOK="$OCTON_DIR/framework/execution-roles/practices/git-autonomy-playbook.md"
MANIFEST="$OCTON_DIR/framework/orchestration/runtime/workflows/manifest.yml"

! yq -e '.routes[].route_id | select(. == "direct-main")' "$POLICY" >/dev/null 2>&1
yq -e '(.operating_model.route_ids | length) == 3' "$CONTRACT" >/dev/null
! yq -e '.operating_model.route_ids[] | select(. == "direct-main")' "$CONTRACT" >/dev/null 2>&1
yq -e '.helpers.git_branch_land.denial_reason == "RP00_CONTAINMENT_PUBLICATION_DISABLED" and .helpers.git_branch_cleanup.denial_reason == "RP00_CONTAINMENT_CLEANUP_DISABLED"' "$CONTRACT" >/dev/null
jq -e '(.change.route_ids | index("direct-main")) == null and .change.containment.state == "SI-00"' "$STANDARDS" >/dev/null
grep -Fq 'direct-main is not an admitted Octon route' "$WORKFLOW"
grep -Fq 'RP00_CONTAINMENT_CLEANUP_DISABLED' "$WORKFLOW"
grep -Fq 'direct-main is denied during SI-00' "$PLAYBOOK"
yq -e '.workflows[] | select(.id == "closeout" and (.summary | test("SI-00")))' "$MANIFEST" >/dev/null
echo "[OK] Git/GitHub SI-00 workflow alignment passes"
