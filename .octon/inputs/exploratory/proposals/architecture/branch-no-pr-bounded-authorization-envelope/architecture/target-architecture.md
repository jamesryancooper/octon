# Target Architecture

Define and validate a bounded authorization envelope with staged proof locks for branch-no-PR delivery.

## Target Behavior

- Envelope declares route, target/source branch, allowed effects, rollback handle, forbidden PR fallback, required validators, and staged proof locks.
- Push proof is required before landing; landing proof before sync; sync proof before cleanup; cleanup authorization before branch deletion; all proofs before cleaned.
- Envelope never authorizes PR fallback, PR creation, or PR merge.

## Safety Properties

- Child authority is preserved.
- Parent summaries cannot satisfy child-owned evidence.
- Generated outputs remain derived-only and non-authoritative.
- Material side effects remain explicitly authorization-gated.
- PR fallback remains forbidden where branch-no-PR delivery is in scope.
