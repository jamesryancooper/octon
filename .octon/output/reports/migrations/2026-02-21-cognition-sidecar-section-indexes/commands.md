# Commands

## Core Migration Edits

```bash
rm -rf .octon/cognition/practices/methodology/sections \
  .octon/cognition/_meta/architecture/sections
```

## Validation Commands

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
bash .octon/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
bash .octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,skills,workflows
```
