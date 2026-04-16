#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACK_ROOT="$(cd -- "$TEST_DIR/../.." && pwd)"

check_contains() {
  local pattern="$1"
  local file="$2"
  grep -Fq -- "$pattern" "$file"
}

check_contains "/.octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene.sh" \
  "$PACK_ROOT/skills/octon-retirement-and-hygiene-packetizer/references/boundary.md"
check_contains "/.octon/instance/governance/policies/repo-hygiene.yml" \
  "$PACK_ROOT/skills/octon-retirement-and-hygiene-packetizer/references/evidence-map.md"
check_contains "/.octon/instance/governance/contracts/closeout-reviews.yml" \
  "$PACK_ROOT/skills/octon-retirement-and-hygiene-packetizer/references/evidence-map.md"
check_contains "/.octon/instance/governance/contracts/retirement-registry.yml" \
  "$PACK_ROOT/skills/octon-retirement-and-hygiene-packetizer/references/evidence-map.md"
check_contains "/.octon/instance/governance/retirement-register.yml" \
  "$PACK_ROOT/skills/octon-retirement-and-hygiene-packetizer/references/evidence-map.md"
check_contains "/.octon/instance/governance/retirement/claim-gate.yml" \
  "$PACK_ROOT/skills/octon-retirement-and-hygiene-packetizer/references/evidence-map.md"
check_contains "/.octon/instance/governance/contracts/ablation-deletion-workflow.yml" \
  "$PACK_ROOT/skills/octon-retirement-and-hygiene-packetizer/references/evidence-map.md"
check_contains "/.octon/state/evidence/runs/ci/repo-hygiene/<audit-id>/" \
  "$PACK_ROOT/skills/octon-retirement-and-hygiene-packetizer/references/evidence-map.md"
check_contains "live build-to-delete packet" \
  "$PACK_ROOT/skills/octon-retirement-and-hygiene-packetizer-audit-to-packet-draft/SKILL.md"
