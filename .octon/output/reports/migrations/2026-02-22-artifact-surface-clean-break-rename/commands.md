# Commands

## Core Migration Edits

```bash
git mv .octon/cognition/_meta/architecture/content-plane \
  .octon/cognition/_meta/architecture/artifact-surface

git mv .octon/cognition/_meta/architecture/artifact-surface/runtime-content-layer.md \
  .octon/cognition/_meta/architecture/artifact-surface/runtime-artifact-layer.md
```

## Static Sweep Commands

```bash
rg -n "content-plane" .octon \
  --glob '!**/target/**' \
  --glob '!**/_ops/state/**' \
  --glob '!**/runtime/migrations/**' \
  --glob '!**/runtime/decisions/**' \
  --glob '!**/runtime/context/decisions.md' \
  --glob '!**/practices/methodology/migrations/legacy-banlist.md' \
  --glob '!**/output/reports/migrations/**'

rg -n "Content Plane|content publishing surface|Octon Content Publishing Surface|\\bHCP\\b|Octon Content Plane" .octon \
  --glob '!**/target/**' \
  --glob '!**/_ops/state/**' \
  --glob '!**/runtime/migrations/**' \
  --glob '!**/runtime/decisions/**' \
  --glob '!**/runtime/context/decisions.md' \
  --glob '!**/practices/methodology/migrations/legacy-banlist.md' \
  --glob '!**/output/reports/migrations/**'
```

## Diff Hygiene

```bash
git diff --check -- \
  .octon/cognition/_meta/architecture/artifact-surface \
  .octon/cognition/runtime/knowledge-plane/knowledge-plane.md \
  .octon/continuity/_meta/architecture/three-planes-integration.md
```
