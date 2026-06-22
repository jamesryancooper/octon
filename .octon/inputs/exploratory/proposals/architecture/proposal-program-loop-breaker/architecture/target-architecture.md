# Target Architecture

Proposal-program recovery records stable blocker fingerprints and compares them before selecting another recovery route.

## Target Behavior

- Compute a blocker fingerprint from blocker class, route id, child id when present, relevant path set, source evidence refs, digests, and recovery disposition.
- Permit a repeated route only when the fingerprint changes or a recovery receipt proves changed evidence.
- Treat cleanup as terminal for the current blocker when cleanup evidence, classifier digest, and residue fingerprint are unchanged.
- Prefer publication-drift or generated-freshness repair when drift is the blocker that cleanup would not resolve.
- Track token and attempt budgets in model-visible compact state and stop recovery when the budget is exhausted.

## Safety Properties

- Loop breaking does not authorize cleanup, archive, publication, branch mutation, or child closeout.
- Changed blocker evidence remains retryable inside the configured budget.
- Unknown or ambiguous blocker classes fail closed.
- Parent summaries cannot reset child-owned blocker state.
