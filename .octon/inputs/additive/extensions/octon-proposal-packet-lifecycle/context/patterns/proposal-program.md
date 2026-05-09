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
- `resources/child-packet-index.yml`
- `architecture/packet-sequence.md`
- `architecture/child-packet-contract.md`
- `architecture/program-closeout-plan.md`
- program-level risk, evidence, implementation, verification, correction, and
  closeout support prompts

The parent may coordinate; it does not own child lifecycle truth, child subtype
manifest truth, child promotion target truth, child acceptance criteria, child
validation verdicts, or child archive metadata.

## Required Relationship Consistency

Child ids in the parent `related_proposals`, `resources/child-packet-index.yml`,
`resources/child-packet-index.md`, and `architecture/packet-sequence.md` must
agree. The YAML child index is the structured runtime registry for Lifecycle
Autopilot program orchestration; the Markdown index remains human-facing
navigation. Every child validates as a normal manifest-governed proposal.

## Controller Invariants

Lifecycle Autopilot program runs are reviewed against the canonical controller
invariants in
`.octon/framework/engine/runtime/spec/lifecycle-program-controller-invariants.md`.
Those invariants require parent/child authority separation, child-owned receipt
freshness, event/checkpoint convergence, lock integrity, approval binding,
recovery truthfulness, atomic barrier limits, mutation/scaffold controls,
aggregate closeout completeness, and honest support claims.

## Execution Modes

- `sequential`
- `parallel-independent`
- `gated-parallel`
- `program-atomic`
- `approval-gated`

Executable `program-atomic` requires the v2 YAML registry schema, explicit
child write scopes, dependency gate type, recovery profile, rollback posture,
and child routes with atomic stage, commit, and rollback or compensation
metadata. Inference-based atomic eligibility is not allowed. Atomic execution is
barrier recovery: the controller preflights, locks, stages, verifies a barrier,
commits, and then rolls back or compensates where declared. It does not claim
universal transactionality; ambiguous committed state or missing compensation
fails closed.

V2 registry child entries add these structured fields:

```yaml
schema_version: "octon-proposal-program-child-registry-v2"
execution_mode: "program-atomic"
children:
  - child_id: "example-child"
    path: ".octon/inputs/exploratory/proposals/architecture/example-child"
    dependency_gate: "terminal"
    recovery_profile: "default"
    rollback_posture: "compensating"
    write_scopes:
      - ".octon/framework/example.md"
```

## Closeout

Program closeout requires every required child to reach a terminal outcome
allowed by the active lifecycle contract. The current proposal-program contract
allows required child closeout through `archived` or `rejected`; a deferred,
superseded, replaced, or rejected child must be covered by explicit registry
metadata and resolving evidence where the rollback posture requires it. The
parent closeout route refuses archival while any required child remains
non-terminal or blocked without explicit deferral, supersession, replacement, or
rejection evidence.

Runtime aggregate closeout writes `aggregate-closeout-receipt.yml` only after
the controller verifies required child terminal outcomes, child-owned receipts,
deferred or superseded evidence, aggregate evidence, and parent/child authority
boundaries. Receipt checks use live child receipt freshness and digest state,
not file existence alone. Parent evidence summarizes child outcomes only; it
never satisfies child receipts, promotion targets, or archive metadata.

## Mutation And Scaffold Controls

Parent registry changes use explicit mutation specs with an expected registry
digest and operator reason. `propose-mutation` writes evidence only;
`apply-mutation` updates the parent registry, appends a program event, and
updates checkpoint state after digest, dependency, supersession/replacement,
path ambiguity, and authority checks pass.

Program scaffold specs may generate parent packet surfaces, a structured child
registry, a human child index, and packet sequence notes from a seed/reference
packet plus follow-on child candidates. Non-dry-run scaffold refuses to
overwrite existing parent files. The seed/reference packet anchors the program
shape; it is not the parent program and does not create the real Governed
Workflow Runtime transition program by itself.
