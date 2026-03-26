# Scenario-Resolution Normalization

## Decision

Scenario handling remains **derived**. The canonical effective route is:

`generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`

This packet keeps that design and finishes it.

## Why Normalization Is Still Needed

The repo already has real route generation, but three issues remain:

1. the distinction between `mission_class` and effective route family is not
   yet explicit enough
2. safe-boundary taxonomy still allows generic fallbacks
3. material route behavior can still degrade toward generic action semantics
   when intent/slice state is weak

## Final Route Model

### Authoritative inputs
- mission charter
- mission-autonomy policy
- ownership registry
- deny-by-default / ACP policy
- root manifest executor-profile rules
- lease
- mode state
- intent register
- action slices
- directives
- authorize-updates
- schedule control
- autonomy budget
- circuit breakers
- subscriptions

### Generated output
`scenario-resolution.yml` must contain:

- `mission_id`
- `source_refs`
- `effective.mission_class`
- `effective.effective_scenario_family`
- `effective.effective_action_class`
- `effective.oversight_mode`
- `effective.execution_posture`
- `effective.preview_policy`
- `effective.feedback_window_required`
- `effective.proceed_on_silence_allowed`
- `effective.approval_required`
- `effective.safe_interrupt_boundary_class`
- `effective.overlap_policy`
- `effective.backfill_policy`
- `effective.pause_on_failure`
- `effective.digest_route`
- `effective.alert_route`
- `effective.required_quorum`
- `effective.recovery_profile`
- `effective.finalize_policy`
- `effective.safing_subset`
- `rationale`
- `generated_at`
- `fresh_until`

## Mission Class vs Effective Scenario Family

### Mission class
Mission class stays authored in the mission charter:
- `observe`
- `campaign`
- `reconcile`
- `maintenance`
- `migration`
- `incident`
- `destructive`

### Effective scenario family
Effective scenario family is derived and may upgrade the mission class:
- `observe`
- `campaign`
- `maintenance`
- `reconcile`
- `migration`
- `external_sync`
- `incident`
- `release_sensitive`
- `destructive`

### Upgrade examples
- `maintenance` + external write -> `external_sync`
- `campaign` + public publish boundary -> `release_sensitive`
- `observe` + bounded containment fork -> `incident`
- any mission + irreversible finalize -> `destructive`

## Boundary Taxonomy

Use one normalized set only:

- `immediate`
- `task_boundary`
- `batch_boundary`
- `checkpoint_boundary`
- `rollout_boundary`
- `stage_boundary`
- `finalize_boundary`

Mapping rules:
- coding/campaign work -> `task_boundary`
- repo housekeeping/high-volume repetitive work -> `batch_boundary`
- reconcile and external sync -> `batch_boundary`
- rollout/drift/canary -> `rollout_boundary`
- migration/backfill -> `checkpoint_boundary`
- destructive soft-pre-finalize work -> `stage_boundary`
- irreversible finalize -> `finalize_boundary`
- pure monitoring/observe-only -> `immediate`

No other boundary vocabulary should appear in the effective route.

## No Generic Fallback Rule

For material autonomous work:
- `effective_action_class` must come from the current or next action slice
- `recovery_profile` must come from slice + policy
- if either cannot be derived, the runtime must tighten

Generic fallback route data is allowed only for:
- pure observe-only missions
- newly created but not yet scheduled missions
- explicitly paused missions with no active or next material slice

## Observe-To-Operate Rule

An `observe` mission does not silently become open-ended operate behavior.

If the effective route upgrades from `observe` to an operate family because of
an anomaly or incident, the runtime must either:
- fork a bounded operate sub-mission, or
- require an explicit authorize-update to widen authority.

## Route Freshness Rule

The route must be regenerated whenever any of these change:
- mission charter
- mission-autonomy policy
- ownership registry
- mode state
- lease
- intent register
- action slices
- directives
- authorize-updates
- schedule
- autonomy budget
- circuit breakers
- subscriptions

The route must carry a freshness TTL and the runtime must reject stale route
use for material work.

## Consumers

The effective route must be the common input for:
- scheduler behavior
- preview publication
- digest routing
- evaluator allow/pause/block results
- recovery/finalize gating
- mission summaries
- mission view generation
