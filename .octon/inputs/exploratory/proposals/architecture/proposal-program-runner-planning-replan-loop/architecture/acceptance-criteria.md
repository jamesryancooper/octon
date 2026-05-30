# Acceptance Criteria

- Default `octon lifecycle run --lifecycle proposal-program` remains handoff-only and writes planned `program-route-handoff` evidence without dispatching durable routes.
- `--execute-routes` enters a bounded plan-execute-replan loop where one parent route or one runnable child batch consumes one step.
- The scheduler never treats `planned`, `route-ready`, or `program-route-handoff` as completion.
- Planning uses live state plus generated effective lifecycle projections rather than prompt or skill discovery alone.

## Negative Criteria

- Do not infer scheduler routes from skill or prompt bundles.
- Do not introduce proposal statuses for runtime states.
- Do not let parent evidence satisfy child receipts or child authority.

## Terminal Criteria

- Child implementation evidence exists only after a later
  `run-packet-implementation` route.
- Child promotion is workflow-owned by `promote-proposal` and cannot be claimed
  by parent program evidence.
- Child closeout and archive remain child-owned and route-gated.
