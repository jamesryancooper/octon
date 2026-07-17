#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-branch-no-pr-delivery-authorization-envelope.sh"
AUTHORIZER="$ROOT_DIR/.octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh"

bash "$VALIDATOR"
if bash "$AUTHORIZER" --output /tmp/rp00-forbidden-authorization.json --rollback-handle keep >/tmp/rp00-auth-output 2>&1; then
  echo "FAIL: no-PR authorizer succeeded" >&2
  exit 1
fi
grep -Fq 'RP00_CONTAINMENT_PUBLICATION_DISABLED' /tmp/rp00-auth-output
[[ ! -e /tmp/rp00-forbidden-authorization.json ]]
rm -f /tmp/rp00-auth-output
echo "PASS: no-PR authorization envelope is deny-only"
