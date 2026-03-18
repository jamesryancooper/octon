# Commands

## Baseline (Phase 0)

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
```

## Migration Execution

```bash
git mv .octon/instance/cognition/decisions/013-planning-services-native-first-no-python.md \
  .octon/instance/cognition/decisions/034-planning-services-native-first-no-python.md

bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
```

## Final Validation (Phase 5)

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,skills,workflows
```
