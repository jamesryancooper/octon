# Command Log

Executed from `/Users/jamesryancooper/Projects/octon`.

## Syntax And Sanity

```bash
bash -n .octon/framework/assurance/runtime/_ops/scripts/validate-objective-binding-cutover.sh
```

## Direct Validation

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-objective-binding-cutover.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-mission-authority.sh
```

## Publication Refresh

```bash
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
```

## Publication Validation

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
```

## Broad Runtime And Mission Flow Validation

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile mission-autonomy
```

## Run Projection And Canonical Run-Root Validation

```bash
bash .octon/framework/orchestration/runtime/runs/_ops/scripts/validate-runs.sh
bash .octon/framework/orchestration/runtime/_ops/tests/test-shared-runtime-primitives.sh
bash .octon/framework/orchestration/runtime/_ops/tests/test-first-end-to-end-slice.sh
```

## Final Comprehensive Confirmation

```bash
bash .octon/framework/orchestration/runtime/_ops/scripts/validate-orchestration-runtime.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-authoritative-doc-triggers.sh
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness
```
