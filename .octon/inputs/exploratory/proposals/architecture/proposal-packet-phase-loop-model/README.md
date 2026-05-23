# Proposal Packet Phase-Loop Model

## Purpose

This packet proposes a clean-break, governed Proposal Packet Phase-Loop Model
for the existing Octon proposal lifecycle and Lifecycle Autopilot system.

It is proposal creation only. It does not implement framework, schema, runtime,
validator, generated projection, skill, documentation, or test changes.

## Current-State Summary

Proposal packets currently live under
`.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/` as temporary,
non-canonical implementation aids. `proposal.yml` is the packet-local lifecycle
manifest, with a single subtype manifest such as `architecture-proposal.yml`.
Allowed proposal statuses are `draft`, `in-review`, `accepted`, `implemented`,
`rejected`, and `archived`.

Lifecycle Autopilot currently supplies a generic runner and executor adapter
for extension-declared lifecycle contracts. The proposal packet lifecycle is
the first single-target pilot. Its contract declares route progression through
packet creation, review, revision, implementation authorization, implementation
prompt generation, implementation, promotion, verification, closeout, and
archive. The review/revision loop is receipt-driven through
`support/proposal-review.md` and `support/revisions/**`; it is not represented
as extra proposal manifest statuses.

The runner owns planning, gate evaluation, stale receipt detection, loop
bounds, evidence, checkpoints, resume, cancellation, and hash-chained packet
event logs. The lifecycle executor adapter owns route invocation, input
binding, completion observation, timeouts, retries, approval pauses, and
structured execution results. Generated effective extension projections are
runtime discovery handles only.

The Change Closeout State Machine already uses a phase-loop vocabulary for
route-neutral closeout phases, exit evidence, loops, cleanup safety, receipts,
rollback posture, and final verification. That model proves the value of a
generic phase-loop vocabulary, but it is not currently shared with proposal
packet lifecycle contracts.

## Target Model

The target model makes proposal packet lifecycle execution explicitly
phase-loop based while preserving the existing proposal status contract.

Each phase has:

- entry evidence;
- allowed routes;
- loop policy and maximum iterations or steps;
- required receipts and validators;
- exit evidence;
- fail-closed stop classes;
- checkpoint and resume expectations;
- event-log obligations.

The phase-loop model does not make proposal packets authoritative. It does not
make generated projections, proposal-local receipts, GitHub or CI state, chat,
browser state, tool availability, or model memory authoritative. It also does
not make self-operating lifecycle execution self-authorizing.

## Placement Decision

The proposed placement is layered/both.

Generic substrate should own common phase-loop mechanics: phase declarations,
loop bounds, stop classes, checkpoint and resume semantics, event-log schema
fields, stale receipt behavior, cancellation, and runner/executor boundaries.

The proposal lifecycle extension should own proposal-specific semantics:
proposal packet phases, route eligibility, review and revision receipts,
implementation-grade completeness gates, implementation authorization, closeout
receipts, archive eligibility, and documentation for proposal operators.

## Required Route After This Packet

This packet must be reviewed and revised until accepted before implementation
prompt generation. A later implementation may proceed only after fresh accepted
proposal-review evidence, required gates, and authority-boundary checks pass.

## Recommended Reading Order

1. `navigation/source-of-truth-map.md`
2. `architecture/current-state-gap-map.md`
3. `architecture/target-architecture.md`
4. `architecture/file-change-map.md`
5. `architecture/implementation-plan.md`
6. `architecture/validation-plan.md`
7. `architecture/acceptance-criteria.md`
8. `resources/traceability-map.md`
9. `resources/risk-register.md`
10. `support/implementation-grade-completeness-review.md`

## Non-Authority Notice

This packet is under `inputs/exploratory/proposals/**` and is not canonical
runtime, policy, support, or closeout authority. Promotion targets named here
must stand on their own after any later governed implementation.
