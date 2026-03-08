# Campaign Mission Coordination Contract

## Purpose

Define the relationship between campaigns and missions while preventing
campaigns from becoming execution containers.

## Coordination Model

Campaigns coordinate missions through:

- `mission_ids[]`
- milestone linkage
- status rollups
- risk summaries

Campaigns do not directly own workflows, queue items, or automation launches.

## Allowed Aggregation Semantics

Campaigns may aggregate:

- mission membership
- mission status rollups
- milestone completion state
- portfolio-level risks
- residual waivers

Campaigns may not aggregate:

- workflow definitions
- queue state
- run evidence payloads

## Progress And Milestone Linkage

- milestones may reference one or more missions
- campaign progress is derived from mission progress or milestone completion
- campaign completion does not override mission completion criteria

## Optionality Rules

- campaigns are optional
- missions may exist without campaigns
- introducing campaigns requires demonstrated coordination value

## Lifecycle Interaction Boundaries

- campaign lifecycle does not mutate mission lifecycle directly
- campaign archival does not archive active missions
- campaign completion may require all linked missions to be terminal or waived

## Non-Goals

- execution routing
- workflow launch ownership
- incident response ownership

## Prohibited Behaviors

- campaigns launching workflows directly
- campaigns claiming queue items
- campaigns becoming a second mission layer with independent execution logic
