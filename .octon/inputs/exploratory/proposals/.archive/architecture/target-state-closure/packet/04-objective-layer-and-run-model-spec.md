# 04. Objective Layer and Run Model Spec

## 1. Goal

Normalize the objective stack into one coherent, machine-enforced model:

**Workspace Charter + Mission Charter + Run Contract + Execution Attempt/Stage + Checkpoint + Continuity**

Mission remains the continuity container.
Run contract remains the atomic consequential execution primitive.

## 2. Preserve current load-bearing surfaces

Preserve:

- `.octon/instance/charter/workspace.md`
- `.octon/instance/charter/workspace.yml`
- `.octon/instance/orchestration/missions/<mission-id>/**`
- `.octon/state/control/execution/runs/<run-id>/**`
- `.octon/state/continuity/{repo,scopes,missions,runs}/**`

## 3. Problems to solve

1. workspace machine charter and charter-pair still reference different canonical run-contract families
2. mission authority is operationally real but under-normalized at the constitutional contract layer
3. stage/attempt semantics remain split between objective and runtime families
4. mission-vs-run rules still rely partly on prose instead of deterministic validation

## 4. Target canonical family

### 4.1 Workspace charter pair

Preserve paths:
- `workspace.md` remains human-readable
- `workspace.yml` remains machine-readable
- the charter-pair contract remains the binder

Normalize both to point only to the canonical `runtime/run-contract-v3` family and the canonical runtime stage-attempt family.

### 4.2 Mission charter

Create canonical schema:

- `.octon/framework/constitution/contracts/objective/mission-charter-v1.schema.json`

Mission machine artifacts remain at:
- `.octon/instance/orchestration/missions/<mission-id>/mission.yml`

Optional narrative remains at:
- `.octon/instance/orchestration/missions/<mission-id>/mission.md`

Required fields:
- `mission_id`
- `version`
- `mission_class`
- `owner_ref`
- `workspace_refs`
- `allowed_run_classes`
- `default_support_tiers`
- `autonomy_class`
- `protected_zones`
- `scope_refs`
- `approval_policy_ref`
- `quorum_policy_ref`
- `revocation_policy_ref`
- `continuity_root_ref`
- `retention_expectations`
- `retirement_triggers`

### 4.3 Canonical run contract

Create the one live canonical family:

- `.octon/framework/constitution/contracts/runtime/run-contract-v3.schema.json`

Why v3:
- v1 contains richer objective semantics
- v2 contains runtime-native execution binding
- v3 merges them and ends the split

Required v3 fields:
- `schema_version`
- `run_id`
- `status`
- `workflow_mode`
- `objective_refs`
- `objective_summary`
- `scope_in`
- `scope_out`
- `done_when`
- `acceptance_criteria`
- `materiality`
- `risk_class`
- `reversibility_class`
- `requested_capabilities`
- `requested_capability_packs`
- `protected_zone_scope`
- `support_target_ref`
- `support_target_tuple`
- `mission_id`
- `requires_mission`
- `required_approvals`
- `required_evidence`
- `retry_class`
- `rollback_posture_ref`
- `stage_attempt_root`
- `checkpoint_root`
- `continuity_root_ref`
- `authority_bundle_ref`
- `run_manifest_ref`
- `runtime_state_ref`
- `run_card_ref`

### 4.4 Stage / attempt contract

Create canonical runtime family:

- `.octon/framework/constitution/contracts/runtime/stage-attempt-v2.schema.json`

Retire to shim:
- `.octon/framework/constitution/contracts/objective/stage-attempt-v1.schema.json`

Rule:
- all live claim-bearing runs bind the runtime family only

### 4.5 Checkpoint family

If current checkpoint schema is sufficient, preserve its family and version.
If not, introduce:

- `.octon/framework/constitution/contracts/runtime/checkpoint-v2.schema.json`

### 4.6 Continuity artifact

Canonical run continuity path:

- `.octon/state/continuity/runs/<run-id>/continuity.yml`

Required fields:
- `run_id`
- `latest_checkpoint_ref`
- `pending_stage_ref`
- `remaining_tasks`
- `contamination_status`
- `resume_preconditions`
- `handoff_notes`
- `source_run_contract_ref`

## 5. Mission vs run rules

### Mission required
Mission is mandatory for:
- recurring or scheduled autonomy
- overlapping or long-horizon work
- boundary-sensitive or protected-zone mutation
- any support tier whose policy declares `requires_mission: true`

### Mission optional
Mission may be omitted only for:
- bounded observe-and-read runs
- bounded repo-local consequential runs in admitted support tiers
- one-off reversible work with no recurring autonomy or boundary-sensitive scope

### Fail-closed rule
If a run requires a mission and `mission_id` is missing:
- route may be `stage_only` at most
- material side effects are denied
- the run may not count as live admitted support evidence

## 6. Migration

1. Add mission-charter schema.
2. Add `runtime/run-contract-v3`.
3. Add `runtime/stage-attempt-v2`.
4. Rebind workspace machine charter and charter-pair to v3/v2.
5. Mark `objective/run-contract-v1` and `runtime/run-contract-v2` as deprecated shims.
6. Backfill claim-bearing run bundles to v3 references.
7. Add `validate-single-canonical-run-contract-family.sh`.

## 7. Acceptance criteria

- one and only one canonical live run-contract family remains
- mission authority is schema-normalized at the constitutional contract layer
- every claim-bearing run binds workspace charter, optional mission charter, run-contract-v3, and stage-attempt-v2
- mission is no longer the atomic consequential execution primitive anywhere in the live claim path
