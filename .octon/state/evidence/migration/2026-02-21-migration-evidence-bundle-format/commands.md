# Commands

Command receipts for migration `2026-02-21-migration-evidence-bundle-format`.

## File and reference sweeps

- `find .octon/state/evidence/migration -maxdepth 2 -type f | sort`
- `find .octon/instance/cognition/context/shared/migrations -maxdepth 2 -type f | sort`
- `rg -n "YYYY-MM-DD-<slug>-evidence\.md|migration-evidence\.md|reports/migrations/.+-evidence\.md" .octon`
- `find .octon/generated/reports -maxdepth 1 -type f -name '*evidence.md' | sort`

## Validator and quality gates

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
- `bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh`
- `bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict`
- `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile skills,workflows,harness`
