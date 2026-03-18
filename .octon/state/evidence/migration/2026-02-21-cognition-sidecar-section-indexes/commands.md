# Commands

## Core Migration Edits

```bash
rm -rf .octon/framework/cognition/practices/methodology/sections \
  .octon/framework/cognition/_meta/architecture/sections
```

## Validation Commands

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,skills,workflows
```
