# Implementation Plan

## Workstream 1: Runtime Doctrine And Schemas

Add `mission-plan-v1.md` and schemas for MissionPlan, PlanNode,
DependencyEdge, PlanRevisionRecord, PlanCompileReceipt, and PlanDriftRecord
under `framework/engine/runtime/spec/`.

Acceptance:

- schemas parse and validate representative fixtures
- doctrine states plan non-authority and compile-only boundaries
- schema fields carry mission digest, risk, support-target, evidence, and
  compile mapping requirements

## Workstream 2: Registries And Placement

Update structural and constitutional registries to declare the planning family,
control root, evidence root, generated projection posture, and validators.

Acceptance:

- planned roots have declared class roles
- generated planning projections are marked derived-only
- proposal and generated paths are forbidden as runtime authority

## Workstream 3: Mission Workflow

Add `derive-mission-plan` under the mission workflow family with stages for
mission binding, plan drafting, critic/readiness, leaf compilation, and
evidence-based revision.

Acceptance:

- workflow requires mission authority before planning
- workflow compiles leaves only to action-slice candidates and run-contract
  drafts
- workflow records evidence requirements and rollback posture

## Workstream 4: Instance Policy

Add optional instance policy for hierarchical planning budgets, risk thresholds,
and approval thresholds.

Acceptance:

- default route is disabled or stage-only until validators pass
- policy cannot widen mission scope, support targets, or capabilities
- ACP-3 and ACP-4 thresholds require human approval before compile-to-run

## Workstream 5: Validators And Tests

Add `validate-mission-plan-compiler.sh` plus fixtures or shell tests covering
positive and negative cases.

Acceptance:

- valid mission-bound plan passes
- generated/input/proposal authority misuse fails
- direct execution from PlanNode fails
- stale mission digest blocks compile
- dependency cycles fail or stage
- duplicate leaf candidates fail or stage
- missing compile receipt fails
- support-target widening fails

## Workstream 6: Documentation And Closeout

Update mission, run, context-pack, authorization, evidence, and lifecycle docs
only where needed to describe the new preparation layer and its non-authority
boundary.

Acceptance:

- durable docs do not cite this active proposal as authority
- implementation conformance receipt passes
- drift/churn receipt passes
- proposal registry is regenerated
- packet is archived after promotion evidence is retained
