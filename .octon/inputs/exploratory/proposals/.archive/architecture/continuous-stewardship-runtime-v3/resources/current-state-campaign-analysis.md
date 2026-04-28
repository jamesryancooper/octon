# Current-State Campaign Analysis

## Repo Finding

Campaigns exist only as deferred groundwork and promotion criteria. The standing
position is no-go/deferred unless evidence shows multiple active missions need a
shared coordination object.

## Campaign Purpose

Campaigns are optional coordination objects for multi-mission objectives,
milestones, waiver/exception/risk tracking, or deterministic portfolio rollups.

## Campaign Boundaries

Campaigns must not:

- become execution containers;
- become a second mission system;
- launch workflows;
- claim queue items;
- own runs;
- own incidents;
- become required for normal execution.

## Stewardship Relationship

Stewardship is a long-running care layer above missions. It may create conditions
where campaigns become useful, but stewardship should not be implemented by
renaming or overloading campaigns.

## Recommendation

Add only optional campaign coordination hooks in v3. Keep campaign promotion
gated by the existing criteria and evidence-backed go decision.
