# Commands

## Baseline (Phase 0)

```bash
bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .harmony/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
bash .harmony/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
```

## Migration Execution

```bash
git mv .harmony/cognition/runtime/decisions/013-planning-services-native-first-no-python.md \
  .harmony/cognition/runtime/decisions/034-planning-services-native-first-no-python.md

bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .harmony/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
```

## Final Validation (Phase 5)

```bash
bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .harmony/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
bash .harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
bash .harmony/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,skills,workflows
```
