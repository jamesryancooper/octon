# Architectural Review Mechanism

This feature note is navigation-only. It helps agents and operators find the
native architectural review doctrine, workflows, skills, commands, validators,
retained evidence, and generated projections.

## Boundary

- The product feature entry does not authorize review outcomes, lifecycle
  gates, generated publication, or closeout.
- Pre-Integration Architecture Review remains mandatory for architecture
  proposal acceptance and implementation authorization.
- Post-Integration Architecture Review remains evidence-only.
- Current-State Mechanism Architecture Review remains evidence-only.
- `architecture-readiness-audit` remains the canonical readiness audit name.
- `audit-architecture-readiness` remains retired outside historical,
  retired-name documentation, and validator contexts.
- `audit-domain-architecture` and `audit-surface-architecture` are invocation
  aliases for the canonical `domain-architecture-audit` and
  `surface-architecture-audit` modes.
- Generated outputs remain derived-only and must be refreshed through canonical
  publication scripts.
- Proposal-local receipts remain evidence only.

## Main Surfaces

- Methodology: `.octon/framework/cognition/practices/methodology/architectural-review/`
- Governed mechanism detail:
  `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/mechanisms/architectural-review-mechanism.md`
- Workflows:
  `.octon/framework/orchestration/runtime/workflows/audit/pre-integration-architecture-review/`,
  `.octon/framework/orchestration/runtime/workflows/audit/post-integration-architecture-review/`,
  `.octon/framework/orchestration/runtime/workflows/audit/current-state-mechanism-architecture-review/`,
  and `.octon/framework/orchestration/runtime/workflows/audit/architecture-readiness-audit/`
- Command facades:
  `/pre-integration-architecture-review`,
  `/post-integration-architecture-review`,
  `/current-state-mechanism-architecture-review`,
  `/architecture-readiness-audit`,
  `/audit-domain-architecture`,
  and `/audit-surface-architecture`

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-workflows.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-skills-commands.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
```
