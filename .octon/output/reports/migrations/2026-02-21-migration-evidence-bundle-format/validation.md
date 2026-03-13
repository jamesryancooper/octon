# Validation

Validation receipts for migration `2026-02-21-migration-evidence-bundle-format`.

## Receipts

- `bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - `Validation summary: errors=0 warnings=0`
- `bash .octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
  - `Validation summary: errors=0 warnings=0`
- `bash .octon/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh`
  - `Validation summary: errors=0 warnings=0`
- `bash .octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict`
  - `All checks passed!`
- `bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile skills,workflows,harness`
  - `Alignment check summary: errors=0`

All required validation gates passed locally.
