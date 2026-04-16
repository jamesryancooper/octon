# Octon Decision Drafter Validation

Validate the extension pack directly without changing live repo activation posture:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh
bash validation/tests/test-contract-shape.sh
bash validation/tests/test-routing-behavior.sh
bash validation/tests/test-non-authoritative-output-contract.sh
```

## Fixture Convention

`test-routing-behavior.sh` publishes the pack in a temporary fixture root with
an isolated `instance/extensions.yml`. That exercises route resolution and
prompt freshness without mutating the live repo's generated or retained
publication surfaces.

## Activation-Time Validation

If maintainers later enable the pack in `instance/extensions.yml`, validate the
published routing path with:

```bash
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
```

`validate-extension-local-tests.sh` only auto-runs tests for enabled packs, so
this pack keeps its fixture tests directly runnable while disabled by default.
