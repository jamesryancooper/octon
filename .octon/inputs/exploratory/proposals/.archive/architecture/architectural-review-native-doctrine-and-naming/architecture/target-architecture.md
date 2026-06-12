# Target Architecture

## Native Doctrine

Create native methodology for:

- Architectural Review Mechanism overview;
- Balanced Architecture Review Method;
- review mode taxonomy references;
- authority and evidence boundaries;
- naming model and legacy alias retirement.

## Canonical Naming Model

| Class | Canonical Name Or Pattern |
| --- | --- |
| Mechanism display name | Architectural Review Mechanism |
| Family slug | `architectural-review` |
| Method display name | Balanced Architecture Review Method |
| Method slug | `balanced-architecture-review-method` |
| Workflow directories | canonical review or audit slug |
| Schemas | `architectural-review-<artifact>-v1.schema.json` |
| Validators | `validate-architectural-review-<artifact>.sh` |
| Evidence roots | `architectural-review/<mode-slug>/` |
| Support artifacts | `<mode-slug>-receipt.yml` and `<mode-slug>-review.md` during migration |

## Canonical Review And Audit Slugs

- `pre-integration-architecture-review`
- `post-integration-architecture-review`
- `current-state-mechanism-architecture-review`
- `architecture-readiness-audit`
- `domain-architecture-audit`
- `surface-architecture-audit`
- `architecture-revision-packet`
- `lifecycle-postmortem-evaluator`

## Legacy Alias Rule

`architecture-readiness-audit` may exist only as a bounded migration source. The
target state removes permanent differently named aliases.
