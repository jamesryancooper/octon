# Implementation Plan

1. Update architecture proposal standard with mandatory Pre-Integration
   Architecture Review.
2. Add support receipt template expectations.
3. Add validator script for architecture proposal pre-integration review.
4. Wire create, audit, validate, promote, and archive proposal workflows to
   require the receipt before acceptance or implementation authorization.
5. Add negative controls for missing, stale, invalid, and non-passing receipts.
6. Verify conformance and drift/churn gates still control implemented closeout.

## Strict Receipt Requirements

The lifecycle gate must consume the strict receipt schema from the schemas child
and must reject prose-only or generated-only review claims.
