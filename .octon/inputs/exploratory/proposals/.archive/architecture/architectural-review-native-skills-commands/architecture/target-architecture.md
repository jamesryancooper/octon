# Target Architecture

## Thin Invocation Surfaces

Add skill and command entry points for:

- Pre-Integration Architecture Review;
- Post-Integration Architecture Review;
- Current-State Mechanism Architecture Review;
- Architecture Readiness Audit;
- Domain Architecture Audit;
- Surface Architecture Audit.

## Rules

- Skill manifests point to canonical workflow refs.
- Commands call workflow routes.
- Skill prose cannot define alternate schemas, validators, receipts, or gate
  outcomes.
- Generated projections are refreshed by publication scripts only.
- Legacy `architecture-readiness-audit` skill naming is retired according to
  the naming child.
