#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
HARMONY_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HARMONY_DIR/.." && pwd)"
VALIDATE_SCRIPT=".harmony/assurance/runtime/_ops/scripts/validate-design-package-standard.sh"

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
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/design-package-standard.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p "$fixture_root/.harmony/assurance/runtime/_ops/scripts" "$fixture_root/.design-packages"
  cp "$REPO_ROOT/.harmony/assurance/runtime/_ops/scripts/validate-design-package-standard.sh" \
    "$fixture_root/.harmony/assurance/runtime/_ops/scripts/validate-design-package-standard.sh"

  printf '%s\n' "$fixture_root"
}

write_manifest() {
  local file="$1"
  local package_id="$2"
  local package_class="$3"
  local selected_modules="$4"
  local implementation_targets="$5"
  local conformance_path="$6"

  cat >"$file" <<EOF
schema_version: "design-package-v1"
package_id: "$package_id"
title: "Fixture ${package_id}"
summary: "Fixture package for validator testing."
package_class: "$package_class"
selected_modules:
$selected_modules
implementation_targets:
$implementation_targets
status: "draft"
lifecycle:
  temporary: true
  exit_expectation: "Promote durable outputs and remove the package after implementation."
validation:
  default_audit_mode: "rigorous"
  package_validator_path: null
  conformance_validator_path: $conformance_path
EOF
}

create_common_core() {
  local package_dir="$1"
  mkdir -p "$package_dir/navigation" "$package_dir/implementation"
  cat >"$package_dir/README.md" <<'EOF'
# Fixture Package

This is a temporary, implementation-scoped design package for `fixture`.
It is a build aid for engineers. It is not a canonical runtime, documentation,
policy, or contract authority.

## Implementation Targets

- `.harmony/example/target.md`

## Exit Path

Promote durable outputs and remove the package after implementation.
EOF
  cat >"$package_dir/navigation/artifact-catalog.md" <<'EOF'
# Artifact Catalog
EOF
  cat >"$package_dir/navigation/source-of-truth-map.md" <<'EOF'
# Package Reading And Precedence Map
EOF
  cat >"$package_dir/implementation/README.md" <<'EOF'
# Implementation
EOF
  cat >"$package_dir/implementation/minimal-implementation-blueprint.md" <<'EOF'
# Minimal Implementation Blueprint
EOF
  cat >"$package_dir/implementation/first-implementation-plan.md" <<'EOF'
# First Implementation Plan
EOF
}

create_domain_runtime_package() {
  local fixture_root="$1"
  local package_id="${2:-runtime-package}"
  local package_dir="$fixture_root/.design-packages/$package_id"
  mkdir -p "$package_dir"
  create_common_core "$package_dir"

  mkdir -p \
    "$package_dir/normative/architecture" \
    "$package_dir/normative/execution" \
    "$package_dir/normative/assurance" \
    "$package_dir/reference" \
    "$package_dir/history" \
    "$package_dir/contracts/schemas" \
    "$package_dir/contracts/fixtures/valid" \
    "$package_dir/contracts/fixtures/invalid" \
    "$package_dir/conformance/scenarios"

  cat >"$package_dir/normative/architecture/domain-model.md" <<'EOF'
# Domain Model
EOF
  cat >"$package_dir/normative/architecture/runtime-architecture.md" <<'EOF'
# Runtime Architecture
EOF
  cat >"$package_dir/normative/execution/behavior-model.md" <<'EOF'
# Behavior Model
EOF
  cat >"$package_dir/normative/assurance/implementation-readiness.md" <<'EOF'
# Implementation Readiness
EOF
  cat >"$package_dir/reference/README.md" <<'EOF'
# Reference
EOF
  cat >"$package_dir/history/README.md" <<'EOF'
# History
EOF
  cat >"$package_dir/contracts/README.md" <<'EOF'
# Contracts
EOF
  cat >"$package_dir/navigation/canonicalization-target-map.md" <<'EOF'
# Canonicalization Target Map
EOF
  cat >"$package_dir/conformance/README.md" <<'EOF'
# Conformance
EOF
  cat >"$package_dir/conformance/validate_scenarios.py" <<'EOF'
#!/usr/bin/env python3
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
scenario_dir = root / "conformance" / "scenarios"
print(f"[OK] {scenario_dir}")
EOF

  write_manifest \
    "$package_dir/design-package.yml" \
    "$package_id" \
    "domain-runtime" \
    '  - reference
  - history
  - contracts
  - conformance
  - canonicalization' \
    '  - ".harmony/example/runtime.md"' \
    '".design-packages/'"$package_id"'/conformance/validate_scenarios.py"'

  printf '%s\n' "$package_dir"
}

create_experience_product_package() {
  local fixture_root="$1"
  local package_id="${2:-experience-package}"
  local package_dir="$fixture_root/.design-packages/$package_id"
  mkdir -p "$package_dir"
  create_common_core "$package_dir"

  mkdir -p \
    "$package_dir/normative/experience" \
    "$package_dir/normative/assurance" \
    "$package_dir/reference" \
    "$package_dir/history"

  cat >"$package_dir/normative/experience/user-journeys.md" <<'EOF'
# User Journeys
EOF
  cat >"$package_dir/normative/experience/information-architecture.md" <<'EOF'
# Information Architecture
EOF
  cat >"$package_dir/normative/experience/screen-states-and-flows.md" <<'EOF'
# Screen States And Flows
EOF
  cat >"$package_dir/normative/assurance/implementation-readiness.md" <<'EOF'
# Implementation Readiness
EOF
  cat >"$package_dir/reference/README.md" <<'EOF'
# Reference
EOF
  cat >"$package_dir/history/README.md" <<'EOF'
# History
EOF

  write_manifest \
    "$package_dir/design-package.yml" \
    "$package_id" \
    "experience-product" \
    '  - reference
  - history' \
    '  - ".harmony/example/experience.md"' \
    'null'

  printf '%s\n' "$package_dir"
}

run_validator_in_fixture() {
  local fixture_root="$1"
  shift
  (
    cd "$fixture_root"
    bash "$VALIDATE_SCRIPT" "$@"
  )
}

case_valid_domain_runtime_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  create_domain_runtime_package "$fixture_root" >/dev/null
  run_validator_in_fixture "$fixture_root" --package ".design-packages/runtime-package"
}

case_valid_experience_product_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  create_experience_product_package "$fixture_root" >/dev/null
  run_validator_in_fixture "$fixture_root" --package ".design-packages/experience-package"
}

case_missing_core_doc_fails() {
  local fixture_root package_dir
  fixture_root="$(create_fixture_repo)"
  package_dir="$(create_experience_product_package "$fixture_root")"
  rm "$package_dir/implementation/first-implementation-plan.md"
  run_validator_in_fixture "$fixture_root" --package ".design-packages/experience-package"
}

case_empty_targets_fail() {
  local fixture_root package_dir
  fixture_root="$(create_fixture_repo)"
  package_dir="$(create_experience_product_package "$fixture_root")"
  perl -0pi -e 's/implementation_targets:\n  - ".harmony\/example\/experience\.md"/implementation_targets: []/' \
    "$package_dir/design-package.yml"
  run_validator_in_fixture "$fixture_root" --package ".design-packages/experience-package"
}

case_forbidden_authority_phrase_fails() {
  local fixture_root package_dir
  fixture_root="$(create_fixture_repo)"
  package_dir="$(create_experience_product_package "$fixture_root")"
  printf '\nThis package is the source of truth.\n' >>"$package_dir/README.md"
  run_validator_in_fixture "$fixture_root" --package ".design-packages/experience-package"
}

case_live_target_backreference_fails() {
  local fixture_root package_dir
  fixture_root="$(create_fixture_repo)"
  package_dir="$(create_experience_product_package "$fixture_root")"
  mkdir -p "$fixture_root/.harmony/example"
  cat >"$fixture_root/.harmony/example/experience.md" <<'EOF'
# Live Target

Do not leave `.design-packages/experience-package/navigation/source-of-truth-map.md`
as a dependency.
EOF
  run_validator_in_fixture "$fixture_root" --package ".design-packages/experience-package"
}

case_selected_module_missing_artifact_fails() {
  local fixture_root package_dir
  fixture_root="$(create_fixture_repo)"
  package_dir="$(create_domain_runtime_package "$fixture_root")"
  rm "$package_dir/navigation/canonicalization-target-map.md"
  run_validator_in_fixture "$fixture_root" --package ".design-packages/runtime-package"
}

case_all_standard_packages_ignore_legacy_dirs() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  create_experience_product_package "$fixture_root" >/dev/null
  mkdir -p "$fixture_root/.design-packages/legacy-package"
  printf '# Legacy only\n' >"$fixture_root/.design-packages/legacy-package/README.md"
  run_validator_in_fixture "$fixture_root" --all-standard-packages
}

main() {
  assert_success \
    "design-package standard validator accepts domain-runtime package" \
    case_valid_domain_runtime_passes

  assert_success \
    "design-package standard validator accepts experience-product package" \
    case_valid_experience_product_passes

  assert_failure_contains \
    "design-package standard validator rejects missing core docs" \
    "first implementation plan exists" \
    case_missing_core_doc_fails

  assert_failure_contains \
    "design-package standard validator rejects empty implementation targets" \
    "implementation_targets must contain at least one path" \
    case_empty_targets_fail

  assert_failure_contains \
    "design-package standard validator rejects forbidden authority phrases" \
    "README avoids forbidden source-of-truth phrase" \
    case_forbidden_authority_phrase_fails

  assert_failure_contains \
    "design-package standard validator rejects live targets that still reference the package" \
    "implementation target retains temporary package dependency" \
    case_live_target_backreference_fails

  assert_failure_contains \
    "design-package standard validator rejects missing selected-module artifacts" \
    "canonicalization map exists" \
    case_selected_module_missing_artifact_fails

  assert_success \
    "design-package standard validator ignores legacy packages without manifests during scan" \
    case_all_standard_packages_ignore_legacy_dirs

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"

  if [[ "$fail_count" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
