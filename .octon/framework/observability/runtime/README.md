# Observability Runtime

Observability runtime contracts define the retained measurement and
intervention artifacts attached to consequential runs.

Canonical retained outputs live under:

- `/.octon/state/evidence/runs/<run-id>/measurements/**`
- `/.octon/state/evidence/runs/<run-id>/interventions/**`
- `/.octon/state/evidence/validation/publication/**/drift-*.yml`

Runtime contracts also define:

- failure taxonomy bundles
- observability report bundles that aggregate measurement, intervention, and
  failure-class evidence without becoming a control surface
