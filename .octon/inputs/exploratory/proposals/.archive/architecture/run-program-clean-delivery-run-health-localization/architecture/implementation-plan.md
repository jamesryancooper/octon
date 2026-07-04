# Implementation Plan

1. Classify run-health projections as diagnostic/local-private by default.
2. Redirect speculative generator output away from tracked generated files.
3. Add explicit promotion mode with path, digest, source refs, freshness, and
   owning route.
4. Update validators to reject unreceipted tracked run-health churn.
5. Add tests proving validator reruns leave tracked generated run-health files
   clean unless publish mode is explicitly selected.
