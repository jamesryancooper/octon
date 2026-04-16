# Octon Impact Map And Validation Selector Validation

Validate the extension family and its publication path with:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-local-tests.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh
```

## Extension-Local Test Convention

Extension-specific validation scripts live under:

- `validation/tests/*.sh`

Scenario docs live under:

- `validation/scenarios/*.md`

This pack does not emit proposal packets. Its validation scope is therefore:

- route resolution
- prompt bundle publication and freshness receipts
- output contract presence
- deterministic selection-rule coverage
- mixed-input drift handling
- pack-local operator documentation integrity

## Ownership Rule

Use the canonical extension ownership model from the extension governance
surface.

Pack-local implication:

- all selector logic, route scenarios, and extension-local tests stay inside
  this pack
- generic publication, routing, and validation machinery remains framework-owned

## Pack-Local Read Order

1. `README.md`
2. `context/overview.md`
3. `context/routing-guide.md`
4. `context/selection-rules.md`
5. `validation/bundle-matrix.md`
