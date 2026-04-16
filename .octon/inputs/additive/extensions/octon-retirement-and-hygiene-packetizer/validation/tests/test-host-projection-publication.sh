#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../fixture-lib.sh"

fixture_root="$(setup_publication_fixture)"
trap 'rm -r -f -- "$fixture_root"' EXIT

run_in_fixture "$fixture_root" \
  bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
run_in_fixture "$fixture_root" \
  bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh" >/dev/null
run_in_fixture "$fixture_root" \
  bash "$fixture_root/.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh" >/dev/null
run_in_fixture "$fixture_root" \
  bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh" >/dev/null
run_in_fixture "$fixture_root" \
  bash "$fixture_root/.octon/framework/capabilities/_ops/scripts/publish-host-projections.sh" >/dev/null
run_in_fixture "$fixture_root" \
  bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh" >/dev/null

for host in claude cursor codex; do
  [[ -f "$fixture_root/.${host}/commands/octon-retirement-and-hygiene-packetizer.md" ]]
  [[ -d "$fixture_root/.${host}/skills/octon-retirement-and-hygiene-packetizer" ]]
  [[ -f "$fixture_root/.${host}/skills/octon-retirement-and-hygiene-packetizer/SKILL.md" ]]
done
