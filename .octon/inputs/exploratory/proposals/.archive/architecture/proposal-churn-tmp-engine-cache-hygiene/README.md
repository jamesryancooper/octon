# Churn Tmp Engine Cache Hygiene

## Target Surfaces

- `.octon/generated/.tmp/**`
- Engine build/cache output under `.octon/generated/.tmp/engine/**`
- Publication wrapper and cleanup helpers

## Producer Owner

Engine build/cache wrappers and validation/publication runners.

## Producer Entrypoint Inventory

Before implementation, enumerate every wrapper, build runner, validation
runner, and cleanup helper that writes under `.octon/generated/.tmp/**`,
including engine build/cache roots. The inventory must identify scratch roots,
cache roots, rebuild inputs, cleanup owner, and refusal boundaries.

## Current Problem

The attached audit found no landed tracked `.tmp` churn and no current residue,
but prior local measurements showed very large ignored scratch/build output.
Cleaned transient residue cannot be reconstructed from current `main`.

## Intended Efficiency Improvement

Add explicit TTL, file/byte budgets, cache placement discipline, cleanup dry
runs, and rebuildability proof for local scratch.

## Required Budgets

Implementation must declare concrete maximum file count, maximum byte count,
TTL, and cleanup trigger for each scratch/cache root. If a root cannot be
bounded safely, the packet must document the reason and route it to a separate
owner decision instead of silently exempting it.

## Guardrails

- Retained evidence is not deleted.
- Runtime-facing generated/effective outputs are not pruned as scratch.
- Cleanup must be owner-scoped and proof-backed.
- Missing reconstructed residue remains an unknown, not a false clean claim.
- Host projections, proposal archives, source/framework/input files, retained evidence, and active control truth are cleanup refusal surfaces.

## Validation Gates

- `.tmp` file and byte budget checks.
- Cleanup dry-run and refusal tests.
- Rebuildability proof for pruned scratch.
- Repo hygiene policy validation.
- Negative controls proving cleanup refuses retained evidence, active generated/effective outputs, host projections, proposal archives, and source files.

## Measurable Success Criteria

- Representative lifecycle runs leave `.tmp` under declared file/byte budgets.
- Cleanup dry-run classifies only rebuildable/unreferenced scratch.
- Post-cleanup validation can rebuild required outputs.

## Common Metrics

Implementation must report the applicable parent metrics: `.tmp` byte/file
count, dirty-worktree residue count, process runtime, token budget impact, and
validation coverage retained after cleanup and rebuild.

## External Dependencies

- `run-program-clean-delivery-cleanup-disposition`: consumed for cleanup
  authority and residue classification boundaries. This child must not
  duplicate cleanup disposition or broaden cleanup authority.
