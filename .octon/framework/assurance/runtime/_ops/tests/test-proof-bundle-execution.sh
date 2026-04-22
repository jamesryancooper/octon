#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"

pass_count=0
fail_count=0
cleanup_dirs=()

remove_dir_tree() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0

  find "$dir" -depth \( -type f -o -type l \) -exec rm -f -- {} + 2>/dev/null || true
  find "$dir" -depth -type d -exec rmdir -- {} + 2>/dev/null || true
}

cleanup() {
  local dir
  for dir in "${cleanup_dirs[@]}"; do
    remove_dir_tree "$dir"
  done
}
trap cleanup EXIT

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

create_fixture() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/packet10-proof-bundle.XXXXXX")"
  cleanup_dirs+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.octon/instance/governance" \
    "$fixture_root/.octon/state/evidence/validation/support-targets" \
    "$fixture_root/.octon/state/evidence/lab/replays"

  cat >"$fixture_root/.octon/instance/governance/support-targets.yml" <<'EOF'
tuple_admissions:
  - proof_bundle_ref: .octon/state/evidence/validation/support-targets/demo-proof.yml
EOF

  printf 'ok\n' >"$fixture_root/.octon/state/evidence/lab/replays/demo.yml"
  printf '%s\n' "$fixture_root"
}

write_bundle() {
  local fixture_root="$1"
  local execution_block="$2"
  cat >"$fixture_root/.octon/state/evidence/validation/support-targets/demo-proof.yml" <<EOF
schema_version: support-target-proof-bundle-v1
bundle_id: support-proof://demo/current
tuple_id: tuple://demo
freshness:
  reviewed_at: "2026-04-22T00:00:00Z"
  review_due_at: "2026-06-30T00:00:00Z"
command_or_evaluator: validator://demo-proof
evaluator_version: executable-proof-bundle-v1
input_digests:
  support_targets_sha256: abc
output_digests:
  proof_sha256: def
pass_fail_criteria:
  - "proof stays executable"
receipt_refs:
  - .octon/state/evidence/validation/architecture/10of10-target-transition/support-targets/proofing.yml
result: pass
proof_planes:
  - plane_id: structural
    status: pass
scenario_evidence:
  representative_run_refs:
    - .octon/state/control/execution/runs/demo/run-contract.yml
  negative_control_refs:
    - .octon/instance/governance/exclusions/action-classes.yml
  lab_refs:
    - .octon/state/evidence/lab/replays/demo.yml
disclosure_evidence:
  run_card_refs:
    - .octon/state/evidence/disclosure/runs/demo/run-card.yml
sufficiency:
  status: qualified
$execution_block
EOF
}

run_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proof-bundle-executability.sh" >/dev/null
}

case_explicit_replay_execution_passes() {
  local fixture_root
  fixture_root="$(create_fixture)"
  write_bundle "$fixture_root" $'execution:\n  mode: replay\n  replay_ref: .octon/state/evidence/lab/replays/demo.yml'
  run_validator "$fixture_root"
}

case_legacy_executable_bundle_without_execution_block_passes() {
  local fixture_root
  fixture_root="$(create_fixture)"
  write_bundle "$fixture_root" ""
  run_validator "$fixture_root"
}

case_missing_execution_or_replay_evidence_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  write_bundle "$fixture_root" $'execution:\n  mode: replay'
  yq -i 'del(.scenario_evidence.lab_refs)' "$fixture_root/.octon/state/evidence/validation/support-targets/demo-proof.yml"
  ! run_validator "$fixture_root"
}

case_missing_negative_controls_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  write_bundle "$fixture_root" $'execution:\n  mode: replay\n  replay_ref: .octon/state/evidence/lab/replays/demo.yml'
  yq -i 'del(.scenario_evidence.negative_control_refs)' "$fixture_root/.octon/state/evidence/validation/support-targets/demo-proof.yml"
  ! run_validator "$fixture_root"
}

main() {
  assert_success "explicit replay execution passes" case_explicit_replay_execution_passes
  assert_success "legacy executable bundles remain accepted" case_legacy_executable_bundle_without_execution_block_passes
  assert_success "missing execution or replay evidence fails" case_missing_execution_or_replay_evidence_fails
  assert_success "missing negative controls fail" case_missing_negative_controls_fails

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
