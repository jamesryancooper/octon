# Mission Control Contracts

This document resolves the remaining open questions around the per-mission
control surfaces by defining the required contract family and the minimum
authoritative fields each contract must expose.

These sketches are **implementation-guiding**, not final JSON Schema text. The
cutover must convert them into durable schemas under
`.octon/framework/engine/runtime/spec/` and register them in the contract
registry.

## Contract Family To Add

- `mission-control-lease-v1.schema.json`
- `mode-state-v1.schema.json`
- `action-slice-v1.schema.json`
- `intent-register-v1.schema.json`
- `control-directive-v1.schema.json`
- `schedule-control-v1.schema.json`
- `autonomy-budget-v1.schema.json`
- `circuit-breaker-v1.schema.json`
- `subscriptions-v1.schema.json`
- `control-receipt-v1.schema.json`
- `scenario-resolution-v1.schema.json`

## 1. Mission Control Lease

**Path**
`.octon/state/control/execution/missions/<mission-id>/lease.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `state`: `active | paused | revoked | expired`
- `issued_at`
- `issued_by`
- `expires_at`
- `continuation_scope`: allowed execution posture and mission scope summary
- `revocation_reason` when not active
- `last_reviewed_at`

**Rules**
- active autonomous work requires a non-expired lease
- lease expiration must tighten behavior before any new material execution
- lease does not replace grants or approvals

## 2. Mode State

**Path**
`.octon/state/control/execution/missions/<mission-id>/mode-state.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `oversight_mode`
- `execution_posture`
- `safety_state`
- `phase`
- `active_run_ref`
- `current_slice_ref`
- `next_safe_interrupt_boundary_id`
- `effective_scenario_resolution_ref`
- `autonomy_burn_state`
- `breaker_state`
- `updated_at`

**Rules**
- mode state is the canonical mode beacon
- operator views render from this file
- scheduler/runtime must read this file before material mission progression

## 3. Action Slice

**Path**
embedded in `intent-register.yml` and optionally normalized under
`.octon/state/control/execution/missions/<mission-id>/slices/<slice-id>.yml`

**Required fields**
- `slice_ref`
- `intent_ref`
- `action_class`
- `target_ref`
- `rationale`
- `predicted_acp`
- `planned_reversibility_class`
- `safe_interrupt_boundary_id`
- `expected_blast_radius`
- `expected_budget_impact`
- `required_authorize_updates`
- `rollback_plan_ref`
- `compensation_plan_ref`
- `finalize_policy_ref`

## 4. Intent Register

**Path**
`.octon/state/control/execution/missions/<mission-id>/intent-register.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `revision`
- `generated_from`: planner/workflow refs
- `entries[]`, where each entry contains:
  - `intent_ref`
  - `slice_ref`
  - `state`: `proposed | published | superseded | consumed | cancelled`
  - `action_class`
  - `target_ref`
  - `rationale`
  - `planned_reversibility_class`
  - `earliest_start_at`
  - `feedback_deadline_at`
  - `default_on_silence`
  - `required_authorize_updates`
  - `safe_interrupt_boundary_id`
  - `rollback_plan_ref`
  - `compensation_plan_ref`
  - `supersedes_intent_ref` (optional)
  - `published_notice_ref` (optional)

**Rules**
- autonomous material work must bind to an `intent_ref`
- stale or superseded intents may not be executed
- preview notices are derived from published intent entries

## 5. Control Directives

**Path**
`.octon/state/control/execution/missions/<mission-id>/directives.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `revision`
- `directives[]`, each with:
  - `directive_id`
  - `kind`
  - `target_scope`
  - `submitted_by`
  - `precedence_source`
  - `submitted_at`
  - `effective_at`: `immediate | next_safe_boundary | next_run | recovery_window`
  - `status`: `pending | accepted | superseded | rejected | consumed`
  - `rationale`

**Required directive kinds**
- `pause_at_boundary`
- `suspend_future_runs`
- `stop_after_slice`
- `reprioritize`
- `narrow_scope`
- `exclude_target`
- `veto_next_promote`
- `block_finalize`
- `enter_safing`
- `clear_safing` (authorized only)

**Rules**
- directives are binding only when materialized here
- runtime must emit a control receipt for any directive that affects active or
  future execution

## 6. Schedule Control

**Path**
`.octon/state/control/execution/missions/<mission-id>/schedule.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `schedule_source`
- `cadence_or_trigger`
- `next_planned_run_at`
- `suspended_future_runs`
- `pause_active_run_requested`
- `overlap_policy`
- `backfill_policy`
- `pause_on_failure_rules`
- `preview_lead`
- `feedback_window_default`
- `quiet_hours`
- `digest_route_override`
- `last_schedule_mutation_ref`

**Rules**
- future-run suspension and active-run pause are distinct
- overlap and backfill behavior must be explicit
- pause-on-failure rules must be machine-consumable

## 7. Autonomy Budget

**Path**
`.octon/state/control/execution/missions/<mission-id>/autonomy-budget.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `state`: `healthy | warning | exhausted`
- `window`
- `counters` for:
  - `rollback_events`
  - `compensation_events`
  - `retries`
  - `exceptions_used`
  - `promote_denials`
  - `operator_vetoes`
  - `confidence_failures`
  - `near_misses`
- `threshold_profile_ref`
- `last_state_change_at`
- `applied_mode_adjustments`

**Rules**
- autonomy budget is separate from spend/data budgets
- runtime must update this state from receipts and incident/control evidence

## 8. Circuit Breakers

**Path**
`.octon/state/control/execution/missions/<mission-id>/circuit-breakers.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `state`: `clear | tripped | latched`
- `trip_reasons[]`
- `trip_conditions_snapshot`
- `applied_actions[]`
- `tripped_at`
- `reset_requirements`
- `reset_ref` when cleared

**Rules**
- breaker trips must emit control receipts
- breaker state must feed mode state and scheduler decisions

## 9. Subscriptions

**Path**
`.octon/state/control/execution/missions/<mission-id>/subscriptions.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `owners[]`
- `watchers[]`
- `digest_recipients[]`
- `alert_recipients[]`
- `routing_policy_ref`
- `last_routing_evaluation_at`

**Rules**
- ownership routing wins over generic subscribers
- operator digests are derived from this state plus repo-owned policy

## 10. Control Receipts

**Path**
`.octon/state/evidence/control/execution/**`

**Required fields**
- `schema_version`
- `receipt_id`
- `mission_id`
- `control_event_kind`
- `subject_ref`
- `applied_by`
- `applied_at`
- `prior_state_ref`
- `new_state_ref`
- `reason_codes`
- `policy_refs`
- `supersedes_receipt_id` when relevant

**Required control event kinds**
- `directive_applied`
- `authorize_update_applied`
- `lease_changed`
- `schedule_changed`
- `breaker_tripped`
- `breaker_reset`
- `safing_changed`
- `break_glass_activated`
- `break_glass_cleared`

## 11. Scenario Resolution

**Path**
`.octon/generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `source_refs`:
  - mission charter
  - mission-autonomy policy
  - deny-by-default policy
  - root manifest
  - mode state
  - schedule control
  - autonomy budget
  - circuit breakers
  - subscriptions
- `effective`:
  - `scenario_family`
  - `oversight_mode`
  - `execution_posture`
  - `preview_policy`
  - `feedback_window_required`
  - `proceed_on_silence_allowed`
  - `approval_required`
  - `safe_interrupt_boundary_class`
  - `overlap_policy`
  - `backfill_policy`
  - `pause_on_failure`
  - `digest_route`
  - `alert_route`
  - `required_quorum`
  - `recovery_profile`
  - `finalize_policy`
  - `safing_subset`
- `rationale[]`
- `generated_at`
- `fresh_until`

**Rules**
- this artifact is derived, not authoritative
- runtime may consume it only while fresh
- operator views and scheduler behavior should resolve from the same effective
  route to prevent split-brain behavior

## Open Questions Resolved By This Contract Family

1. **Continuation lease design** — resolved through `mission-control-lease-v1`
   with explicit state and expiration.
2. **Forward intent register design** — resolved through
   `intent-register-v1` with versioned entries and binding `intent_ref`.
3. **Scenario routing** — resolved as a derived effective artifact, not a new
   authority registry.
4. **Subscription routing** — resolved as canonical mutable control truth with
   derived digest output, not hardcoded channels.
