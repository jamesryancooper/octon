# Mission-Control Contract Deltas

This document defines the final steady-state mission-control family.

## Canonical Mission-Control Layout

```text
.octon/state/control/execution/missions/<mission-id>/
├── lease.yml
├── mode-state.yml
├── intent-register.yml
├── action-slices/
│   ├── <slice-id>.yml
│   └── ...
├── directives.yml
├── authorize-updates.yml
├── schedule.yml
├── autonomy-budget.yml
├── circuit-breakers.yml
└── subscriptions.yml
```

## Why This Layout

- mission continuity lives in one place
- interaction grammar becomes complete
- intent and action-slice identity become explicit
- scheduler and runtime consume the same control truth
- read models and control receipts can project from one canonical family

## Contract Decisions

### 1. `lease.yml`
Keep `mission-control-lease-v1`.

Required semantics:
- one current lease per mission
- explicit `state`
- explicit `continuation_scope`
- allowed postures and allowed action classes
- no ambient authority beyond the lease contents

### 2. `mode-state.yml`
Keep `mode-state-v1`, but tighten it.

Required fields:
- `mission_id`
- `oversight_mode`
- `execution_posture`
- `safety_state`
- `phase`
- `active_run_ref`
- `current_slice_ref`
- `next_safe_interrupt_boundary_id`
- `effective_scenario_resolution_ref` **required for active or paused missions**
- `autonomy_burn_state`
- `breaker_state`
- `updated_at`

Required normalization:
- `breaker_state` must use the same vocabulary as `circuit-breakers.yml`

### 3. `intent-register.yml`
Keep `intent-register-v1`, but tighten it.

Required register-level fields:
- `mission_id`
- `revision`
- `generated_from`
- `entries`

Required entry fields:
- `intent_id`
- `sequence`
- `action_slice_ref`
- `intent_ref`
- `action_class`
- `predicted_acp`
- `reversibility_class`
- `earliest_start`
- `feedback_deadline` when relevant
- `default_on_silence`
- `operator_options`
- `expected_externality_class`
- `state` (`queued`, `active`, `consumed`, `cancelled`, `expired`)

Rule:
- for material autonomous work, an active or next entry is required

### 4. `action-slices/<slice-id>.yml`
Keep `action-slice-v1`, and make placement explicit.

Required fields:
- `slice_id`
- `mission_id`
- `title`
- `action_class`
- `scope_ids`
- `predicted_acp`
- `reversibility_class`
- `rollback_primitive` or `compensation_primitive`
- `safe_interrupt_boundary_class`
- `expected_blast_radius`
- `expected_externality_class`
- `executor_profile`
- `approval_required`
- `owner_attestation_required`
- `rationale`
- `created_at`
- `updated_at`

Rule:
- intent entries reference slices
- receipts reference slices
- route generation consumes slices

### 5. `directives.yml`
Keep `control-directive-v1`, but tighten it.

Required per-directive fields:
- `directive_id`
- `type`
- `state`
- `issuer_ref`
- `issued_at`
- `expires_at`
- `payload`
- `consumed_by_receipt_ref`

Supported types:
- `pause_at_boundary`
- `suspend_future_runs`
- `stop_after_slice`
- `reprioritize`
- `narrow_scope`
- `exclude_target`
- `block_finalize`
- `enter_safing`

### 6. `authorize-updates.yml`
Add `authorize-update-v1`.

This is the missing binding surface for synchronous authority mutations.

Required per-entry fields:
- `update_id`
- `type`
- `state`
- `issuer_ref`
- `issued_at`
- `expires_at`
- `payload`
- `applied_by_receipt_ref`

Supported types:
- `approve`
- `extend_lease`
- `revoke_lease`
- `raise_budget`
- `grant_exception`
- `reset_breaker`
- `enter_break_glass`
- `exit_break_glass`

### 7. `schedule.yml`
Keep `schedule-control-v1`, but tighten it.

Required semantics:
- future-run suspension vs active-run pause are distinct
- overlap policy is explicit
- backfill policy is explicit
- pause-on-failure rules are explicit
- preview lead and quiet-hours overrides are explicit
- route overrides are constrained and receipted

### 8. `autonomy-budget.yml`
Keep `autonomy-budget-v1`, but tighten it.

Required semantics:
- counters are derived from runtime/control evidence
- state is recomputed
- applied mode adjustments are recorded
- last recomputation receipt is recorded

### 9. `circuit-breakers.yml`
Keep `circuit-breaker-v1`, but tighten it.

Required semantics:
- one normalized `state` vocabulary
- tripped breaker list
- trip reasons
- applied actions
- reset requirements
- reset receipt reference

### 10. `subscriptions.yml`
Keep `subscriptions-v1`.

Required semantics:
- owners
- watchers
- digest recipients
- alert recipients
- routing policy reference
- last evaluation timestamp

## New Generated Machine Contract

### `mission-view.yml`
Add `mission-view-v1`.

Canonical generated location:
`generated/cognition/projections/materialized/missions/<mission-id>/mission-view.yml`

Required top-level fields:
- mission identity and owner
- live mode state
- effective route summary
- current and next slice references
- budget/breaker summary
- active directives and authorize-updates
- route freshness
- recovery/finalize summary
- summary artifact refs
- last refresh timestamp

## Contract Enforcement Rules

1. No active mission may exist without the full control family.
2. No material autonomous run may exist without a current intent entry and
   action-slice reference.
3. No active mission may have a null route reference.
4. No generated mission view may become authoritative.
5. Every control mutation must emit a control receipt.
