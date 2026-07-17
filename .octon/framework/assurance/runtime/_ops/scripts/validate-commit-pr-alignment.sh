#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
COMMITS="$OCTON_DIR/framework/execution-roles/practices/commits.md"
PRS="$OCTON_DIR/framework/execution-roles/practices/pull-request-standards.md"
STANDARDS="$OCTON_DIR/framework/execution-roles/practices/standards/commit-pr-standards.json"

jq -e '.commit.policy_doc == ".octon/framework/execution-roles/practices/commits.md"' "$STANDARDS" >/dev/null
jq -e '.pr.policy_doc == ".octon/framework/execution-roles/practices/pull-request-standards.md"' "$STANDARDS" >/dev/null
jq -e '(.change.route_ids | index("direct-main")) == null and .change.containment.direct_main == "denied"' "$STANDARDS" >/dev/null
jq -e '.pr.autonomous_draft_completion.route == "branch-pr" and .pr.autonomous_draft_completion.protected_main_bypass_allowed == false' "$STANDARDS" >/dev/null
grep -Fq 'direct-main is a historical receipt label only' "$COMMITS"
grep -Fq 'no Octon direct-main or hosted branch-no-PR publication route exists' "$PRS"
echo "[OK] commit/PR SI-00 alignment passes"
