# Scenario-Resolution Normalization

## Final design

Scenario handling remains a **generated effective-routing layer**.
It is not promoted into a new authored scenario registry.

## Canonical inputs

- mission charter
- mission-autonomy policy
- ownership registry
- ACP / deny-by-default policy
- root manifest
- live mission control truth
- current intent entry
- current action slice

## Normalized precedence

### 1. Mission class
Provides the broad default posture:
- default oversight mode
- default execution posture
- default preview lead
- default digest route
- default overlap and backfill policy
- default pause-on-failure
- default safing subset

### 2. Effective scenario family
Refines the mission-class default into a more specific operational family.

Examples:
- `maintenance.repo_housekeeping`
- `campaign.long_refactor`
- `reconcile.infra_drift`
- `migration.chunked_backfill`
- `incident.containment`
- `destructive.irreversible`

### 3. Action slice
Supplies the most specific boundary, recovery, externality, and predicted ACP semantics for the current work item.

### 4. Tightening overlays
Directives, breaker state, safing state, and break-glass may only tighten or explicitly exceptionalize behavior.

## Safe-boundary taxonomy

The packet normalizes safe-boundary classes to:

- `file_batch_boundary`
- `task_boundary`
- `resource_batch_boundary`
- `chunk_boundary`
- `deployment_step_boundary`
- `api_page_boundary`
- `playbook_step_boundary`
- `publish_gate`
- `contract_phase_boundary`

The route generator must record the source of the chosen boundary class.

## Scenario families that must be differentiated

- routine repo housekeeping
- long-running campaign/refactor
- dependency/security patching
- release-sensitive work
- infrastructure drift correction
- migration/backfill
- external sync
- observe-only monitoring
- incident containment
- destructive work
- absent human
- late feedback
- conflicting human input
- reversible work
- compensable-only work
- irreversible work

## Validation rule

No material route may fall back to a generic family or generic boundary when a more specific family or slice override exists.
