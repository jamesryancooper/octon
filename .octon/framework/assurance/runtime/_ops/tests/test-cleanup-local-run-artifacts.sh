#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HELPER="$SCRIPT_DIR/../scripts/cleanup-local-run-artifacts.sh"

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

assert_exists() {
  [[ -e "$1" ]] || fail "expected path to exist: $1"
}

assert_missing() {
  [[ ! -e "$1" ]] || fail "expected path to be removed: $1"
}

root="$(mktemp -d "${TMPDIR:-/tmp}/octon-local-run-artifacts.XXXXXX")"
trap 'rm -rf "$root"' EXIT

git -C "$root" init >/dev/null
mkdir -p "$root/.octon/generated/effective/capabilities"
cat >"$root/.octon/generated/effective/capabilities/generation.lock.yml" <<'LOCK'
schema_version: test-lock-v1
retained_receipt_ref: ".octon/state/evidence/validation/publication/capabilities/final.yml"
LOCK
git -C "$root" add .octon/generated/effective/capabilities/generation.lock.yml
git -C "$root" -c user.name="Octon Test" -c user.email="octon@example.invalid" commit -m "test fixture" >/dev/null

mkdir -p "$root/.octon/state/evidence/validation/publication/capabilities"
printf 'receipt: final\n' >"$root/.octon/state/evidence/validation/publication/capabilities/final.yml"
printf 'receipt: stale\n' >"$root/.octon/state/evidence/validation/publication/capabilities/stale.yml"

mkdir -p "$root/.octon/state/control/execution/runs/publish-1"
printf 'run: publish\n' >"$root/.octon/state/control/execution/runs/publish-1/run-manifest.yml"

mkdir -p "$root/.octon/state/continuity/runs/service-build-1"
printf 'run: service\n' >"$root/.octon/state/continuity/runs/service-build-1/state.yml"

mkdir -p "$root/.octon/state/control/engine/agent/checkpoints"
printf '{}\n' >"$root/.octon/state/control/engine/agent/checkpoints/runtime-agent-quorum-allow-1.json"

mkdir -p "$root/.octon/state/evidence/validation/analysis"
printf 'manual: true\n' >"$root/.octon/state/evidence/validation/analysis/manual.yml"

dry_run_output="$(bash "$HELPER" --root "$root")"
printf '%s\n' "$dry_run_output" | grep -F "cleanup_candidate" >/dev/null || fail "dry-run did not report cleanup candidates"
printf '%s\n' "$dry_run_output" | grep -F ".octon/state/evidence/validation/publication/capabilities/stale.yml" >/dev/null || fail "dry-run did not classify stale receipt"
printf '%s\n' "$dry_run_output" | grep -F "protected" | grep -F ".octon/state/evidence/validation/publication/capabilities/final.yml" >/dev/null || fail "dry-run did not protect referenced receipt"
printf '%s\n' "$dry_run_output" | grep -F "manual_review" | grep -F ".octon/state/evidence/validation/analysis/manual.yml" >/dev/null || fail "dry-run did not surface manual-review artifact"

assert_exists "$root/.octon/state/evidence/validation/publication/capabilities/stale.yml"
assert_exists "$root/.octon/state/control/execution/runs/publish-1/run-manifest.yml"

bash "$HELPER" --root "$root" --confirm >/dev/null

assert_missing "$root/.octon/state/evidence/validation/publication/capabilities/stale.yml"
assert_missing "$root/.octon/state/control/execution/runs/publish-1/run-manifest.yml"
assert_missing "$root/.octon/state/continuity/runs/service-build-1/state.yml"
assert_missing "$root/.octon/state/control/engine/agent/checkpoints/runtime-agent-quorum-allow-1.json"
assert_exists "$root/.octon/state/evidence/validation/publication/capabilities/final.yml"
assert_exists "$root/.octon/state/evidence/validation/analysis/manual.yml"

if bash "$HELPER" --root "$root" --fail-on-manual >/dev/null 2>&1; then
  fail "--fail-on-manual should fail while manual-review artifacts remain"
fi

echo "[OK] cleanup-local-run-artifacts helper preserves referenced evidence and removes only cleanup candidates"
