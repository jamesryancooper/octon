#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"

required_paths=(
  ".octon/framework/scaffolding/runtime/templates/octon/instance/extensions.yml"
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/additive/.incoming/.gitkeep"
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/additive/.archive/.gitkeep"
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/additive/extensions/.gitkeep"
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/exploratory/README.md"
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/exploratory/ideation/.gitkeep"
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/exploratory/plans/.gitkeep"
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/exploratory/plans/README.md"
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/exploratory/proposals/.gitkeep"
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/exploratory/reports/.gitkeep"
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/exploratory/reports/README.md"
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/exploratory/syntheses/.gitkeep"
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/exploratory/syntheses/README.md"
  ".octon/framework/scaffolding/runtime/templates/octon/generated/effective/extensions/catalog.effective.yml"
  ".octon/framework/scaffolding/runtime/templates/octon/generated/effective/extensions/artifact-map.yml"
  ".octon/framework/scaffolding/runtime/templates/octon/generated/effective/extensions/generation.lock.yml"
  ".octon/framework/scaffolding/runtime/templates/octon/state/control/extensions/active.yml"
  ".octon/framework/scaffolding/runtime/templates/octon/state/control/extensions/quarantine.yml"
)

for rel in "${required_paths[@]}"; do
  [[ -e "$REPO_ROOT/$rel" ]] || {
    echo "FAIL: missing Packet 8 scaffold path $rel" >&2
    exit 1
  }
done

for rel in \
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/additive/extensions/.incoming" \
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/additive/extensions/.archive" \
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/exploratory/drafts" \
  ".octon/framework/scaffolding/runtime/templates/octon/inputs/exploratory/packages"; do
  [[ ! -e "$REPO_ROOT/$rel" ]] || {
    echo "FAIL: obsolete Packet 8 scaffold path exists $rel" >&2
    exit 1
  }
done

echo "PASS: Packet 8 scaffold paths are present in the octon template"
