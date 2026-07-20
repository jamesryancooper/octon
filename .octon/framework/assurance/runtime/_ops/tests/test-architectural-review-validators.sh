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

new_architectural_review_digest_package() {
  local root package digest
  root="$(mktemp -d "${TMPDIR:-/tmp}/architectural-review-digest.XXXXXX")"
  CLEANUP_DIRS+=("$root")
  package="$root/review-fixture"
  mkdir -p "$package/support" "$package/navigation" "$package/architecture"

  cat >"$package/proposal.yml" <<'EOF'
schema_version: "proposal-v1"
proposal_id: "architectural-review-digest-fixture"
title: "Architectural Review Digest Fixture"
summary: "Fixture for architecture receipt digest freshness."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/example.md"
status: "accepted"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF
  cat >"$package/architecture-proposal.yml" <<'EOF'
schema_version: "architecture-proposal-v1"
architecture_scope: "repo-architecture"
decision_type: "boundary-change"
EOF
  cat >"$package/README.md" <<'EOF'
# Architectural Review Digest Fixture
EOF
  cat >"$package/navigation/artifact-catalog.md" <<'EOF'
# Artifact Catalog
EOF
  cat >"$package/navigation/source-of-truth-map.md" <<'EOF'
# Source Of Truth
EOF
  cat >"$package/architecture/target-architecture.md" <<'EOF'
# Target Architecture
EOF
  cat >"$package/architecture/implementation-plan.md" <<'EOF'
# Implementation Plan
EOF
  cat >"$package/architecture/acceptance-criteria.md" <<'EOF'
# Acceptance Criteria
EOF

  digest="$(bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh" --package "$package" --print-digest)"
  cat >"$package/support/pre-integration-architecture-review.yml" <<EOF
schema_version: "architectural-review-support-receipt-v1"
receipt_id: "architectural-review-digest-fixture-001"
proposal_path: "$package"
packet_digest: "$digest"
review_mode: "pre-integration-architecture-review"
verdict: "pass"
unresolved_count: 0
non_authority_classification: "retained-evidence-only"
recorded_at: "2026-07-16T14:24:00Z"
evidence_refs:
  - "$package/architecture/target-architecture.md"
validator_refs:
  - ".octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh"
blockers: []
mode_specific_coverage:
  fixture: "covered"
  external_tool_integrity: "covered: external tools remain unmodified and Octon owns all required solution changes"
EOF
  printf '%s\n' "$package"
}

case_architecture_stale_digest_diagnostic_fields() {
  local package receipt output rc=0
  package="$(new_architectural_review_digest_package)"
  receipt="$package/support/pre-integration-architecture-review.yml"
  printf '\nChanged after architecture review.\n' >>"$package/README.md"

  output="$(bash "$RECEIPT_VALIDATOR" \
    --receipt "$receipt" \
    --package "$package" \
    --mode pre-integration-architecture-review \
    --require-pass 2>&1)" || rc=$?

  if (( rc == 0 )); then
    echo "$output" >&2
    echo "[ERROR] stale architecture digest passed unexpectedly" >&2
    exit 1
  fi
  for needle in \
    '"stale_cause":"architectural review receipt packet_digest does not match current packet digest"' \
    '"last_mutation_class":"packet-content-drift-after-architecture-review"' \
    '"owning_refresh_route":"pre-integration-architecture-review"' \
    '"stable_digest_boundary":"packet_digest"'; do
    if ! grep -Fq "$needle" <<<"$output"; then
      echo "$output" >&2
      echo "[ERROR] stale architecture digest diagnostic missing: $needle" >&2
      exit 1
    fi
  done
  echo "[OK] stale architecture digest emits refresh diagnostics"
}

case_architecture_digest_survives_archive_metadata_relocation() {
  local package receipt manifest
  package="$(new_architectural_review_digest_package)"
  receipt="$package/support/pre-integration-architecture-review.yml"
  manifest="$package/proposal.yml"
  perl -0pi -e 's/status: "accepted"/status: "archived"\narchive:\n  archived_at: 2026-05-08\n  archived_from_status: implemented\n  disposition: implemented\n  original_path: .octon\/inputs\/exploratory\/proposals\/architecture\/architectural-review-digest-fixture\n  promotion_evidence:\n    - .octon\/framework\/example.md/' "$manifest"

  bash "$RECEIPT_VALIDATOR" \
    --receipt "$receipt" \
    --package "$package" \
    --mode pre-integration-architecture-review \
    --require-pass
  echo "[OK] architecture digest survives archive metadata relocation"
}

case_architecture_missing_receipt_fails() {
  local package receipt
  package="$(new_architectural_review_digest_package)"
  receipt="$package/support/pre-integration-architecture-review.yml"
  rm -f "$receipt"

  expect_failure \
    "missing architecture review receipt" \
    bash "$RECEIPT_VALIDATOR" \
      --receipt "$receipt" \
      --package "$package" \
      --mode pre-integration-architecture-review \
      --require-pass
}

case_architecture_non_pass_receipt_fails() {
  local package receipt
  package="$(new_architectural_review_digest_package)"
  receipt="$package/support/pre-integration-architecture-review.yml"
  perl -0pi -e 's/verdict: "pass"/verdict: "blocked"/; s/unresolved_count: 0/unresolved_count: 1/; s/blockers: \[\]/blockers:\n  - blocked fixture/' "$receipt"

  expect_failure \
    "non-pass architecture review receipt" \
    bash "$RECEIPT_VALIDATOR" \
      --receipt "$receipt" \
      --package "$package" \
      --mode pre-integration-architecture-review \
      --require-pass
}

case_external_tool_integrity_coverage_required() {
  local package receipt
  package="$(new_architectural_review_digest_package)"
  receipt="$package/support/pre-integration-architecture-review.yml"
  yq -i 'del(.mode_specific_coverage.external_tool_integrity)' "$receipt"

  expect_failure \
    "current architecture receipt missing external-tool integrity coverage" \
    bash "$RECEIPT_VALIDATOR" \
      --receipt "$receipt" \
      --package "$package" \
      --mode pre-integration-architecture-review \
      --require-pass
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

# Lens-reference validator: positive control over the shipped bank plus the two
# fail-closed negative controls (undefined lens id, missing method profile).
LENS_REFERENCE_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh"
LENS_FIXTURE_DIR="$FIXTURE_DIR/lens-references"
bash "$LENS_REFERENCE_VALIDATOR"
bash "$LENS_REFERENCE_VALIDATOR" --lens-bank "$LENS_FIXTURE_DIR/pass/lens-bank.yml"
expect_failure \
  "undefined lens id in method profile" \
  bash "$LENS_REFERENCE_VALIDATOR" --lens-bank "$LENS_FIXTURE_DIR/fail-undefined-lens/lens-bank.yml"
expect_failure \
  "bank-known method missing profile" \
  bash "$LENS_REFERENCE_VALIDATOR" --lens-bank "$LENS_FIXTURE_DIR/fail-missing-profile/lens-bank.yml"

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

case_architecture_stale_digest_diagnostic_fields
case_architecture_digest_survives_archive_metadata_relocation
case_architecture_missing_receipt_fails
case_architecture_non_pass_receipt_fails
case_external_tool_integrity_coverage_required

echo "[OK] architectural review validator fixtures passed"
