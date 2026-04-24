# Decision Record Plan

## ADR need assessment

This packet likely warrants an instance decision record because it changes durable expectations for:
- what a consequential Run must emit before authorization
- what instruction-layer evidence must bind
- how repo-local context policy is expressed

## Recommended ADR posture

Add one append-only repo-local decision under:
- `/.octon/instance/cognition/decisions/`

Recommended ADR scope:
- confirm deterministic Context Pack Builder v1 as the accepted runtime context assembly model
- record why Octon chose extension of current contracts instead of a parallel context subsystem
- record non-goals, especially no generated authority and no memory-as-context substitution

## ADR is not a release blocker if

- maintainers treat this packet as the immediate implementation guide
- the promoted surfaces themselves are self-sufficient and validator-enforced

But ADR landing is recommended before packet archival.
