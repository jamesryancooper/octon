# Commands

Command receipts for migration `2026-02-21-migration-evidence-bundle-format`.

## File and reference sweeps

- `find .octon/output/reports/migrations -maxdepth 2 -type f | sort`
- `find .octon/cognition/runtime/migrations -maxdepth 2 -type f | sort`
- `rg -n "YYYY-MM-DD-<slug>-evidence\.md|migration-evidence\.md|reports/migrations/.+-evidence\.md" .octon`
- `find .octon/output/reports -maxdepth 1 -type f -name '*evidence.md' | sort`

## Validator and quality gates

- `bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `bash .octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
- `bash .octon/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh`
- `bash .octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict`
- `bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile skills,workflows,harness`
