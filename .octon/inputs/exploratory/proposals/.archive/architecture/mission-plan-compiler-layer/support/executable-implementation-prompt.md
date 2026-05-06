# Executable Implementation Prompt

You are a senior Octon implementation engineer responsible for promoting the
Mission Plan Compiler Layer proposal into durable Octon authority, control,
evidence, workflow, validator, and documentation surfaces.

Implement the proposal packet at:

```text
.octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer/
```

Treat the proposal packet as non-authoritative implementation input. Durable
behavior must land only in declared promotion targets, registry-backed path
families, validators, tests, and retained evidence. Do not make proposal-local
files, generated projections, chat context, or raw inputs runtime authority.

## Mission

Promote an optional, mission-bound Mission Plan Compiler layer that helps the
single accountable orchestrator turn approved mission authority into validated
work-package candidates. The promoted layer must remain a compiler-style
preparation surface between mission authority and action-slice/run-contract
execution.

The target flow is:

```text
Mission authority
-> MissionPlan candidate
-> PlanNode decomposition
-> dependency, risk, assumption, and decision mapping
-> readiness checks
-> action-slice candidates
-> run-contract drafts
-> context-pack request
-> authorization request
-> execution through existing run lifecycle
-> plan revision from retained evidence
```

The forbidden flow is:

```text
MissionPlan -> direct execution
```

## Required Preflight

Before editing durable targets:

1. Read root `AGENTS.md` and `.octon/instance/ingress/AGENTS.md`.
2. Record the required execution profile receipt: `change_profile=atomic`
   unless a hard gate forces transitional, and `release_state=pre-1.0`.
3. Re-read this packet:
   - `proposal.yml`
   - `architecture-proposal.yml`
   - `README.md`
   - `navigation/source-of-truth-map.md`
   - `resources/bounded-planning-layer-source-analysis.md`
   - `architecture/target-architecture.md`
   - `architecture/current-state-gap-map.md`
   - `architecture/hierarchical-planning-model.md`
   - `architecture/authority-control-evidence-map.md`
   - `architecture/workflow-lifecycle.md`
   - `architecture/schemas-and-artifacts.md`
   - `architecture/stop-rules-and-anti-bloat-controls.md`
   - `architecture/runtime-integration-plan.md`
   - `architecture/governance-and-approval-plan.md`
   - `architecture/validation-plan.md`
   - `architecture/migration-plan.md`
   - `architecture/rollback-plan.md`
   - `architecture/implementation-plan.md`
   - `architecture/acceptance-criteria.md`
   - `support/implementation-grade-completeness-review.md`
4. Confirm implementation is authorized from the packet lifecycle state. If
   the packet is still `in-review` and human acceptance has not been granted,
   stop after reporting readiness. Do not promote durable runtime behavior.
5. Inspect live target state. At prompt generation time these targets already
   exist and must be updated without losing unrelated behavior:
   - `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
   - `.octon/framework/constitution/contracts/registry.yml`
   - `.octon/framework/orchestration/runtime/missions/README.md`
   - `.octon/framework/orchestration/runtime/runs/README.md`
   - `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
   - `.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
   - `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
   - `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
6. Inspect live target state. At prompt generation time these targets are
   missing and must be created during promotion:
   - `.octon/framework/engine/runtime/spec/mission-plan-v1.md`
   - `.octon/framework/engine/runtime/spec/mission-plan-v1.schema.json`
   - `.octon/framework/engine/runtime/spec/plan-node-v1.schema.json`
   - `.octon/framework/engine/runtime/spec/plan-dependency-edge-v1.schema.json`
   - `.octon/framework/engine/runtime/spec/plan-revision-record-v1.schema.json`
   - `.octon/framework/engine/runtime/spec/plan-compile-receipt-v1.schema.json`
   - `.octon/framework/engine/runtime/spec/plan-drift-record-v1.schema.json`
   - `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/workflow.yml`
   - `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/01-bind-mission.md`
   - `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/02-draft-plan.md`
   - `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/03-critic-and-readiness.md`
   - `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/04-compile-leaves.md`
   - `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/05-update-from-evidence.md`
   - `.octon/instance/governance/policies/hierarchical-planning.yml`
   - `.octon/framework/assurance/runtime/_ops/scripts/validate-mission-plan-compiler.sh`
   - `.octon/framework/assurance/runtime/_ops/tests/test-mission-plan-compiler.sh`

## Hard Boundaries

- Do not use a plan as authority.
- Do not create a second orchestrator.
- Do not allow a PlanNode to execute directly.
- Do not bypass run contracts, Context Pack Builder, `authorize_execution`,
  typed authorized effects, retained evidence, Run Journal coverage, replay,
  rollback, or support-target governance.
- Do not create a free-text `AtomicAction` runtime primitive.
- Do not create a generic project-management board.
- Do not treat generated planning views as control truth or evidence.
- Do not treat proposal packet paths, raw inputs, generated views, chat, host
  labels, host comments, or host UI state as runtime authority.
- Do not widen mission scope, support targets, capability admissions, risk
  ceiling, or allowed action classes through planning artifacts.
- Do not create state/control mission plan instances as part of this promotion
  unless a separate authorized mission/run route explicitly requires fixtures.
- Do not publish generated planning operator views in the first slice unless
  freshness, source-traceability, and non-authority metadata are enforced.

## Workstream 1: Runtime Doctrine And Schemas

Create `.octon/framework/engine/runtime/spec/mission-plan-v1.md`.

It must define:

- Mission Plan Compiler as an optional mission-bound preparation layer;
- MissionPlan as mutable planning control state, not authority;
- PlanNode as a typed planning node, not an executable action;
- DependencyEdge as a non-tree dependency relation;
- PlanRevisionRecord, PlanCompileReceipt, and PlanDriftRecord as retained
  evidence records;
- compile-only semantics from ready leaves to action-slice candidates,
  run-contract drafts, context-pack requests, authorization requests, rollback
  refs, and evidence requirements;
- required fail-closed behavior for stale mission digests, authority misuse,
  duplicate work, dependency cycles, missing receipts, unresolved approvals,
  support-target widening, capability admission, and direct execution.

Create these JSON schemas under `.octon/framework/engine/runtime/spec/`:

- `.octon/framework/engine/runtime/spec/mission-plan-v1.schema.json`
- `.octon/framework/engine/runtime/spec/plan-node-v1.schema.json`
- `.octon/framework/engine/runtime/spec/plan-dependency-edge-v1.schema.json`
- `.octon/framework/engine/runtime/spec/plan-revision-record-v1.schema.json`
- `.octon/framework/engine/runtime/spec/plan-compile-receipt-v1.schema.json`
- `.octon/framework/engine/runtime/spec/plan-drift-record-v1.schema.json`

Schema requirements:

- `MissionPlan` includes mission ref, mission digest, workspace charter ref,
  owner ref, status, risk ceiling, allowed action classes, support-target tuple
  refs, scope IDs, success criteria refs, failure condition refs, planning
  budget, decomposition depth budget, rolling-wave window, index refs,
  compiled run refs, evidence root ref, created time, and updated time.
- `PlanNode` includes node identity, plan ref, parent ref, enumerated node
  type, title, purpose, scope, non-scope, expected output, acceptance criteria,
  evidence requirements, dependencies, risks, assumptions, decision points,
  predicted ACP, reversibility, approval requirement, support-target tuple
  refs, readiness state, decomposition status, stop reason, and compiled
  artifact refs.
- `DependencyEdge` includes edge identity, plan ref, source node, target node,
  edge type, rationale, status, and evidence ref.
- Revision, compile, and drift records include digest linkage, evidence refs,
  timestamps, validation outcome, and responsible compiler or actor identity.
- Schema examples or fixtures must be representative enough for validator
  coverage.

## Workstream 2: Registries And Placement

Update structural and constitutional registries:

- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/framework/constitution/contracts/registry.yml`

Required registry behavior:

- declare the planning schema family under authored `framework/**` authority;
- declare future mission-local plan control roots under
  `.octon/state/control/execution/missions/<mission-id>/plans/**`;
- declare future planning evidence roots under
  `.octon/state/evidence/control/execution/planning/**`;
- declare generated planning projections under
  `.octon/generated/cognition/projections/materialized/planning/**` as
  derived-only;
- make proposal-local and generated planning artifacts invalid as runtime
  authority;
- declare `validate-mission-plan-compiler.sh` as the durable validator surface.

Do not weaken existing mission, run, authorization, evidence, support-target,
generated/effective, or proposal packet registry semantics.

## Workstream 3: Mission Workflow Integration

Create the mission workflow:

- `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/workflow.yml`
- `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/01-bind-mission.md`
- `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/02-draft-plan.md`
- `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/03-critic-and-readiness.md`
- `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/04-compile-leaves.md`
- `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/05-update-from-evidence.md`

The workflow must enforce:

- planning begins only from existing mission authority, an approved mission
  candidate, or an accepted proposal whose promotion requires mission-scoped
  execution;
- the first pass drafts mission objective, strategic outcomes, workstreams,
  constraints, risks, dependencies, decisions, budget, depth budget, and
  rolling-wave window only;
- critic/readiness checks run before deeper decomposition;
- selective decomposition is allowed only for blocking, risky, dependency,
  approval, rollback, support-target, or compile-readiness reasons;
- ready leaves compile only to action-slice candidates, run-contract drafts,
  context-pack requests, authorization requests, rollback refs, and evidence
  requirements;
- material execution remains outside the planning workflow and goes through
  existing run lifecycle, context packing, authorization, journal, and evidence
  gates;
- plan updates after execution cite retained run journal, lifecycle,
  authorization, effect, evidence-store, rollback, intervention, or validation
  records.

If the workflow registry or manifest requires an entry for discoverability,
update it in the smallest existing local pattern. Do not invent a parallel
workflow registry convention.

## Workstream 4: Optional Instance Policy

Create:

```text
.octon/instance/governance/policies/hierarchical-planning.yml
```

The policy must be optional and fail closed. It must include:

- enablement mode, defaulting to disabled or stage-only until validators pass;
- planning budget and depth budget defaults;
- maximum children per node: 7 by default;
- maximum open decompositions per branch: 3 by default;
- maximum initial executable leaves: 20 by default;
- maximum plan revisions without execution evidence: 2 by default;
- rolling-wave limits;
- ACP-0/ACP-1, ACP-2, ACP-3, ACP-4/destructive/irreversible thresholds;
- human approval requirements for mission scope changes, strategic goal
  changes, risk ceiling changes, protected-zone mutation, support-target
  widening, capability admission, external effects, destructive effects,
  irreversible effects, high-risk workstream activation, and consequential
  completion declaration.

The policy cannot widen mission scope, support targets, capability admissions,
risk ceiling, or allowed action classes.

## Workstream 5: Boundary Documentation Updates

Update only the durable docs that need boundary language:

- `.octon/framework/orchestration/runtime/missions/README.md`
- `.octon/framework/orchestration/runtime/runs/README.md`
- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`

Required documentation behavior:

- missions remain the continuity and long-horizon authority container;
- run contracts remain the atomic execution authority;
- context packs may include planning refs only with source-class preservation;
- authorization requests from planning never become grants;
- planning evidence stays separate from run evidence;
- Run Journal and run lifecycle remain canonical for replay and execution
  reconstruction;
- rollback truth remains in run control and run evidence;
- generated planning projections remain non-authoritative.

Do not cite this active proposal packet as durable authority in promoted docs.

## Workstream 6: Validator And Test Coverage

Create:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-mission-plan-compiler.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-mission-plan-compiler.sh`

The validator must cover, at minimum:

- schema parse and fixture validation for all new schemas;
- class-root placement for framework schemas, instance policy, future state
  roots, and generated planning projections;
- mission binding and mission digest presence;
- stale mission digest blocking compile;
- maximum depth, breadth, open decomposition, initial executable leaves, and
  revision-without-evidence budgets;
- duplicate node or leaf detection by scope, expected output, dependency, and
  action class;
- dependency cycle rejection or stage-only disposition;
- unresolved assumptions and approvals blocking compile;
- action-slice compile readiness fields;
- retained revision, compile, drift, check, and closeout evidence records;
- generated/input/proposal authority misuse negative controls;
- PlanNode direct execution negative controls;
- run-contract, Context Pack Builder, and `authorize_execution` non-bypass
  negative controls;
- support-target widening and capability admission negative controls;
- rollback mapping without replacing run rollback truth.

The test file must exercise positive and negative cases. Include fixtures under
an existing assurance fixture pattern if the local validator family already
uses one.

## Workstream 7: Proposal Receipts, Registry, And Closeout Preparation

After durable implementation:

1. Regenerate the proposal registry:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write
   ```

2. Update `support/implementation-conformance-review.md` with a real
   post-implementation review. It must include `verdict: pass`,
   `unresolved_items_count: 0`, checked evidence, promotion target coverage,
   implementation map coverage, validator coverage, generated output coverage,
   rollback coverage, downstream reference coverage, exclusions, and final
   closeout recommendation.
3. Update `support/post-implementation-drift-churn-review.md` with a real
   post-implementation review. It must include `verdict: pass`,
   `unresolved_items_count: 0`, checked evidence, backreference scan, naming
   drift, generated projection freshness, manifest and schema validity,
   repo-local projection boundaries, target family boundaries, churn review,
   validators run, exclusions, and final closeout recommendation.
4. Refresh `support/validation.md` and `support/SHA256SUMS.txt` if proposal
   support files changed.

Do not claim implementation closeout, implemented status, or archive
eligibility before both post-implementation receipts pass.

## Validation Commands

Run at minimum after implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-mission-plan-compiler.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-mission-plan-compiler.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
```

Also run any schema-specific, workflow-specific, and registry-specific
validators that are touched by the implementation. Run shell tests for any
validator you create or modify.

## Evidence Plan

Retain implementation evidence with:

- selected Change or run route and rationale;
- release state and change profile receipt;
- changed target list grouped by workstream;
- schema validation and fixture results;
- validator and shell test command outputs or summaries;
- proposal registry generation result;
- implementation conformance receipt;
- post-implementation drift/churn receipt;
- rollback instructions for each workstream;
- generated projection status and exclusions;
- unresolved blockers, explicit deferrals, or human approval refs.

Do not store evidence only in PR bodies. PR metadata may project evidence for a
PR-backed Change, but Octon receipts and retained evidence remain the durable
record.

## Rollback Posture

Rollback must leave existing missions, action slices, run contracts,
authorization, retained evidence, replay, rollback, continuity, and
support-target claims operational.

Pre-promotion rollback is deletion or archival of this packet and regeneration
of the non-authoritative proposal registry.

Post-promotion rollback must:

- disable `.octon/instance/governance/policies/hierarchical-planning.yml`;
- block new plan creation;
- prevent stale or active plans from compiling further leaves;
- preserve existing plan evidence as historical retained evidence;
- leave run contracts, Run Journals, run evidence, and disclosures untouched;
- delete and regenerate generated planning projections;
- archive or retire plan control roots only after no active run references
  them as lineage.

Rollback succeeds only if existing mission charters, action slices, run
contracts, run replay, generated projection rebuilds, and support-target claims
remain valid.

## Authorized Delegation Boundaries

The implementer remains the single accountable orchestrator. No independent
planner, worker, generated dashboard, or proposal-local artifact may gain
execution authority.

Delegation is optional and must be bounded. If delegated, split by disjoint
write ownership:

- schema and doctrine slice under `.octon/framework/engine/runtime/spec/**`;
- mission workflow slice under
  `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/**`;
- validator and fixture slice under `.octon/framework/assurance/runtime/_ops/**`;
- documentation boundary slice under the listed mission, run, context-pack,
  authorization, evidence, and lifecycle docs.

Delegates must not revert unrelated user changes and must not edit outside
their assigned write scope.

## Post-Implementation Gate Requirements

Before claiming implementation closeout or archive eligibility:

- write `support/implementation-conformance-review.md` with `verdict: pass`;
- write `support/post-implementation-drift-churn-review.md` with
  `verdict: pass`;
- run `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer`;
- run `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer`;
- refuse closeout or archive if either receipt is missing, failing,
  incomplete, stale, or records unresolved blockers.

## Full Promotion Target Checklist

The executable implementation prompt must cover every declared promotion
target. Treat this as the full target checklist:

- `.octon/framework/engine/runtime/spec/mission-plan-v1.md`
- `.octon/framework/engine/runtime/spec/mission-plan-v1.schema.json`
- `.octon/framework/engine/runtime/spec/plan-node-v1.schema.json`
- `.octon/framework/engine/runtime/spec/plan-dependency-edge-v1.schema.json`
- `.octon/framework/engine/runtime/spec/plan-revision-record-v1.schema.json`
- `.octon/framework/engine/runtime/spec/plan-compile-receipt-v1.schema.json`
- `.octon/framework/engine/runtime/spec/plan-drift-record-v1.schema.json`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/framework/constitution/contracts/registry.yml`
- `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/workflow.yml`
- `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/01-bind-mission.md`
- `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/02-draft-plan.md`
- `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/03-critic-and-readiness.md`
- `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/04-compile-leaves.md`
- `.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/stages/05-update-from-evidence.md`
- `.octon/instance/governance/policies/hierarchical-planning.yml`
- `.octon/framework/orchestration/runtime/missions/README.md`
- `.octon/framework/orchestration/runtime/runs/README.md`
- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-mission-plan-compiler.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-mission-plan-compiler.sh`

## Terminal Criteria

Implementation is complete only when:

- every promotion target exists or has an explicit human-approved blocker;
- all new schemas parse and validate representative fixtures;
- mission workflow stages enforce mission binding, critic/readiness checks,
  compile-only leaves, and evidence-based revision updates;
- optional instance policy is fail-closed and does not widen authority;
- documentation updates preserve existing runtime boundaries;
- generated and proposal-local artifacts remain non-authoritative;
- `validate-mission-plan-compiler.sh` and its shell tests pass;
- packet validators pass;
- proposal registry generation reports `errors=0`;
- `support/implementation-conformance-review.md` passes;
- `support/post-implementation-drift-churn-review.md` passes;
- rollback instructions are sufficient to disable the planning layer without
  breaking existing mission/run execution.
