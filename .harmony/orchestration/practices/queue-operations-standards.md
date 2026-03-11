# Queue Operations Standards

Operational discipline for the shared orchestration queue under
`/.harmony/orchestration/runtime/queue/`.

## Scope

Applies to queue claim, acknowledgement, retry, dead-letter, and receipt
handling.

## Standards

1. Queue ingress remains automation-only.
   - Missions are not queue targets.
2. Claims must be atomic.
   - A valid claim sets `claimed_by`, `claimed_at`, `claim_deadline`, and
     `claim_token` together.
3. Acknowledgement must verify `claim_token`.
   - Stale acknowledgements are rejected and recorded.
4. Expiry moves items deterministically.
   - Expired claims move to `retry` or `dead-letter` according to the contract.
5. Receipts are append-only evidence.
   - Do not treat receipts as mutable queue state.

## Operator Rules

- Prefer expiry or dead-letter over ad hoc queue-file edits.
- Preserve queue item identifiers when moving across lanes.
- Do not introduce named queue collections or `queue_id` semantics in v1.
