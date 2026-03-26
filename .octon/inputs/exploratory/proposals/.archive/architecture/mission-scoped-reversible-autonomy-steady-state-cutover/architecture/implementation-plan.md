# Implementation Plan

This packet should land as one big-bang, clear-break, atomic promotion.
The repo already contains a partial MSRAOM implementation, which means the job
is not invention but closure: align every authored authority surface, mutable
mission-control surface, runtime consumer, generated view, validator, CI gate,
and retained evidence path to one steady-state model in one branch.

Keeping the old partial model alive alongside the completed model would preserve
exactly the contradictions this packet exists to remove: scaffold/runtime drift,
nullable route linkage, generic recovery fallback, thin evidence coverage,
projection-format mismatch, and CI blind spots.

The authoritative execution record for this cutover belongs in:

`/.octon/instance/cognition/context/shared/migrations/mission-scoped-reversible-autonomy-steady-state-cutover/plan.md`

This proposal-local plan mirrors that final implementation blueprint so the
package remains self-contained until promotion.

## Profile Selection Receipt

- Date: `2026-03-24`
- Version source(s): `version.txt`, `/.octon/octon.yml`
- Current intended baseline: `0.6.0`
- Current ratification defect: `version.txt` and `/.octon/octon.yml` do not yet
  agree
- Target release: `0.6.1`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - affected surfaces are repo-local architecture, runtime, generated, and CI
    control-plane paths
  - there is no external compatibility promise that requires a staged dual model
  - historical evidence must be preserved, but no historical evidence needs to
    be rewritten
  - the correct rollback is full branch revert, not long-lived coexistence
  - the blast radius is high enough that every runtime, doc, and validator
    consumer must be switched together
- Hard-gate outcomes:
  - no zero-downtime coexistence requirement
  - no tolerated split between old and new mission-control families
  - no tolerated split between old and new mission-view formats
  - no deferred advisory-only validator stage

## Repo-Grounded Starting Point

The current repo state already proves where the implementation has to land:

- `/.octon/instance/orchestration/missions/_scaffold/template/` still creates
  only `mission.yml`, `mission.md`, `tasks.json`, and `log.md`
- `seed-mission-autonomy-state.sh` creates `lease.yml`, `mode-state.yml`,
  `intent-register.yml`, `directives.yml`, `schedule.yml`,
  `autonomy-budget.yml`, `circuit-breakers.yml`, and `subscriptions.yml`, but
  not `authorize-updates.yml` or `action-slices/`
- the live mission
  `/.octon/state/control/execution/missions/mission-autonomy-live-validation/`
  still has `mode-state.effective_scenario_resolution_ref: null`
- `publish-mission-effective-route.sh` still emits
  `effective.scenario_family` and falls back to `service.execute` when intent
  state is empty
- the generated projection is still
  `/.octon/generated/cognition/projections/materialized/missions/<mission-id>.json`
  rather than the packet's final `mission-view.yml`
- the assurance surface already contains
  `validate-mission-control-state.sh`,
  `validate-mission-effective-routes.sh`,
  `validate-mission-generated-summaries.sh`,
  `validate-mission-control-evidence.sh`,
  `validate-mission-runtime-contracts.sh`,
  `validate-mission-source-of-truth.sh`, and
  `test-mission-autonomy-scenarios.sh`, so the cutover must converge these
  existing validators instead of inventing a second parallel validator family

## Atomic Execution Model

- There is one live mission-control family after merge:
  `lease.yml`, `mode-state.yml`, `intent-register.yml`, `action-slices/`,
  `directives.yml`, `authorize-updates.yml`, `schedule.yml`,
  `autonomy-budget.yml`, `circuit-breakers.yml`, `subscriptions.yml`.
- There is one live mission projection format after merge:
  `generated/cognition/projections/materialized/missions/<mission-id>/mission-view.yml`.
- Mission creation becomes atomic through scaffold plus immediate seed, not by
  placing mutable control truth under authored scaffold roots.
- Material autonomous work must fail closed unless intent, slice, route
  freshness, and route-derived recovery semantics are all present.
- Validators and CI gates become blocking in the same branch that fixes the
  live drift; there is no advisory-first phase.
- Rollback is full cutover revert only; there is no supported long-lived mixed
  model.

## Workstream 1: Ratify Release, Manifest, And Durable Change Record

Outcome:
One release story, one root contract story, and one durable evidence trail.

Changes:

- bump `version.txt` to `0.6.1`
- bump `/.octon/octon.yml` `release_version` to `0.6.1`
- add `/.octon/framework/assurance/runtime/_ops/scripts/validate-version-parity.sh`
- wire version-parity enforcement into
  `validate-runtime-effective-state.sh` and blocking CI
- update `/.octon/README.md`,
  `/.octon/instance/bootstrap/START.md`,
  `/.octon/framework/cognition/_meta/architecture/specification.md`,
  `/.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`,
  and `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
  so they name the final mission-control family, mission-view path, validator
  set, and route semantics
- write the durable migration plan under
  `/.octon/instance/cognition/context/shared/migrations/mission-scoped-reversible-autonomy-steady-state-cutover/plan.md`
- write the durable decision record under
  `/.octon/instance/cognition/decisions/`

Primary targets:

- `version.txt`
- `/.octon/octon.yml`
- `/.octon/README.md`
- `/.octon/instance/bootstrap/START.md`
- `/.octon/framework/cognition/_meta/architecture/specification.md`
- `/.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-version-parity.sh`
- `/.octon/instance/cognition/context/shared/migrations/mission-scoped-reversible-autonomy-steady-state-cutover/plan.md`
- `/.octon/instance/cognition/decisions/`

Exit condition:
The release version, architecture docs, contract registry, and durable
evidence roots all describe the same completed model, and version parity is
validated rather than assumed.

## Workstream 2: Make Mission Creation Atomic Without Breaking SSOT Boundaries

Outcome:
`create-mission` produces a valid MSRAOM mission immediately, while authored
authority, mutable control truth, continuity, and generated outputs remain in
their correct roots.

Changes:

- keep `/.octon/instance/orchestration/missions/_scaffold/template/` limited to
  authored mission files and any authored helper content only
- extend the create-mission workflow and any calling command surface so mission
  creation immediately invokes the autonomy seed path
- extend `seed-mission-autonomy-state.sh` to create:
  `authorize-updates.yml`, `action-slices/`, continuity stubs, route output,
  summary outputs, operator digests, mission view, and seed receipt
- ensure the seed path creates directories in:
  `state/control/execution/missions/<mission-id>/`,
  `state/continuity/repo/missions/<mission-id>/`,
  `generated/effective/orchestration/missions/<mission-id>/`,
  `generated/cognition/summaries/missions/<mission-id>/`,
  `generated/cognition/summaries/operators/<operator-id>/`, and
  `generated/cognition/projections/materialized/missions/<mission-id>/`
- migrate the in-tree active mission
  `mission-autonomy-live-validation` to the final family in the same branch

Primary targets:

- `/.octon/instance/orchestration/missions/_scaffold/template/mission.yml`
- `/.octon/instance/orchestration/missions/_scaffold/template/mission.md`
- `/.octon/instance/orchestration/missions/_scaffold/template/tasks.json`
- `/.octon/instance/orchestration/missions/_scaffold/template/log.md`
- create-mission workflow/command surfaces under
  `/.octon/framework/orchestration/runtime/workflows/missions/`
- `/.octon/framework/orchestration/runtime/_ops/scripts/seed-mission-autonomy-state.sh`
- `/.octon/state/control/execution/missions/mission-autonomy-live-validation/`
- `/.octon/state/continuity/repo/missions/mission-autonomy-live-validation/`

Exit condition:
No active mission can exist after creation without the complete control family,
continuity stubs, generated route, summary set, operator digest, mission view,
and seed receipt.

## Workstream 3: Complete The Contract Family And Registry Alignment

Outcome:
Every runtime-required authored, mutable, retained, and generated artifact has
one schema, one registry entry, and one canonical path.

Changes:

- add `authorize-update-v1.schema.json`
- add `mission-view-v1.schema.json`
- tighten:
  `mission-control-lease-v1`,
  `mode-state-v1`,
  `intent-register-v1`,
  `action-slice-v1`,
  `control-directive-v1`,
  `schedule-control-v1`,
  `autonomy-budget-v1`,
  `circuit-breaker-v1`,
  `subscriptions-v1`,
  `control-receipt-v1`,
  `scenario-resolution-v1`,
  `execution-request-v2`,
  `execution-receipt-v2`,
  `policy-receipt-v2`, and
  `policy-digest-v2`
- make `mode-state.effective_scenario_resolution_ref` required for active or
  paused autonomous missions
- normalize breaker vocabulary between `mode-state.yml` and
  `circuit-breakers.yml`
- require slice-linked intent entries for material autonomous work
- define the final machine-readable projection contract as
  `mission-view.yml`, not `<mission-id>.json`
- update `policy-interface.yml`, mission registry roots, and contract-registry
  entries to match the final path and contract set

Primary targets:

- `/.octon/framework/engine/runtime/spec/`
- `/.octon/framework/engine/runtime/config/policy-interface.yml`
- `/.octon/instance/orchestration/missions/registry.yml`
- `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `/.octon/generated/cognition/projections/definitions/cognition-runtime-surface-map.yml`

Exit condition:
Schemas, runtime config, registries, and path declarations all agree on the
final file family and projection format.

## Workstream 4: Rewrite Route Generation And Mission-Control Mutation Paths

Outcome:
Control truth, effective route, and mode-state linkage never drift, and route
semantics are derived from the final control family rather than generic
fallbacks.

Changes:

- extend `publish-mission-effective-route.sh` to consume
  `authorize-updates.yml` and `action-slices/`
- change the generated route to emit:
  `effective.mission_class`,
  `effective.effective_scenario_family`,
  `effective.effective_action_class`,
  normalized boundary vocabulary,
  route reason codes,
  finalize policy,
  and explicit freshness metadata
- remove the generic `service.execute` fallback for material autonomous work
- permit generic fallback route data only for pure observe-only, newly created,
  or explicitly paused missions with no material slice
- refresh `mode-state.effective_scenario_resolution_ref` whenever a route is
  published
- extend `apply-mission-authorize-update.sh` so authorize-updates become a real
  control file with stateful application and receipt linkage rather than a
  bypass around control truth
- extend `evaluate-mission-control-state.sh` to consume authorize-updates,
  non-empty intent rules, slice presence, route freshness, observe-to-operate
  fork rules, safing state, breaker state, and finalize blockers
- extend `close-mission-autonomy-state.sh` and
  `write-mission-control-receipt.sh` to align with the broadened mutation set

Primary targets:

- `/.octon/framework/orchestration/runtime/_ops/scripts/publish-mission-effective-route.sh`
- `/.octon/framework/orchestration/runtime/_ops/scripts/apply-mission-authorize-update.sh`
- `/.octon/framework/orchestration/runtime/_ops/scripts/evaluate-mission-control-state.sh`
- `/.octon/framework/orchestration/runtime/_ops/scripts/close-mission-autonomy-state.sh`
- `/.octon/framework/orchestration/runtime/_ops/scripts/write-mission-control-receipt.sh`
- `/.octon/state/control/execution/missions/mission-autonomy-live-validation/`
- `/.octon/generated/effective/orchestration/missions/mission-autonomy-live-validation/scenario-resolution.yml`

Exit condition:
Every route-affecting mutation republishes the effective route, refreshes the
mode-state link, and either derives valid material-work semantics from intent
plus slice or fails closed.

## Workstream 5: Align Engine And Runtime Enforcement With The Published Model

Outcome:
The kernel, policy engine, and orchestration runtime enforce the same model the
control-plane scripts publish.

Changes:

- require mission context, route freshness, intent entry, and slice reference
  for material autonomous execution
- route recovery, reversibility, and finalize semantics from slice plus policy
  rather than hidden generic fallback logic
- require `owner_ref` everywhere and remove legacy `owner` reader paths
- preserve `STAGE_ONLY`, `SAFE`, and `DENY` as the only legal fallback modes
  when autonomy context is incomplete
- ensure observe missions either fork bounded operate sub-missions or require an
  explicit authorize-update before widening authority
- extend Rust tests in the kernel and any policy-engine consumers to cover:
  missing intent,
  missing slice,
  stale route,
  route-link mismatch,
  authorize-update behavior,
  proceed-on-silence gating,
  budget/breaker tightening,
  and route-derived recovery/finalize behavior

Primary targets:

- `/.octon/framework/engine/runtime/crates/kernel/src/authorization.rs`
- `/.octon/framework/engine/runtime/crates/kernel/src/pipeline.rs`
- `/.octon/framework/engine/runtime/crates/policy_engine/`
- `/.octon/framework/engine/runtime/config/policy-interface.yml`
- `/.octon/framework/engine/runtime/spec/`
- `/.octon/framework/orchestration/runtime/`

Exit condition:
The runtime cannot execute material autonomous work unless the completed MSRAOM
context is present and current, and the Rust test suite proves those fail-closed
behaviors.

## Workstream 6: Generalize The Operator Plane, Mission View, And Control Evidence

Outcome:
Summaries, digests, mission view, and control receipts become standard outputs
for every active mission rather than one-off seeded artifacts.

Changes:

- replace
  `generated/cognition/projections/materialized/missions/<mission-id>.json`
  with
  `generated/cognition/projections/materialized/missions/<mission-id>/mission-view.yml`
- update the summary-generation path so every active mission emits
  `now.md`, `next.md`, `recent.md`, `recover.md`
- update the digest-generation path so every routed owner, watcher, digest
  recipient, and alert recipient gets the correct mission digest output
- ensure mission-view generation cites source refs for mission charter, route,
  control files, summaries, and continuity
- expand control receipts to cover:
  seed,
  directive add/apply/reject/expire,
  authorize-update add/apply/reject/expire,
  schedule mutations,
  budget transitions,
  breaker trip/reset,
  safing enter/exit,
  break-glass enter/exit,
  finalize block/unblock,
  and closeout
- keep historical run evidence and historical control evidence intact; do not
  rewrite old receipts

Primary targets:

- `/.octon/framework/orchestration/runtime/_ops/scripts/summarize-mission-health.sh`
- mission summary generation surfaces under
  `/.octon/framework/cognition/_ops/runtime/scripts/`
- `/.octon/generated/cognition/projections/definitions/cognition-runtime-surface-map.yml`
- `/.octon/generated/cognition/projections/materialized/missions/`
- `/.octon/generated/cognition/summaries/missions/`
- `/.octon/generated/cognition/summaries/operators/`
- `/.octon/state/evidence/control/execution/`

Exit condition:
Every active mission has the full summary set, the correct operator digests, a
materialized `mission-view.yml`, and retained control receipts for every
required mutation class.

## Workstream 7: Migrate In-Tree Missions And Add Deterministic Scenario Fixtures

Outcome:
The repo proves the completed model with committed examples, not just with
proposal prose.

Changes:

- migrate `mission-autonomy-live-validation` to:
  full control family,
  non-null route link,
  normalized breaker vocabulary,
  final projection format,
  and refreshable generated outputs
- add committed fixture state for at least one non-empty intent register and
  slice-derived recovery path
- add committed fixture state for:
  routine housekeeping,
  campaign/refactor,
  dependency/security patching,
  release-sensitive work,
  infra drift,
  migration/backfill,
  external sync,
  observe-only monitoring,
  incident containment,
  destructive work,
  absent human,
  late feedback,
  conflicting human input,
  reversible work,
  compensable-only work,
  and irreversible work
- keep the active live-validation mission minimally canonical and deterministic;
  use dedicated fixtures when a scenario would make the live mission noisy or
  misleading

Primary targets:

- `/.octon/state/control/execution/missions/mission-autonomy-live-validation/`
- `/.octon/generated/effective/orchestration/missions/mission-autonomy-live-validation/`
- `/.octon/generated/cognition/summaries/missions/mission-autonomy-live-validation/`
- `/.octon/generated/cognition/projections/materialized/missions/mission-autonomy-live-validation/`
- assurance/runtime test fixtures under
  `/.octon/framework/assurance/runtime/_ops/tests/`

Exit condition:
The repo contains deterministic, committed proof for every scenario class the
proposal promises, including at least one slice-linked, non-empty intent path.

## Workstream 8: Converge Existing Validators, Aggregators, And CI Gates

Outcome:
MSRAOM completeness becomes a blocking property of the repository, not a manual
review exercise.

Changes:

- add `validate-version-parity.sh`
- extend `validate-mission-control-state.sh` for
  `authorize-updates.yml`,
  `action-slices/`,
  route linkage,
  and continuity completeness
- extend `validate-mission-effective-routes.sh` for
  route field names,
  normalized boundaries,
  route freshness,
  no generic material-work fallback,
  and non-null mode-state linkage
- extend `validate-mission-generated-summaries.sh` for
  `mission-view.yml`,
  per-recipient digests,
  and source-ref assertions
- extend `validate-mission-control-evidence.sh` for receipt-class coverage
- keep `validate-runtime-effective-state.sh` as the umbrella gate and make it
  call the expanded mission validators
- if the doc/contract layer standardizes names like
  `validate-generated-mission-views.sh` or
  `validate-control-evidence-coverage.sh`, implement them as thin wrappers over
  the converged existing validators rather than creating a second divergent
  validator family
- update `.github/workflows/architecture-conformance.yml`
- add `.github/workflows/mission-autonomy-conformance.yml` only if runtime
  duration requires splitting jobs
- update branch-protection requirements for `main`

Primary targets:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-mission-runtime-contracts.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-mission-control-state.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-mission-effective-routes.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-mission-generated-summaries.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-mission-control-evidence.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/test-mission-autonomy-scenarios.sh`
- `/.github/workflows/architecture-conformance.yml`
- `.github` branch-protection configuration

Exit condition:
All mission-runtime, effective-state, scenario, summary/view, and evidence
checks are blocking in CI and required in branch protection.

## Cutover Sequence

1. Land Workstream 1 so the branch has one release target, one durable
   migration record, and one contract registry story.
2. Land Workstream 2 so mission creation becomes atomic before runtime
   enforcement tightens.
3. Land Workstream 3 so schemas, registries, and projection path declarations
   are final before scripts and runtime depend on them.
4. Land Workstream 4 so route generation and control mutations obey the final
   model.
5. Land Workstream 5 so engine/runtime enforcement matches the published route
   and control truth.
6. Land Workstream 6 so summary, digest, mission-view, and evidence outputs are
   standard and refreshable.
7. Land Workstream 7 so the repo's active mission and fixtures prove the final
   model deterministically.
8. Land Workstream 8 so validators and CI become blocking in the same branch.
9. Re-run the full validator and scenario suite on the final branch state.
10. Write the ADR and migration evidence bundle, archive the prior
    completion-cutover packet, regenerate `/.octon/generated/proposals/registry.yml`,
    and cut `0.6.1`.

## Verification Matrix

- release and manifest ratification:
  `validate-version-parity.sh`,
  `validate-architecture-conformance.sh`,
  `alignment-check.sh --profile harness,mission-autonomy`
- mission runtime contracts:
  `validate-mission-runtime-contracts.sh`
- mission source-of-truth discipline:
  `validate-mission-source-of-truth.sh`
- mission control family and route linkage:
  `validate-mission-control-state.sh`,
  `validate-mission-effective-routes.sh`,
  `evaluate-mission-control-state.sh --mission-id mission-autonomy-live-validation`
- runtime effective-state umbrella:
  `validate-runtime-effective-state.sh`
- generated summaries, mission view, and control receipts:
  `validate-mission-generated-summaries.sh`,
  `validate-mission-control-evidence.sh`
- scenario coverage:
  `test-mission-autonomy-scenarios.sh`
- proposal/package closeout:
  `validate-proposal-standard.sh`,
  `validate-architecture-proposal.sh`,
  `generate-proposal-registry.sh --check`

## Release Evidence Bundle

Before cutting `0.6.1`, the durable migration bundle must contain:

- validator outputs for every command in the verification matrix
- scenario-suite receipts and fixture inventory
- a list of migrated in-tree missions
- a list of generated mission views and operator digests
- control receipt samples for every required mutation class
- the ADR for the steady-state cutover
- proof that the prior completion-cutover packet has been archived
- proof that this packet is ready to archive immediately after promotion

## Rollback Guidance

- rollback by reverting the full cutover branch
- do not keep the new validators while restoring the old partial control family
- do not keep both mission projection formats live
- do not restore nullable route linkage or generic material-work recovery
- historical run and control evidence remain intact either way

## Final Done Gate

This implementation is complete only when:

- mission creation is atomic
- the full control family exists for every active mission
- material autonomous work requires current intent plus slice plus fresh route
- route linkage is non-null and refreshed automatically
- mission-view generation uses the final `mission-view.yml` format
- control receipts cover every required mutation class
- validators and scenario tests are blocking in CI and branch protection
- version surfaces and canonical docs all agree on `0.6.1`
- the prior completion-cutover packet can be archived without leaving any
  deferred MSRAOM remediation behind
