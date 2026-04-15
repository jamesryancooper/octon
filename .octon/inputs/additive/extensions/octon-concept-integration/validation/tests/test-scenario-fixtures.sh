#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../../.." && pwd)"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r -f -- "$dir"
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

assert_contains() {
  local file="$1" pattern="$2"
  grep -Fq -- "$pattern" "$file"
}

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-concept-fixtures.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas" \
    "$fixture_root/.octon/generated/proposals" \
    "$fixture_root/.octon/inputs/exploratory/proposals/architecture" \
    "$fixture_root/docs"

  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh"
  cp "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json"

  printf '%s\n' "$fixture_root"
}

write_file() {
  local path="$1"
  shift
  mkdir -p "$(dirname "$path")"
  cat >"$path"
}

write_registry() {
  local root="$1" proposal_id="$2" title="$3" promotion_target="$4"
  write_file "$root/.octon/generated/proposals/registry.yml" <<EOF
schema_version: "proposal-registry-v1"
active:
  - id: "$proposal_id"
    kind: "architecture"
    scope: "repo-local"
    path: ".octon/inputs/exploratory/proposals/architecture/$proposal_id"
    title: "$title"
    status: "draft"
    promotion_targets:
      - "$promotion_target"
archived: []
EOF
}

write_architecture_package() {
  local root="$1" proposal_id="$2" title="$3" summary="$4" promotion_target="$5" architecture_scope="$6" decision_type="$7"
  local proposal_dir="$root/.octon/inputs/exploratory/proposals/architecture/$proposal_id"
  mkdir -p "$proposal_dir/navigation" "$proposal_dir/architecture" "$proposal_dir/support"

  write_file "$proposal_dir/proposal.yml" <<EOF
schema_version: "proposal-v1"
proposal_id: "$proposal_id"
title: "$title"
summary: "$summary"
proposal_kind: "architecture"
promotion_scope: "repo-local"
promotion_targets:
  - "$promotion_target"
status: "draft"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF

  write_file "$proposal_dir/architecture-proposal.yml" <<EOF
schema_version: "architecture-proposal-v1"
architecture_scope: "$architecture_scope"
decision_type: "$decision_type"
EOF
}

write_artifact_catalog() {
  local proposal_dir="$1"
  cat >"$proposal_dir/navigation/artifact-catalog.md" <<'EOF'
# Artifact Catalog

## Files

| Path | Role |
| --- | --- |
| `README.md` | Scenario fixture overview |
| `proposal.yml` | Base proposal manifest |
| `architecture-proposal.yml` | Architecture subtype manifest |
| `navigation/artifact-catalog.md` | Generated inventory entry |
| `navigation/source-of-truth-map.md` | Source-of-truth inventory |
| `architecture/target-architecture.md` | Target architecture summary |
| `architecture/acceptance-criteria.md` | Acceptance criteria |
| `architecture/implementation-plan.md` | Implementation plan |
| `support/source-artifact.md` | Materialized source set |
| `support/concept-extraction-output.md` | Materialized extraction output |
| `support/concept-verification-output.md` | Materialized verification output |
| `support/executable-implementation-prompt.md` | Materialized execution prompt |
EOF
}

validate_architecture_package() {
  local root="$1" proposal_id="$2"
  (
    cd "$root"
    bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh \
      --package ".octon/inputs/exploratory/proposals/architecture/$proposal_id" \
      --skip-promotion-target-checks
    bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh \
      --package ".octon/inputs/exploratory/proposals/architecture/$proposal_id"
  ) >/dev/null
}

case_packet_drift_fixture_validates_and_records_supersession() {
  local fixture_root proposal_id proposal_dir
  fixture_root="$(create_fixture_repo)"
  proposal_id="packet-drift-superseding-packet"
  write_architecture_package \
    "$fixture_root" \
    "$proposal_id" \
    "Packet Drift Superseding Packet" \
    "Superseding packet emitted after packet-time repo drift invalidated the prior execution basis." \
    "docs/packet-drift-superseding-packet.md" \
    "repo-architecture" \
    "boundary-change"
  proposal_dir="$fixture_root/.octon/inputs/exploratory/proposals/architecture/$proposal_id"
  write_registry "$fixture_root" "$proposal_id" "Packet Drift Superseding Packet" "docs/packet-drift-superseding-packet.md"
  write_file "$fixture_root/docs/packet-drift-superseding-packet.md" <<'EOF'
# Packet Drift Superseding Packet
EOF
  write_file "$proposal_dir/README.md" <<'EOF'
# Packet Drift Superseding Packet

This scenario fixture represents a packet refresh outcome where packet-time
repo drift forced supersession instead of in-place refresh.
EOF
  write_file "$proposal_dir/navigation/source-of-truth-map.md" <<'EOF'
# Source Of Truth Map

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
EOF
  write_artifact_catalog "$proposal_dir"
  write_file "$proposal_dir/architecture/target-architecture.md" <<'EOF'
# Target Architecture

## Packet Drift Note

- Current repo state already landed part of the original packet.
- Remaining changes now require a narrower superseding packet.
EOF
  write_file "$proposal_dir/architecture/acceptance-criteria.md" <<'EOF'
# Acceptance Criteria

- Packet drift is surfaced before any refresh claim.
- The superseding packet narrows scope to the still-valid targets.
EOF
  write_file "$proposal_dir/architecture/implementation-plan.md" <<'EOF'
# Implementation Plan

- Re-ground the live repo and record a Packet Drift Note.
- Supersede the stale packet instead of refreshing in place.
EOF
  write_file "$proposal_dir/support/source-artifact.md" <<'EOF'
# Source Artifact

- prior packet: `architecture/original-packet`
- live repo evidence: drift detected
EOF
  write_file "$proposal_dir/support/concept-extraction-output.md" <<'EOF'
# Concept Extraction Output

- candidate: preserve original intent
- candidate: supersede stale delivery plan
EOF
  write_file "$proposal_dir/support/concept-verification-output.md" <<'EOF'
# Concept Verification Output

- Packet Drift Note: original execution basis is stale.
- Recommended outcome: supersede when drift makes in-place refresh misleading.
EOF
  write_file "$proposal_dir/support/executable-implementation-prompt.md" <<'EOF'
# Executable Implementation Prompt

Stop and record packet drift before claiming refresh readiness.
EOF

  validate_architecture_package "$fixture_root" "$proposal_id"
  assert_contains "$proposal_dir/architecture/target-architecture.md" "Packet Drift Note"
  assert_contains "$proposal_dir/architecture/implementation-plan.md" "Supersede the stale packet"
  assert_contains "$proposal_dir/support/concept-verification-output.md" "supersede when drift makes in-place refresh misleading"
}

case_multi_source_conflict_fixture_validates_and_records_resolution() {
  local fixture_root proposal_id proposal_dir
  fixture_root="$(create_fixture_repo)"
  proposal_id="multi-source-conflict-synthesis-packet"
  write_architecture_package \
    "$fixture_root" \
    "$proposal_id" \
    "Multi-Source Conflict Synthesis Packet" \
    "Architecture packet built from conflicting sources after normalization and explicit resolution." \
    "docs/multi-source-conflict-synthesis-packet.md" \
    "repo-architecture" \
    "surface-refactor"
  proposal_dir="$fixture_root/.octon/inputs/exploratory/proposals/architecture/$proposal_id"
  write_registry "$fixture_root" "$proposal_id" "Multi-Source Conflict Synthesis Packet" "docs/multi-source-conflict-synthesis-packet.md"
  write_file "$fixture_root/docs/multi-source-conflict-synthesis-packet.md" <<'EOF'
# Multi-Source Conflict Synthesis Packet
EOF
  write_file "$proposal_dir/README.md" <<'EOF'
# Multi-Source Conflict Synthesis Packet

This scenario fixture represents a synthesized architecture packet produced
after normalizing conflicting source claims.
EOF
  write_file "$proposal_dir/navigation/source-of-truth-map.md" <<'EOF'
# Source Of Truth Map

- `support/source-artifact.md`
- `support/concept-extraction-output.md`
- `support/concept-verification-output.md`
- `architecture/target-architecture.md`
EOF
  write_artifact_catalog "$proposal_dir"
  write_file "$proposal_dir/architecture/target-architecture.md" <<'EOF'
# Target Architecture

## Source Reconciliation

- consensus concepts are promoted directly
- contested concepts stay explicit with resolution rationale
EOF
  write_file "$proposal_dir/architecture/acceptance-criteria.md" <<'EOF'
# Acceptance Criteria

- conflicting source claims are normalized before synthesis
- contested concepts remain explicit in the final packet
EOF
  write_file "$proposal_dir/architecture/implementation-plan.md" <<'EOF'
# Implementation Plan

- normalize duplicate framing
- preserve disagreements where they matter
- build one packet with source-set traceability
EOF
  write_file "$proposal_dir/support/source-artifact.md" <<'EOF'
# Source Artifact

- source-a: advocates explicit authority routing
- source-b: advocates implicit tool routing
EOF
  write_file "$proposal_dir/support/concept-extraction-output.md" <<'EOF'
# Concept Extraction Output

- consensus: explicit authority routing
- contested: tool routing policy
EOF
  write_file "$proposal_dir/support/concept-verification-output.md" <<'EOF'
# Concept Verification Output

- conflict resolution: preserve explicit authority routing
- contested concepts remain visible with implementation notes
EOF
  write_file "$proposal_dir/support/executable-implementation-prompt.md" <<'EOF'
# Executable Implementation Prompt

Implement only the consensus concepts and preserve contested concepts in notes.
EOF

  validate_architecture_package "$fixture_root" "$proposal_id"
  assert_contains "$proposal_dir/support/source-artifact.md" "source-a"
  assert_contains "$proposal_dir/support/source-artifact.md" "source-b"
  assert_contains "$proposal_dir/support/concept-verification-output.md" "conflict resolution"
  assert_contains "$proposal_dir/architecture/target-architecture.md" "contested concepts stay explicit"
}

case_subsystem_scope_mismatch_fixture_validates_and_records_boundary_controls() {
  local fixture_root proposal_id proposal_dir
  fixture_root="$(create_fixture_repo)"
  proposal_id="subsystem-scope-mismatch-architecture-packet"
  write_architecture_package \
    "$fixture_root" \
    "$proposal_id" \
    "Subsystem Scope Mismatch Architecture Packet" \
    "Subsystem-scoped packet that records boundary controls and explicit cross-subsystem dependencies." \
    "docs/subsystem-scope-mismatch-architecture-packet.md" \
    "repo-architecture" \
    "boundary-change"
  proposal_dir="$fixture_root/.octon/inputs/exploratory/proposals/architecture/$proposal_id"
  write_registry "$fixture_root" "$proposal_id" "Subsystem Scope Mismatch Architecture Packet" "docs/subsystem-scope-mismatch-architecture-packet.md"
  write_file "$fixture_root/docs/subsystem-scope-mismatch-architecture-packet.md" <<'EOF'
# Subsystem Scope Mismatch Architecture Packet
EOF
  write_file "$proposal_dir/README.md" <<'EOF'
# Subsystem Scope Mismatch Architecture Packet

This scenario fixture represents a subsystem-targeted packet that rejects
silent scope escape and keeps cross-subsystem dependencies explicit.
EOF
  write_file "$proposal_dir/navigation/source-of-truth-map.md" <<'EOF'
# Source Of Truth Map

- `support/source-artifact.md`
- `support/concept-verification-output.md`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
EOF
  write_artifact_catalog "$proposal_dir"
  write_file "$proposal_dir/architecture/target-architecture.md" <<'EOF'
# Target Architecture

## Scope Boundary

- included paths stay inside `framework/orchestration/**`
- excluded adjacent domains remain outside packet scope
- explicit cross-subsystem dependencies are listed instead of silently widened
EOF
  write_file "$proposal_dir/architecture/acceptance-criteria.md" <<'EOF'
# Acceptance Criteria

- concepts that escape the declared scope are rejected or escalated
- cross-subsystem dependencies remain explicit
EOF
  write_file "$proposal_dir/architecture/implementation-plan.md" <<'EOF'
# Implementation Plan

- preserve subsystem scope boundaries
- reject concepts that require silent escape
- annotate allowable cross-subsystem dependencies
EOF
  write_file "$proposal_dir/support/source-artifact.md" <<'EOF'
# Source Artifact

- requested subsystem: orchestration runtime
- adjacent domain: cognition governance
EOF
  write_file "$proposal_dir/support/concept-extraction-output.md" <<'EOF'
# Concept Extraction Output

- accepted: runtime-local telemetry refinement
- rejected: cognition governance rewrite outside declared scope
EOF
  write_file "$proposal_dir/support/concept-verification-output.md" <<'EOF'
# Concept Verification Output

- scope escape rejected without explicit justification
- cross-subsystem dependency note retained for shared telemetry schema
EOF
  write_file "$proposal_dir/support/executable-implementation-prompt.md" <<'EOF'
# Executable Implementation Prompt

Stay inside the declared subsystem and stop on silent scope escape.
EOF

  validate_architecture_package "$fixture_root" "$proposal_id"
  assert_contains "$proposal_dir/architecture/target-architecture.md" "excluded adjacent domains"
  assert_contains "$proposal_dir/architecture/implementation-plan.md" "reject concepts that require silent escape"
  assert_contains "$proposal_dir/support/concept-verification-output.md" "cross-subsystem dependency note"
}

main() {
  assert_success "packet drift scenario fixture validates and records supersession evidence" case_packet_drift_fixture_validates_and_records_supersession
  assert_success "multi-source conflict scenario fixture validates and records conflict resolution" case_multi_source_conflict_fixture_validates_and_records_resolution
  assert_success "subsystem scope mismatch scenario fixture validates and records explicit boundary controls" case_subsystem_scope_mismatch_fixture_validates_and_records_boundary_controls

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
