#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
FRAMEWORK_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
RUNNER_REL=".octon/framework/engine/runtime/run"
TMP_ROOT="${TMPDIR:-/tmp}/assurance-workflow-tests"

pass_count=0
fail_count=0
declare -a CLEANUP_PATHS=()

cleanup() {
  local path
  for path in "${CLEANUP_PATHS[@]}"; do
    [[ -e "$path" ]] && rm -r "$path"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }
assert_file_exists() { [[ -f "$1" ]]; }
assert_dir_exists() { [[ -d "$1" ]]; }

new_fixture_repo() {
  mkdir -p "$TMP_ROOT"
  local fixture_root
  fixture_root="$(mktemp -d "$TMP_ROOT/proposal-ops.XXXXXX")"
  CLEANUP_PATHS+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.octon/framework/assurance/runtime/_ops" \
    "$fixture_root/.octon/framework/constitution" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas" \
    "$fixture_root/.octon/framework/engine/runtime" \
    "$fixture_root/.octon/framework/capabilities/governance" \
    "$fixture_root/.octon/framework/capabilities/_ops" \
    "$fixture_root/.octon/generated/.tmp/engine/build/runtime-crates-target/debug" \
    "$fixture_root/.octon/generated" \
    "$fixture_root/.octon/inputs/additive" \
    "$fixture_root/.octon/instance/capabilities/runtime" \
    "$fixture_root/.octon/instance/charter" \
    "$fixture_root/.octon/instance/cognition/context/shared" \
    "$fixture_root/.octon/instance/governance" \
    "$fixture_root/.octon/state/control" \
    "$fixture_root/.octon/state/evidence/validation"
  cp -R "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/"
  rsync -a --exclude 'crates/target' \
    "$REPO_ROOT/.octon/framework/engine/runtime/" \
    "$fixture_root/.octon/framework/engine/runtime/"
  cp -R "$REPO_ROOT/.octon/framework/constitution/"* "$fixture_root/.octon/framework/constitution/"
  rsync -a "$REPO_ROOT/.octon/framework/capabilities/" "$fixture_root/.octon/framework/capabilities/"
  cp "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json"
  rsync -a "$REPO_ROOT/.octon/instance/governance/" \
    "$fixture_root/.octon/instance/governance/"
  cp -R "$REPO_ROOT/.octon/instance/capabilities/runtime/packs" \
    "$fixture_root/.octon/instance/capabilities/runtime/"
  cp "$REPO_ROOT/.octon/instance/charter/workspace.yml" \
    "$fixture_root/.octon/instance/charter/workspace.yml"
  cp "$REPO_ROOT/.octon/instance/charter/workspace.md" \
    "$fixture_root/.octon/instance/charter/workspace.md"
  cp "$REPO_ROOT/.octon/instance/extensions.yml" \
    "$fixture_root/.octon/instance/extensions.yml"
  cp -R "$REPO_ROOT/.octon/inputs/additive/extensions" \
    "$fixture_root/.octon/inputs/additive/"
  cp -R "$REPO_ROOT/.octon/generated/effective" \
    "$fixture_root/.octon/generated/"
  rsync -a "$REPO_ROOT/.octon/state/evidence/validation/" \
    "$fixture_root/.octon/state/evidence/validation/"
  cp -R "$REPO_ROOT/.octon/state/control/extensions" \
    "$fixture_root/.octon/state/control/"
  cp "$REPO_ROOT/.octon/generated/.tmp/engine/build/runtime-crates-target/debug/octon-policy" \
    "$fixture_root/.octon/generated/.tmp/engine/build/runtime-crates-target/debug/octon-policy"
  cp "$REPO_ROOT/.octon/octon.yml" "$fixture_root/.octon/octon.yml"
  cat >"$fixture_root/.octon/instance/cognition/context/shared/intent.contract.yml" <<'EOF'
intent_id: "intent://test/proposals"
version: "1.0.0"
EOF
  touch "$fixture_root/.octon/README.md"
  printf '%s\n' "$fixture_root"
}

write_file() {
  local path="$1"
  shift
  mkdir -p "$(dirname "$path")"
  cat >"$path"
}

write_active_architecture_proposal() {
  local root="$1"
  local status="$2"
  local proposal_dir="$root/.octon/inputs/exploratory/proposals/architecture/fixture-proposal"
  mkdir -p "$proposal_dir/navigation" "$proposal_dir/architecture" "$proposal_dir/support"

  write_file "$proposal_dir/proposal.yml" <<EOF
schema_version: "proposal-v1"
proposal_id: "fixture-proposal"
title: "Fixture Proposal"
summary: "Architecture fixture."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/README.md"
status: "$status"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF

  write_file "$proposal_dir/architecture-proposal.yml" <<'EOF'
schema_version: "architecture-proposal-v1"
architecture_scope: "repo-architecture"
decision_type: "boundary-change"
EOF

  write_file "$proposal_dir/README.md" <<'EOF'
# Fixture Proposal
EOF
  write_file "$proposal_dir/navigation/source-of-truth-map.md" <<'EOF'
# Sources
EOF
  write_file "$proposal_dir/architecture/target-architecture.md" <<'EOF'
# Target
EOF
  write_file "$proposal_dir/architecture/acceptance-criteria.md" <<'EOF'
# Acceptance
EOF
  write_file "$proposal_dir/architecture/implementation-plan.md" <<'EOF'
# Plan
EOF
  write_file "$proposal_dir/navigation/artifact-catalog.md" <<'EOF'
# Artifact Catalog

## Proposal

- `proposal_id`: `fixture-proposal`
- `proposal_kind`: `architecture`
- `proposal_path`: `.octon/inputs/exploratory/proposals/architecture/fixture-proposal`

## Files

| Path | Role |
| --- | --- |
| `README.md` | Generated inventory entry |
| `proposal.yml` | Generated inventory entry |
| `architecture-proposal.yml` | Generated inventory entry |
| `navigation/artifact-catalog.md` | Generated inventory entry |
| `navigation/source-of-truth-map.md` | Generated inventory entry |
| `architecture/target-architecture.md` | Generated inventory entry |
| `architecture/acceptance-criteria.md` | Generated inventory entry |
| `architecture/implementation-plan.md` | Generated inventory entry |
EOF

  if [[ "$status" != "draft" ]]; then
    write_file "$proposal_dir/support/implementation-grade-completeness-review.md" <<'EOF'
# Implementation-Grade Completeness Review

verdict: pass
unresolved_questions_count: 0
clarification_required: no

## Blockers

None.

## Assumptions

None.

## Promotion Target Coverage

- .octon/README.md

## Affected Artifact Coverage

- .octon/README.md

## Validator Coverage

- validate-proposal-standard.sh

## Implementation Prompt Readiness

Ready.

## Exclusions

None.

## Final Route Recommendation

Proceed according to lifecycle state.
EOF
  fi
}

write_registry_for_active_status() {
  local root="$1"
  local status="$2"
  write_file "$root/.octon/generated/proposals/registry.yml" <<EOF
schema_version: "proposal-registry-v1"

active:
  - id: "fixture-proposal"
    kind: "architecture"
    scope: "octon-internal"
    path: ".octon/inputs/exploratory/proposals/architecture/fixture-proposal"
    title: "Fixture Proposal"
    status: "$status"
    promotion_targets:
      - ".octon/README.md"
archived: []
EOF
}

write_accepted_proposal_review() {
  local root="$1"
  local proposal_rel=".octon/inputs/exploratory/proposals/architecture/fixture-proposal"
  local proposal_dir="$root/$proposal_rel"
  local digest
  digest="$(
    cd "$root"
    bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh \
      --package "$proposal_rel" \
      --print-digest
  )"

  write_file "$proposal_dir/support/proposal-review.md" <<EOF
review_id: "review-fixture"
reviewed_at: "2026-05-06T00:00:00Z"
reviewer: "workflow-fixture"
verdict: accepted
implementation_prompt_authorized: yes
reviewed_packet_digest: $digest
open_blocking_findings_count: 0

## Approved Promotion Targets

- .octon/README.md

## Exclusions

- none

## Blocking Findings

- none

## Nonblocking Findings

- none

## Final Route Recommendation

- generate-implementation-prompt
EOF
}

run_workflow() {
  local fixture_root="$1"
  shift
  (
    cd "$fixture_root"
    OCTON_WORKFLOW_RUN_COMPAT=1 "$fixture_root/$RUNNER_REL" workflow run "$@"
  )
}

case_validate_passes() {
  local fixture_root output bundle_root
  fixture_root="$(new_fixture_repo)"
  write_active_architecture_proposal "$fixture_root" "draft"
  write_registry_for_active_status "$fixture_root" "draft"
  output="$(run_workflow "$fixture_root" validate-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal")"
  bundle_root="$(printf '%s\n' "$output" | sed -n 's/^bundle_root: //p' | tail -n 1)"
  assert_file_exists "$bundle_root/summary.md" || return 1
  assert_file_exists "$bundle_root/validation.md" || return 1
  assert_file_exists "$bundle_root/standard-validator.log" || return 1
}

case_promote_passes() {
  local fixture_root output bundle_root manifest registry
  fixture_root="$(new_fixture_repo)"
  write_active_architecture_proposal "$fixture_root" "accepted"
  write_registry_for_active_status "$fixture_root" "accepted"
  write_accepted_proposal_review "$fixture_root"
  output="$(run_workflow "$fixture_root" promote-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal" --set "promotion_evidence=.octon/README.md")"
  bundle_root="$(printf '%s\n' "$output" | sed -n 's/^bundle_root: //p' | tail -n 1)"
  manifest="$fixture_root/.octon/inputs/exploratory/proposals/architecture/fixture-proposal/proposal.yml"
  registry="$fixture_root/.octon/generated/proposals/registry.yml"
  assert_file_exists "$bundle_root/summary.md" || return 1
  [[ "$(yq -r '.status' "$manifest")" == "implemented" ]] || return 1
  grep -Fq 'status: "implemented"' "$registry" || return 1
}

case_promote_rejects_accepted_without_review() {
  local fixture_root
  fixture_root="$(new_fixture_repo)"
  write_active_architecture_proposal "$fixture_root" "accepted"
  write_registry_for_active_status "$fixture_root" "accepted"
  run_workflow "$fixture_root" promote-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal" --set "promotion_evidence=.octon/README.md"
}

case_promote_rejects_non_accepted_status() {
  local fixture_root
  fixture_root="$(new_fixture_repo)"
  write_active_architecture_proposal "$fixture_root" "draft"
  write_registry_for_active_status "$fixture_root" "draft"
  run_workflow "$fixture_root" promote-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal" --set "promotion_evidence=.octon/README.md"
}

case_archive_passes() {
  local fixture_root output bundle_root archived_manifest registry
  fixture_root="$(new_fixture_repo)"
  write_active_architecture_proposal "$fixture_root" "implemented"
  write_registry_for_active_status "$fixture_root" "implemented"
  output="$(run_workflow "$fixture_root" archive-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal" --set "disposition=implemented" --set "promotion_evidence=.octon/README.md")"
  bundle_root="$(printf '%s\n' "$output" | sed -n 's/^bundle_root: //p' | tail -n 1)"
  archived_manifest="$fixture_root/.octon/inputs/exploratory/proposals/.archive/architecture/fixture-proposal/proposal.yml"
  registry="$fixture_root/.octon/generated/proposals/registry.yml"
  assert_file_exists "$bundle_root/summary.md" || return 1
  assert_file_exists "$archived_manifest" || return 1
  [[ "$(yq -r '.status' "$archived_manifest")" == "archived" ]] || return 1
  grep -Fq '.archive/architecture/fixture-proposal' "$registry" || return 1
}

case_archive_passes_with_retained_closed_stage_runs() {
  local fixture_root
  fixture_root="$(new_fixture_repo)"
  write_active_architecture_proposal "$fixture_root" "implemented"
  write_registry_for_active_status "$fixture_root" "implemented"
  run_workflow "$fixture_root" archive-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal" --set "disposition=implemented" --set "promotion_evidence=.octon/README.md" >/dev/null
  rm -rf "$fixture_root/.octon/inputs/exploratory/proposals/.archive/architecture/fixture-proposal"
  write_active_architecture_proposal "$fixture_root" "implemented"
  write_registry_for_active_status "$fixture_root" "implemented"
  run_workflow "$fixture_root" archive-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal" --set "disposition=implemented" --set "promotion_evidence=.octon/README.md" >/dev/null
}

case_archive_rejects_non_implemented_disposition() {
  local fixture_root
  fixture_root="$(new_fixture_repo)"
  write_active_architecture_proposal "$fixture_root" "accepted"
  write_registry_for_active_status "$fixture_root" "accepted"
  run_workflow "$fixture_root" archive-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal" --set "disposition=implemented" --set "promotion_evidence=.octon/README.md"
}

main() {
  case_validate_passes && pass "validate-proposal workflow validates a proposal and writes bundle receipts" || fail "validate-proposal workflow validates a proposal and writes bundle receipts"
  case_promote_passes && pass "promote-proposal workflow marks an accepted proposal implemented and regenerates registry" || fail "promote-proposal workflow marks an accepted proposal implemented and regenerates registry"
  if ! case_promote_rejects_non_accepted_status >/dev/null 2>&1; then
    pass "promote-proposal rejects proposals that are not accepted"
  else
    fail "promote-proposal rejects proposals that are not accepted"
  fi
  if ! case_promote_rejects_accepted_without_review >/dev/null 2>&1; then
    pass "promote-proposal rejects accepted proposals without fresh accepted review"
  else
    fail "promote-proposal rejects accepted proposals without fresh accepted review"
  fi
  case_archive_passes && pass "archive-proposal workflow archives an implemented proposal and regenerates registry" || fail "archive-proposal workflow archives an implemented proposal and regenerates registry"
  case_archive_passes_with_retained_closed_stage_runs && pass "archive-proposal workflow reruns with retained closed stage runs" || fail "archive-proposal workflow reruns with retained closed stage runs"
  if ! case_archive_rejects_non_implemented_disposition >/dev/null 2>&1; then
    pass "archive-proposal rejects implemented disposition when the proposal is not implemented"
  else
    fail "archive-proposal rejects implemented disposition when the proposal is not implemented"
  fi

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
