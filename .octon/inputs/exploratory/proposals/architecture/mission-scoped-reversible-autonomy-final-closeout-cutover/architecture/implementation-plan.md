# Implementation Plan

## Delivery posture

This plan is a **big-bang, clean-break, atomic cutover**.
There is one branch, one merge, one release target, and one live post-merge model.
Workstreams A through H implement the remediation list from the [implementation audit](../resources/implementation-audit.md), normalized by the [final remediation ledger](../resources/final-remediation-ledger.md).

## Atomic delivery rules

1. No dual-write, shadow lifecycle, or compatibility window remains after merge.
2. No mission may continue using a legacy activation or routing path after merge.
3. No validator, workflow, or generated-view allowlist may exempt MSRAOM-governed surfaces from the full closeout suite.
4. No follow-on “cleanup” packet is assumed; any known missing behavior blocks merge.
5. Any migration required for in-tree missions lands in the same change as the runtime and validation cutover.
6. If the branch cannot satisfy the full proof set, it does not merge.

## Execution model

The branch should be executed in eight ordered phases.
Implementation can happen in parallel inside the branch, but integration must follow this dependency order:

| Phase | Outcome | Primary surfaces | Depends on |
|---|---|---|---|
| 0 | Scope lock and baseline inventory | proposal packet, mission inventory, validator inventory | none |
| 1 | Authored contract alignment | root manifest, architecture docs, policy, contract registry, mission scaffold | 0 |
| 2 | Lifecycle seeding and activation cutover | mission seeding, activation path, continuity creation, lifecycle validator | 1 |
| 3 | Intent admission and route normalization | evaluator, kernel, policy engine, route publisher, runtime effective state | 2 |
| 4 | Interaction grammar and control evidence | directive/update writers, schedule handling, receipt writer, finalize handling | 3 |
| 5 | Burn, breaker, safing, and break-glass reducer loop | recompute reducer, mode overlays, control receipts, runtime consumers | 4 |
| 6 | Generated awareness generalization | artifact sync, summaries, operator digests, mission view | 3, 4, 5 |
| 7 | Assurance, fixtures, and blocking CI | validators, scenario suite, architecture-conformance workflow | 1, 2, 3, 4, 5, 6 |
| 8 | Migration, documentation, release evidence, and archival | docs, migration evidence, decision record, packet archival | 2, 3, 4, 5, 6, 7 |

## Phase 0 — Scope lock and baseline inventory

### Goal
Establish the exact cutover surface and prove what must change in the same merge.

### Actions
1. Inventory every active or paused in-tree mission and record whether it is already seed-complete.
2. Inventory the current activation path, route publisher, reducer path, summary generators, and blocking workflow jobs.
3. Freeze the no-change zones from [change-map.md](../navigation/change-map.md):
   - ACP conceptual backbone
   - execution grant/receipt fundamental shape
   - `STAGE_ONLY` semantics
   - generated-vs-authoritative class separation
   - mission public-facing naming
4. Enumerate the committed fixtures and identify any missing scenario families required by the closeout suite.
5. Record the single target release as `0.6.3` and reject any partial release framing.

### Outputs
- active-mission inventory
- fixture coverage inventory
- validator inventory
- release target lock

### Exit gate
The branch has a closed list of active missions, fixtures, validators, and docs that must be touched before merge.

## Phase 1 — Authored contract alignment

### Goal
Make the repo’s durable authority surfaces describe the final model before runtime wiring begins.

### Actions
1. Update `.octon/octon.yml` so the root manifest, generated commit policy, and release version agree with the cutover.
2. Update `.octon/README.md`, `.octon/instance/bootstrap/START.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, and `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` so they all describe:
   - seed-before-active
   - one control/evidence/read-model split
   - one generated effective route
   - one generated awareness model
3. Update `.octon/framework/cognition/_meta/architecture/contract-registry.yml` so all required schemas are registered and normalized:
   - `authorize-update-v1`
   - `mission-view-v1`
   - `intent-register-v1`
   - `action-slice-v1`
   - `mode-state-v1`
   - `schedule-control-v1`
   - `mission-control-lease-v1`
   - `autonomy-budget-v1`
   - `circuit-breaker-v1`
4. Normalize `.octon/instance/governance/policies/mission-autonomy.yml` around:
   - mission-class defaults
   - effective scenario families
   - safe-boundary taxonomy
   - tightening-only overlays
5. Confirm `.octon/instance/governance/ownership/registry.yml` remains the sole ownership precedence surface for control mutations and digest routing.
6. Keep `.octon/instance/orchestration/missions/_scaffold/template/mission.yml` authority-only, with canonical `owner_ref` usage and no control-state authoring.

### Exit gate
All durable docs, policy, and registry surfaces describe the same final model and no authoritative surface claims scaffold-owned control truth.

## Phase 2 — Lifecycle seeding and activation cutover

### Goal
Make seed-before-active the only legal path into active or paused autonomy.

### Actions
1. Harden `.octon/framework/orchestration/runtime/_ops/scripts/seed-mission-autonomy-state.sh` into the canonical idempotent seeding path.
2. Require the seeding path to create, or verify and repair, the full mission-control family under `state/control/execution/missions/<mission-id>/`:
   - `lease.yml`
   - `mode-state.yml`
   - `intent-register.yml`
   - `action-slices/`
   - `directives.yml`
   - `authorize-updates.yml`
   - `schedule.yml`
   - `autonomy-budget.yml`
   - `circuit-breakers.yml`
   - `subscriptions.yml`
3. Require the seeding path to create continuity stubs under `state/continuity/repo/missions/<mission-id>/`.
4. Require the seeding path to trigger or guarantee:
   - route publication
   - summary generation
   - operator digest generation
   - mission-view generation
   - mission-seed control receipt emission
5. Update the mission activation path so a mission cannot become active or paused until the seeding path completes successfully.
6. Add migration logic for any in-tree active or paused mission that is not yet seed-complete.
7. Fail activation if control-state creation would violate source-of-truth boundaries or leave an incomplete family.

### Primary files
- `.octon/framework/orchestration/runtime/_ops/scripts/seed-mission-autonomy-state.sh`
- `.octon/framework/orchestration/runtime/_ops/scripts/activate-mission-*.sh` or equivalent mission activation path
- `.octon/state/control/execution/missions/**`
- `.octon/state/continuity/repo/missions/**`

### Exit gate
No active or paused autonomous mission can exist without a seed receipt, a complete control family, continuity stubs, and generated route/read models.

## Phase 3 — Intent admission and route normalization

### Goal
Make the generated route plus slice-linked intent the single runtime admission model for material autonomous work.

### Actions
1. Tighten `.octon/framework/orchestration/runtime/_ops/scripts/evaluate-mission-control-state.sh` so material work requires:
   - active lease or explicit break-glass authority
   - current mode state
   - fresh linked route
   - fresh intent register
   - current intent entry
   - current slice reference
   - derivable recovery semantics
2. Update `.octon/framework/engine/runtime/crates/kernel/**` and `.octon/framework/engine/runtime/crates/policy_engine/**` so runtime admission, preview, proceed-on-silence, promote eligibility, and recovery derivation all consume the same current intent entry and action slice.
3. Update `.octon/framework/orchestration/runtime/_ops/scripts/publish-mission-effective-route.sh` so the route records:
   - `mission_class`
   - `effective_scenario_family`
   - `effective_action_class`
   - `scenario_family_source`
   - `boundary_source`
   - `recovery_source`
   - `tightening_overlays`
4. Normalize route precedence exactly as declared in the proposal:
   - mission class default
   - effective scenario family
   - current intent entry
   - current action slice specificity
   - directive / breaker / safing / break-glass tightening overlays
5. Remove any legal path where material autonomy falls back to generic `service.execute` behavior.
6. Require `mode-state.effective_scenario_resolution_ref` for active or paused autonomous missions.

### Exit gate
Material autonomous work is impossible without current slice-linked intent and a fresh provenance-rich route.

## Phase 4 — Interaction grammar and control-evidence completion

### Goal
Make `Inspect / Signal / Authorize-Update` operationally complete, precedence-governed, and receipted.

### Actions
1. Ensure runtime handlers exist for all declared signal types:
   - `pause_at_boundary`
   - `suspend_future_runs`
   - `resume_future_runs`
   - `reprioritize`
   - `narrow_scope`
   - `exclude_target`
   - `block_finalize`
   - `unblock_finalize`
   - `enter_safing`
2. Ensure runtime handlers exist for all declared authorize-update types:
   - `approve`
   - `extend_lease`
   - `revoke_lease`
   - `raise_budget`
   - `grant_exception`
   - `reset_breaker`
   - `enter_break_glass`
   - `exit_break_glass`
3. Keep schedule mutations distinct from directives and authorize-updates.
4. Make finalize handling consume:
   - recovery-window state
   - route finalize policy
   - `block_finalize` directives
   - authorize-updates
   - breaker and safing overlays
5. Emit control receipts for every control mutation and application event, not just for steady-state snapshots.
6. Keep run evidence and control evidence separate, with summaries reading from canonical truth plus receipts rather than inventing state.

### Primary files
- `.octon/framework/orchestration/runtime/_ops/scripts/record-mission-directive.sh`
- `.octon/framework/orchestration/runtime/_ops/scripts/record-mission-authorize-update.sh`
- `.octon/framework/orchestration/runtime/_ops/scripts/write-mission-control-receipt.sh`
- `.octon/framework/orchestration/runtime/_ops/scripts/evaluate-mission-control-state.sh`

### Exit gate
Every supported control mutation updates canonical truth, emits a control receipt, and has one precedence-governed runtime effect.

## Phase 5 — Burn, breaker, safing, and break-glass reducer loop

### Goal
Turn trust tightening into one retained-evidence-driven reducer loop shared by runtime, routing, and summaries.

### Actions
1. Harden `.octon/framework/orchestration/runtime/_ops/scripts/recompute-mission-autonomy-state.sh` so it consumes:
   - run receipts
   - rollback events
   - compensation events
   - repeated denials
   - repeated retries
   - control-surface corruption events
   - out-of-blast-radius side effects
   - missing observability on risky work
   - breaker trip triggers
   - explicit breaker resets
   - safing and break-glass state
2. Recompute and persist canonical outputs in:
   - `autonomy-budget.yml`
   - `circuit-breakers.yml`
   - `mode-state.yml` overlays where needed
3. Emit receipts for burn transitions, breaker trips/resets, safing entry/exit, and break-glass entry/exit.
4. Require route publisher, evaluator, scheduler, summaries, and digests to consume the same recomputed state.
5. Keep policy responsible only for thresholds and actions, not hand-maintained live breaker state.

### Exit gate
Burn and breaker state become evidence-derived operational truth rather than static configuration.

## Phase 6 — Generated awareness and mission-view generalization

### Goal
Make generated awareness universal for every active autonomous mission and keep it visibly non-authoritative.

### Actions
1. Update `.octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh` so every active autonomous mission triggers the full read-model sync.
2. Require `.octon/framework/cognition/_ops/runtime/scripts/generate-mission-summaries.sh` to emit:
   - `now.md`
   - `next.md`
   - `recent.md`
   - `recover.md`
3. Require `.octon/framework/cognition/_ops/runtime/scripts/generate-operator-digests.sh` to route digests by subscriptions plus ownership precedence.
4. Require `.octon/framework/cognition/_ops/runtime/scripts/generate-mission-view.sh` to materialize `mission-view.yml` for every active autonomous mission.
5. Ensure every generated output cites its source roots:
   - mission charter
   - mode state
   - intent register
   - current slice
   - route
   - continuity
   - relevant receipts
6. Follow the root manifest’s commit/rebuild policy for every generated surface; no generated output silently escapes the manifest contract.

### Exit gate
Generated awareness exists for every active autonomous mission and is transparently derived from canonical inputs.

## Phase 7 — Assurance, fixtures, and blocking CI

### Goal
Make the cutover self-proving and impossible to merge without the full evidence set.

### Actions
1. Add or harden the full validator set:
   - `validate-version-parity.sh`
   - `validate-architecture-conformance.sh`
   - `alignment-check.sh`
   - `validate-mission-lifecycle-cutover.sh`
   - `validate-mission-runtime-contracts.sh`
   - `validate-mission-source-of-truth.sh`
   - `validate-mission-intent-invariants.sh`
   - `validate-route-normalization.sh`
   - `validate-runtime-effective-state.sh`
   - `validate-mission-generated-summaries.sh`
   - `validate-mission-view-generation.sh`
   - `validate-mission-control-evidence.sh`
   - `test-mission-autonomy-scenarios.sh`
   - `test-mission-lifecycle-activation.sh`
   - `test-autonomy-burn-reducer.sh`
2. Extend fixtures so the scenario suite proves at least:
   - routine housekeeping
   - long-running campaign/refactor
   - dependency/security patching
   - release-sensitive work
   - infrastructure drift correction
   - migration/backfill
   - external sync
   - observe-only monitoring
   - incident containment
   - destructive work
   - absent human
   - late feedback
   - conflicting human input
   - breaker trip and safing
   - break-glass activation
   - reversible vs compensable vs irreversible work
3. Update `.github/workflows/architecture-conformance.yml` so the full MSRAOM suite is blocking.
4. Remove any allowlist or workflow pattern that would let lifecycle, route, evidence, or generated-view checks be skipped for MSRAOM-touching changes.

### Exit gate
The branch is only mergeable when the full validator and scenario suite passes locally and in CI.

## Phase 8 — Migration, documentation, release evidence, and archival

### Goal
Finish the clear-break cutover by migrating repo state, writing the evidence trail, and closing prior packets.

### Actions
1. Migrate every in-tree active or paused mission to the final seed-complete shape in the same branch.
2. Regenerate all required routes, summaries, digests, and mission views after the runtime changes settle.
3. Update canonical docs so they describe only behavior the branch now proves.
4. Write migration evidence under `.octon/instance/cognition/context/shared/migrations/**`.
5. Write the completion decision under `.octon/instance/cognition/decisions/**`.
6. Archive the prior `mission-scoped-reversible-autonomy-steady-state-cutover` packet after promotion.
7. Archive this packet after promotion.
8. Cut and ratify `0.6.3` as the MSRAOM closeout release.

### Exit gate
The repo contains migration evidence, decision evidence, updated docs, regenerated artifacts, and no live references to the superseded steady-state packet.

## Parallelization inside the branch

The cutover is atomic, but implementation can be split into disjoint ownership slices:

| Slice | Ownership | Primary files |
|---|---|---|
| Contract and docs | architecture, policy, scaffold, registry, README | `.octon/octon.yml`, `.octon/README.md`, bootstrap/spec/policy/registry docs |
| Mission lifecycle | seeding, activation, continuity, migration | orchestration runtime scripts, mission control state, continuity state |
| Runtime admission and routing | evaluator, kernel, policy engine, route publisher | orchestration scripts, engine crates, effective route outputs |
| Control evidence and reducer | directive/update writers, receipt writer, autonomy reducer | orchestration scripts, control evidence surfaces |
| Generated awareness | sync scripts, summaries, digests, mission view | cognition runtime scripts, generated cognition outputs |
| Assurance and CI | validators, scenarios, workflow wiring | assurance scripts, fixtures, `.github/workflows/architecture-conformance.yml` |

These slices may be implemented in parallel, but final integration must respect the phase order above.

## Atomic readiness gates

The branch is ready to merge only when all of the following are true at the same time:

1. Durable docs, policy, and contract registries match the final runtime model.
2. Seed-before-active is the only legal activation path.
3. Material autonomous work requires current slice-linked intent and a fresh route.
4. Route provenance and precedence are explicit and validated.
5. Every supported control mutation emits a control receipt.
6. Burn and breaker state are recomputed from retained evidence.
7. Every active autonomous mission gets summaries, digests, and a mission view.
8. The full validator and scenario suite is blocking and green.
9. Active mission migrations, migration evidence, and the completion decision are present.
10. No acceptance criterion in `acceptance-criteria.md` remains unmet.

## Abort rule

If any readiness gate fails, the cutover is not partially shipped.
The branch continues until the gate is green, or the entire closeout attempt is abandoned and re-planned as a different proposal.
