# ADR 0007: Queue Claims Require Claimed-At And Claim-Token

## Status

- accepted

## Context

The queue design needs deterministic claim, ack, and lease-expiry behavior.
`claimed_by` and `claim_deadline` alone are insufficient because stale
acknowledgements and concurrent claim races cannot be validated or rejected
unambiguously.

## Decision

Queue claims require both `claimed_at` and `claim_token`.

Every successful claim atomically moves an eligible item into `claimed/` and
sets `claimed_by`, `claimed_at`, `claim_deadline`, and `claim_token`. Ack and
release operations must present the matching `claim_token`, and stale tokens are
rejected.

## Consequences

- makes stale acknowledgements detectable
- makes lease timing auditable
- keeps claim/ack semantics deterministic without introducing v1 heartbeats or
  lease renewal

## Alternatives Considered

- Use only `claimed_by` plus `claim_deadline`
- Add heartbeat and renewal semantics in the first contract version

## Relationship To Existing Contracts

- reinforces `contracts/queue-item-and-lease-contract.md`
- aligns with `normative/execution/lifecycle-and-state-machine-spec.md`
- aligns with `normative/assurance/assurance-and-acceptance-matrix.md`
