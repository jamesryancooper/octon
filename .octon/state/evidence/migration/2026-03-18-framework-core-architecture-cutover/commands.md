# Commands

## Packet 3 Boundary Validation

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-framework-core-boundary.sh
```

## Harness Contract Validation

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness
```

## Capability Policy Validation

```bash
bash .octon/framework/capabilities/_ops/scripts/validate-agent-only-governance.sh
bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-services.sh --profile dev-fast
bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --profile dev-fast
```
