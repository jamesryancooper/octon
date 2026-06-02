# Acceptance Criteria

## Functional Acceptance

- Proposed artifacts are emitted at the declared path placement.
- Compact artifacts include source refs, digests, freshness state, producer, consumer, validation, replay refs, and failure behavior.
- Readers prefer compact artifacts by default.
- Raw/full evidence remains retained and reachable by handle.
- Stale or unverifiable compact artifacts fail closed.
- Context-pack and authorization bindings remain valid.

## Token Acceptance

- Model-visible use of repeated full-text context for this surface is reduced by at least 30% in minimal rollout.
- Raw/full evidence is not model-visible by default unless escalation receipt exists.
- Token-budget ledger records the before/after effect for this surface.
- Prompt/context/completion/tool-output attribution is retained when LLM is used.

## Governance Acceptance

- No proposal input becomes authority.
- No generated/read-model artifact becomes source of truth.
- Engine-owned authorization is not bypassed.
- Child-owned receipts remain child-owned.
- Rollback and replay evidence are complete.

## Child-Specific Acceptance

Default route: deterministic-first; high-reasoning only on escalation

Token ceiling: slice-specific; final completion ≤8k, child dispatch ≤12k base, architecture exception ≤40k

Escalation trigger: authority ambiguity, architecture decision, rollback conflict, support-proof interpretation, promotion evidence conflict, archive/recovery failure, unexplained test failure
