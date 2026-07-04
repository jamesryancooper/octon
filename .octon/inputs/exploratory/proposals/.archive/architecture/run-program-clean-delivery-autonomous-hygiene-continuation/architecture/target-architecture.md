# Target Architecture

Recoverable blocker classes route to a target-owned closeout path before
pausing. The route classifies residue as owned, in-scope, retained evidence,
generated/publication residue, foreign, ambiguous, or manual-review. It then
preserves or excludes safely, emits fresh evidence, reruns the blocked gate, and
continues only after the gate passes.

The explicit PM-002 continuation case is: cleanup-safe count is `0`, no
deletion is required, and a non-mutating preserve/exclude route can bind the
current fingerprint. In that case the lifecycle continues after the rerun gate
passes instead of stopping for human review.

The route does not silently delete or mutate refs. Destructive cleanup, external
credentials, protected refs, unpreservable foreign residue, stale receipts, and
conflicting operator instructions still require human review.
