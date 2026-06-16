#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
FIXTURE_DIR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/fixtures/architectural-review"
RECEIPT_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh"
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -rf "$dir"
  done
}
trap cleanup EXIT

new_architectural_review_fixture_root() {
  local root
  root="$(mktemp -d "${TMPDIR:-/tmp}/architectural-review-validators.XXXXXX")"
  CLEANUP_DIRS+=("$root")

  mkdir -p "$root/.octon/framework/cognition/practices/methodology"
  mkdir -p "$root/.octon/framework/capabilities/runtime/skills"
  mkdir -p "$root/.octon/framework/capabilities/runtime"
  mkdir -p "$root/.octon/framework/orchestration/runtime/workflows/audit"
  mkdir -p "$root/.octon/inputs/additive/extensions"

  cp -R "$ROOT_DIR/.octon/framework/cognition/practices/methodology/architectural-review" \
    "$root/.octon/framework/cognition/practices/methodology/"
  cp -R "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/audit" \
    "$root/.octon/framework/capabilities/runtime/skills/"
  cp "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/manifest.yml" \
    "$root/.octon/framework/capabilities/runtime/skills/manifest.yml"
  cp "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/registry.yml" \
    "$root/.octon/framework/capabilities/runtime/skills/registry.yml"
  cp -R "$ROOT_DIR/.octon/framework/capabilities/runtime/commands" \
    "$root/.octon/framework/capabilities/runtime/"

  for workflow in \
    pre-integration-architecture-review \
    post-integration-architecture-review \
    current-state-mechanism-architecture-review \
    architecture-readiness-audit; do
    cp -R "$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/audit/$workflow" \
      "$root/.octon/framework/orchestration/runtime/workflows/audit/"
  done

  printf '%s\n' "$root"
}

expect_failure() {
  local label="$1"
  shift
  if "$@" >/tmp/architectural-review-negative.out 2>&1; then
    cat /tmp/architectural-review-negative.out >&2
    echo "[ERROR] negative control passed unexpectedly: $label" >&2
    exit 1
  fi
  echo "[OK] negative control failed as expected: $label"
}

bash "$RECEIPT_VALIDATOR" \
  --receipt "$FIXTURE_DIR/valid-pre-integration-receipt.yml" \
  --mode pre-integration-architecture-review \
  --require-pass

if bash "$RECEIPT_VALIDATOR" \
  --receipt "$FIXTURE_DIR/invalid-placeholder-receipt.yml" \
  --mode pre-integration-architecture-review \
  --require-pass >/tmp/architectural-review-invalid-placeholder.out 2>&1; then
  cat /tmp/architectural-review-invalid-placeholder.out >&2
  echo "[ERROR] invalid placeholder receipt passed" >&2
  exit 1
fi

bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-routing.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-workflows.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lifecycle-gates.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-extension-split.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-skills-commands.sh"

root="$(new_architectural_review_fixture_root)"
printf '\nlegacy readiness alias: audit-architecture-readiness\n' \
  >>"$root/.octon/framework/capabilities/runtime/commands/architecture-readiness-audit.md"
expect_failure \
  "stale readiness naming in command facade" \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh" --root "$root"

root="$(new_architectural_review_fixture_root)"
yq -i '(.canonical_modes[] | select(.slug == "domain-architecture-audit")) |= del(.invocation_aliases)' \
  "$root/.octon/framework/cognition/practices/methodology/architectural-review/naming.yml"
expect_failure \
  "undeclared domain architecture alias" \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh" --root "$root"

root="$(new_architectural_review_fixture_root)"
rm -f "$root/.octon/framework/capabilities/runtime/commands/audit-surface-architecture.md"
expect_failure \
  "missing surface architecture command facade" \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-skills-commands.sh" --root "$root"

echo "[OK] architectural review validator fixtures passed"
