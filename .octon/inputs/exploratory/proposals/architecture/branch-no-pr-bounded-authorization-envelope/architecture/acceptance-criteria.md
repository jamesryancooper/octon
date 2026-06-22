# Acceptance Criteria

- Envelope declares route, target/source branch, allowed effects, rollback handle, forbidden PR fallback, required validators, and staged proof locks.
- Push proof is required before landing; landing proof before sync; sync proof before cleanup; cleanup authorization before branch deletion; all proofs before cleaned.
- Envelope never authorizes PR fallback, PR creation, or PR merge.

## Safety Acceptance

- No parent evidence replaces child-owned evidence.
- No PR fallback is introduced.
- No protected retained evidence is deleted.
- No generated output is hand-edited.
