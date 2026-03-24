# Implementation Plan

This proposal is implemented as one pre-1.0, atomic cutover.
The workstreams below may be developed in parallel on one branch, but they
must merge together and become the only live operating model in the same
change set.

The durable execution record for this cutover must be created at:

`/.octon/instance/cognition/context/shared/migrations/<YYYY-MM-DD>-mission-scoped-reversible-autonomy-cutover/plan.md`

The retained cutover evidence bundle must land under:

`/.octon/state/evidence/migration/<YYYY-MM-DD>-mission-scoped-reversible-autonomy-cutover/`

This proposal-local plan is paired with `architecture/validation-plan.md` and
`architecture/cutover-checklist.md` so the package remains implementation-grade
until promotion and archive.

## Profile Selection Receipt

- Date: 2026-03-23
- Version source(s): `/.octon/octon.yml`
- Current version: `0.5.5`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - downtime tolerance: one-step cutover is acceptable because this is an
    internal harness operating-model change rather than an external service
    migration
  - external consumer coordination ability: not required; affected surfaces
    are repo-local docs, contracts, runtime code, state, evidence, and
    generated summaries
  - data migration/backfill needs: active mission migration is expected to be
    light because the current registry is empty, but the branch must still be
    able to migrate any active mission that appears before cutover
  - rollback mechanism: full revert of the cutover change set
  - blast radius and uncertainty: high; mission authority, runtime contracts,
    control truth, retained evidence, generated views, workflows, validators,
    and docs all change together
  - compliance/policy constraints: no dual live operating model, no shadow
    control plane, no mission-less autonomous execution, and no rewrite of
    historical receipts
- Hard-gate outcomes:
  - no zero-downtime requirement
  - no staged coexistence requirement
  - no historical receipt rewrite requirement
- Tie-break status: `atomic` selected without exception

## Cutover Strategy

### Atomic release rule

Ship the operating model as the next harness minor release after `0.5.5`
(`0.6.0` is recommended) and update the root manifest, docs, runtime
contracts, control-state surfaces, evidence surfaces, and generated read
models together.

### No-dual-mode rule

After merge:

- all new autonomous runs must provide mission autonomy context
- all mission-authority readers and writers must use the v2 mission charter
- all generated operator views must source from the new control and evidence
  surfaces
- any remaining legacy autonomous path must fail closed

Historical retained evidence and archived missions are not rewritten.
The clean break applies to live runtime behavior and active mission artifacts.

## Workstream 1: Root Manifest And Architecture Contract Cutover

### Required changes

- Bump `octon.yml#versioning.harness.release_version` to the cutover release.
- Add runtime-input bindings for:
  - missions registry
  - mission control root
  - ownership registry
  - mission-autonomy repo policy
- Update the umbrella architecture specification to:
  - declare mission-scoped control truth under
    `state/control/execution/missions/**`
  - declare control-plane evidence under `state/evidence/control/**`
  - declare generated mission/operator summaries under
    `generated/cognition/summaries/missions/**` and
    `generated/cognition/summaries/operators/**`
- Update the runtime-vs-ops contract so any mission-control helper automation
  is limited to canonical state and generated roots only.
- Update the machine-readable contract registry with all new schemas and
  receipt contracts.
- Add or update the canonical governance principle text so
  Mission-Scoped Reversible Autonomy becomes the normative operating-model
  reference and supervisory-control language is integrated into it.

### Why this lands first in the branch

The rest of the implementation depends on stable canonical paths and contract
names.
Without these updates, runtime and UI work would risk creating shadow surfaces
or undocumented assumptions.

## Workstream 2: Mission Authority Upgrade

### Required changes

- Upgrade `instance/orchestration/missions/registry.yml` to
  `octon-mission-registry-v2`.
- Upgrade `_scaffold/template/mission.yml` to `octon-mission-v2`.
- Update `_scaffold/template/mission.md` to explain mission class, scope,
  risk ceiling, allowed action classes, safe subset, and schedule intent.
- Keep `tasks.json` and `log.md` as mission-local planning aids, but do not
  treat them as runtime control truth.
- Create `instance/governance/policies/mission-autonomy.yml`.
- Create `instance/governance/ownership/registry.yml`.

### Migration rule for existing mission artifacts

- rewrite every active mission `mission.yml` to v2 in the same branch
- if a mission is only historical and already archived, it may remain in its
  original archived form until reactivated
- because the current active registry is effectively empty, this migration is
  low-risk and should be done in place rather than through a compatibility shim

### Required mission-autonomy policy defaults

`mission-autonomy.yml` must define:

- mission-class default modes and postures
- preview timing defaults
- digest cadence defaults
- overlap/backfill defaults
- pause-on-failure defaults
- recovery-window defaults
- autonomy burn thresholds
- breaker actions
- safe interrupt boundary defaults
- quorum rules by ACP
- proceed-on-silence allowlist constraints
- safing subset defaults

## Workstream 3: Runtime And Policy Contract Upgrade

### Required changes

Create or upgrade runtime specs so autonomous runs carry complete mission
context.

#### New or upgraded schema/spec files

- `mission-charter-v2.schema.json`
- `mission-autonomy-policy-v1.schema.json`
- `ownership-registry-v1.schema.json`
- `mission-control-lease-v1.schema.json`
- `action-slice-v1.schema.json`
- `intent-register-v1.schema.json`
- `mode-state-v1.schema.json`
- `control-directive-v1.schema.json`
- `schedule-control-v1.schema.json`
- `autonomy-budget-v1.schema.json`
- `circuit-breaker-v1.schema.json`
- `execution-request-v2.schema.json`
- `execution-receipt-v2.schema.json`
- `policy-receipt-v2.schema.json`
- `policy-digest-v2.md`
- `control-receipt-v1.schema.json`

#### Required autonomous execution-request additions

Autonomous runs must provide, directly or under `autonomy_context`:

- `mission_ref`
- `slice_ref`
- `intent_ref`
- `oversight_mode`
- `execution_posture`
- `reversibility_class`
- `boundary_id`
- `mission_class`

Autonomous runtime or policy evaluation must deny when this context is missing.

#### Required autonomous receipt additions

Receipts for new runs must include:

- `mission_ref`
- `slice_ref`
- `oversight_mode`
- `execution_posture`
- `reversibility_class`
- `boundary_id`
- `rollback_handle` or `compensation_handle`
- `recovery_window`
- `autonomy_budget_state`
- `breaker_state`
- `applied_directive_refs`
- `applied_authorize_update_refs`

### Runtime code work

Update runtime crates so:

- the kernel binds every autonomous run to mission and slice context
- policy launchers evaluate mission-autonomy defaults and current mission
  control truth
- receipt emission is mandatory for both execution and material control-plane
  mutations
- no material autonomous execution path may proceed without the v2 contract
- rollback/finalize state is surfaced into receipts and generated summaries

## Workstream 4: Mutable Control Truth And Control Evidence

### Required control surface creation

Create mission-scoped control directories under:

- `state/control/execution/missions/<mission-id>/lease.yml`
- `.../mode-state.yml`
- `.../intent-register.yml`
- `.../directives.yml`
- `.../schedule.yml`
- `.../autonomy-budget.yml`
- `.../circuit-breakers.yml`
- `.../subscriptions.yml`

Retain existing global state:

- `state/control/execution/budget-state.yml`
- `state/control/execution/exception-leases.yml`

### Required control evidence creation

Create retained evidence under:

- `state/evidence/control/execution/**`

Minimum receipted control-plane events:

- directive write that affects active execution or durable outcome
- authorize-update
- continuation lease create/update/revoke
- breaker trip/reset
- entry into or exit from safing
- break-glass activation/deactivation

### Continuity integration

Create mission continuity directories under:

- `state/continuity/repo/missions/<mission-id>/`

Minimum continuity artifacts:

- `next-actions.yml`
- `handoff.md`

Do not place mutable continuity or handoff state in mission authority files,
generated digests, or run receipts.

## Workstream 5: Supervisory Workflows And Generated Read Models

### Required runtime/orchestration workflows

Add or update workflows so the harness can:

- evaluate mission mode and schedule before opening a material slice
- publish preview notices and feedback windows from the intent register
- respect safe interrupt boundaries
- emit Now / Next / Recent / Recover read models
- compute autonomy burn and breaker state
- enter safing deterministically
- perform rollback or compensation actions from recovery handles
- block finalize when a directive or breaker requires it

### Required generated outputs

Generate mission views:

- `now.md`
- `next.md`
- `recent.md`
- `recover.md`

Generate operator digests by routing rules in `subscriptions.yml`,
mission ownership, and the ownership registry.

### No-second-journal rule

`recent.md` and operator digests must be projections over:

- `state/evidence/runs/**`
- `state/evidence/control/**`
- `state/continuity/repo/missions/**`

No additional authoritative activity ledger may be added.

## Workstream 6: Assurance, Conformance, And Scenario Tests

### Required assurance additions

Add conformance tests and validators for:

- mission charter v2 schema
- mission-autonomy policy schema
- ownership registry schema
- all new mission control-state schemas
- execution request v2 and receipt v2
- control receipt v1
- generated summary freshness and completeness
- source-of-truth enforcement and no-shadow-surface checks
- pause semantics, overlap behavior, and backfill behavior
- breaker and safing transitions
- the dedicated mission-autonomy alignment profile or equivalent aggregate gate

### Required scenario conformance suite

The harness must have automated or semi-automated conformance coverage for at
least these scenarios:

| Scenario | Expected mode/result |
| --- | --- |
| routine repo housekeeping | silent or notify, reversible receipt, no blocking |
| long-running refactor | notify at mission open, interruptible scheduled posture, boundary pause |
| scheduled dependency patching | feedback window or proceed-on-silence with rollback |
| release maintenance | stage allowed; publish boundary approval required |
| infra drift correction | feedback window, boundary-aware pause, attestation-aware promote |
| cost cleanup / soft delete | proceed-on-silence for soft step, separate finalize |
| data migration / backfill | checkpoint boundaries, rollback before contract/finalize |
| external API sync | notify or feedback window, compensable recovery |
| monitoring / guard agent | silent continuous observe mission, alert on anomaly |
| production incident response | bounded proceed-on-silence for emergency containment only |
| high-volume low-risk repetitive work | campaign-level digest, not per-item alerts |
| destructive high-impact work | approval required, no proceed-on-silence |

Additional conformance tests must cover:

- absent operator on proceed-on-silence
- late feedback inside and outside recovery window
- conflicting human input
- rollback path failure
- breaker trip and safing entry
- break-glass activation

## Workstream 7: Cutover Execution And Cleanup

### Cutover steps

1. Write the durable migration plan for the cutover.
2. Land schema, policy, and doc updates.
3. Upgrade mission scaffolds and active mission artifacts to v2.
4. Create empty or seeded mission control directories for active missions.
5. Update runtime and policy code to require the new autonomy context.
6. Add generated view builders and routing logic.
7. Add assurance and scenario tests.
8. Regenerate generated cognition outputs.
9. Write the retained cutover evidence bundle and ADR.
10. Update bootstrap and README guidance.
11. Merge the branch atomically.
12. Reject any remaining legacy autonomous invocation path after merge.

### Explicit cleanup tasks

- remove or dead-code any legacy autonomous runtime path that bypasses mission
  control
- remove any draft or experimental operator view that sources from anything
  other than canonical control/evidence surfaces
- archive any superseded proposal-local notes once promotion lands
- update the proposals registry entry for this proposal
- create a migration bundle and ADR or decision entry noting that the operating
  model became canonical at cutover release

## Practical Solutions To The Remaining Open Questions

This proposal already resolves the previously open questions architecturally.
Implementation must therefore treat the following as settled, not optional:

- use `lease.yml` for mission continuation rather than inventing ad hoc
  "keep going" state
- use `instance/governance/ownership/registry.yml` plus mission owner plus
  `CODEOWNERS` precedence instead of relying on comments or social convention
- encode digest cadence defaults in `mission-autonomy.yml`
- encode safe interrupt boundary classes in `action-slice-v1` and require every
  material slice to pick one
- enforce quorum independence by policy dimensions, not by same-model repeats
- encode recovery-window defaults in `mission-autonomy.yml`
- keep repo-native surfaces canonical and treat external UIs as adapters only

## Rollback And Failure Plan For The Cutover Itself

Because this is a big-bang architectural cutover, implementation must include a
branch-level rollback plan:

- retain historical receipts untouched
- keep cutover changes isolated in one branch until assurance passes
- if cutover validation fails before merge, abandon the branch rather than
  merging partial runtime, partial docs, or partial control surfaces
- if an issue is discovered immediately after merge, revert the entire cutover
  commit series together; do not try to keep a half-new, half-old operating
  model live
