#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

APPROVAL_SCRIPT="$OCTON_DIR/framework/engine/_ops/scripts/materialize-authority-approval.sh"
EXCEPTION_SCRIPT="$OCTON_DIR/framework/engine/_ops/scripts/record-authority-exception-lease.sh"
REVOCATION_SCRIPT="$OCTON_DIR/framework/engine/_ops/scripts/record-authority-revocation.sh"
GITHUB_WRAPPER="$OCTON_DIR/framework/agency/_ops/scripts/github/materialize-pr-authority.sh"

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
  --support-tier "repo-local-transitional" \
  --request-state "granted" \
  --grant-state "active" \
  --ownership-ref "operator://octon-maintainers" \
  --required-evidence "approval-grant" \
  --projection-kind "github-label" \
  --projection-ref "github://pull/101/label/accept:human" \
  >"$tmp_root/authority-approval.json"
jq -e '.approval_granted == true and (.approval_grant_ref | length > 0)' "$tmp_root/authority-approval.json" >/dev/null
[[ -f "$tmp_root/.octon/state/control/execution/approvals/requests/req-tooling.yml" ]]
[[ -f "$tmp_root/.octon/state/control/execution/approvals/grants/grant-req-tooling.yml" ]]
find "$tmp_root/.octon/state/evidence/control/execution" -type f -name '*approval*' | grep -q .

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

OCTON_DIR_OVERRIDE="$tmp_root/.octon" OCTON_ROOT_DIR="$tmp_root" bash "$GITHUB_WRAPPER" \
  --pr-number "101" \
  --labels-json '["accept:human","ai-gate:waive"]' \
  --request-scope "ai-review-gate-waiver" \
  --issued-by "github://pull/101" \
  --required-label "accept:human" \
  --required-label "ai-gate:waive" \
  --output "$tmp_root/waiver.json" \
  >/dev/null

jq -e '.approval_granted == true' "$tmp_root/waiver.json" >/dev/null

echo "[OK] authority control tooling writes canonical approval, exception, revocation, and GitHub projection artifacts"
