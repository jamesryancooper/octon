# Campaign Relationship

## Standing Repo Posture

The live repository treats campaigns as optional and deferred by default. The
campaign promotion criteria say campaigns are coordination objects, not execution
containers, and must not become a second mission system.

## Stewardship Relationship

Stewardship is not campaign. Campaigns may be used inside stewardship only when
multiple missions require shared objective coordination, shared milestones,
shared waiver/exception/risk tracking, or a deterministic portfolio rollup.

## Hierarchy

```text
Stewardship Program
  -> Stewardship Epoch
    -> optional Campaign
      -> Mission
        -> Action Slice
          -> Run Contract
            -> Governed Run
```

## Campaign Must Not

- launch workflows;
- claim queue items;
- own runs;
- own incidents;
- replace missions;
- become required for normal stewardship;
- become a second mission system;
- become the stewardship model itself.

## Campaign Candidate Flow

A Stewardship Admission Decision may produce `campaign_candidate` only when the
candidate includes evidence that the campaign promotion criteria are met. The
candidate remains blocked until a separate go decision promotes campaign surfaces
according to existing criteria.
