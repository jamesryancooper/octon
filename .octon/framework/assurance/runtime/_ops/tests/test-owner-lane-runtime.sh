#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

MANIFEST=.octon/framework/engine/runtime/crates/Cargo.toml
ASKPASS=.octon/framework/execution-roles/_ops/scripts/git/git-owner-lane-askpass.sh
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/octon-owner-lane-test.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

jq empty .octon/framework/constitution/contracts/authority/owner-lane-*.schema.json

OWNER_LANE=.octon/framework/engine/runtime/crates/kernel/src/owner_lane.rs
KERNEL_MAIN=.octon/framework/engine/runtime/crates/kernel/src/main.rs

rg -q 'capture_metadata: PathBuf' "$OWNER_LANE"
rg -q 'operation_plan: PathBuf' "$OWNER_LANE"
rg -q 'PullRequestReconcile' "$OWNER_LANE"
rg -q 'canonical_pr_number' "$OWNER_LANE"
rg -q 'normalize_realized_operation' "$OWNER_LANE"
rg -q 'capture-metadata' "$KERNEL_MAIN"
rg -q 'operation-plan' "$KERNEL_MAIN"

if rg -n 'issuance_outcome: PathBuf|admission_receipt: PathBuf|manifest: PathBuf|attestation: PathBuf' \
  "$OWNER_LANE"; then
  echo 'owner-lane runtime still accepts observation-dependent artifacts as inputs' >&2
  exit 1
fi

cargo test --manifest-path "$MANIFEST" -p octon_authority_engine \
  owner_lane --no-fail-fast
cargo test --manifest-path "$MANIFEST" -p octon_kernel owner_lane --no-fail-fast
cargo test --manifest-path "$MANIFEST" -p octon_kernel provider_authority --no-fail-fast

username="$($ASKPASS 'Username for https://github.com:')"
[[ "$username" == x-access-token ]]

fifo="$TMP_ROOT/credential.fifo"
mkfifo "$fifo"
fixture='github_pat_fixture_never_live_owner_lane'
(
  printf '%s\n' "$fixture" >"$fifo"
) &
writer_pid=$!
password="$(OCTON_OWNER_LANE_CREDENTIAL_FIFO="$fifo" "$ASKPASS" 'Password for https://github.com:')"
wait "$writer_pid"
[[ "$password" == "$fixture" ]]
password=''
fixture=''

if OCTON_OWNER_LANE_CREDENTIAL_FIFO="$fifo" "$ASKPASS" 'Password for https://github.com:' >/dev/null 2>&1; then
  echo 'owner-lane askpass incorrectly allowed a second password read' >&2
  exit 1
fi

rm -f "$fifo"
rmdir "${fifo}.used"
[[ ! -e "$fifo" && ! -e "${fifo}.used" ]]

if rg -n 'Command::new\([^)]*"gh"|ProcessCommand::new\([^)]*"gh"|ssh://' "$OWNER_LANE"; then
  echo 'owner-lane runtime contains a prohibited gh or SSH launch path' >&2
  exit 1
fi

echo 'owner-lane runtime hermetic protocol and denial suite: pass'
