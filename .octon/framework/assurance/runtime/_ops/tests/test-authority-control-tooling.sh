#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

APPROVAL_SCRIPT="$OCTON_DIR/framework/engine/_ops/scripts/materialize-authority-approval.sh"
PROJECTION_SCRIPT="$OCTON_DIR/framework/engine/_ops/scripts/project-github-control-approval.sh"
EXCEPTION_SCRIPT="$OCTON_DIR/framework/engine/_ops/scripts/record-authority-exception-lease.sh"
REVOCATION_SCRIPT="$OCTON_DIR/framework/engine/_ops/scripts/record-authority-revocation.sh"
tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-authority-tooling.XXXXXX")"
trap 'rm -rf "$tmp_root"' EXIT

mkdir -p \
  "$tmp_root/.octon/state/control/execution/approvals/requests" \
  "$tmp_root/.octon/state/control/execution/approvals/grants" \
  "$tmp_root/.octon/state/control/execution/exceptions" \
  "$tmp_root/.octon/state/control/execution/revocations" \
  "$tmp_root/.octon/state/evidence/control/execution"

printf 'schema_version: "authority-exception-lease-set-v1"\nleases: []\n' > "$tmp_root/.octon/state/control/execution/exceptions/leases.yml"
printf 'schema_version: "authority-revocation-set-v1"\nrevocations: []\n' > "$tmp_root/.octon/state/control/execution/revocations/grants.yml"
OCTON_DIR_OVERRIDE="$tmp_root/.octon" OCTON_ROOT_DIR="$tmp_root" bash "$APPROVAL_SCRIPT" \
  --request-id "req-tooling" \
  --run-id "req-tooling" \
  --target-id "github-pr:101" \
  --action-type "pr-autonomy-merge" \
  --issued-by "github://pull/101" \
  --support-tier "repo-consequential" \
  --request-state "granted" \
  --grant-state "active" \
  --ownership-ref "operator://octon-maintainers" \
  --required-evidence "approval-grant" \
  --projection-kind "operator-record" \
  --projection-ref "operator://octon-maintainers/authority-review/req-tooling" \
  >"$tmp_root/authority-approval.json"
jq -e '.approval_granted == true and (.approval_grant_ref | length > 0)' "$tmp_root/authority-approval.json" >/dev/null
[[ -f "$tmp_root/.octon/state/control/execution/approvals/requests/req-tooling.yml" ]]
[[ -f "$tmp_root/.octon/state/control/execution/approvals/grants/grant-req-tooling.yml" ]]
find "$tmp_root/.octon/state/evidence/control/execution" -type f -name '*approval*' | grep -q .

OCTON_DIR_OVERRIDE="$tmp_root/.octon" OCTON_ROOT_DIR="$tmp_root" bash "$PROJECTION_SCRIPT" \
  --request-id "github-pr-101-ai-gate" \
  --run-id "github-pr-101-ai-gate" \
  --target-id "github-pr:101" \
  --action-type "github-ai-review-gate" \
  --issued-by "github://workflow/ai-review-gate" \
  --status "staged" \
  --projection-label "github://pull/101#label:ai-gate:blocker" \
  --projection-check "github://pull/101#check:AI Review Gate / decision" \
  --reason-code "AI_GATE_DECISION_FAIL_BLOCKERS" \
  --output-json "$tmp_root/github-projection.json" \
  >/dev/null
[[ -f "$tmp_root/.octon/state/control/execution/approvals/requests/github-pr-101-ai-gate.yml" ]]
[[ ! -f "$tmp_root/.octon/state/control/execution/approvals/grants/grant-github-pr-101-ai-gate.yml" ]]
jq -e '.approval_granted == false and .approval_request_ref == ".octon/state/control/execution/approvals/requests/github-pr-101-ai-gate.yml"' "$tmp_root/github-projection.json" >/dev/null

OCTON_DIR_OVERRIDE="$tmp_root/.octon" OCTON_ROOT_DIR="$tmp_root" bash "$PROJECTION_SCRIPT" \
  --request-id "github-pr-101-ai-gate-denied" \
  --run-id "github-pr-101-ai-gate-denied" \
  --target-id "github-pr:101" \
  --action-type "github-ai-review-gate" \
  --issued-by "github://workflow/ai-review-gate" \
  --status "denied" \
  --projection-check "github://pull/101#check:AI Review Gate / decision" \
  --reason-code "AI_GATE_DECISION_FAIL_PROVIDER_UNAVAILABLE" \
  --output-json "$tmp_root/github-projection-denied.json" \
  >/dev/null
[[ -f "$tmp_root/.octon/state/control/execution/approvals/requests/github-pr-101-ai-gate-denied.yml" ]]
[[ ! -f "$tmp_root/.octon/state/control/execution/approvals/grants/grant-github-pr-101-ai-gate-denied.yml" ]]
jq -e '.approval_granted == false and .approval_request_ref == ".octon/state/control/execution/approvals/requests/github-pr-101-ai-gate-denied.yml"' "$tmp_root/github-projection-denied.json" >/dev/null

OCTON_DIR_OVERRIDE="$tmp_root/.octon" OCTON_ROOT_DIR="$tmp_root" bash "$EXCEPTION_SCRIPT" \
  --lease-id "lease-tooling" \
  --lease-kind "network-egress" \
  --issued-by "operator://octon-maintainers" \
  --service "execution/flow" \
  --adapter "langgraph-http" \
  --method "POST" \
  --scheme "https" \
  --host "example.com" \
  --path-prefix "/v1" \
  --ttl-seconds 300 \
  --run-id "req-tooling" \
  >/dev/null

yq -e '.leases[] | select(.id == "lease-tooling" and .state == "active")' "$tmp_root/.octon/state/control/execution/exceptions/leases.yml" >/dev/null
find "$tmp_root/.octon/state/evidence/control/execution" -type f -name '*exception*' | grep -q .

OCTON_DIR_OVERRIDE="$tmp_root/.octon" OCTON_ROOT_DIR="$tmp_root" bash "$REVOCATION_SCRIPT" \
  --revocation-id "revoke-tooling" \
  --grant-id "grant-req-tooling" \
  --request-id "req-tooling" \
  --run-id "req-tooling" \
  --revoked-by "operator://octon-maintainers" \
  --reason-code "AUTHORITY_GRANT_REVOKED" \
  >/dev/null

yq -e '.revocations[] | select(.revocation_id == "revoke-tooling" and .state == "active")' "$tmp_root/.octon/state/control/execution/revocations/grants.yml" >/dev/null
find "$tmp_root/.octon/state/evidence/control/execution" -type f -name '*revocation*' | grep -q .

echo "[OK] authority control tooling writes canonical approval, exception, and revocation artifacts"
