# Decision Record Plan

## ADR / decision follow-up

This packet does not itself create durable decisions, but implementation should plan for
decision-record updates under `instance/cognition/decisions/**` if any of the following occur:

1. the repo-shell execution-class policy materially changes execution semantics
2. the bootstrap/onboarding workflow contract changes in a way that affects operator expectations
3. the branch-freshness policy introduces a new default routing/blocking behavior
4. the repo-shell-supported scenario pack becomes claim-critical support evidence

## Minimum decision-record expectations

If implementation reveals substantive semantic change rather than mere surface refinement, record:
- rationale
- authority placement
- rollback posture
- relationship to the admitted live support universe
- whether any follow-up support widening is intentionally excluded

## Why this matters

The selected concept set is mostly refinement, but it does affect practical runtime behavior.
Decision records are therefore optional only when the landing remains a pure extension of already
approved semantics. If semantics change, a repo decision record should be added.
