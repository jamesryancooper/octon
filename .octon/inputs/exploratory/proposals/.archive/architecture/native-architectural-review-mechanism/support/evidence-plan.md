# Evidence Plan

## Proposed Evidence Roots

- `.octon/state/evidence/runs/workflows/<run-id>/architectural-review/pre-integration-architecture-review/`
- `.octon/state/evidence/runs/workflows/<run-id>/architectural-review/post-integration-architecture-review/`
- `.octon/state/evidence/runs/workflows/<run-id>/architectural-review/current-state-mechanism-architecture-review/`
- `.octon/state/evidence/runs/workflows/<run-id>/architectural-review/architecture-readiness-audit/`
- `.octon/state/evidence/runs/workflows/<run-id>/architectural-review/routing/`
- `.octon/state/evidence/runs/workflows/<run-id>/architectural-review/validators/`

## Required Evidence Classes

- review report;
- routing decision;
- support receipt;
- packet digest or subject digest;
- validator outputs;
- unresolved blocker inventory;
- findings using `review-finding-v1`;
- dispositions using `review-disposition-v1`;
- non-authority classification;
- mode-specific coverage matrix.

## Evidence Boundary

Retained evidence supports gates only through schema-backed receipts. Raw
reports, generated projections, extension prompts, and parent summaries cannot
authorize mutation or closeout.
