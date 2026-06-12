# Target Architecture

## Required Schemas

- `architectural-review-report-v1.schema.json`
- `architectural-review-routing-decision-v1.schema.json`
- `architectural-review-support-receipt-v1.schema.json`
- mode-specific extensions for pre-integration, post-integration,
  current-state mechanism, and architecture-readiness coverage where needed.

## Required Receipt Fields

- verdict;
- subject ref and digest;
- evidence refs;
- validator refs;
- unresolved finding and blocker counts;
- blockers;
- non-authority classification;
- mode-specific coverage;
- route decision ref;
- stale digest status;
- finding refs using `review-finding-v1`;
- disposition refs using `review-disposition-v1`.

## Rejection Rules

A passing receipt is invalid if it contains missing evidence, omitted
validators, stale packet digests, unresolved blockers, placeholder language,
ambiguous prose-only verdicts, or missing mode coverage.
