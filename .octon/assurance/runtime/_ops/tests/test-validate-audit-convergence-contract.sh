#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
OCTON_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
VALIDATE_SCRIPT=".octon/assurance/runtime/_ops/scripts/validate-audit-convergence-contract.sh"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    [[ -n "$path" ]] && rm -rf "$path"
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
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

assert_failure_contains() {
  local name="$1"
  local needle="$2"
  shift 2

  local output=""
  local rc=0
  output="$("$@" 2>&1)" || rc=$?

  if (( rc != 0 )) && grep -Fq "$needle" <<<"$output"; then
    pass "$name"
    return 0
  fi

  fail "$name"
  echo "  expected failure containing: $needle" >&2
  echo "  exit code: $rc" >&2
  echo "  output:" >&2
  echo "$output" >&2
  return 1
}

create_fixture_repo() {
  local fixture_root bundle_dir
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/audit-convergence-contract.XXXXXX")"
  cleanup_paths+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.octon/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/cognition/practices/methodology/audits" \
    "$fixture_root/.octon/cognition/runtime/audits" \
    "$fixture_root/.octon/output/reports/audits"

  cp "$REPO_ROOT/$VALIDATE_SCRIPT" \
    "$fixture_root/.octon/assurance/runtime/_ops/scripts/validate-audit-convergence-contract.sh"

  cat > "$fixture_root/.octon/cognition/practices/methodology/audits/README.md" <<'EOF'
# Bounded Audits
EOF
  cat > "$fixture_root/.octon/cognition/practices/methodology/audits/index.yml" <<'EOF'
schema_version: "audit-methodology-index-v1"
artifacts: []
EOF
  cat > "$fixture_root/.octon/cognition/practices/methodology/audits/doctrine.md" <<'EOF'
# Doctrine
EOF
  cat > "$fixture_root/.octon/cognition/practices/methodology/audits/invariants.md" <<'EOF'
# Invariants
EOF
  cat > "$fixture_root/.octon/cognition/practices/methodology/audits/exceptions.md" <<'EOF'
# Exceptions
EOF
  cat > "$fixture_root/.octon/cognition/practices/methodology/audits/ci-gates.md" <<'EOF'
# CI Gates
EOF
  cat > "$fixture_root/.octon/cognition/practices/methodology/audits/findings-contract.md" <<'EOF'
# Findings Contract
EOF

  cat > "$fixture_root/.octon/cognition/runtime/audits/README.md" <<'EOF'
# Runtime Audits
EOF
  cat > "$fixture_root/.octon/cognition/runtime/audits/index.yml" <<'EOF'
schema_version: "audit-runtime-index-v1"
records: []
EOF

  cat > "$fixture_root/.octon/output/reports/audits/README.md" <<'EOF'
# Audit Reports
EOF

  bundle_dir="$fixture_root/.octon/output/reports/audits/2026-03-11-valid-bundle"
  mkdir -p "$bundle_dir"

  cat > "$bundle_dir/bundle.yml" <<'EOF'
kind: audit-evidence-bundle
id: 2026-03-11-valid-bundle
findings: findings.yml
coverage: coverage.yml
convergence: convergence.yml
evidence: evidence.md
commands: commands.md
validation: validation.md
inventory: inventory.md
EOF
  cat > "$bundle_dir/findings.yml" <<'EOF'
findings: []
EOF
  cat > "$bundle_dir/coverage.yml" <<'EOF'
unaccounted_files: 0
EOF
  cat > "$bundle_dir/convergence.yml" <<'EOF'
run_id: "run-001"
commit_sha: "abc123"
scope_hash: "scope-hash"
prompt_hash: "prompt-hash"
findings_hash: "findings-hash"
params_hash: "params-hash"
seed_unsupported: true
fingerprint_unsupported: true
stable: true
union_blocking_findings: 0
open_findings_at_or_above_threshold: 0
done: true
EOF
  cat > "$bundle_dir/evidence.md" <<'EOF'
# Evidence
EOF
  cat > "$bundle_dir/commands.md" <<'EOF'
# Commands
EOF
  cat > "$bundle_dir/validation.md" <<'EOF'
# Validation
EOF
  cat > "$bundle_dir/inventory.md" <<'EOF'
# Inventory
EOF

  (
    cd "$fixture_root"
    git init >/dev/null
    git add .octon
  )

  printf '%s\n' "$fixture_root"
}

run_validator_in_fixture() {
  local fixture_root="$1"
  (
    cd "$fixture_root"
    bash "$VALIDATE_SCRIPT"
  )
}

case_ignores_untracked_stale_workspace_dirs() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  mkdir -p \
    "$fixture_root/.octon/output/reports/audits/2026-03-08-architecture-validation-pipeline-smoke/reports" \
    "$fixture_root/.octon/output/reports/audits/2026-03-08-architecture-validation-pipeline-smoke/stage-inputs" \
    "$fixture_root/.octon/output/reports/audits/2026-03-08-architecture-validation-pipeline-smoke/stage-logs"
  mkdir -p \
    "$fixture_root/.octon/output/reports/audits/2026-03-09-pipeline-design-package-smoke/reports" \
    "$fixture_root/.octon/output/reports/audits/2026-03-09-pipeline-design-package-smoke/stage-inputs" \
    "$fixture_root/.octon/output/reports/audits/2026-03-09-pipeline-design-package-smoke/stage-logs"
  run_validator_in_fixture "$fixture_root"
}

case_tracked_partial_bundle_still_fails() {
  local fixture_root broken_dir
  fixture_root="$(create_fixture_repo)"
  broken_dir="$fixture_root/.octon/output/reports/audits/2026-03-08-pipeline-smoke"
  mkdir -p "$broken_dir/reports"
  cat > "$broken_dir/reports/01-stage.md" <<'EOF'
# Partial Report
EOF
  (
    cd "$fixture_root"
    git add ".octon/output/reports/audits/2026-03-08-pipeline-smoke/reports/01-stage.md"
  )
  run_validator_in_fixture "$fixture_root"
}

case_materialized_untracked_bundle_fails() {
  local fixture_root broken_dir
  fixture_root="$(create_fixture_repo)"
  broken_dir="$fixture_root/.octon/output/reports/audits/2026-03-09-pipeline-design-package-smoke"
  mkdir -p "$broken_dir"
  cat > "$broken_dir/bundle.yml" <<'EOF'
kind: audit-evidence-bundle
id: 2026-03-09-pipeline-design-package-smoke
findings: findings.yml
coverage: coverage.yml
convergence: convergence.yml
evidence: evidence.md
commands: commands.md
validation: validation.md
inventory: inventory.md
EOF
  run_validator_in_fixture "$fixture_root"
}

main() {
  assert_success \
    "audit convergence validator ignores untracked stale workspace directories" \
    case_ignores_untracked_stale_workspace_dirs

  assert_failure_contains \
    "audit convergence validator still rejects tracked partial bundles" \
    "bundle missing metadata file: .octon/output/reports/audits/2026-03-08-pipeline-smoke/bundle.yml" \
    case_tracked_partial_bundle_still_fails

  assert_failure_contains \
    "audit convergence validator rejects materialized untracked bundles missing required files" \
    "bundle missing required file (findings.yml): .octon/output/reports/audits/2026-03-09-pipeline-design-package-smoke" \
    case_materialized_untracked_bundle_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"

  if (( fail_count > 0 )); then
    exit 1
  fi
}

main "$@"
