# Assumptions and Blockers

## Assumptions

- v1 Engagement / Project Profile / Work Package compiler is available or has
  minimal compatibility shims.
- v2 Mission Runner / Autonomy Window / Mission Queue exists or has minimal
  compatibility shims.
- Existing run lifecycle and authorization boundary remain canonical for all
  material execution.
- Campaigns remain deferred unless promotion criteria are separately satisfied.

## Blockers

- If v1/v2 are absent, v3 cannot be fully operational without limited shims.
- If runtime CLI architecture has changed since packet generation, command names
  may require adjustment while preserving semantics.
- If event sources are not implemented, MVP should support scheduled-review and
  human-objective triggers only.
