# Naming Migration Plan

## Canonical Names

| Class | Canonical Value |
| --- | --- |
| Mechanism display name | Architectural Review Mechanism |
| Family slug | `architectural-review` |
| Method display name | Balanced Architecture Review Method |
| Method slug | `balanced-architecture-review-method` |
| Pre-integration review slug | `pre-integration-architecture-review` |
| Post-integration review slug | `post-integration-architecture-review` |
| Current-state mechanism review slug | `current-state-mechanism-architecture-review` |
| Architecture readiness audit slug | `architecture-readiness-audit` |
| Domain audit slug | `domain-architecture-audit` |
| Surface audit slug | `surface-architecture-audit` |
| Architecture revision helper slug | `architecture-revision-packet` |
| Lifecycle postmortem evaluator slug | `lifecycle-postmortem-evaluator` |

## Naming Pattern

Use modifier plus subject plus review type:

- Pre-Integration Architecture Review
- Post-Integration Architecture Review
- Current-State Mechanism Architecture Review
- Architecture Readiness Audit
- Domain Architecture Audit
- Surface Architecture Audit

## Directory And Artifact Pattern

- workflow directories use the canonical slug;
- schemas use `architectural-review-<artifact>-v1.schema.json`;
- validators use `validate-architectural-review-<artifact>.sh`;
- evidence roots nest under `architectural-review/<mode-slug>/`;
- support receipts use `support/<mode-slug>-receipt.yml` or
  `support/<mode-slug>-review.md` only until strict receipt schema cutover.

## Legacy Alias Retirement

`architecture-readiness-audit` is a legacy alias. The migration window may
include transitional redirects or compatibility notes, but the target state
removes differently named permanent aliases. The retirement condition is a
passing validator sweep proving all workflow, skill, command, registry,
documentation, and generated references use `architecture-readiness-audit`.
