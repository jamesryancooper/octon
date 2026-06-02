# Evidence And Replay Model

## Principle

Token reduction happens by changing what is model-visible by default, not by deleting evidence.

## Required Evidence Chain

Every consequential or boundary-sensitive run must retain context-pack receipt, model-visible context JSON, model-visible context hash, source manifest, omissions manifest, invalidation events, authorization decision/grant refs, execution receipts, evidence index, token ledger, raw stdout/stderr refs, validator manifests, rollback refs, closeout receipts, and disclosure/run-card refs where required.

## Compact Artifacts

Compact artifacts are projections over retained evidence. They cannot authorize execution and cannot replace raw evidence.

Examples:

- `evidence-index.yml` points to raw logs.
- `raw-log-summary.yml` points to raw logs and failing slices.
- `planner-state.yml` points to checkpoint/event log heads.
- `program-context-capsule.yml` points to child receipts and blocker ledger.
- `validator-result-manifest.yml` points to stdout/stderr and contracts.
- `closeout-projection.yml` points to full closeout receipt and rollback refs.

## Replay Requirement

A reviewer must be able to reconstruct the exact model-visible context used by a route, the digest chain of prompt capsules and source assets, the child dependency state, the child receipt state, validator results, raw evidence behind summaries, the route/model selection decision, and rollback/closeout evidence.

## Failure Behavior

Fail closed when raw evidence referenced by compact artifact is missing, compact artifact digest does not match source evidence, model-visible hash cannot be reconstructed, generated handle is stale, prompt capsule is stale, child receipt is missing, authority class is ambiguous, generated/read-model source is treated as authority, or proposal input is treated as runtime authority.
