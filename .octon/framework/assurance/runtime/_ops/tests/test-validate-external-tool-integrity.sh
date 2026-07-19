#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-external-tool-integrity.sh"
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -rf "$dir"
  done
}
trap cleanup EXIT

copy_path() {
  local root="$1" relative="$2"
  mkdir -p "$root/.octon/$(dirname -- "$relative")"
  cp -R "$ROOT_DIR/.octon/$relative" "$root/.octon/$relative"
}

new_fixture_root() {
  local root relative
  root="$(mktemp -d "${TMPDIR:-/tmp}/external-tool-integrity.XXXXXX")"
  CLEANUP_DIRS+=("$root")

  for relative in \
    framework/constitution/CHARTER.md \
    framework/constitution/charter.yml \
    framework/constitution/obligations/fail-closed.yml \
    framework/constitution/contracts/registry.yml \
    instance/charter/workspace.md \
    instance/charter/workspace.yml \
    instance/ingress/AGENTS.md \
    instance/ingress/manifest.yml \
    instance/cognition/context/shared/constraints.md \
    instance/governance/policies/external-tool-integrity.yml \
    framework/execution-roles/runtime/orchestrator/ROLE.md \
    framework/execution-roles/practices/standards/external-tool-integrity.md \
    framework/execution-roles/practices/standards/ai-assisted-development-discipline.md \
    framework/execution-roles/practices/standards/dependency-discipline.md \
    framework/scaffolding/governance/patterns/proposal-standard.md \
    framework/scaffolding/governance/patterns/architecture-proposal-standard.md \
    framework/scaffolding/runtime/templates/proposal-architecture-core \
    framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md \
    framework/orchestration/runtime/workflows/audit/pre-integration-architecture-review \
    framework/orchestration/runtime/workflows/audit/post-integration-architecture-review \
    framework/orchestration/runtime/workflows/audit/current-state-mechanism-architecture-review \
    framework/orchestration/runtime/workflows/audit/architecture-readiness-audit \
    framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh \
    framework/assurance/runtime/_ops/scripts/alignment-check.sh; do
    copy_path "$root" "$relative"
  done

  printf '%s\n' "$root"
}

expect_failure() {
  local label="$1"
  shift
  if "$@" >/tmp/external-tool-integrity-negative.out 2>&1; then
    cat /tmp/external-tool-integrity-negative.out >&2
    printf '[ERROR] negative control passed unexpectedly: %s\n' "$label" >&2
    exit 1
  fi
  printf '[OK] negative control failed as expected: %s\n' "$label"
}

bash "$VALIDATOR"

root="$(new_fixture_root)"
yq -i 'del(.rules[] | select(.id == "FCR-039"))' \
  "$root/.octon/framework/constitution/obligations/fail-closed.yml"
expect_failure \
  "missing constitutional fail-closed rule" \
  env OCTON_DIR_OVERRIDE="$root/.octon" bash "$VALIDATOR"

root="$(new_fixture_root)"
yq -i '.rules.supported_interfaces_only = false' \
  "$root/.octon/instance/governance/policies/external-tool-integrity.yml"
expect_failure \
  "supported-interface requirement disabled" \
  env OCTON_DIR_OVERRIDE="$root/.octon" bash "$VALIDATOR"

root="$(new_fixture_root)"
perl -0pi -e 's/External Tool Boundary/External Dependency Notes/' \
  "$root/.octon/framework/scaffolding/runtime/templates/proposal-architecture-core/architecture/target-architecture.md"
expect_failure \
  "architecture template loses external-tool boundary" \
  env OCTON_DIR_OVERRIDE="$root/.octon" bash "$VALIDATOR"

printf '[OK] external-tool integrity validator fixtures passed\n'
