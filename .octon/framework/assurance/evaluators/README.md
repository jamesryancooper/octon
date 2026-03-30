# Evaluator Proof Plane

The evaluator plane records independent review when deterministic proof is
insufficient or when separation of duties materially improves trust.

Canonical retained outputs live under:

- `/.octon/state/evidence/runs/<run-id>/assurance/evaluator.yml`
- `/.octon/state/evidence/lab/**`

Routing guidance lives at:

- `review-routing.yml`
- `adapters/registry.yml`

Reusable authoring inputs live at:

- `templates/review-template.md`
- `runtime/_ops/scripts/write-evaluator-review.sh`
- `runtime/_ops/scripts/run-evaluator-adapter.sh`

Proof-suite execution for functional, behavioral, maintainability, and recovery
planes is handled by:

- `/.octon/framework/assurance/runtime/_ops/scripts/run-phase4-proof-suite.sh`

Evaluator outputs remain evidence. They do not mint authority.
