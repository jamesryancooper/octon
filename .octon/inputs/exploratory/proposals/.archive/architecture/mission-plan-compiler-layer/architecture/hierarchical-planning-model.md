# Hierarchical Planning Model

## Model Rule

Use one minimal typed planning model. Do not create separate durable schemas
for workstream, milestone, deliverable, task, subtask, and atomic action.

The hierarchy should be:

```text
MissionPlan
-> PlanNode tree
-> DependencyEdge graph
-> readiness and critic receipts
-> action-slice candidates
-> run-contract drafts
```

## MissionPlan

`MissionPlan` is the mission-bound planning container. It is mutable control
state after durable promotion and should live under:

```text
.octon/state/control/execution/missions/<mission-id>/plans/<plan-id>/plan.yml
```

Required fields:

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

## PlanNode

`PlanNode` is the only node schema. Node type carries semantics without
creating a schema family explosion.

Required fields:

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

## DependencyEdge

Dependencies are not hierarchy. They are explicit graph edges so a child tree
does not hide blocking work, approvals, rollback coupling, or support-target
dependencies.

Required fields:

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

## Evidence Records

Promoted planning should retain:

- `PlanRevisionRecord` for digest-to-digest plan changes
- `PlanCompileReceipt` for leaf-to-action-slice/run-contract/context request mappings
- `PlanDriftRecord` for mission, run, evidence, or assumption mismatch

These records belong under:

```text
.octon/state/evidence/control/execution/planning/<plan-id>/**
```

## Executable Leaf Rule

A plan leaf is executable only when it can be compiled into an
`action-slice-v1` candidate with mission ID, action class, scope IDs, predicted
ACP, reversibility class, safe interrupt boundary class, blast radius,
externality class, executor profile, approval requirement, owner attestation
requirement, rationale, and rollback or compensation primitive.
