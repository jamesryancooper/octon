# Bounded Planning Layer Source Analysis

Captured from the operator-provided resource on 2026-05-05. This file is
proposal-local source material for the Mission Plan Compiler Layer packet. It
is non-authoritative and must not be cited by promoted runtime targets as
runtime, policy, control, or evidence authority.

## 1. Executive Verdict

**Recommendation: adopt as a bounded optional planning layer, not as a core autonomous control plane.**

Octon should add hierarchical planning only as a **mission-bound, evidence-backed, compiler-style planning layer** that helps turn an approved mission into validated work-package candidates. It should not become a rival orchestrator, a project-management subsystem, or a source of runtime authority.

The reason is that Octon already has strong mission, run, authorization, evidence, rollback, support-target, and proposal-packet machinery. Its README describes the system as a governed runtime that binds runs to explicit objectives, run contracts, capability limits, authorization, evidence, rollback, continuity, review, and disclosure; it also explicitly separates authority, state, evidence, and summaries. ([GitHub][1]) The constitution frames Octon as a **Constitutional Engineering Harness** and **Governed Agent Runtime**, requiring explicit scoping, authorization, fail-closed behavior, observability, reviewability, and recoverability, while rejecting raw inputs, generated summaries, chat state, and host UI as authority. ([GitHub][2])

So the correct answer is:

> **Yes, but only as a subordinate “Mission Plan Compiler” layer that lives between mission authority and run-contract/action-slice execution.**

It should help answer: “Given this mission, what bounded work packages should be staged, validated, approved, and compiled into run contracts?” It must not answer: “What is Octon allowed to do?” Authority still comes from `framework/**`, `instance/**`, mission charters, governance policy, authorization grants, run contracts, and retained evidence.

---

## 2. What Octon Already Has That Relates To Hierarchical Planning

Octon already implies a partial hierarchy, but it does **not** appear to have a dedicated canonical recursive `MissionPlan` / `PlanNode` planning model in the inspected surfaces.

The existing structure is roughly:

```text
Constitution / Charter / Governance
└── Workspace objective / objective brief
    └── Mission
        └── Mission-local control state
            └── Action slices / run contracts
                └── Authorized effects
                    └── Evidence / replay / rollback / disclosure
```

The repository’s `.octon` README defines the five class roots and their roles: `framework/` as portable authored core, `instance/` as repo-specific durable authority, `state/` as mutable control/evidence/continuity truth, `generated/` as rebuildable projections, and `inputs/` as non-authoritative material. It also states that only `framework/` and `instance/` are authored authority. ([GitHub][3])

Several existing Octon components already do planning-adjacent work:

| Existing Octon surface | Planning relevance | Evidence |
| --- | ---: | --- |
| `/.octon/instance/orchestration/missions/**` | Durable mission definitions and mission-scoped orchestration artifacts | Missions are canonical repo-instance mission homes; mission authority lives under `instance/**`, while consequential runs bind under `state/control/execution/runs/**`. ([GitHub][4]) |
| `mission.yml` / `octon-mission-v2` | Canonical mission object | Mission schema requires mission identity, owner, risk ceiling, allowed action classes, scope IDs, success criteria, and failure conditions. ([GitHub][5]) |
| `state/control/execution/missions/<mission-id>/**` | Mission-local mutable control state | Current mission control state includes action slices, directives, leases, schedules, mode state, subscriptions, and related control files. ([GitHub][6]) |
| `action-slice-v1` | Existing bounded execution-unit primitive | Action slices require mission ID, action class, scope IDs, predicted ACP, reversibility, safe interrupt boundary, blast radius, executor profile, approval flags, and rollback or compensation primitive. ([GitHub][7]) |
| `run-contract.yml` under `state/control/execution/runs/**` | Canonical per-run execution contract | Runs README makes the run contract the canonical per-run execution contract and keeps evidence, continuity, rollback, and projections separate. ([GitHub][8]) |
| Orchestrator role | Existing accountable planner/sequencer | The orchestrator binds requests to the smallest robust implementation plan, owns sequencing/delegation/final integration, and escalates one-way-door/security/policy/ambiguity cases. ([GitHub][9]) |
| Context Pack Builder | Existing deterministic context assembly | Context packs use durable authority/evidence/state sources and explicitly exclude proposal-local exploratory artifacts, generated read models, raw additive inputs, labels, comments, chat, and host UI as authority. ([GitHub][10]) |
| Authorization runtime | Existing execution gate | Material execution must pass through `authorize_execution(request) -> GrantBundle`; side effects require typed authorized effects and verification before mutation. ([GitHub][11]) |
| Evidence store and Run Journal | Existing retained proof/replay model | Evidence store is required for closeout, replay, support, and disclosure; the Run Journal is append-only and canonical for lifecycle reconstruction. ([GitHub][12]) |

The strongest existing “planning-like” artifact is **not** a nested outline. It is the combination of mission authority, mission-local control state, action slices, run contracts, context packs, authorization grants, rollback posture, and retained evidence.

---

## 3. Where The Proposed Workflow Aligns With Octon

Hierarchical planning aligns with Octon in four places.

First, Octon already treats large or long-horizon work as mission-scoped. The missions README says missions are for time-bounded sub-projects, parallel workstreams, large initiatives, or delegatable units, and not for single tasks. ([GitHub][13]) That is exactly the domain where hierarchical planning can help.

Second, Octon already expects one accountable orchestrator to produce a bounded implementation plan. The orchestrator role says it owns sequencing, delegation, final integration, runtime discipline, evidence, support claims, and escalation. ([GitHub][9]) A bounded planning layer could improve that role by giving it a typed intermediate object instead of relying on ad hoc prose plans.

Third, Octon already has a natural “leaf” artifact: the `action-slice-v1` schema. A hierarchical planning layer should not invent “atomic actions” as free-form text. It should compile executable leaves into action-slice candidates or run-contract drafts, because action slices already encode risk, reversibility, approval, scope, executor profile, and rollback/compensation requirements. ([GitHub][7])

Fourth, Octon’s architecture already separates hierarchy from execution. The architecture specification distinguishes authored authority, mutable control, retained evidence, continuity state, generated runtime-effective handles, operator read models, proposal inputs, and raw additive inputs. It also says generated artifacts never mint authority and proposal packets remain lineage-only. ([GitHub][14]) A properly designed plan layer can respect this by treating the plan as **control preparation state**, not as runtime authority.

---

## 4. Where It Conflicts Or Could Become Dangerous

The candidate hierarchy becomes dangerous if it is treated as an autonomous control plane.

The major conflict is this: Octon is not a generic task manager. It is a governed runtime. The constitution requires one accountable orchestrator, explicit authority routing before material side effects, retained evidence, fail-closed behavior, and final disclosure within the admitted claim envelope. ([GitHub][2]) A recursive planning engine that freely mutates scope, spawns tasks, or treats generated plans as authority would directly violate that posture.

Specific dangers:

| Danger | Why it conflicts with Octon |
| --- | --- |
| Plan as authority | Octon says authored authority lives only in `framework/**` and `instance/**`; `state/**` is operational truth and `generated/**` is derived-only. ([GitHub][3]) |
| Plan as second orchestrator | Octon requires one accountable orchestrator for consequential runs. The planner may assist the orchestrator but must not own execution authority. ([GitHub][9]) |
| Plan-generated execution | Octon requires material execution to pass through engine-owned authorization and typed grants. ([GitHub][11]) |
| Raw/proposal-derived plans used at runtime | Runtime direct reads from inputs are invalid, and proposal packets remain lineage-only. ([GitHub][14]) |
| Generated dashboards becoming canonical | Generated and operator read models may summarize, but cannot satisfy control/evidence requirements by themselves. ([GitHub][12]) |
| Infinite decomposition | Octon’s fail-closed, support-proof, and authorization model rewards bounded proof, not planning volume. |
| Stale plan state | Run lifecycle requires reconstruction from canonical journal/control state; drift blocks transitions. ([GitHub][15]) |

The narrow conclusion: **the planning layer is useful only if it is a compiler and evidence-organizer, not a decision sovereign.**

---

## 5. Recommended Integration Model

Add a bounded optional layer called something like:

```text
Mission Plan Compiler
```

Its job:

```text
Mission authority
→ MissionPlan candidate
→ PlanNode decomposition
→ Dependency/risk/decision mapping
→ Readiness checks
→ ActionSlice candidates
→ Run-contract drafts
→ Context-pack request
→ Authorization request
→ Execution / evidence / revision update
```

It should not be:

```text
MissionPlan
→ direct execution
```

The planning model should be integrated at the mission-control level because Octon already says mission-local mutable execution control truth belongs under `state/control/execution/missions/<mission-id>/**`, while durable mission authority remains under `instance/orchestration/missions/**`. ([GitHub][4])

Recommended posture:

```text
Authoritative doctrine/schema:
  .octon/framework/**

Instance enablement / policy:
  .octon/instance/**

Mission authority:
  .octon/instance/orchestration/missions/<mission-id>/mission.yml

Mutable plan control state:
  .octon/state/control/execution/missions/<mission-id>/plans/<plan-id>/**

Plan mutation / compile evidence:
  .octon/state/evidence/control/execution/planning/<plan-id>/**

Run execution evidence:
  .octon/state/evidence/runs/<run-id>/**

Mission continuity:
  .octon/state/continuity/repo/missions/<mission-id>/**

Generated visualizations:
  .octon/generated/cognition/projections/materialized/planning/**
```

That location choice follows Octon’s existing mission boundary rules: mission authority under `instance/**`, mission-local control under `state/control/execution/missions/**`, retained control evidence under `state/evidence/control/execution/**`, run evidence under `state/evidence/runs/**`, generated summaries as derived views, and continuity under `state/continuity/repo/missions/**`. ([GitHub][4])

---

## 6. Planning Lifecycle

The Octon-native lifecycle should be:

```text
No Plan
→ Plan Candidate
→ Mission-Bound Plan
→ Partially Decomposed Plan
→ Readiness-Checked Plan
→ Work-Package Candidates
→ Compiled Run Contracts
→ Authorized Runs
→ Evidence-Updated Plan Revision
→ Closed / Superseded / Retired
```

### Step 1: Start From Mission Authority

Planning begins only from one of these:

1. an existing `octon-mission-v2` mission;
2. an approved mission candidate created by the existing mission workflow;
3. an accepted proposal whose promotion work requires mission-scoped execution.

It should not begin from chat, generated summaries, raw proposal notes, or `inputs/**` as runtime authority. Octon’s ingress explicitly says only `framework/` and `instance/` are authored authority, `state/` is operational truth/evidence, `generated/` is derived-only, and raw inputs never become runtime or policy dependencies. ([GitHub][16])

### Step 2: Produce A 10,000-Foot `MissionPlan` Candidate

The first plan pass should create only:

```text
Mission objective
Strategic outcomes
Major workstreams
Known constraints
Known risks
Known dependencies
Known decision points
Planning budget
Decomposition depth budget
Rolling-wave window
```

It should not immediately decompose every branch to atomic actions.

### Step 3: Critique Before Deeper Decomposition

A planning critic pass must check:

```text
Is the plan mission-bound?
Does it preserve mission scope?
Does every workstream map to success criteria?
Does any branch exceed the risk ceiling?
Are required approvals identified?
Are generated/input/proposal artifacts being treated as authority?
Are there duplicate branches?
Are dependencies separate from hierarchy?
```

### Step 4: Selectively Decompose

Only decompose a branch when at least one is true:

```text
It blocks near-term execution.
It carries material risk.
It is needed for run-contract compilation.
It has unresolved dependencies.
It needs human decision or approval.
It affects rollback/reversibility.
It affects support-target admission or support claims.
```

### Step 5: Compile Leaves Into Action-Slice Candidates

A leaf is ready only when it can be mapped to `action-slice-v1` fields: mission ID, action class, scope IDs, predicted ACP, reversibility, safe interrupt boundary, executor profile, approval requirement, owner attestation requirement, rationale, and rollback or compensation primitive. ([GitHub][7])

### Step 6: Authorize Through The Existing Runtime

A plan leaf does not authorize anything. It can only produce:

```text
action-slice candidate
run-contract draft
context-pack request
authorization request
rollback-plan reference
evidence requirements
```

Execution proceeds only through the existing engine-owned authorization path. ([GitHub][11])

### Step 7: Update From Evidence, Not Intention

After execution, the plan is updated from:

```text
run journal events
run lifecycle state
authorization receipts
effect receipts
evidence-store records
rollback posture
interventions
validation results
```

The Run Journal should remain canonical for execution reconstruction; the plan should be a linked control artifact that records planning revisions and compile mappings, not an alternate journal. ([GitHub][17])

---

## 7. Artifact And Schema Model

Do **not** create separate schemas for `Workstream`, `Milestone`, `Deliverable`, `Task`, `Subtask`, and `AtomicAction`. That would over-design Octon and create planning bloat.

Use a minimal typed model.

| Artifact | Purpose | Canonical location | Class |
| --- | --- | --- | --- |
| `MissionPlan` | Mission-bound planning container | `state/control/execution/missions/<mission-id>/plans/<plan-id>/plan.yml` | Mutable control |
| `PlanNode` | Typed node inside the plan tree | same plan root, likely `nodes/*.yml` or embedded index | Mutable control |
| `DependencyEdge` | Non-tree dependency graph | `edges.yml` or `dependencies/*.yml` | Mutable control |
| `PlanRevisionRecord` | Records digest-to-digest plan changes | `state/evidence/control/execution/planning/<plan-id>/revisions/*.yml` | Retained evidence |
| `PlanCompileReceipt` | Maps leaf node to action slice / run contract / context request | `state/evidence/control/execution/planning/<plan-id>/compile/*.yml` | Retained evidence |
| `PlanDriftRecord` | Records mission/run/evidence mismatch or stale assumptions | `state/evidence/control/execution/planning/<plan-id>/drift/*.yml` | Retained evidence |
| Generated plan view | Operator dashboard / graph / map | `generated/cognition/projections/materialized/planning/**` | Generated projection |

### `MissionPlan` Required Fields

```yaml
schema_version: octon-mission-plan-v1
plan_id:
mission_ref:
mission_digest:
workspace_charter_ref:
owner_ref:
status: candidate | bound | active | stale | superseded | closed
risk_ceiling:
allowed_action_classes:
support_target_tuple_refs:
scope_ids:
success_criteria_refs:
failure_condition_refs:
planning_budget:
decomposition_depth_budget:
rolling_wave_window:
node_index_ref:
dependency_index_ref:
assumption_index_ref:
decision_index_ref:
compiled_run_refs:
evidence_root_ref:
created_at:
updated_at:
```

### `PlanNode` Required Fields

```yaml
schema_version: octon-plan-node-v1
node_id:
plan_id:
parent_node_id:
node_type: strategic_goal | workstream | milestone | deliverable | task | action_slice_candidate | validation_gate | decision_point | risk_record | assumption_record
title:
purpose:
scope:
non_scope:
expected_output:
acceptance_criteria:
evidence_required:
dependencies:
risks:
assumptions:
decision_points:
predicted_acp:
reversibility:
approval_required:
support_target_tuple_refs:
readiness_state: not_ready | blocked | ready_for_compile | compiled | superseded
decomposition_status: open | stopped | blocked | escalated
decomposition_stop_reason:
compiled_artifact_refs:
```

### `DependencyEdge` Required Fields

```yaml
schema_version: octon-plan-dependency-edge-v1
edge_id:
plan_id:
from_node_id:
to_node_id:
edge_type: blocks | enables | requires_decision | requires_evidence | requires_approval | rollback_affects | support_target_depends_on
rationale:
status:
evidence_ref:
```

### Relationship To Existing Artifacts

The executable leaf should not be a new `AtomicAction` schema. It should become an `action-slice-v1` candidate, because Octon already has that schema and it already encodes the governance properties that an executable leaf needs. ([GitHub][7])

---

## 8. Authority / Control / Evidence Placement Map

| Planning concern | Correct placement | Must not be placed in |
| --- | --- | --- |
| Planning doctrine | `framework/orchestration/**` or `framework/engine/runtime/spec/**` | `inputs/**`, `generated/**` |
| Planning schema | `framework/engine/runtime/spec/**` | proposal packet only |
| Planning lifecycle rules | `framework/engine/runtime/spec/**` and validators | generated dashboards |
| Instance enablement policy | `instance/governance/policies/**` | state/evidence |
| Mission-to-plan binding | mission-authorized reference plus `state/control/execution/missions/<mission-id>/plans/**` | `generated/**` |
| Work-package compilation rules | `framework/orchestration/runtime/workflows/**` and engine spec | `inputs/**` |
| Plan control state | `state/control/execution/missions/<mission-id>/plans/**` | `framework/**`, `instance/**`, `generated/**` |
| Plan revisions | `state/evidence/control/execution/planning/**` | generated summaries |
| Human decisions / approvals | existing approvals roots under `state/control/execution/approvals/**`, with evidence under `state/evidence/control/execution/**` | plan prose |
| Execution queue candidates | plan control root until compiled; run contract becomes canonical execution control | generated task board |
| Run execution | `state/control/execution/runs/<run-id>/**` | plan tree |
| Evidence from execution | `state/evidence/runs/<run-id>/**` | plan node fields alone |
| Continuity handoff | `state/continuity/repo/missions/<mission-id>/**` | generated summaries |
| Visualizations | `generated/cognition/projections/materialized/planning/**` | any authority/control/evidence root |
| Proposal packet for feature | `inputs/exploratory/proposals/architecture/<proposal_id>/` | runtime resolution |

This follows Octon’s existing architecture specification: authored authority is `framework/**` and `instance/**`; mutable control is `state/control/**`; retained evidence is `state/evidence/**`; continuity is separate; generated operator read models and proposal inputs are non-authoritative. ([GitHub][14])

---

## 9. Runtime Integration Plan

The runtime integration should be deliberately narrow.

### Orchestrator Responsibilities

The orchestrator may:

```text
Create a MissionPlan candidate.
Select branches for decomposition.
Run duplicate/dependency/readiness checks.
Compile ready leaves into action-slice candidates.
Request context packs.
Request authorization.
Update plan state from retained evidence.
Escalate conflicts, missing approvals, and drift.
```

The orchestrator may not:

```text
Use a plan as authority.
Bypass run contracts.
Bypass authorize_execution.
Treat generated plan views as control truth.
Treat proposal packets or raw inputs as runtime dependencies.
Declare consequential completion without evidence-store completeness.
```

That matches the existing orchestrator role: it binds requests to the smallest robust implementation plan, owns sequencing and integration, and escalates unresolved risk, policy, support-target, or validation issues. ([GitHub][9])

### Mission/Run Binding

The mission remains the continuity container. Consequential execution remains bound to per-run contracts under `state/control/execution/runs/<run-id>/**`, exactly as the missions and runs READMEs define. ([GitHub][4])

### Context Pack Construction

The context pack should include:

```text
mission.yml
mission digest
MissionPlan control refs
selected PlanNode refs
DependencyEdge refs
ActionSlice candidate
run-contract draft
risk and rollback refs
support-target tuple refs
required evidence refs
approval refs
```

But the Context Pack Builder must preserve source classes. It already distinguishes durable authority, control, evidence, continuity, generated handles, capabilities, derived sources, and non-authoritative inputs, and it blocks missing/stale context. ([GitHub][10])

### Capability Gates And Support-Target Admission

A plan node may propose required capabilities, but it must not admit capabilities or widen support claims. Support-target policy is deny-by-default, uses bounded admitted finite support claims, forbids support claim widening, and keeps generated support matrices as derived runtime handles rather than policy authority. ([GitHub][18])

### Evidence Capture

Every consequential planning transition should produce retained evidence:

```text
plan-created receipt
decomposition receipt
critic receipt
duplicate-check receipt
dependency-check receipt
readiness-check receipt
compile receipt
approval receipt
drift receipt
plan-revision receipt
plan-closeout receipt
```

Run evidence remains under `state/evidence/runs/**`; planning evidence for control mutations belongs under `state/evidence/control/execution/**`, consistent with Octon’s evidence obligations. ([GitHub][19])

### Replay And Rollback

Replay reconstructs execution from the Run Journal first. The plan may help explain why the run existed, but it must not become replay authority. Run lifecycle and Run Journal specs already state that generated/input artifacts are invalid lifecycle authority and that replay reconstructs from the canonical journal. ([GitHub][15])

Rollback should update the plan node’s derived status, but rollback truth remains in run control and run evidence.

---

## 10. Proposal Packet Integration

This feature should be introduced through an **architecture proposal packet**, because it adds a new planning/control surface and changes runtime workflow boundaries.

Octon’s proposal README says active manifest-governed proposals live under:

```text
.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/
```

and every manifest-governed proposal must include `proposal.yml`, exactly one subtype manifest, `README.md`, `navigation/source-of-truth-map.md`, `navigation/artifact-catalog.md`, and optional `support/`. It also says proposals are non-canonical and excluded from runtime and policy resolution. ([GitHub][20])

The generic proposal standard confirms that proposal authority is limited to `proposal.yml` and the subtype manifest, that `generated/proposals/registry.yml` is discovery-only, and that proposals cannot claim canonical authority at any lifecycle stage. ([GitHub][21])

Because this is an architecture change, the packet should follow the architecture proposal standard, which requires:

```text
architecture-proposal.yml
architecture/target-architecture.md
architecture/acceptance-criteria.md
architecture/implementation-plan.md
```

and requires the source-of-truth map to identify durable authorities, proposal-local authorities, derived projections, retained evidence surfaces, and boundary rules. ([GitHub][22])

Recommended packet:

```text
.octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer/
  proposal.yml
  architecture-proposal.yml
  README.md
  navigation/
    source-of-truth-map.md
    artifact-catalog.md
  architecture/
    target-architecture.md
    current-state-gap-map.md
    hierarchical-planning-model.md
    authority-control-evidence-map.md
    workflow-lifecycle.md
    schemas-and-artifacts.md
    stop-rules-and-anti-bloat-controls.md
    runtime-integration-plan.md
    governance-and-approval-plan.md
    validation-plan.md
    migration-plan.md
    rollback-plan.md
    acceptance-criteria.md
  support/
    SHA256SUMS.txt
```

The user-suggested packet files are mostly appropriate, but the required Octon subtype files must be placed under `architecture/`, not invented as top-level canonical conventions.

The proposal may use hierarchical planning to organize its own implementation work, but the proposal packet must not itself become the runtime planning authority.

---

## 11. Stop Rules And Anti-Bloat Controls

Octon should make stop rules validator-enforced, not advisory.

### Default Depth Budget

Default semantic depth:

```text
Mission
→ Workstream
→ Milestone
→ Deliverable
→ ActionSlice candidate
```

That is enough for most Octon work. Avoid default `Task → Subtask → AtomicAction` recursion because Octon already has `action-slice-v1` as the executable leaf.

### Risk-Based Depth

```text
ACP-0 / ACP-1:
  max depth 4 unless needed for validation

ACP-2:
  max depth 5; requires explicit evidence requirements and rollback mapping

ACP-3:
  decomposition may draft, but compile requires human approval

ACP-4 or destructive / irreversible:
  planning allowed only in stage-only mode until explicit human approval and authorization gates exist
```

The risk ceiling should inherit from mission authority, because missions already define `risk_ceiling` and allowed action classes. ([GitHub][5])

### Branch Decomposition Budget

```text
Max children per node by default: 7
Max open decompositions per branch: 3
Max initial executable leaves: 20
Max plan revisions without execution evidence: 2
```

If a branch exceeds the budget, it must become one of:

```text
blocked
requires human decision
requires discovery run
requires proposal
deferred
```

### Executability Test

A node is executable only if it can be compiled to an action-slice candidate with:

```text
mission_id
action_class
scope_ids
predicted_acp
reversibility
safe_interrupt_boundary
blast_radius
executor_profile
approval_required
rollback_primitive or compensation_primitive
evidence_required
```

Those fields mirror the existing action-slice schema. ([GitHub][7])

### Validation-Readiness Test

A node is ready only if it has:

```text
expected output
acceptance criteria
validation method
evidence root
dependencies resolved or explicitly blocked
risk classification
rollback or compensation path
support-target tuple refs
authorization path
```

### Rolling-Wave Rule

Only near-term or blocking work may be decomposed to action-slice level. Future work must stop at milestone or deliverable level unless deeper decomposition is needed to expose risk, approval, rollback, or dependency issues.

### No “Planning As Progress”

A plan revision does not count as progress unless it produces one of:

```text
resolved dependency
resolved decision
validated assumption
compiled action-slice candidate
approved run-contract draft
retained evidence
closed blocker
```

### Staleness Checks

A plan becomes stale when:

```text
mission digest changes
risk ceiling changes
allowed action classes change
support-target tuple changes
run evidence contradicts assumptions
dependency edge is invalidated
compiled run closes, fails, rolls back, or is revoked
required evidence is missing or stale
```

Plan staleness should block compilation, not necessarily block all reading or generated visualization.

---

## 12. Human Oversight And Governance Gates

The workflow should be **hybrid**.

### Agent May Do Independently

```text
Draft a MissionPlan candidate.
Draft workstreams.
Draft dependency edges.
Draft risks, assumptions, and decision points.
Suggest branch decomposition.
Run duplicate/dependency/staleness checks.
Compile low-risk ready leaves into action-slice candidates.
Prepare run-contract drafts.
Prepare approval requests.
Update plan status from retained run evidence.
```

### Human Must Approve

```text
Mission creation or mission scope change.
Strategic goal changes.
Risk ceiling changes.
Protected-zone mutation.
Support-target widening.
Capability admission.
External effects.
Destructive or irreversible actions.
High-risk workstream activation.
Plan mutation that changes mission scope after execution begins.
Completion declaration for consequential work.
```

This matches Octon’s ownership rules: humans own charter changes, support-target changes, policy changes, one-way-door approvals, exception leases, public/external commitments, and final release sign-off; models own bounded planning, run-contract drafts, capability invocation strategy within granted scope, local checks, and low-risk retries, but cannot approve/revoke/grant exceptions, widen support tiers, authorize irreversible actions, or perform final consequential acceptance. ([GitHub][23])

### Approval Thresholds

```text
ACP-0 / ACP-1:
  agent may decompose and stage; authorization still required for material effects

ACP-2:
  agent may decompose; human approval required before activation if scope/risk/support changes

ACP-3:
  human approval before compile-to-run

ACP-4 / destructive / irreversible:
  human approval before decomposition beyond risk/decision mapping
```

---

## 13. Failure Modes And Mitigations

| Failure mode | Harm to Octon | Mitigation |
| --- | --- | --- |
| Second orchestrator | Splits accountability | Planner is a tool of the single orchestrator; no independent execution authority |
| Generated plan treated as authority | Violates class-root model | Generated views are projections only; validators reject runtime reads from generated planning maps |
| Plan bypasses authorization | Breaks runtime gate | Leaves compile only to action-slice/run-contract candidates; material effects still require `authorize_execution` |
| Proposal packet becomes runtime dependency | Violates proposal non-canonical rule | Proposals remain under `inputs/exploratory/proposals/**` and are excluded from runtime/policy resolution |
| Planning bloat | Slows operator, creates fake progress | Depth, child-count, revision, and rolling-wave budgets |
| Infinite decomposition | Agent avoids execution | Executability test; after two non-useful decompositions, branch must execute, block, defer, or escalate |
| Duplicate work | Multiple branches compile same work | Global duplicate check by scope/output/dependencies/action class |
| Stale plans | Plan diverges from evidence | Plan drift records; stale plans block compile |
| Brittle assumptions | Plans encode guesses as facts | Assumption ledger; unresolved assumptions compile only to discovery work |
| Weakens mission-scoped autonomy | Plan mutates scope | Mission digest binding; scope mutation requires mission owner approval |
| Turns Octon into PM tool | Expands beyond governance harness | Planning applies only to mission-scoped, governed execution; no generic task board semantics |
| Increases cognitive load | Operators face huge trees | Generated dashboards show only active branches, blockers, decisions, and compiled leaves |
| Makes evidence harder | Plan has its own truth | Plan mutations retain evidence; run evidence remains canonical |

---

## 14. Repository Change Plan

### Phase 1: Proposal Packet

Create:

```text
.octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer/
```

with the required base and architecture proposal files. This respects Octon’s proposal packet rules and keeps the feature non-authoritative until promoted. ([GitHub][20])

### Phase 2: Framework Doctrine And Schemas

Add durable authored authority under `framework/**`, for example:

```text
.octon/framework/engine/runtime/spec/mission-plan-v1.md
.octon/framework/engine/runtime/spec/mission-plan-v1.schema.json
.octon/framework/engine/runtime/spec/plan-node-v1.schema.json
.octon/framework/engine/runtime/spec/plan-dependency-edge-v1.schema.json
.octon/framework/engine/runtime/spec/plan-revision-record-v1.schema.json
.octon/framework/engine/runtime/spec/plan-compile-receipt-v1.schema.json
```

Update the contract registry so the new path family is declared. Octon’s architecture specification says overlay legality and class placement must be declared, and undeclared overlays or wrong-class placement are invalid. ([GitHub][14])

### Phase 3: Workflow Integration

Add a framework workflow under the existing orchestration workflow structure, preferably in the mission workflow family rather than inventing an unrelated control surface:

```text
.octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/
  workflow.yml
  stages/
```

The workflow should be governed like existing workflows: the workflows README says each workflow unit has a canonical `workflow.yml`, stages, and required authorization blocks for side effects. ([GitHub][24])

### Phase 4: Instance Policy

Add optional instance policy:

```text
.octon/instance/governance/policies/hierarchical-planning.yml
```

This is a valid overlay style because the overlay registry includes `instance-governance-policies` with instance glob `.octon/instance/governance/policies/**`. ([GitHub][25])

### Phase 5: State Roots

Add, if the contract registry and validators are updated:

```text
.octon/state/control/execution/missions/<mission-id>/plans/<plan-id>/
.octon/state/evidence/control/execution/planning/<plan-id>/
.octon/generated/cognition/projections/materialized/planning/
```

The state location is consistent with existing mission boundary rules for mission-local control, control evidence, generated summaries, and mission continuity. ([GitHub][4])

### Phase 6: Validators And Tests

Add validator coverage for:

```text
schema validation
class-root placement
mission binding
depth budget
duplicate nodes
dependency cycles
generated/input/proposal authority misuse
action-slice compile readiness
authorization non-bypass
evidence completeness
drift blocking
rollback mapping
```

Octon already treats validators as enforcement surfaces in proposal workflows, but not substitutes for manifests and standards. ([GitHub][20])

---

## 15. Validation And Acceptance Criteria

A hierarchical planning layer should be accepted only if all of the following pass.

### Structural Acceptance

```text
No planning artifact under inputs/** or generated/** is used as runtime authority.
All durable doctrine/schemas live under framework/**.
All instance enablement lives under instance/**.
All mutable plan state lives under state/control/**.
All plan mutation evidence lives under state/evidence/**.
All generated plan views are derived-only.
```

### Runtime Acceptance

```text
A PlanNode cannot directly execute.
A PlanNode cannot bypass run-contract creation.
A PlanNode cannot bypass context-pack construction.
A PlanNode cannot bypass authorize_execution.
A PlanNode cannot widen support targets.
A PlanNode cannot admit capabilities.
A PlanNode cannot mutate mission scope without approval.
```

### Evidence Acceptance

```text
Every plan revision has a retained evidence record.
Every compiled leaf has a compile receipt.
Every authorized execution has run evidence.
Every plan update after execution cites run journal or evidence-store records.
Every stale plan condition blocks further compile.
Every rollback updates plan projection without replacing run rollback truth.
```

### Anti-Bloat Acceptance

```text
Default maximum depth is enforced.
Rolling-wave limits are enforced.
Duplicate detection is enforced.
Dependency cycles are rejected or staged.
More than two non-useful decomposition passes force execute/block/defer/escalate.
Future work cannot be decomposed to action-slice level without a risk/dependency/approval reason.
```

### Governance Acceptance

```text
Mission owner approval is required for mission binding or scope mutation.
Human approval is required for high-risk, irreversible, external, protected-zone, support-target, and capability-admission changes.
Generated dashboards cannot be cited as authority.
Proposal packet paths cannot remain in promoted runtime targets.
```

### Rollback Acceptance

```text
Removing the planning layer leaves mission.yml, action slices, run contracts, authorization, evidence, rollback, and continuity operational.
Plan roots can be retired or archived without breaking runtime replay.
Generated planning projections can be deleted and rebuilt.
Existing missions and runs remain valid.
```

---

## 16. Final Recommendation

**Choose option 2: Adopt as a bounded optional planning layer.**

Do not adopt the full recursive hierarchy as a core Octon workflow. Do not make it fully autonomous. Do not let it become proposal authority, generated authority, or execution authority.

The exact adoption scope should be:

```text
Adopt:
  Mission-bound planning container
  Typed PlanNode model
  Dependency edges separate from hierarchy
  Risk / decision / assumption records
  Readiness checks
  Compile-to-action-slice workflow
  Evidence-backed plan revisions
  Generated plan projections

Do not adopt:
  Fully autonomous recursive decomposition
  Generic project-management boards
  Atomic free-text execution steps
  Plan-as-authority semantics
  Plan-owned execution queue
  Generated plan dashboards as canonical state
```

The architectural rationale is simple: Octon’s current posture is already a governed runtime with mission-scoped reversible autonomy, run contracts, context packs, engine-owned authorization, evidence retention, replay, rollback, intervention, support-proof dossiers, and generated projections. A bounded hierarchical planning layer can strengthen this by making mission-to-run decomposition more explicit and auditable. It weakens Octon if it becomes anything more powerful than that.

The implementation should land through an architecture proposal packet, be promoted only into durable `framework/**`, `instance/**`, `state/**`, and validator surfaces, and remain **stage-only** until the validation suite proves that plans cannot bypass mission authority, run contracts, context packs, authorization, evidence, replay, rollback, or support-target governance.

[1]: https://github.com/jamesryancooper/octon "GitHub - jamesryancooper/octon · GitHub"
[2]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/constitution/CHARTER.md "raw.githubusercontent.com"
[3]: https://github.com/jamesryancooper/octon/tree/main/.octon "octon/.octon at main · jamesryancooper/octon · GitHub"
[4]: https://github.com/jamesryancooper/octon/tree/main/.octon/instance/orchestration/missions "octon/.octon/instance/orchestration/missions at main · jamesryancooper/octon · GitHub"
[5]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/engine/runtime/spec/mission-charter-v2.schema.json "octon/.octon/framework/engine/runtime/spec/mission-charter-v2.schema.json at main · jamesryancooper/octon · GitHub"
[6]: https://github.com/jamesryancooper/octon/tree/main/.octon/state/control/execution/missions/mission-autonomy-live-validation "octon/.octon/state/control/execution/missions/mission-autonomy-live-validation at main · jamesryancooper/octon · GitHub"
[7]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/engine/runtime/spec/action-slice-v1.schema.json "octon/.octon/framework/engine/runtime/spec/action-slice-v1.schema.json at main · jamesryancooper/octon · GitHub"
[8]: https://github.com/jamesryancooper/octon/tree/main/.octon/framework/orchestration/runtime/runs "octon/.octon/framework/orchestration/runtime/runs at main · jamesryancooper/octon · GitHub"
[9]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/execution-roles/runtime/orchestrator/ROLE.md "octon/.octon/framework/execution-roles/runtime/orchestrator/ROLE.md at main · jamesryancooper/octon · GitHub"
[10]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md "octon/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md at main · jamesryancooper/octon · GitHub"
[11]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/engine/runtime/spec/execution-authorization-v1.md "octon/.octon/framework/engine/runtime/spec/execution-authorization-v1.md at main · jamesryancooper/octon · GitHub"
[12]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/engine/runtime/spec/evidence-store-v1.md "octon/.octon/framework/engine/runtime/spec/evidence-store-v1.md at main · jamesryancooper/octon · GitHub"
[13]: https://github.com/jamesryancooper/octon/tree/main/.octon/framework/orchestration/runtime/missions "octon/.octon/framework/orchestration/runtime/missions at main · jamesryancooper/octon · GitHub"
[14]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/cognition/_meta/architecture/specification.md "octon/.octon/framework/cognition/_meta/architecture/specification.md at main · jamesryancooper/octon · GitHub"
[15]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md "octon/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md at main · jamesryancooper/octon · GitHub"
[16]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/ingress/AGENTS.md "raw.githubusercontent.com"
[17]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/engine/runtime/spec/run-journal-v1.md "octon/.octon/framework/engine/runtime/spec/run-journal-v1.md at main · jamesryancooper/octon · GitHub"
[18]: https://github.com/jamesryancooper/octon/blob/main/.octon/instance/governance/support-targets.yml "octon/.octon/instance/governance/support-targets.yml at main · jamesryancooper/octon · GitHub"
[19]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/constitution/obligations/evidence.yml "octon/.octon/framework/constitution/obligations/evidence.yml at main · jamesryancooper/octon · GitHub"
[20]: https://github.com/jamesryancooper/octon/tree/main/.octon/inputs/exploratory/proposals "octon/.octon/inputs/exploratory/proposals at main · jamesryancooper/octon · GitHub"
[21]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/scaffolding/governance/patterns/proposal-standard.md "octon/.octon/framework/scaffolding/governance/patterns/proposal-standard.md at main · jamesryancooper/octon · GitHub"
[22]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md "octon/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md at main · jamesryancooper/octon · GitHub"
[23]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/constitution/ownership/roles.yml "octon/.octon/framework/constitution/ownership/roles.yml at main · jamesryancooper/octon · GitHub"
[24]: https://github.com/jamesryancooper/octon/tree/main/.octon/framework/orchestration/runtime/workflows "octon/.octon/framework/orchestration/runtime/workflows at main · jamesryancooper/octon · GitHub"
[25]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/overlay-points/registry.yml "octon/.octon/framework/overlay-points/registry.yml at main · jamesryancooper/octon · GitHub"
