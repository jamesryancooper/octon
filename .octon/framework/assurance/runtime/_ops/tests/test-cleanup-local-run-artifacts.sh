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

assert_fails() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    fail "$label should fail"
  fi
}

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-local-run-artifacts.XXXXXX")"
trap 'rm -rf "$tmp_root"' EXIT
fixture_index=0

make_fixture() {
  fixture_index=$((fixture_index + 1))
  local root="$tmp_root/fixture-$fixture_index"
  mkdir -p "$root"
  git -C "$root" init >/dev/null
  git -C "$root" config core.excludesFile /dev/null
  printf '.DS_Store\n' >"$root/.gitignore"

  mkdir -p "$root/.octon/generated/effective/capabilities"
  cat >"$root/.octon/generated/effective/capabilities/generation.lock.yml" <<'LOCK'
schema_version: test-lock-v1
retained_receipt_ref: ".octon/state/evidence/validation/publication/capabilities/final.yml"
LOCK
  git -C "$root" add .gitignore .octon/generated/effective/capabilities/generation.lock.yml
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

  mkdir -p "$root/.octon/state/control/execution/runs/lifecycle-proposal-program-1"
  printf 'checkpoint: local\n' >"$root/.octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"

  mkdir -p "$root/.octon/state/continuity/runs/lifecycle-proposal-program-1-workflow"
  printf 'handoff: local\n' >"$root/.octon/state/continuity/runs/lifecycle-proposal-program-1-workflow/handoff.yml"

  mkdir -p "$root/.octon/state/evidence/control/execution"
  printf 'decision: local\n' >"$root/.octon/state/evidence/control/execution/authority-decision-lifecycle-proposal-program-1.yml"
  printf 'grant: local\n' >"$root/.octon/state/evidence/control/execution/authority-grant-bundle-lifecycle-proposal-program-1.yml"

  mkdir -p "$root/.octon/state/evidence/external-index/runs"
  printf 'external-index: local\n' >"$root/.octon/state/evidence/external-index/runs/lifecycle-proposal-program-1.yml"

  mkdir -p "$root/.octon/state/evidence/runs/skills/closeout-worktree/run-1"
  printf 'wrapper-log: local\n' >"$root/.octon/state/evidence/runs/skills/closeout-worktree/run-1/log.yml"

  mkdir -p "$root/.octon/inputs/exploratory/proposals/fixture-local"
  printf 'local finder metadata\n' >"$root/.octon/inputs/exploratory/proposals/fixture-local/.DS_Store"
  printf 'proposal input must stay\n' >"$root/.octon/inputs/exploratory/proposals/fixture-local/proposal.yml"

  mkdir -p "$root/.octon/state/evidence/validation/analysis"
  printf 'manual: true\n' >"$root/.octon/state/evidence/validation/analysis/manual.yml"

  mkdir -p "$root/.octon/generated/cognition/projections/materialized/runs/publish-1"
  printf 'run_health: projection\n' >"$root/.octon/generated/cognition/projections/materialized/runs/publish-1/index.yml"

  echo "$root"
}

authorize_fixture() {
  local root="$1"
  local selected_path="${2:-}"
  local receipt="$tmp_root/receipt-$fixture_index.json"
  if [[ -n "$selected_path" ]]; then
    bash "$HELPER" --root "$root" --cleanup-path "$selected_path" --authorize "$receipt" >/dev/null
  else
    bash "$HELPER" --root "$root" --authorize "$receipt" >/dev/null
  fi
  echo "$receipt"
}

first_authorized_path() {
  python3 - "$1" <<'PY'
import json
import sys
from pathlib import Path

receipt = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
for item in receipt["authorized_paths"]:
    path = item["path"]
    if not path.endswith("/.DS_Store") and path != ".DS_Store":
        print(path)
        break
else:
    print(receipt["authorized_paths"][0]["path"])
PY
}

mutate_receipt() {
  local receipt="$1"
  local mode="$2"
  local value="${3:-}"
  python3 - "$receipt" "$mode" "$value" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
mode = sys.argv[2]
value = sys.argv[3]
receipt = json.loads(path.read_text(encoding="utf-8"))

if mode == "deny":
    receipt["authorization_result"] = "denied"
elif mode == "path":
    receipt["authorized_paths"][0]["path"] = value
elif mode == "proof_false":
    receipt["authorized_paths"][0]["proofs"][value] = False
elif mode == "expire":
    receipt.pop("valid_until_status_changes", None)
    receipt["expires_at"] = "2000-01-01T00:00:00Z"
elif mode == "schema_extra":
    receipt["unexpected_field"] = True
else:
    raise SystemExit(f"unknown mutation mode: {mode}")

path.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
}

root="$(make_fixture)"
dry_run_output="$(bash "$HELPER" --root "$root")"
printf '%s\n' "$dry_run_output" | grep -F "cleanup_candidate" >/dev/null || fail "dry-run did not report cleanup candidates"
printf '%s\n' "$dry_run_output" | grep -F ".octon/state/evidence/validation/publication/capabilities/stale.yml" >/dev/null || fail "dry-run did not classify stale receipt"
printf '%s\n' "$dry_run_output" | grep -F "proposal lifecycle runner residue" >/dev/null || fail "dry-run did not classify lifecycle runner residue"
printf '%s\n' "$dry_run_output" | grep -F "closeout skill run residue" >/dev/null || fail "dry-run did not classify closeout skill run residue"
printf '%s\n' "$dry_run_output" | grep -F "local_filesystem_metadata" | grep -F ".octon/inputs/exploratory/proposals/fixture-local/.DS_Store" >/dev/null || fail "dry-run did not classify local filesystem metadata"
printf '%s\n' "$dry_run_output" | grep -F "cleanup_candidate" | grep -F ".octon/inputs/exploratory/proposals/fixture-local/proposal.yml" >/dev/null && fail "dry-run treated proposal input file as cleanup candidate"
printf '%s\n' "$dry_run_output" | grep -F "protected" | grep -F ".octon/state/evidence/validation/publication/capabilities/final.yml" >/dev/null || fail "dry-run did not protect referenced receipt"
printf '%s\n' "$dry_run_output" | grep -F "manual_review" | grep -F ".octon/state/evidence/validation/analysis/manual.yml" >/dev/null || fail "dry-run did not surface manual-review artifact"
printf '%s\n' "$dry_run_output" | grep -F "generated_run_health_projection" >/dev/null || fail "dry-run did not route generated run-health projection to manual review"

root="$(make_fixture)"
target_metadata_path=".octon/inputs/exploratory/proposals/fixture-local/.DS_Store"
target_receipt="$(authorize_fixture "$root" "$target_metadata_path")"
python3 - "$target_receipt" "$target_metadata_path" <<'PY'
import json
import sys
from pathlib import Path

receipt = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
target = sys.argv[2]
paths = [item["path"] for item in receipt["authorized_paths"]]
if paths != [target]:
    raise SystemExit(f"targeted receipt authorized unexpected paths: {paths}")
item = receipt["authorized_paths"][0]
if item["class"] != "local_filesystem_metadata":
    raise SystemExit(f"targeted receipt used unexpected class: {item['class']}")
PY
bash "$HELPER" --root "$root" --cleanup-path "$target_metadata_path" --authorization "$target_receipt" >/dev/null
assert_missing "$root/$target_metadata_path"
assert_exists "$root/.octon/inputs/exploratory/proposals/fixture-local/proposal.yml"
assert_exists "$root/.octon/state/evidence/validation/publication/capabilities/stale.yml"
assert_exists "$root/.octon/state/control/execution/runs/publish-1/run-manifest.yml"

root="$(make_fixture)"
active_run_output="$(bash "$HELPER" --root "$root" --active-run-id lifecycle-proposal-program-1)"
printf '%s\n' "$active_run_output" | grep -F "protected" | grep -F "active_run_state" | grep -F ".octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml" >/dev/null || fail "active run checkpoint was not protected"
printf '%s\n' "$active_run_output" | grep -F "protected" | grep -F "active_run_state" | grep -F ".octon/state/continuity/runs/lifecycle-proposal-program-1-workflow/handoff.yml" >/dev/null || fail "active run continuity artifact was not protected"
printf '%s\n' "$active_run_output" | grep -F "protected" | grep -F "active_run_state" | grep -F ".octon/state/evidence/control/execution/authority-decision-lifecycle-proposal-program-1.yml" >/dev/null || fail "active run authority decision was not protected"
active_receipt="$tmp_root/active-receipt-$fixture_index.json"
bash "$HELPER" --root "$root" --active-run-id lifecycle-proposal-program-1 --authorize "$active_receipt" >/dev/null
bash "$HELPER" --root "$root" --active-run-id lifecycle-proposal-program-1 --authorization "$active_receipt" >/dev/null
assert_exists "$root/.octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
assert_exists "$root/.octon/state/continuity/runs/lifecycle-proposal-program-1-workflow/handoff.yml"
assert_exists "$root/.octon/state/evidence/control/execution/authority-decision-lifecycle-proposal-program-1.yml"
assert_missing "$root/.octon/state/control/execution/runs/publish-1/run-manifest.yml"

receipt="$(authorize_fixture "$root")"
grep -F '"schema_version": "repo-hygiene-cleanup-authorization-v1"' "$receipt" >/dev/null || fail "authorization receipt has wrong schema version"
bash "$HELPER" --root "$root" --authorization "$receipt" >/dev/null
assert_missing "$root/.octon/state/evidence/validation/publication/capabilities/stale.yml"
assert_missing "$root/.octon/state/control/execution/runs/publish-1/run-manifest.yml"
assert_missing "$root/.octon/state/continuity/runs/service-build-1/state.yml"
assert_missing "$root/.octon/state/control/engine/agent/checkpoints/runtime-agent-quorum-allow-1.json"
assert_missing "$root/.octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
assert_missing "$root/.octon/state/continuity/runs/lifecycle-proposal-program-1-workflow/handoff.yml"
assert_missing "$root/.octon/state/evidence/control/execution/authority-decision-lifecycle-proposal-program-1.yml"
assert_missing "$root/.octon/state/evidence/control/execution/authority-grant-bundle-lifecycle-proposal-program-1.yml"
assert_missing "$root/.octon/state/evidence/external-index/runs/lifecycle-proposal-program-1.yml"
assert_missing "$root/.octon/state/evidence/runs/skills/closeout-worktree/run-1/log.yml"
assert_missing "$root/.octon/inputs/exploratory/proposals/fixture-local/.DS_Store"
assert_exists "$root/.octon/inputs/exploratory/proposals/fixture-local/proposal.yml"
assert_exists "$root/.octon/state/evidence/validation/publication/capabilities/final.yml"
assert_exists "$root/.octon/state/evidence/validation/analysis/manual.yml"
assert_exists "$root/.octon/generated/cognition/projections/materialized/runs/publish-1/index.yml"

root="$(make_fixture)"
bash "$HELPER" --root "$root" --confirm >/dev/null
assert_missing "$root/.octon/state/evidence/validation/publication/capabilities/stale.yml"
assert_missing "$root/.octon/inputs/exploratory/proposals/fixture-local/.DS_Store"
assert_exists "$root/.octon/inputs/exploratory/proposals/fixture-local/proposal.yml"
assert_exists "$root/.octon/state/evidence/validation/publication/capabilities/final.yml"

assert_fails "--fail-on-manual" bash "$HELPER" --root "$root" --fail-on-manual

root="$(make_fixture)"
assert_fails "missing authorization receipt" bash "$HELPER" --root "$root" --authorization "$root/missing.json"

root="$(make_fixture)"
malformed="$tmp_root/malformed.json"
printf '{not-json\n' >"$malformed"
assert_fails "malformed authorization receipt" bash "$HELPER" --root "$root" --authorization "$malformed"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" deny
assert_fails "denied authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" schema_extra
assert_fails "schema-invalid authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" expire
assert_fails "expired authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mkdir -p "$root/.octon/state/control/execution/runs/publish-2"
printf 'run: publish\n' >"$root/.octon/state/control/execution/runs/publish-2/run-manifest.yml"
assert_fails "stale status and path-set authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/state/evidence/validation/publication/capabilities/final.yml"
assert_fails "path-mismatched protected authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
candidate="$(first_authorized_path "$receipt")"
git -C "$root" add "$candidate"
git -C "$root" -c user.name="Octon Test" -c user.email="octon@example.invalid" commit -m "track cleanup candidate" >/dev/null
assert_fails "tracked path authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
candidate="$(first_authorized_path "$receipt")"
printf 'ref: %s\n' "$candidate" >"$root/tracked-reference.yml"
git -C "$root" add tracked-reference.yml
git -C "$root" -c user.name="Octon Test" -c user.email="octon@example.invalid" commit -m "reference cleanup candidate" >/dev/null
assert_fails "referenced path authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/state/evidence/validation/analysis/manual.yml"
assert_fails "manual-review durable evidence authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/state/control/custom.yml"
assert_fails "active control authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/inputs/exploratory/proposals/fixture-local/proposal.yml"
assert_fails "proposal input file authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/generated/effective/capabilities/generation.lock.yml"
assert_fails "generated authority authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/generated/cognition/projections/materialized/runs/publish-1/index.yml"
assert_fails "generated run-health authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" proof_false "not_ignored_or_user_owned_residue"
assert_fails "ignored or user-owned residue authorization proof" bash "$HELPER" --root "$root" --authorization "$receipt"

echo "[OK] cleanup-local-run-artifacts helper preserves referenced evidence and requires validating cleanup authorization receipts"
