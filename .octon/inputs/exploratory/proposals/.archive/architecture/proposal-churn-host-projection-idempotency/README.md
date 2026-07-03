# Churn Host Projection Idempotency

## Target Surfaces

- `.claude/**`
- `.codex/**`
- `.cursor/**`
- `.octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`

## Producer Owner

Host projection publisher.

## Producer Entrypoint Inventory

Before implementation, enumerate the host projection publisher, validators,
source capability/extension projection inputs, and every host root in scope:
`.claude/**`, `.codex/**`, and `.cursor/**`. The inventory must identify any
publisher-owned prune rules and distinguish projected files from user-owned or
authority surfaces.

## Current Problem

The audit found about 33 changed host projection files. These surfaces are
generated-like and user-facing, but they are not `.octon/generated` and must
not be treated as authority or generic cleanup.

## Intended Efficiency Improvement

Make host publishing idempotent, host-aware, and changed-file-only while
preserving projection parity and non-authority notices.

## Guardrails

- Host projections remain non-authoritative.
- Cleanup or pruning must be publisher-owned.
- Host parity and projection purity validation remain required.
- Host projections cannot satisfy authority, policy, support-claim, closeout, archive, cleanup, or terminal proof.
- Publisher-owned pruning cannot delete unrelated user-authored host state.

## Validation Gates

- Host projection validation.
- Host projection purity validation.
- No-op host publish diff check.
- Changed-source-only projection fixtures.
- Negative controls proving host projections cannot mint authority or widen support claims.

## Measurable Success Criteria

- No-op host projection publishing creates zero diffs under `.claude`, `.codex`, and `.cursor`.
- Changed command or skill source projects only to affected host files.
- Host projections cannot satisfy authority, closeout, or support-proof gates.

## Common Metrics

Implementation must report the applicable parent metrics: changed file count,
generated no-op rewrite rate for host projections, dirty-worktree residue
count, process runtime, token budget impact, validation coverage retained, and
host parity retained.

## External Dependencies

No existing external packet owns this child. It consumes
`proposal-churn-common-generator-idempotency-metrics` through the parent
program sequence.
