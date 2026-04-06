#!/usr/bin/env bash
set -euo pipefail
for f in \
  .octon/state/evidence/validation/publication/drift/documentation-drift.yml \
  .octon/state/evidence/validation/publication/drift/state-drift.yml \
  .octon/state/evidence/validation/publication/drift/governance-drift.yml \
  .octon/state/evidence/validation/publication/drift/adapter-drift.yml; do
  [[ -f "$f" ]] || exit 1
done

