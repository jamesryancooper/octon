# Proposal Program Pattern

- proposal: `octon-proposal-packet-lifecycle-automation`

## Purpose

The Proposal Program pattern coordinates a set of related proposal packets
under one parent proposal packet without physically nesting those child packets.
It supports large, heterogeneous initiatives where the parent owns sequence,
dependency gates, aggregate implementation, aggregate verification, aggregate
closeout, cross-packet risk, and program evidence while every child packet
retains first-class proposal identity and proposal-local authority.

The implemented `octon-proposal-packet-lifecycle` extension pack must include
this pattern as a durable reusable context contract and must expose
program-specific lifecycle routes.

## Durable Extension-Pack Placement

The preferred durable placement is:

```text
.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/
  context/
    patterns/
      proposal-program.md
  prompts/
    create-proposal-program/
    generate-program-implementation-prompt/
    generate-program-verification-prompt/
    generate-program-correction-prompt/
    run-program-verification-and-correction-loop/
    generate-program-closeout-prompt/
    closeout-proposal-program/
  validation/
    scenarios/
      proposal-program/
```

If the implementation chooses a single shared pattern file instead, this full
contract must appear as a clearly labeled Proposal Program section in
`context/patterns.md`.

## Use When

Use a proposal program when:

- one initiative needs multiple independently valid proposal packets,
- child packets have different proposal kinds such as architecture, policy,
  migration, design, or implementation follow-up,
- child packets can be reviewed, implemented, verified, or closed out in a
  governed sequence,
- a parent needs to generate aggregate implementation, verification, correction,
  or closeout prompts,
- the work needs explicit cross-packet dependency, readiness, risk, evidence,
  deferral, supersession, or rollback tracking.

Do not use a proposal program when the work is tightly coupled and should land
as one atomic proposal. In that case, use one proposal packet with workstreams.

## Non-Negotiable Placement Rule

The parent packet references child packets. It does not contain nested child
proposal package directories.

Valid child packet placement remains:

```text
.octon/inputs/exploratory/proposals/<kind>/<child-proposal-id>/
```

Invalid nested placement:

```text
.octon/inputs/exploratory/proposals/<kind>/<parent-id>/children/<child-id>/
```

This preserves the current Octon proposal contract: every manifest-governed
proposal has one canonical active or archived path, one `proposal.yml`, exactly
one subtype manifest, one validator surface, and its own promotion targets.

## Parent Packet Shape

The parent packet is itself a normal manifest-governed proposal:

```text
.octon/inputs/exploratory/proposals/<kind>/<program-proposal-id>/
  proposal.yml
  <kind>-proposal.yml
  README.md
  navigation/
    source-of-truth-map.md
    artifact-catalog.md
  architecture/
    target-architecture.md
    implementation-plan.md
    validation-plan.md
    acceptance-criteria.md
    packet-sequence.md
    child-packet-contract.md
    program-closeout-plan.md
  resources/
    source-context.md
    child-packet-index.md
    program-risk-register.md
    program-evidence-plan.md
  support/
    executable-program-implementation-prompt.md
    follow-up-program-verification-prompt.md
    program-correction-prompts/
    child-closeout-prompts/
    custom-program-closeout-prompt.md
```

The subtype directory may vary by proposal kind, but every parent must include
equivalent sequence, child contract, validation, acceptance, and closeout
artifacts.

## Child Packet Shape

Each child is a normal proposal packet at its own canonical path. Child packets
may reference the parent through `related_proposals`, but the child packet's
own `proposal.yml` and subtype manifest remain authoritative for the child.

Child packets should include, when applicable:

- a `related_proposals` reference to the parent program id,
- packet-specific implementation, verification, correction, and closeout
  support prompts,
- child-local acceptance criteria and promotion targets,
- child-local validation and archive evidence,
- an explicit statement of whether the child can be implemented independently
  or only as part of a declared program gate.

## Relationship Model

The parent `proposal.yml` lists child proposal ids in `related_proposals`.

The richer relationship model belongs in `resources/child-packet-index.md` and
`architecture/packet-sequence.md`, not in invented manifest schema fields.

`resources/child-packet-index.md` must capture at least:

| Field | Meaning |
| --- | --- |
| `child_id` | Child `proposal_id`. |
| `child_kind` | Proposal kind, such as `architecture`, `policy`, `migration`, or `design`. |
| `canonical_path` | Active child packet path under `.octon/inputs/exploratory/proposals/<kind>/`. |
| `status` | Current child proposal lifecycle status from the child manifest. |
| `promotion_scope` | Child promotion scope. |
| `promotion_targets_summary` | Human-readable summary of durable targets. |
| `dependency_role` | `foundation`, `parallel`, `follower`, `optional`, `blocked`, or another declared role. |
| `gate_state` | Current program gate state for the child. |
| `execution_group` | Sequence or parallel group identifier. |
| `manifest_digest` | Optional digest or receipt proving which child manifest version was indexed. |

Child ids listed in `related_proposals`, `child-packet-index.md`, and
`packet-sequence.md` must agree.

## Sequence Contract

`architecture/packet-sequence.md` must define:

- program objective,
- child packet list,
- dependency graph,
- execution mode,
- entry criteria for each child,
- exit criteria for each child,
- aggregate program closeout criteria,
- allowed parallelism,
- rollback or stop policy,
- deferral policy,
- supersession policy.

Allowed execution modes:

- `sequential`: one child must close before the next begins.
- `parallel-independent`: children may run in parallel after shared preflight.
- `gated-parallel`: children may run in groups separated by gates.
- `program-atomic`: all child changes are implemented in one coordinated
  changeset, while children remain separate packets for review and traceability.
- `approval-gated`: parent prompts prepare the plan, but explicit approval is
  required for each child or group transition.

Allowed child gate states:

- `planned`
- `created`
- `validated`
- `ready`
- `implementing`
- `implemented`
- `verified`
- `correction-needed`
- `corrected`
- `closed`
- `blocked`
- `deferred`
- `superseded`
- `rejected`

## Authority Boundary

The parent packet owns:

- sequence,
- dependency ordering,
- aggregate implementation prompt,
- aggregate verification prompt,
- aggregate correction routing,
- aggregate closeout prompt,
- cross-packet risk and deferral tracking,
- program-level evidence expectations.

The parent packet does not own:

- child packet lifecycle truth,
- child subtype manifest truth,
- child promotion target truth,
- child acceptance criteria,
- child validation verdicts,
- child archive metadata.

Each child packet remains governed by its own `proposal.yml`, subtype manifest,
proposal standards, validators, promotion targets, support artifacts, and
closeout evidence.

## Program Lifecycle States

The program-level state machine extends the base lifecycle pattern:

```text
program-source-context
  -> program-created
  -> child-packets-planned
  -> child-packets-created
  -> child-packets-validated
  -> program-implementation-prompt-generated
  -> children-implemented
  -> program-verification-prompt-generated
  -> program-verified
  -> child-corrections-needed
  -> child-corrections-resolved
  -> program-closeout-prompt-generated
  -> program-closeout-ready
  -> children-closed
  -> program-archived
```

Fail-closed states:

- `child-blocked`
- `program-needs-revision`
- `child-superseded`
- `program-superseded`
- `program-deferred`

## Program Routes

The lifecycle automation extension pack must add these routes:

- `create-proposal-program`
- `generate-program-implementation-prompt`
- `generate-program-verification-prompt`
- `generate-program-correction-prompt`
- `run-program-verification-and-correction-loop`
- `generate-program-closeout-prompt`
- `closeout-proposal-program`

These routes must compose the base packet routes wherever possible. Program
routes may coordinate child packets, but they must not bypass child validators,
child manifests, child acceptance criteria, or child support artifact placement.

## Program Implementation Model

An aggregate implementation prompt may execute child packets in the declared
sequence or allowed parallel groups. It must:

- re-read the parent packet and every child packet before implementation,
- validate every child packet before using it as implementation input,
- respect each child packet's promotion targets,
- stop or request revision when a child packet's live repo grounding is stale,
- record child-level and program-level evidence,
- avoid broadening one child to cover another child's scope unless the parent
  sequence explicitly requires a coordinated changeset.

## Program Verification Model

Aggregate verification must check both levels:

- parent-level sequence, dependency, risk, evidence, deferral, and closeout
  criteria,
- child-level acceptance criteria, validation plans, promotion targets, and
  implementation evidence.

Program verification findings must identify whether each finding belongs to the
parent, one child, a child group, or a cross-packet dependency.

## Program Closeout

Program closeout requires:

1. every child is implemented, archived, rejected, superseded, or explicitly
   deferred with rationale,
2. child closeout order follows `packet-sequence.md`,
3. aggregate evidence exists,
4. no durable target depends on the parent packet path,
5. no durable target depends on child packet paths,
6. the proposal registry is regenerated when safe,
7. the parent is archived only after child lifecycle states are coherent.

The parent closeout route must refuse to archive the parent when any required
child is still `planned`, `created`, `validated`, `ready`, `implementing`,
`correction-needed`, or `blocked` unless an explicit deferral, supersession, or
rejection receipt exists.

## Program Validation Fixtures

The extension pack must include fixtures for:

- a parent with two same-kind child architecture packets,
- a mixed-kind program with architecture and policy children,
- a sequential program,
- a `parallel-independent` program,
- a `gated-parallel` program,
- a `program-atomic` program,
- a blocked child that prevents parent closeout,
- a deferred child with rationale that allows parent closeout,
- invalid nested child proposal directories,
- parent and child `related_proposals` mismatch,
- aggregate prompts attempting to override child manifests.

## Pattern Outcome

This pattern gives Octon a governed way to run multi-packet programs without
weakening the existing proposal contract. It supports the desired "parent
packet implements child packets" workflow by making the parent a coordinator of
first-class child packets, not a container that absorbs their identity,
validation, authority, or archival.
