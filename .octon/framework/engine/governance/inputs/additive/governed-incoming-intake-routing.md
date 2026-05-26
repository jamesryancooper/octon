# Governed Incoming Intake Routing

Governed Incoming Intake Routing is the additive `.incoming/<intake-id>`
admission layer inside `process-incoming-intake`.

It accepts only one explicitly provided raw additive intake unit, validates the
existing non-authoritative intake envelope, classifies deterministic routing
facts, selects exactly one target-owned route or fail-closed denial, and records
replayable evidence. It is not a generic entry router and it does not make raw
intake, intake workflow output, proposal handoff context, generated output,
host state, chat history, model memory, tool availability, or lifecycle
interaction receipts authoritative.

The existing incoming intake envelope validator remains the first gate. Route
classification starts only after
`validate-incoming-intake-unit.sh --intake-id <intake-id>` succeeds. A malformed
or unsafe raw intake envelope is blocked before route classification.

## Mature Route Set

Governed Incoming Intake Routing has exactly four route decisions.

| Route | Meaning |
| --- | --- |
| `single-work-unit-handoff` | Target-owned proposal packet admission for straightforward extension packs, core skills, or coherent single-surface additions. |
| `coordinated-program-handoff` | Target-owned proposal program admission for multi-surface, staged, dependent, migration, cutover, or governance-plus-runtime additions. |
| `target-owned-direct-handoff` | Reserved for future non-proposal targets with explicit target-owned intake admission contracts; disabled until such a contract exists. |
| `blocked-rejected-deferred` | Malformed, unsafe, ambiguous, unsupported, unverifiable, low-value, deferred, or authority-confused intake. |

Direct additive extension and core-skill installation from raw intake is a
legacy disposition model. Mature governed intake routes extension packs, core
skills, and other core surfaces through proposal packet or proposal program
admission by default. Any future non-proposal direct handoff must declare and
validate a target-owned intake admission contract before dispatch can be
enabled.

## Route Criteria

Use `single-work-unit-handoff` only when all of these are true:

- the intake envelope passed validation
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
denied because no non-proposal target-owned intake admission contract exists.

Use `blocked-rejected-deferred` when any of these are true:

- the intake envelope is malformed or fails containment validation
- provenance or licensing is unsafe or unverifiable
- source material contains secrets, private data, proprietary material, opaque
  binaries, or unsafe executable content
- route classification is ambiguous
- a requested route disagrees with deterministic classification
- target return evidence is missing, stale, or digest-mismatched
- scope digests drift between classification and handoff
- the target surface is unsupported
- parent program evidence is offered as a child packet receipt
- lifecycle interaction receipts are treated as authorization
- the intake claims authority to install, promote, mutate Git, close Changes,
  clean worktrees, delete hygiene residue, archive source material, widen
  scope, or authorize downstream lifecycle action
- a direct target handoff is requested without a target-owned intake admission
  contract

## Target-Owned Admission

The intake workflow may package advisory context and request target admission.
The selected target owns validation, authority, mutation, receipts, rollback or
correction, completion claims, and return evidence.

Target-owned contracts:

- `governed-incoming-intake-route-decision-v1` records selected route, rejected
  routes, classification facts, envelope and inventory digests, denial evidence,
  authority boundaries, and replay posture.
- `governed-incoming-intake-handoff-v1` records advisory target context, source
  intake digest, decision digest, scope digest, forbidden authority transfers,
  expected target return evidence, and duplicate-target prevention.
- `target-owned-intake-admission-contract-v1` declares which target lifecycle
  can receive a handoff route, what preflight validators and receipts are
  required, and which target-owned boundaries are enforced.

Proposal-owned admission contracts currently live under the
`octon-proposal-lifecycle` extension context:

- `proposal-packet-intake-admission` accepts `single-work-unit-handoff`
  context and owns packet creation through the proposal packet lifecycle.
- `proposal-program-intake-admission` accepts `coordinated-program-handoff`
  context and owns parent program creation, child registry planning, and child
  receipt isolation through the proposal program lifecycle.

## Lifecycle Ownership

Intake routing owns:

- explicit intake binding
- envelope validation invocation
- deterministic classification
- route decision receipt
- denial evidence
- advisory handoff packaging
- target invocation bookkeeping
- target return references

Proposal packet lifecycle owns packet creation, review/revision,
implementation readiness, implementation prompt/run, verification/correction,
proposal closeout, archive, and packet-local receipts.

Proposal program lifecycle owns parent program creation, child registry, child
packet planning, dependency ordering, program checkpoints, program evidence,
and child receipt isolation.

Governed Lifecycle Orchestration owns lifecycle planning, gating, dispatch
through lifecycle contracts, checkpoints, resume, return observation, and
fail-closed lifecycle state.

`closeout-change`, `closeout-worktree`, and `repo-hygiene-cleanup` own their
respective closeout/cleanup validation, authority, mutation, receipts, and
returns. Proposal lifecycle handoff receipts are advisory context only.

Intake routing must never claim target completion unless target-owned return
evidence is present, fresh, digest-bound, and within scope.

## Handoff Boundaries

Handoff context must forbid authorization transfer for:

- Git mutation
- hosted provider action
- branch cleanup
- worktree cleanup
- repo hygiene deletion
- promotion
- archive
- scope expansion

Lifecycle interaction receipts are advisory context only and never authorize
target action. Parent proposal-program evidence never satisfies child packet
receipts.

## Evidence And Replay

Each routing run must retain:

- explicit intake id and path
- intake validator output
- meaningful payload inventory and excluded noise
- intake envelope digest
- payload inventory digest
- classification facts
- selected route or denial
- rejected routes and rationale
- denial evidence
- handoff scope digest when handoff context is created
- target admission request and target-owned preflight result when invoked
- target return references when a target lifecycle returns evidence

Reclassification is idempotent: the same explicit intake plus the same
authoritative state and payload digest must produce the same route decision.
Re-running after target creation must resume or reference the existing
digest-compatible target-owned run; it must not create duplicate proposal
packets or programs.

## Modes

`/process-incoming-intake <intake-id>` supports these mature modes:

- default: validate, classify, create target-owned handoff context, and stop if
  target dispatch is unavailable
- `--stop-after-classification`: write the decision receipt only
- `--execute-handoff`: invoke only target-owned admission/GLO routes whose
  contracts validate
- `--requested-route <route>`: advisory hint only; fail closed if deterministic
  classification disagrees

Autonomous dispatch remains disabled until target contracts, receipts, rollback
posture, and negative fixtures prove it safe.

## Fixture Matrix

The authoritative fixture expectations for validators live in
`governed-incoming-intake-routing-fixtures.yml`.

The fixture matrix must cover positive packet/program handoff decisions and
negative cases for invalid envelopes, ambiguous packet/program routing, unsafe
provenance or licensing, secrets/private data, malicious authority confusion,
direct target handoff without a contract, stale target return evidence, parent
program evidence used for child packet receipts, lifecycle interaction receipts
used as authorization, requested-route mismatch, and scope digest drift.

## Fail-Closed Rules

The validator must fail closed when:

- the incoming envelope validator fails
- the fixture route set differs from the four-route model
- `target-owned-direct-handoff` is enabled without a target-owned intake
  admission contract
- a fixture selects more than one route or selects an unknown route
- a non-blocked route omits rejected route evidence
- blocked routes omit denial evidence
- a required route decision, handoff, admission, or target return schema is
  missing or invalid
- proposal packet/program admission contracts are missing, disabled, or
  authority-confused
- handoff context attempts to authorize Git, branch cleanup, hosted provider
  action, worktree cleanup, repo hygiene deletion, promotion, archive, or scope
  expansion
- parent proposal-program evidence is allowed to satisfy child packet receipts
- raw intake, generated output, host state, chat history, model memory, tool
  availability, or lifecycle interaction receipts are treated as authority

