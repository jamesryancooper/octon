#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
AUTHORIZER="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh"
LANDER="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh"

yq -e '.containment.branch_no_pr_landing == "denied" and .containment.publication_denial_reason == "RP00_CONTAINMENT_PUBLICATION_DISABLED"' "$POLICY" >/dev/null
grep -Fq 'no current branch-landing authorization can be minted' "$AUTHORIZER"
grep -Fq 'no approval receipt was emitted' "$AUTHORIZER"
grep -Fq 'candidate and remote refs are preserved' "$LANDER"
echo "[OK] branch-no-PR authorization envelope is deny-only during SI-00"
