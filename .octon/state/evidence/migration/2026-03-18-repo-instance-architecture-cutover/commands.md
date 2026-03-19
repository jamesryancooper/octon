# Commands

## Validation Commands

```bash
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-repo-instance-boundary.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-repo-instance-boundary.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness
bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
rg -n --hidden --no-heading --glob '!.octon/state/evidence/**' --glob '!.octon/inputs/exploratory/**' --glob '!.octon/generated/**' --glob '!.octon/instance/cognition/decisions/**' --glob '!.octon/instance/cognition/context/shared/migrations/**' --glob '!.octon/framework/assurance/runtime/_ops/**' --glob '!.octon/framework/cognition/practices/methodology/migrations/legacy-banlist.md' --glob '!.octon/framework/capabilities/runtime/skills/audit/audit-migration/references/**' --glob '!.octon/framework/scaffolding/practices/prompts/**' '(?<!framework/)(?<!instance/)cognition/runtime/context/|(?<!framework/)(?<!instance/)cognition/runtime/decisions/|(?<!state/)continuity/(log\\.md|tasks\\.json|entities\\.json|next\\.md)|(?<!framework/)(?<!instance/)orchestration/runtime/missions/' .octon/framework .octon/instance .github -P
```

## Export Verification

```bash
bash .octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh --profile repo_snapshot --output-dir /var/folders/pj/gxd_hdzx0yj6yz1sdtkh2zrc0000gn/T//repo-instance-export.jDNGvW
```

## Auxiliary Generation

```bash
bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/generate-workflow-guides.sh --workflow-id update-harness --output-root /tmp/octon-workflow-guide-refresh
```

## Outcome Summary

- repo-instance validator test: PASS
- repo-instance validator: PASS
- harness structure validator: PASS
- raw-input dependency validator: PASS
- harness alignment profile: PASS (`errors=0`)
- workflow validator: PASS (`errors=0 warnings=0`)
- broader active-surface mixed-path grep: PASS (no matches after exclusions)
- `repo_snapshot` export: PASS
