#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
FINGERPRINT="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/proposal-lifecycle-residue-fingerprint.sh"
CLEANUP_HELPER="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh"
WORKTREE_CLASSIFIER="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh"

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

assert_not_equals() {
  local left="$1" right="$2" label="$3"
  [[ "$left" != "$right" ]] || fail "$label"
}

assert_equals() {
  local left="$1" right="$2" label="$3"
  [[ "$left" == "$right" ]] || fail "$label: expected '$right', got '$left'"
}

assert_sha256() {
  local digest="$1"
  [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]] || fail "invalid fingerprint digest: $digest"
}

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-residue-fingerprint.XXXXXX")"
trap 'rm -rf "$tmp_root"' EXIT

mkdir -p "$tmp_root/.octon/framework/assurance/runtime/_ops/scripts"
cp "$FINGERPRINT" "$tmp_root/.octon/framework/assurance/runtime/_ops/scripts/proposal-lifecycle-residue-fingerprint.sh"
cp "$CLEANUP_HELPER" "$tmp_root/.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh"
cp "$WORKTREE_CLASSIFIER" "$tmp_root/.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh"
chmod +x "$tmp_root/.octon/framework/assurance/runtime/_ops/scripts/"*.sh

target=".octon/inputs/exploratory/proposals/architecture/fixture-program"
mkdir -p "$tmp_root/$target"
cat >"$tmp_root/$target/proposal.yml" <<'YAML'
schema_version: "proposal-v1"
proposal_id: "fixture-program"
title: "Fixture Program"
summary: "Fixture program."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/example.md"
status: "accepted"
related_proposals: []
YAML
mkdir -p "$tmp_root/.octon/framework"
printf 'baseline\n' >"$tmp_root/.octon/framework/example.md"

git -C "$tmp_root" init -q
git -C "$tmp_root" config user.email "octon-test@example.invalid"
git -C "$tmp_root" config user.name "Octon Test"
git -C "$tmp_root" add .
git -C "$tmp_root" commit -qm baseline

run_fingerprint() {
  OCTON_ROOT_DIR="$tmp_root" bash "$tmp_root/.octon/framework/assurance/runtime/_ops/scripts/proposal-lifecycle-residue-fingerprint.sh" \
    --target "$target" \
    --lifecycle proposal-program
}

summary_only() {
  OCTON_ROOT_DIR="$tmp_root" bash "$tmp_root/.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh" \
    --summary-only \
    --root "$tmp_root" \
    --octon-dir "$tmp_root/.octon"
}

baseline="$(run_fingerprint)"
assert_sha256 "$baseline"

mkdir -p "$tmp_root/.octon/state/evidence/validation/analysis"
printf 'manual: true\n' >"$tmp_root/.octon/state/evidence/validation/analysis/manual.yml"
manual_summary="$(summary_only)"
grep -F "cleanup_candidates: 0" <<<"$manual_summary" >/dev/null || fail "manual-only residue created cleanup candidates"
grep -F "manual_review: 1" <<<"$manual_summary" >/dev/null || fail "manual-only residue was not retained for manual review"
manual_only="$(run_fingerprint)"
assert_equals "$manual_only" "$baseline" "manual-review residue must not stale cleanup fingerprint"

mkdir -p "$tmp_root/.octon/state/control/execution/runs/publish-1"
printf 'run: publish\n' >"$tmp_root/.octon/state/control/execution/runs/publish-1/run-manifest.yml"
one_candidate_summary="$(summary_only)"
grep -F "cleanup_candidates: 1" <<<"$one_candidate_summary" >/dev/null || fail "cleanup candidate was not detected"
one_candidate="$(run_fingerprint)"
assert_sha256 "$one_candidate"
assert_not_equals "$one_candidate" "$baseline" "cleanup candidate must change residue fingerprint"

mkdir -p "$tmp_root/.octon/state/continuity/runs/publish-2"
printf 'run: publish\n' >"$tmp_root/.octon/state/continuity/runs/publish-2/state.yml"
two_candidate_summary="$(summary_only)"
grep -F "cleanup_candidates: 2" <<<"$two_candidate_summary" >/dev/null || fail "second cleanup candidate was not detected"
two_candidates="$(run_fingerprint)"
assert_sha256 "$two_candidates"
assert_not_equals "$two_candidates" "$one_candidate" "changed cleanup path set must change residue fingerprint"

if OCTON_ROOT_DIR="$tmp_root" bash "$tmp_root/.octon/framework/assurance/runtime/_ops/scripts/proposal-lifecycle-residue-fingerprint.sh" \
  --target "$target" \
  --lifecycle unknown >/dev/null 2>&1; then
  fail "unknown lifecycle was accepted"
fi

echo "[OK] proposal lifecycle residue fingerprint tracks cleanup candidates and ignores retained manual-review residue"
