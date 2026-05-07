# Proposal Program Pattern

## Purpose

A proposal program coordinates related proposal packets from one parent packet
without nesting child packet directories. It supports initiatives where the
parent owns sequence, dependency gates, aggregate implementation prompts,
aggregate verification, aggregate correction routing, aggregate closeout,
cross-packet risk, deferral, supersession, rollback posture, and program
evidence.

## Placement

Parent packet:

```text
.octon/inputs/exploratory/proposals/<kind>/<program-proposal-id>/
```

Child packets:

```text
.octon/inputs/exploratory/proposals/<kind>/<child-proposal-id>/
```

Invalid placement:

```text
.octon/inputs/exploratory/proposals/<kind>/<program-proposal-id>/children/<child-proposal-id>/
```

## Parent-Owned Surfaces

- `resources/child-packet-index.md`
- `architecture/packet-sequence.md`
- `architecture/child-packet-contract.md`
- `architecture/program-closeout-plan.md`
- program-level risk, evidence, implementation, verification, correction, and
  closeout support prompts

The parent may coordinate; it does not own child lifecycle truth, child subtype
manifest truth, child promotion target truth, child acceptance criteria, child
validation verdicts, or child archive metadata.

## Required Relationship Consistency

Child ids in the parent `related_proposals`, `resources/child-packet-index.md`,
and `architecture/packet-sequence.md` must agree. Every child validates as a
normal manifest-governed proposal.

## Execution Modes

- `sequential`
- `parallel-independent`
- `gated-parallel`
- `program-atomic`
- `approval-gated`

## Closeout

Program closeout requires every required child to be implemented, archived,
rejected, superseded, or covered by an explicitly deferred report outcome with
rationale. The parent closeout route refuses archival while any required child
remains planned, created, validated, ready, implementing, correction-needed, or
blocked without an explicit deferral, supersession, or rejection receipt.
