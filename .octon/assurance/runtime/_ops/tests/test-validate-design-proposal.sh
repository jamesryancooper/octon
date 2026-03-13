#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
OCTON_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
VALIDATE_SCRIPT=".octon/assurance/runtime/_ops/scripts/validate-design-proposal.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r "$dir"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

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
  local output="" rc=0
  output="$("$@" 2>&1)" || rc=$?
  if (( rc != 0 )) && grep -Fq "$needle" <<<"$output"; then
    pass "$name"
    return 0
  fi
  fail "$name"
  echo "  expected failure containing: $needle" >&2
  echo "  exit code: $rc" >&2
  echo "$output" >&2
  return 1
}

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/design-proposal.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p "$fixture_root/.octon/assurance/runtime/_ops/scripts"
  cp "$REPO_ROOT/.octon/assurance/runtime/_ops/scripts/validate-design-proposal.sh" \
    "$fixture_root/.octon/assurance/runtime/_ops/scripts/validate-design-proposal.sh"
  printf '%s\n' "$fixture_root"
}

create_full_domain_runtime_proposal() {
  local fixture_root="$1"
  local proposal_id="${2:-runtime-proposal}"
  local proposal_dir="$fixture_root/.proposals/design/$proposal_id"

  mkdir -p \
    "$proposal_dir/navigation" \
    "$proposal_dir/implementation" \
    "$proposal_dir/normative/architecture" \
    "$proposal_dir/normative/execution" \
    "$proposal_dir/normative/assurance" \
    "$proposal_dir/reference" \
    "$proposal_dir/history" \
    "$proposal_dir/contracts/fixtures/valid" \
    "$proposal_dir/contracts/fixtures/invalid" \
    "$proposal_dir/contracts/schemas" \
    "$proposal_dir/conformance/scenarios"

  cat >"$proposal_dir/proposal.yml" <<EOF
schema_version: "proposal-v1"
proposal_id: "$proposal_id"
title: "Fixture Proposal"
summary: "Fixture."
proposal_kind: "design"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/example.md"
status: "draft"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF

  cat >"$proposal_dir/design-proposal.yml" <<'EOF'
schema_version: "design-proposal-v1"
design_class: "domain-runtime"
selected_modules:
  - "reference"
  - "history"
  - "contracts"
  - "conformance"
  - "canonicalization"
validation:
  default_audit_mode: "rigorous"
  design_validator_path: null
  conformance_validator_path: ".proposals/design/runtime-proposal/conformance/validate_scenarios.py"
EOF

  cat >"$proposal_dir/README.md" <<'EOF'
# Fixture Proposal
EOF
  cat >"$proposal_dir/navigation/artifact-catalog.md" <<'EOF'
# Artifact Catalog
EOF
  cat >"$proposal_dir/navigation/source-of-truth-map.md" <<'EOF'
# Source Of Truth Map
EOF
  cat >"$proposal_dir/navigation/canonicalization-target-map.md" <<'EOF'
# Canonicalization Target Map
EOF
  cat >"$proposal_dir/implementation/README.md" <<'EOF'
# Implementation
EOF
  cat >"$proposal_dir/implementation/minimal-implementation-blueprint.md" <<'EOF'
# Blueprint
EOF
  cat >"$proposal_dir/implementation/first-implementation-plan.md" <<'EOF'
# Plan
EOF
  cat >"$proposal_dir/normative/architecture/domain-model.md" <<'EOF'
# Domain Model
EOF
  cat >"$proposal_dir/normative/architecture/runtime-architecture.md" <<'EOF'
# Runtime Architecture
EOF
  cat >"$proposal_dir/normative/execution/behavior-model.md" <<'EOF'
# Behavior Model
EOF
  cat >"$proposal_dir/normative/assurance/implementation-readiness.md" <<'EOF'
# Implementation Readiness
EOF
  cat >"$proposal_dir/reference/README.md" <<'EOF'
# Reference
EOF
  cat >"$proposal_dir/history/README.md" <<'EOF'
# History
EOF
  cat >"$proposal_dir/contracts/README.md" <<'EOF'
# Contracts
EOF
  cat >"$proposal_dir/conformance/README.md" <<'EOF'
# Conformance
EOF
  cat >"$proposal_dir/conformance/validate_scenarios.py" <<'EOF'
#!/usr/bin/env python3
print("ok")
EOF
  chmod +x "$proposal_dir/conformance/validate_scenarios.py"
}

create_legacy_archive_proposal() {
  local fixture_root="$1"
  local proposal_dir="$fixture_root/.proposals/.archive/design/legacy-proposal"
  mkdir -p "$proposal_dir"
  cat >"$proposal_dir/proposal.yml" <<'EOF'
schema_version: "proposal-v1"
proposal_id: "legacy-proposal"
title: "Legacy Proposal"
summary: "Legacy."
proposal_kind: "design"
promotion_scope: "repo-local"
promotion_targets:
  - "CHANGELOG.md"
status: "archived"
archive:
  archived_at: "2026-03-12"
  archived_from_status: "legacy-unknown"
  disposition: "historical"
  original_path: ".archive/.design-packages/legacy-proposal"
  promotion_evidence: []
lifecycle:
  temporary: true
  exit_expectation: "Historical only."
related_proposals: []
EOF
  cat >"$proposal_dir/design-proposal.yml" <<'EOF'
schema_version: "design-proposal-v1"
design_class: "domain-runtime"
selected_modules: []
validation:
  default_audit_mode: "rigorous"
  design_validator_path: null
  conformance_validator_path: null
EOF
  cat >"$proposal_dir/README.md" <<'EOF'
# Legacy Proposal
EOF
}

run_validator_in_fixture() {
  local fixture_root="$1"
  local proposal_path="$2"
  (
    cd "$fixture_root"
    bash "$VALIDATE_SCRIPT" --package "$proposal_path"
  )
}

case_valid_proposal_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  create_full_domain_runtime_proposal "$fixture_root" runtime-proposal
  run_validator_in_fixture "$fixture_root" ".proposals/design/runtime-proposal"
}

case_missing_required_file_fails() {
  local fixture_root proposal_dir
  fixture_root="$(create_fixture_repo)"
  create_full_domain_runtime_proposal "$fixture_root" runtime-proposal
  proposal_dir="$fixture_root/.proposals/design/runtime-proposal"
  rm "$proposal_dir/implementation/README.md"
  run_validator_in_fixture "$fixture_root" ".proposals/design/runtime-proposal"
}

case_legacy_archive_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  create_legacy_archive_proposal "$fixture_root"
  run_validator_in_fixture "$fixture_root" ".proposals/.archive/design/legacy-proposal"
}

main() {
  assert_success \
    "design proposal validator accepts a valid domain-runtime proposal" \
    case_valid_proposal_passes

  assert_failure_contains \
    "design proposal validator rejects missing required files" \
    "required file exists: implementation/README.md" \
    case_missing_required_file_fails

  assert_success \
    "design proposal validator accepts reduced legacy archives" \
    case_legacy_archive_passes

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
