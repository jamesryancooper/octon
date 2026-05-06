# Mission Plan Compiler v1

## Purpose

Mission Plan Compiler v1 defines an optional, mission-bound preparation layer
between mission authority and run-contract execution.

The layer helps the single accountable orchestrator decompose approved mission
authority into typed planning state, readiness checks, action-slice candidates,
run-contract drafts, context-pack requests, authorization requests, rollback
refs, and evidence requirements.

It is not a second orchestrator, execution queue, project-management board,
generated dashboard authority, support-target admission path, or run lifecycle
replacement.

## Authority Boundary

Mission planning starts only from one of these durable authority inputs:

- an existing `octon-mission-v2` mission;
- an approved mission candidate promoted through mission workflow authority; or
- an accepted proposal whose promotion requires mission-scoped execution.

Planning artifacts never create or widen mission authority. Mission scope,
owner, risk ceiling, allowed action classes, support posture, and completion
authority remain governed by the mission, workspace charter, governance policy,
run contract, and authorization boundary.

The forbidden flow is:

```text
MissionPlan -> direct execution
```

The allowed compiler flow is:

```text
mission authority
-> MissionPlan candidate
-> PlanNode decomposition
-> dependency, risk, assumption, and decision mapping
-> readiness checks
-> action-slice candidates
-> run-contract drafts
-> context-pack requests
-> authorization requests
-> execution through the existing run lifecycle
-> plan revision from retained evidence
```

## Canonical Artifacts

Durable doctrine and schemas live under:

```text
.octon/framework/engine/runtime/spec/
```

The schema family is:

- `mission-plan-v1.schema.json`
- `plan-node-v1.schema.json`
- `plan-dependency-edge-v1.schema.json`
- `plan-revision-record-v1.schema.json`
- `plan-compile-receipt-v1.schema.json`
- `plan-drift-record-v1.schema.json`

Future mission-bound mutable planning control state lives under:

```text
.octon/state/control/execution/missions/<mission-id>/plans/<plan-id>/
```

Future plan mutation evidence lives under:

```text
.octon/state/evidence/control/execution/planning/<plan-id>/
```

Generated planning operator views, if later admitted, live only as derived
operator read models under:

```text
.octon/generated/cognition/projections/materialized/planning/
```

Generated planning views are forbidden as runtime authority, policy authority,
control truth, evidence substitutes, support claims, or closure evidence.

## Artifact Roles

`MissionPlan` is mutable planning control state bound to one mission digest. It
records objective decomposition, risk limits, budgets, support-target refs,
scope refs, evidence roots, and compiled lineage. It is not authority.

`PlanNode` is a typed planning node. It can describe goals, workstreams,
milestones, deliverables, action-slice candidates, validation gates, decision
points, risks, or assumptions. It is not an executable action.

`PlanDependencyEdge` records non-tree dependencies between nodes so the plan
tree does not hide cycles, blockers, or cross-branch ordering.

`PlanRevisionRecord` is retained evidence for plan digest changes.

`PlanCompileReceipt` is retained evidence that one ready leaf was compiled to
candidates or requests. It is not an authorization grant.

`PlanDriftRecord` is retained evidence that the plan became stale or
contradicted by mission, policy, evidence, dependency, support, or run state.

## Compile Semantics

A ready leaf may compile only to:

- an `action-slice-v1` candidate;
- a run-contract draft;
- a context-pack request;
- an authorization request;
- rollback or compensation refs; and
- retained evidence requirements.

Compiled leaves do not execute. Material execution remains subject to
run-contract binding, Context Pack Builder, `authorize_execution`, typed
authorized-effect tokens, retained run evidence, Run Journal coverage, replay,
rollback, and support-target governance.

## Readiness Requirements

A node is ready for compile only when it has:

- expected output;
- acceptance criteria;
- validation method;
- retained evidence requirements;
- dependency disposition;
- risk classification;
- rollback or compensation path;
- support-target tuple refs;
- approval disposition; and
- authorization path.

Unresolved assumptions may compile only to discovery work or remain blocked.
Unresolved approvals, scope changes, support-target widening, capability
admission, high-risk activation, destructive work, irreversible work, or
external effects require the governing human approval path before compile-to-run.

## Stop Rules

Planning is bounded by instance policy and must fail closed when a branch
exceeds the configured depth, breadth, rolling-wave, open-decomposition, or
revision-without-evidence budgets.

More than two non-useful decomposition passes without execution evidence,
resolved dependencies, validated assumptions, approved run-contract drafts, or
closed blockers must route to execute, block, defer, or escalate.

## Fail-Closed Conditions

Planning must block compile or route to stage-only, escalation, or denial when:

- mission binding is missing or digest-stale;
- a plan or node is cited as runtime authority;
- a node attempts direct execution;
- duplicate work is detected by scope, output, dependency, or action class;
- dependency cycles are unresolved;
- required compile receipts are missing;
- required ownership or approval evidence is missing;
- support-target refs would widen support claims;
- a capability admission is attempted through planning;
- context-pack construction is bypassed;
- `authorize_execution` is bypassed;
- run-contract binding is bypassed;
- rollback truth is replaced by plan status; or
- generated, raw input, host, chat, or proposal-local surfaces are treated as
  authority, control truth, support proof, or closure evidence.

## Replay And Rollback

Run replay reconstructs execution from the Run Journal first. A plan may explain
why a run exists, but it is never replay authority.

Rollback truth remains in run control and retained run evidence. Planning
rollback updates only plan status, stale/blocked disposition, derived operator
views, and retained planning evidence.

Disabling hierarchical planning must leave missions, action slices, run
contracts, authorization, retained evidence, replay, rollback, continuity, and
support-target claims operational.

## Related Contracts

- `mission-charter-v2.schema.json`
- `action-slice-v1.schema.json`
- `run-lifecycle-v1.md`
- `run-journal-v1.md`
- `context-pack-builder-v1.md`
- `execution-authorization-v1.md`
- `evidence-store-v1.md`
- `/.octon/instance/governance/policies/hierarchical-planning.yml`
