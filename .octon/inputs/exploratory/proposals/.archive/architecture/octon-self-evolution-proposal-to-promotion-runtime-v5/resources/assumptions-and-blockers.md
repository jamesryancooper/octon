# Assumptions and Blockers

## Assumptions

- v1-v4 product layers may not yet exist in the live repo; this v5 packet does not reimplement them.
- Existing proposal and architecture proposal standards remain the packet convention.
- Evidence distillation remains proposal-gated and `auto_promote: false`.
- Material repository mutations remain governed by execution authorization.

## Blockers

- If no runtime command framework exists for `octon evolve`, initial implementation may add fail-closed command stubs plus validators before live mutation support.
- If support-target or connector v4 surfaces are absent, v5 must treat support/capability evolution as simulation-only and fail closed for live promotion.
