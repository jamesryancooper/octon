#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
LANDER="$ROOT_DIR/.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh"
AUTHORIZER="$ROOT_DIR/.octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

bash "$VALIDATOR"
git -C "$TMP_DIR" init -q -b main
git -C "$TMP_DIR" config user.email test@example.invalid
git -C "$TMP_DIR" config user.name test
git -C "$TMP_DIR" commit --allow-empty -qm base
git -C "$TMP_DIR" switch -qc candidate
before="$(git -C "$TMP_DIR" show-ref | LC_ALL=C sort)"

if (cd "$TMP_DIR" && bash "$LANDER" --execute-authorized-landing --confirm) >"$TMP_DIR/out" 2>&1; then
  echo "FAIL: hosted lander succeeded" >&2
  exit 1
fi
grep -Fq 'RP00_CONTAINMENT_PUBLICATION_DISABLED' "$TMP_DIR/out"

if (cd "$TMP_DIR" && bash "$AUTHORIZER" --output "$TMP_DIR/authorization.json" --rollback-handle keep) >"$TMP_DIR/auth-out" 2>&1; then
  echo "FAIL: hosted authorizer succeeded" >&2
  exit 1
fi
grep -Fq 'RP00_CONTAINMENT_PUBLICATION_DISABLED' "$TMP_DIR/auth-out"
[[ ! -e "$TMP_DIR/authorization.json" ]]
after="$(git -C "$TMP_DIR" show-ref | LC_ALL=C sort)"
[[ "$before" == "$after" ]]
echo "PASS: hosted no-PR helpers deny before mutation"
