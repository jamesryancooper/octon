#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
AUTHORIZER="$ROOT_DIR/.octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-cleanup.sh"
CLEANUP="$ROOT_DIR/.octon/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh"
SCHEMA="$ROOT_DIR/.octon/framework/product/contracts/branch-cleanup-authorization-v1.schema.json"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

git -C "$TMP_DIR" init -q -b main
git -C "$TMP_DIR" config user.email test@example.invalid
git -C "$TMP_DIR" config user.name test
git -C "$TMP_DIR" commit --allow-empty -qm base
git -C "$TMP_DIR" branch candidate
landed_ref="$(git -C "$TMP_DIR" rev-parse HEAD)"
before_refs="$(git -C "$TMP_DIR" show-ref | LC_ALL=C sort)"
before_worktrees="$(git -C "$TMP_DIR" worktree list --porcelain)"

if (cd "$TMP_DIR" && bash "$AUTHORIZER" --branch candidate --landed-ref "$landed_ref" --retained-rollback-ref refs/heads/candidate --selected-route branch-no-pr --output "$TMP_DIR/denied.json") >"$TMP_DIR/authorize.out" 2>&1; then
  echo "FAIL: cleanup authorizer returned approval" >&2
  exit 1
fi

jq -e '.authorization_result == "denied" and .denial_reason == "RP00_CONTAINMENT_CLEANUP_DISABLED" and .mutation_permitted == false and .observed_local_source_ref != null and .rollback_handles == ["refs/heads/candidate"]' "$TMP_DIR/denied.json" >/dev/null
jq -e '.properties.authorization_result.const == "denied" and .properties.mutation_permitted.const == false' "$SCHEMA" >/dev/null

if (cd "$TMP_DIR" && bash "$CLEANUP" --branch candidate --landed-ref "$landed_ref" --retained-rollback-ref refs/heads/candidate --authorization "$TMP_DIR/denied.json" --confirm) >"$TMP_DIR/cleanup.out" 2>&1; then
  echo "FAIL: cleanup mutation succeeded" >&2
  exit 1
fi
grep -Fq 'RP00_CONTAINMENT_CLEANUP_DISABLED' "$TMP_DIR/cleanup.out"

(cd "$TMP_DIR" && bash "$CLEANUP" --branch candidate --landed-ref "$landed_ref" --retained-rollback-ref refs/heads/candidate --authorization "$TMP_DIR/denied.json" --dry-run) >"$TMP_DIR/dry.out"
grep -Fq 'mutation_permitted=false' "$TMP_DIR/dry.out"

after_refs="$(git -C "$TMP_DIR" show-ref | LC_ALL=C sort)"
after_worktrees="$(git -C "$TMP_DIR" worktree list --porcelain)"
[[ "$before_refs" == "$after_refs" ]]
[[ "$before_worktrees" == "$after_worktrees" ]]
echo "PASS: cleanup receipt is deny-only and candidate state survives"
