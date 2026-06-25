#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh"

pass_count=0
fail_count=0
cleanup_dirs=()

cleanup() {
  local dir
  for dir in "${cleanup_dirs[@]}"; do
    case "$dir" in
      "${TMPDIR:-/tmp}"/generated-non-authority.*)
        [[ -d "$dir" ]] && rm -r -- "$dir"
        ;;
      *)
        echo "refusing to remove unexpected cleanup path: $dir" >&2
        ;;
    esac
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

write_required_contracts() {
  local repo_root="$1"
  mkdir -p \
    "$repo_root/.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery" \
    "$repo_root/.octon/framework/constitution/obligations" \
    "$repo_root/.octon/framework/cognition/_meta/architecture"

  cat >"$repo_root/.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/workflow.yml" <<'EOF'
generated_freshness_scope_detection
generated_freshness_not_in_scope
generated_input_scope_detected_and_owner_routed
generated_refresh_needed_but_not_authorized
generated_output_present_but_stale
generated_output_fresh_but_non_authoritative
proposal_local_or_parent_evidence_satisfies_generated_freshness: false
generated_output_authorizes_closeout_or_archive: false
EOF
  cat >"$repo_root/.octon/framework/constitution/obligations/fail-closed.yml" <<'EOF'
A generated artifact is treated as source-of-truth or as a second control plane.
EOF
  cat >"$repo_root/.octon/framework/cognition/_meta/architecture/specification.md" <<'EOF'
`generated/**` is rebuildable and never mints authority.
EOF
}

write_scan_receipt() {
  local repo_root="$1"
  mkdir -p "$repo_root/.octon/state/evidence/validation/architecture/10of10-remediation/registry"
  cat >"$repo_root/.octon/state/evidence/validation/architecture/10of10-remediation/registry/generated-non-authority-scan.yml" <<'EOF'
schema_version: generated-non-authority-scan-v1
scan_roots:
  - .octon/framework/engine/runtime/crates
  - .octon/instance/governance/policies
scan_patterns:
  - .octon/generated/cognition/
allowed_reference_files:
  - .octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs
required_rule_refs:
  - doc_ref: .octon/framework/constitution/obligations/fail-closed.yml
    required_text:
      - A generated artifact is treated as source-of-truth or as a second control plane.
  - doc_ref: .octon/framework/cognition/_meta/architecture/specification.md
    required_text:
      - "`generated/**` is rebuildable and never mints authority."
EOF
}

create_fixture_repo() {
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/generated-non-authority.XXXXXX")"
  cleanup_dirs+=("$tmp")
  write_required_contracts "$tmp"
  write_scan_receipt "$tmp"
  mkdir -p "$tmp/.octon/framework/engine/runtime/crates/kernel/src"
  printf '%s\n' \
    'const RUN_HEALTH_ROOT: &str = ".octon/generated/cognition/projections/materialized/runs";' \
    >"$tmp/.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs"
  printf '%s\n' "$tmp"
}

run_fixture_validator() {
  local repo_root="$1"
  OCTON_DIR_OVERRIDE="$repo_root/.octon" \
    OCTON_ROOT_DIR="$repo_root" \
    bash "$VALIDATOR" >/dev/null
}

case_allowed_lifecycle_recovery_reference_passes() {
  local tmp
  tmp="$(create_fixture_repo)"
  run_fixture_validator "$tmp"
}

case_unlisted_runtime_generated_reference_fails() {
  local tmp
  tmp="$(create_fixture_repo)"
  cat >"$tmp/.octon/framework/engine/runtime/crates/kernel/src/unlisted.rs" <<'EOF'
const GENERATED_AUTHORITY_LEAK: &str = ".octon/generated/cognition/projections/materialized/runs";
EOF
  ! run_fixture_validator "$tmp"
}

case_generated_output_allowlist_fails_closed() {
  local tmp
  tmp="$(create_fixture_repo)"
  yq -i '.allowed_reference_files += [".octon/generated/cognition/projections/materialized/runs/index.yml"]' \
    "$tmp/.octon/state/evidence/validation/architecture/10of10-remediation/registry/generated-non-authority-scan.yml"
  ! run_fixture_validator "$tmp"
}

main() {
  assert_success "allowed lifecycle recovery generated reference passes" case_allowed_lifecycle_recovery_reference_passes
  assert_success "unlisted runtime generated reference fails" case_unlisted_runtime_generated_reference_fails
  assert_success "generated output allowlist fails closed" case_generated_output_allowlist_fails_closed

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
