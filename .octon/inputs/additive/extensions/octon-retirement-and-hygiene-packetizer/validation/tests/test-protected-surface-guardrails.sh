#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACK_ROOT="$(cd -- "$TEST_DIR/../.." && pwd)"

grep -Fq 'protected_or_claim_adjacent_outcome: "never-delete"' \
  "$PACK_ROOT/templates/cleanup-packet-inputs.yml.tmpl"
grep -Fq 'candidate-for-governed-ablation-review' \
  "$PACK_ROOT/templates/cleanup-packet-inputs.yml.tmpl"
grep -Fq 'Protected or claim-adjacent surfaces must remain `never-delete`' \
  "$PACK_ROOT/templates/ablation-plan.md.tmpl"
grep -Fq 'claim_adjacent: true' \
  "$PACK_ROOT/context/flow-matrix.md"
grep -Fq 'Protected or claim-adjacent surfaces must remain `never-delete`' \
  "$PACK_ROOT/skills/octon-retirement-and-hygiene-packetizer-ablation-plan-draft/SKILL.md"
