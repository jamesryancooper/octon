# Scaffold And Reader Alignment

## Problem

The repo now has runtime-required mission control files and generated mission
outputs, but mission creation still lags behind that reality.

A clean steady state requires mission creation, mission readers, route
generation, and generated views to agree on one complete lifecycle.

## Final Design

### 1. Mission scaffold remains the authoritative mission-authoring starting point
Keep:
- `mission.yml`
- `mission.md`
- `tasks.json`
- `log.md`

Add:
- continuity stubs
- control-file family stubs
- action-slices directory

### 2. Mission creation becomes atomic
The create-mission workflow must automatically run the seed/autonomy-state
initializer after scaffold creation.

That initializer must:
- create initial lease, mode, schedule, directives, authorize-updates,
  subscriptions, autonomy-budget, and circuit-breaker state
- create an initial empty-or-observe-safe intent register
- generate scenario-resolution
- generate summaries
- generate operator digests
- generate mission-view
- emit a seed control receipt

### 3. Reader alignment
All mission readers must:
- read `owner_ref`
- resolve mission-control roots from the root manifest / contract registry
- tolerate only the canonical file family after cutover
- reject stale or incomplete control families

### 4. Migration rule
Any in-tree active mission that predates the full control family must be
migrated in the cutover merge set.

## Required Outputs Of `create-mission`

After mission creation, these must already exist:

- mission charter
- notes/tasks/log
- lease
- mode state
- intent register
- action-slices directory
- directives
- authorize-updates
- schedule
- autonomy budget
- circuit breakers
- subscriptions
- continuity stubs
- scenario-resolution
- now/next/recent/recover
- operator digests
- mission-view
- seed control receipt

## Acceptance Rule

If a newly created mission still needs manual follow-up to become a valid
autonomous mission, the scaffold and reader alignment is not complete.
