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

Default route: deterministic-first; small model only for human summary

Token ceiling: 4k model-visible tokens for summary; 0 LLM tokens for ledger generation

Escalation trigger: provider usage mismatch, missing model accounting, source-token ledger cannot reconstruct context totals
