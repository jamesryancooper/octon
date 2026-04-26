# Execution Constitution Conformance Card

## Constitutional alignment

| Constitutional principle | Migration behavior |
| --- | --- |
| Explicitly scoped execution | Support envelope reconciler bounds live claims |
| Explicit authority routing | Typed effects require engine-owned authorization |
| Fail-closed governance | Missing or contradictory support/token evidence denies action |
| Observable/debuggable execution | Run health and retained evidence expose state and cause |
| Reviewable and recoverable work | Health links to checkpoints, rollback, and closure readiness |
| Generated artifacts not authoritative | Reconciliation and health outputs are derived-only |
| Inputs not authoritative | Proposal packet remains non-authoritative |
| Durable assurance | Closure evidence retained under state/evidence |

## Conformance result

Proposed result: **conformant if implemented as specified**.

## Non-conformance risks

- Runtime code accepts `GrantBundle` or ambient permission as sufficient for a
  material side effect.
- Generated support matrix or run-health output is treated as support authority.
- Support cards/disclosures are published without reconciled proof.
- Proposal-path artifacts are referenced by runtime code.
- Run health collapses continuity, control, and evidence into one authority blob.

## Required proof before closure

- support-envelope reconciliation pass
- token positive/negative enforcement pass
- run-health positive/negative validation pass
- evidence completeness pass
- generated/input non-authority pass
