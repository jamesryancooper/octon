# Validation

Validate the raw pack without changing repo activation posture:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh
bash validation/tests/test-contract-shape.sh
bash validation/tests/test-routing-behavior.sh
bash validation/tests/test-non-authoritative-output-contract.sh
```

## Publication Validation

When maintainers later enable the pack in `instance/extensions.yml`, validate
the publication path with:

```bash
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
```

`validate-extension-local-tests.sh` only auto-runs pack-local tests for
enabled packs. This pack therefore keeps its fixture tests directly runnable
even while disabled by default.
