# ADR 0008: Replace Is Cancel-Safe Latest-Wins

## Status

- accepted

## Context

`replace` overlap behavior is useful for automations where the newest request
should supersede stale in-flight work. Without a precise definition, different
implementations would disagree on whether replace drops, defers, or preempts
running work and whether that preemption is safe.

## Decision

`replace` is a cancel-safe latest-wins mode.

It is valid only when `max_concurrency=1` and the target workflow explicitly
declares `execution_controls.cancel_safe: true`. When a new eligible launch
arrives, the current run is cancelled first, and the replacement run is emitted
only after the prior run reaches `cancelled`. If the workflow is not
cancel-safe, the action blocks and records a decision record.

## Consequences

- keeps replace deterministic and operator-visible
- prevents implicit fallback to other concurrency modes
- avoids unsafe preemption for workflows that cannot guarantee clean
  cancellation

## Alternatives Considered

- Remove `replace` from the contract entirely
- Allow replace to preempt any workflow regardless of cancellation safety

## Relationship To Existing Contracts

- reinforces `contracts/automation-execution-contract.md`
- requires workflow-side `execution_controls.cancel_safe` addenda during
  canonicalization
- aligns with `routing-authority-and-execution-control.md`
