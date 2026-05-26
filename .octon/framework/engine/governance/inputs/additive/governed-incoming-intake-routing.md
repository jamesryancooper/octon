# Governed Incoming Intake Routing

This document defines the target route model and fixture expectations for
Governed Incoming Intake Routing.

Governed Incoming Intake Routing applies only to an explicitly provided
additive incoming intake unit under
`inputs/additive/.incoming/<intake-id>/`. It is a non-mutating classification
and handoff decision layer over the existing incoming intake envelope. It does
not process intake, create proposals, dispatch Governed Lifecycle
Orchestration, install skills, normalize extension packs, activate extensions,
archive source material, close Changes, clean worktrees, or delete repository
hygiene residue.

The existing incoming intake envelope validation remains the first gate. Route
classification starts only after
`validate-incoming-intake-unit.sh --intake-id <intake-id>` succeeds. A malformed
or unsafe raw intake envelope is blocked before route classification.

Raw intake, generated output, host state, chat history, model memory, tool
availability, lifecycle interaction receipts, and proposal handoff context are
not runtime, policy, proposal, closeout, cleanup, retained-evidence, or Git
authority.

## Scope

In scope:

- explicitly provided `.incoming/<intake-id>` additive intake units
- deterministic classification fixture facts
- route decision receipts and denial rationale
- advisory handoff context for a target-owned proposal packet or program route
- proof that a future direct target route is denied until an explicit
  target-owned intake admission contract exists

Out of scope:

- autonomous scanning of `.incoming/**`
- direct installation or normalization of intake payloads
- proposal packet or program creation
- GLO dispatch
- Change closeout
- worktree closeout
- repo hygiene cleanup
- branch, hosted provider, archive, or Git mutation

Existing direct additive extension and core skill dispositions remain current
behavior until a later governed migration changes workflow semantics. This
surface defines the fixture-backed target route model for that migration; it is
not itself a behavior-changing runtime workflow.

## Route Set

Governed Incoming Intake Routing has exactly four route decisions.

| Route | Current Status | Meaning |
| --- | --- | --- |
| `single-work-unit-handoff` | Enabled for fixture classification only | One coherent candidate addition becomes advisory proposal packet handoff context. |
| `coordinated-program-handoff` | Enabled for fixture classification only | Multi-surface, staged, dependent, or complex intake becomes advisory proposal program handoff context. |
| `target-owned-direct-handoff` | Recognized but denied | Reserved for future non-proposal targets with explicit target-owned intake admission contracts. |
| `blocked-rejected-deferred` | Enabled | Intake is malformed, unsafe, ambiguous, unsupported, unverifiable, low-value, intentionally deferred, or authority-confused. |

No route selected by this layer authorizes target mutation. The selected target
owns its own validation, authority, receipt requirements, mutation, closeout,
archive, and cleanup behavior.

## Route Criteria

Use `single-work-unit-handoff` only when all of these are true:

- the incoming envelope has already passed validation
- the candidate has one coherent intent
- the candidate has one primary target surface
- no child sequencing is required
- no migration or cutover is required
- no cross-surface dependency is required
- provenance is reviewable
- validation is bounded enough for one proposal packet

Use `coordinated-program-handoff` when any of these are true:

- multiple target surfaces are involved
- multiple candidate changes are present
- dependency ordering or child sequencing is required
- staged adoption is required
- migration or cutover is required
- governance and runtime-facing surfaces both change
- child packet coordination is required

Recognize `target-owned-direct-handoff` only when an intake attempts to route to
a non-proposal target. In the current implementation, this route is always
denied because no target-owned intake admission contract exists.

Use `blocked-rejected-deferred` when any of these are true:

- the intake envelope is malformed or fails containment validation
- provenance or licensing is unsafe or unverifiable
- source material contains secrets, private data, proprietary material, opaque
  binaries, or unsafe executable content
- route classification is ambiguous
- the target surface is unsupported
- the intake claims authority to install, promote, mutate Git, close Changes,
  clean worktrees, delete hygiene residue, archive source material, widen
  scope, or authorize downstream lifecycle action
- a direct target handoff is requested without a target-owned intake admission
  contract

## Fixture Matrix

The authoritative fixture expectations for validators live in
`governed-incoming-intake-routing-fixtures.yml`.

| Fixture ID | Fixture Type | Expected Route | Expected Result |
| --- | --- | --- | --- |
| `real-rust-source-authority-invalid-envelope` | Real observed intake | none | Block before route classification because top-level `.DS_Store` and `intake-status.yml` violate the current intake envelope. |
| `simple-extension-pack-single-unit` | Synthetic | `single-work-unit-handoff` | One coherent extension pack candidate becomes proposal packet handoff context. |
| `simple-core-skill-single-unit` | Synthetic | `single-work-unit-handoff` | One coherent core skill candidate becomes proposal packet handoff context. |
| `multi-skill-program` | Synthetic | `coordinated-program-handoff` | Multiple skills or surfaces require program coordination and child packet planning. |
| `governance-plus-runtime-program` | Synthetic | `coordinated-program-handoff` | Governance and runtime-facing changes require program handoff. |
| `ambiguous-packet-vs-program` | Synthetic | `blocked-rejected-deferred` | Classification records both candidates and blocks for missing discriminator. |
| `unsafe-provenance-or-license` | Synthetic | `blocked-rejected-deferred` | Unsafe provenance or licensing prevents handoff and may require evidence-only retention. |
| `secret-or-private-data` | Synthetic | `blocked-rejected-deferred` | Secrets or private data prevent archive-by-copy and proposal handoff. |
| `malicious-authority-confusion` | Synthetic | `blocked-rejected-deferred` | Claims to authorize Git, cleanup, generated authority, or direct install are denied. |
| `direct-target-without-contract` | Synthetic | `target-owned-direct-handoff` rejected | Direct target route is recognized but denied because no target contract exists. |

## Evidence Expectations

Each fixture expectation must preserve:

- explicit intake id or observed intake path
- preclassification envelope validation result
- classification signals used to derive the route
- selected route or denial
- rejected route candidates when classification reaches route selection
- rationale for every denial
- proof that handoff context is advisory and cannot authorize target action
- proof that parent program evidence cannot satisfy child packet receipts
- proof that classification replay is idempotent and non-mutating

Every mutating target action remains target-owned and must require a separate
target-owned contract, validator, and receipt before any future implementation
may dispatch it.

## Fail-Closed Rules

The validator must fail closed when:

- the incoming envelope validator fails
- the fixture route set differs from the four-route model
- `target-owned-direct-handoff` is enabled without a target-owned intake
  admission contract
- a fixture selects more than one route or selects an unknown route
- a non-blocked route omits rejected route evidence
- handoff context attempts to authorize Git, branch cleanup, hosted provider
  action, worktree cleanup, repo hygiene deletion, promotion, archive, or scope
  expansion
- parent proposal-program evidence is allowed to satisfy child packet receipts
- raw intake, generated output, host state, chat history, model memory, tool
  availability, or lifecycle interaction receipts are treated as authority

