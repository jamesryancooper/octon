# Campaign Mission Coordination Contract

## Purpose

Define the relationship between campaigns and missions while preventing
campaigns from becoming execution containers.

## Coordination Model

Campaigns coordinate missions through:

- `campaign.yml` `mission_ids[]`
- `campaign.yml` `milestones[]`
- registry rollups derived from campaign and mission state
- `log.md` for append-oriented rationale, waiver context, and outcome notes

Campaigns do not directly own workflows, queue items, or automation launches.

## Authority Boundaries

1. `campaign.yml` is authoritative for campaign identity, lifecycle state,
   mission membership, milestone definitions, and completion-waiver metadata.
2. Mission objects remain authoritative for mission lifecycle, owner, success
   criteria, blockers, and run linkage.
3. `registry.yml` may project campaign status, mission count, milestone
   summaries, and path refs, but it must not outrank `campaign.yml` or any
   referenced mission object.
4. `log.md` is explanatory and append-oriented. It does not replace required
   machine-readable fields in `campaign.yml`.

## Allowed Aggregation Semantics

Campaigns may aggregate:

- mission membership
- mission status rollups
- milestone completion state
- portfolio-level risks
- residual waivers
- operator-facing summary context

Campaigns may not aggregate:

- workflow definitions
- queue state
- run evidence payloads
- incident object state

## Rollup Expectations

- campaign progress is a coordination rollup, not an execution state machine
- mission completion remains authoritative in the mission surface even when the
  campaign reports the mission as completed
- milestone completion may depend on one or more missions, but a completed
  milestone does not override mission state
- campaign completion requires linked missions to be terminal or an explicit
  `completion_waiver_note` in `campaign.yml`
- campaign archival leaves linked missions unchanged

## Progress And Milestone Linkage

- milestones may reference zero or more campaign missions
- milestone mission references must resolve to mission ids already listed in the
  parent campaign
- campaign progress is derived from mission progress, milestone completion, or
  both
- campaign completion does not override mission completion criteria or mission
  archival requirements

## Optionality Rules

- campaigns are optional
- missions may exist without campaigns
- introducing campaigns requires demonstrated coordination value

## Lifecycle Interaction Boundaries

- campaign lifecycle does not mutate mission lifecycle directly
- campaign archival does not archive active missions
- campaign completion may require all linked missions to be terminal or waived
- campaign pause does not pause linked mission execution

## Non-Goals

- execution routing
- workflow launch ownership
- incident response ownership

## Prohibited Behaviors

- campaigns launching workflows directly
- campaigns claiming queue items
- campaigns becoming a second mission layer with independent execution logic
- campaigns storing run receipts, incident timelines, or policy decisions as
  their own canonical state
