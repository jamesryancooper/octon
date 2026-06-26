# Validation Plan

## Packet Validation

```bash
env PATH="/Users/jamesryancooper/.homebrew/bin:$PATH" bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh \
  --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails \
  --skip-registry-check

env PATH="/Users/jamesryancooper/.homebrew/bin:$PATH" bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh \
  --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails

env PATH="/Users/jamesryancooper/.homebrew/bin:$PATH" bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh \
  --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails

env PATH="/Users/jamesryancooper/.homebrew/bin:$PATH" bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

## Future Implementation Validation

Future implementation should add or update focused tests for:

- delivery profile canonical order passes;
- non-canonical order without override fails;
- non-canonical order with valid override passes;
- stage-01 warning/stop emits retained blocker evidence;
- consolidated readiness preflight catches Git write, stale review, child receipt compatibility, tooling, route legality, cleanliness, and generated freshness blockers before expensive continuation;
- stale or dirty source branch selects clean route-owned worktree route;
- include-path classification is required before reconstruction;
- child readiness and readiness projection share validation receipt pass semantics;
- fail/error/blocked validation receipt rows fail closed;
- lifecycle postmortem thresholds require valid postmortem artifacts;
- missing or stale postmortem artifacts fail closed.
