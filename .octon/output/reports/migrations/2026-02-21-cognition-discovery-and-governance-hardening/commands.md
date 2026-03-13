# Commands

## Baseline (Phase 0)

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
bash .octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
```

## Migration Execution

```bash
git mv .octon/cognition/runtime/decisions/013-planning-services-native-first-no-python.md \
  .octon/cognition/runtime/decisions/034-planning-services-native-first-no-python.md

bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
```

## Final Validation (Phase 5)

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
bash .octon/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
bash .octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,skills,workflows
```
