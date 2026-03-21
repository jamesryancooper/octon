# Validation Evidence Architecture

`state/evidence/validation/**` stores retained validation receipts, audit
evidence, and publication-validation artifacts for the active `.octon/`
harness.

## Families

| Family | Canonical path | Purpose |
| --- | --- | --- |
| Assurance evidence | `.octon/state/evidence/validation/assurance/**` | Retained assurance results, effective views, policy deviations, and scorecards |
| Audit evidence | `.octon/state/evidence/validation/audits/**` | Bounded audit bundles and convergence artifacts |
| Publication receipts | `.octon/state/evidence/validation/publication/**` | Machine-readable publication receipts for runtime-facing effective families |
| Analysis reports | `.octon/state/evidence/validation/analysis/**` | Human-readable investigation, freshness, and remediation reports |

## Rules

- Validation evidence is retained operational truth, not generated output.
- Runtime-facing publication receipts must not be written under
  `generated/**`.
- Publication receipts must remain machine-readable enough for fail-closed
  validators to reconstruct why a generation published, quarantined, withdrew,
  or blocked.

