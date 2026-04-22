# Publication Freshness Gates v1

Runtime-facing generated publication is valid only when:

- the generated/effective output exists
- the current publication receipt exists
- the current generation lock exists
- the output remains traceable to canonical authored, control, and evidence roots
- the effective output does not widen authority beyond the admitted support or publication envelope

This contract applies at minimum to:

- `/.octon/generated/effective/capabilities/**`
- `/.octon/generated/effective/extensions/**`
- `/.octon/generated/effective/governance/**`
- freshness-bound generated cognition maps that summarize current architecture or authorization state

Canonical validator:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh`

Supporting validators:

- `validate-generated-effective-freshness.sh`
- `validate-capability-publication-state.sh`
- `validate-extension-publication-state.sh`
