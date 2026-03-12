# Campaign Promotion Criteria

`campaigns` are an optional orchestration surface. They should only be promoted
into live Harmony when they solve a real coordination problem that cannot be
handled cleanly by `missions`, `runs`, `incidents`, and ordinary reports.

## Default Position

- `campaigns` remain deferred by default.
- A mission may exist without a campaign.
- `campaigns` are coordination objects, not execution containers.
- `campaigns` must not become a second mission system.

## Use This Document When

- engineers think multiple missions should roll up under one larger objective
- operators want a shared milestone or waiver view across missions
- a future proposal asks to add `/.harmony/orchestration/runtime/campaigns/`

## Promotion Triggers

Promote `campaigns` only when one or more of these are true in live practice:

1. Multiple active missions regularly serve one larger objective.
2. Two or more missions need shared milestone coordination.
3. Two or more missions need shared waiver, exception, or unresolved-risk
   tracking.
4. Operators need one deterministic portfolio rollup that cannot be expressed
   cleanly through mission, run, incident, or output-report surfaces.

## Non-Triggers

Do not promote `campaigns` for these reasons alone:

- wanting a cleaner hierarchy on paper
- wanting labels for loosely related work
- trying to compensate for weak mission modeling
- wanting a place to launch workflows directly
- wanting a place to store run, queue, or incident authority

## Required Evidence Before A Go Decision

Any future promotion proposal must document:

1. The concrete multi-mission objective that exists in live work.
2. The current coordination pain using only missions, runs, incidents, and
   reports.
3. Why that pain is structural rather than temporary or team-specific.
4. Which operators or workflows will consume campaign rollups.
5. Why `campaigns` remain aggregation-only and do not need execution authority.

## Promotion Boundaries

If `campaigns` are promoted, they must preserve these boundaries:

- `campaign.yml` is authoritative for campaign identity, lifecycle, mission
  membership, milestones, and coordination notes.
- `campaigns` may aggregate mission state, but they do not override mission
  lifecycle.
- `campaigns` must not launch workflows, claim queue items, own runs, or own
  incidents.
- `campaigns` must not become required for normal-path execution.

## Required Promotion Deliverables

If the decision changes from `no-go` to `go`, the implementation must include:

- `/.harmony/orchestration/runtime/campaigns/README.md`
- `/.harmony/orchestration/runtime/campaigns/manifest.yml`
- `/.harmony/orchestration/runtime/campaigns/registry.yml`
- `/.harmony/orchestration/runtime/campaigns/<campaign-id>/campaign.yml`
- `/.harmony/orchestration/runtime/campaigns/<campaign-id>/log.md`
- `/.harmony/orchestration/runtime/campaigns/_ops/scripts/validate-campaigns.sh`
- practice guidance for campaign lifecycle and operator usage
- a new evidence-backed go/no-go receipt replacing the current defer decision

## Current Standing Decision

The current live decision is still `no-go`. See:

- `/.harmony/output/plans/2026-03-10-orchestration-domain-phase9-completion-receipt.md`

## Promotion Independence Rule

If `campaigns` are ever promoted, the implementation must materialize the
campaign object contract, schema, runtime discovery artifacts, practices, and
validator coverage inside live `/.harmony/orchestration/` surfaces before
merge. No live campaign artifact may depend on temporary proposal paths.
