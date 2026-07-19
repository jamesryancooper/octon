# Proposal Program Pattern

## Purpose

A proposal program coordinates related proposal packets from one parent packet
without nesting child packet directories. It supports initiatives where the
parent owns sequence, dependency gates, aggregate implementation orchestration prompts,
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
- `support/program-creation.md`
- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`
- program-level risk, evidence, implementation, verification, correction, and
  closeout support prompts

The parent may coordinate; it does not own child lifecycle truth, child subtype
manifest truth, child promotion target truth, child acceptance criteria, child
validation verdicts, or child archive metadata.

## Parent Review And Revision

Parent program review and revision are parent coordination only. Review covers
the parent `proposal.yml`, child registry and index, sequence, child contract,
validation plan, closeout plan, and parent support artifacts. It may write
parent-local `support/proposal-review.md` with the existing review fields and
may update only the parent manifest status to `accepted`, `rejected`, or
`in-review`.

Parent program revision may change only parent-local coordination files and
write `support/revisions/<revision-id>.md`. It must not edit child manifests,
child receipts, child promotion targets, child validation verdicts, child
archive metadata, runtime truth, or generated effective authority. Parent
review and revision receipts may summarize child outcomes but never satisfy
child receipts.

The `program-review-revision` lifecycle loop is the current review/revision
mechanism. No standalone program review-and-revise wrapper is admitted unless
future accepted evidence shows the generic program lifecycle runner cannot
execute this parent-local loop clearly.

## Required Relationship Consistency

Child ids in the parent `related_proposals`, `resources/child-packet-index.yml`,
`resources/child-packet-index.md`, and `architecture/packet-sequence.md` must
agree. The YAML child index is the structured runtime registry for Lifecycle
Autopilot program orchestration; the Markdown index remains human-facing
navigation. Every child validates as a normal manifest-governed proposal.

Parent program structure is validated with:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package <program-packet-path>
```

This validator checks only parent-owned coordination structure and authority
separation. It does not validate child implementation readiness and never
satisfies child receipts, child promotion targets, child validation verdicts,
or child archive metadata.

## Creation Evidence

Program creation writes parent-local `support/program-creation.md` with
`creation_id`, `created_at`, `creator`, `program_packet_path`,
`child_packet_count`, `execution_mode`, `child_registry_digest`,
`child_authority_preserved`, and `verdict`. The receipt records that the parent
registry and coordination artifacts were created without nesting or absorbing
child authority. It is evidence only.

## Controller Invariants

Governed Lifecycle Orchestration program runs are reviewed against the canonical controller
invariants in
`.octon/framework/engine/runtime/spec/lifecycle-program-controller-invariants.md`.
Those invariants require parent/child authority separation, child-owned receipt
freshness, event/checkpoint convergence, lock integrity, approval binding,
recovery truthfulness, atomic barrier limits, mutation/scaffold controls,
aggregate closeout completeness, and honest support claims.

## Implementation Prompt Readiness

Before `generate-program-implementation-orchestration-prompt` may run, the parent program
must have a fresh accepted parent review authorized with:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <program-packet-path> --require-implementation-authorization
```

Every required, non-deferred child packet must also remain child-owned and pass
the separate program child-readiness validator:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package <program-packet-path>
```

The validator checks child metadata including `change_profile`, child-owned
implementation-grade completeness reviews, accepted fresh proposal-review
digests, packet-specific readiness requirements declared in the child registry,
predecessor/successor coherence, and declared cutover constraints. Parent
evidence may summarize these checks but never replaces child receipts.

This gate is proposal-readiness only. It does not require implementation
receipts or durable promoted artifacts to exist, and it must not be used as
evidence that implementation has completed.

## Freshness And Readiness Projection

Proposal-program runs may materialize or validate a read-only freshness and
readiness projection before child dispatch and again before parent closeout.
The projection contract is
`.octon/framework/engine/runtime/spec/proposal-program-readiness-projection-v1.md`;
the validator is
`.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh`.

The projection reports parent readiness, child readiness, dependency readiness,
route readiness, archive readiness, generated/publication freshness,
retained-run evidence-index availability, blocker posture, and source digest
freshness. It is diagnostic evidence only. It does not authorize dispatch,
implementation, correction, closeout, archive, generated publication, or child
gate satisfaction. Existing child-owned review gates, readiness validators,
implementation receipts, conformance receipts, drift/churn receipts, closeout
receipts, archive metadata, publication freshness receipts, and retained-run
evidence indexes remain authoritative for their own transitions.

When terminal program evidence is hard to locate, operators may use retained-run
evidence indexes under `.octon/state/evidence/runs/<run-id>/` and lifecycle
postmortem `evidence-map.yml` files under
`.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/` as
discovery locators for direct control refs and validated substitute workflow
refs. These locators make retained evidence findable; they do not satisfy child
receipts, replace direct source evidence, close lifecycle state, or turn parent
summaries, generated outputs, or proposal-local packets into authority.

Proposal-program lifecycle postmortems include the optional
`proposal-program-delivery-evaluation` profile under
`evidence-map.yml#proposal_program_delivery_profile`. The profile is retained
evaluation evidence for blocker taxonomy, autonomy gaps, efficiency gaps,
delivery proof-chain audit, recommendation backlog, regression test planning,
and proposed next governed routes. It may bind parent, child, planner, archive,
delivery, git, hygiene, validator, and retained-run evidence refs when present.
It must degrade branch-no-PR, landing, sync, cleanup, and cleaned-claim audit
records to evidence-backed `not_applicable` records when delivery evidence is
absent. It never replaces child-owned receipts or authorizes lifecycle
transition, closeout, archive, delivery, git mutation, cleanup, generated
publication, or cleaned claims.

## Promotion And Archive Workflows

Parent program promotion uses the existing `promote-proposal` workflow id. It
enters only after an accepted fresh parent review, a generated program
implementation prompt, and parent-local `support/program-implementation-orchestration-run.md` with
`verdict: pass` and `child_authority_preserved: yes`. The parent program
structure validator must also pass.

Parent program archival uses the existing `archive-proposal` workflow id. It
enters only after the parent manifest is `implemented`, parent-local aggregate
verification receipts record `verdict: pass` and
`child_authority_preserved: yes`, and parent-local
`support/proposal-closeout.md` records `verdict: pass`, `archive_authorized:
yes`, and `child_authority_preserved: yes`.

These workflow routes change only parent program lifecycle status. They do not
replace child manifests, child receipts, child promotion targets, child
validation verdicts, or child archive metadata.

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
    required_metadata:
      - "change_profile"
    source_lineage_refs:
      - ".octon/inputs/exploratory/proposals/architecture/example-parent/resources/source.md"
    parent_contract_refs:
      - ".octon/inputs/exploratory/proposals/architecture/example-parent/architecture/child-packet-contract.md"
    readiness_requirements:
      - requirement_id: "harness-envelope-completeness"
        summary: "Child review must cover the task-specific harness envelope."
        review_must_mention:
          - "task-specific harness envelope"
    predecessor_constraints:
      - predecessor_child_id: "seed-child"
        constraint: "Seed framing must be proposal-ready first."
    cutover_constraints:
      compatibility_retirement_requires_predecessor_evidence: true
      required_predecessor_child_ids:
        - "seed-child"
      forbidden_claims_until_ready:
        - "compatibility-retired"
    write_scopes:
      - ".octon/framework/example.md"
```

## Write-Scope Collision Ledger

The canonical child registry may include one top-level
`write_scope_collision_ledger`. It is mandatory when two different children
declare the same literal `write_scope`, or when one declared scope ends in `/`
and is a prefix of the other. Prefix matching is path-component-aware:
`framework/host/` collides with `framework/host/adapter.yml`, but not with
`framework/hosted.yml`.

`registry_write_scopes_digest` is the SHA-256 digest of a UTF-8,
LF-terminated compact JSON array. The array has one row per child, sorted by
`child_id`; each row's keys are ordered `child_id`, `dependencies`, and
`write_scopes`; both arrays are sorted lexicographically. The collision ledger
is excluded from this projection. A child, dependency, or write-scope change
therefore makes the old ledger stale.

Each derived collision has exactly one record with:

- two distinct participants sorted by child id, each naming an exact declared
  scope and a nonempty bounded contribution;
- the derived `exact` or `directory-prefix` relation;
- one participant named as physical `integration_owner_child_id`, without any
  transfer of semantic or lifecycle authority; and
- either dependency-consistent `dependency-order`, or an
  `exclusive-integration-lock` with a stable `lock_id`, plus both participant
  ids exactly once in `ordered_child_ids`.

The canonical structure validator derives the complete collision set and
requires a one-to-one ledger match, fresh projection digest, correct derived
counts, transitive dependency agreement, peer-only lock ordering, and an
acyclic union of dependency and serialization edges. A zero-collision program
may omit the ledger or declare a fresh empty ledger. Prose ownership tables do
not satisfy this contract.

The Rust proposal-program controller independently parses the ledger into
unknown-field-rejecting typed structures, recomputes the same digest and
collision set, preserves it through non-projection mutations and canonical
round trips, and refuses a projection-changing mutation unless the resulting
registry has a complete valid replacement ledger. Scheduling uses the
digest-matching `ordered_child_ids` independently of registry or candidate
enumeration order. An exclusive-lock successor does not become runnable until
its predecessor is terminal. Invalid or stale ledger state returns an empty
runnable batch before dispatch. Both whole-program and child-focused planning
run the canonical `program-structure` gate.

## Closeout

Program verification convergence writes parent-local
`support/program-implementation-orchestration-conformance-review.md` and
`support/program-post-implementation-orchestration-drift-churn-review.md`. These aggregate
receipts summarize parent coordination, child receipt posture, and drift
posture. They must include `child_authority_preserved: yes` before parent
closeout or archival may proceed, and they never replace child receipts,
promotion targets, validation verdicts, archive metadata, or terminal outcomes.

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

A completed parent implementation program may supersede an accepted
architecture packet when the parent program and child receipts own the durable
implementation lineage. In that case the architecture packet archives with
`archive.disposition: superseded`, not `implemented`, and its
`archive.promotion_evidence` cites the parent program manifest, parent closeout
receipt, or retained aggregate child outcome evidence.

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
