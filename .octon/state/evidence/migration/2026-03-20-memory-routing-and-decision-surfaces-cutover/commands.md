# Commands

## Cutover Commands

```bash
mv .octon/inputs/exploratory/proposals/architecture/memory-context-adrs-operational-decision-evidence .octon/inputs/exploratory/proposals/.archive/architecture/
git add -A -f .octon/inputs/exploratory/proposals/architecture/memory-context-adrs-operational-decision-evidence .octon/inputs/exploratory/proposals/.archive/architecture/memory-context-adrs-operational-decision-evidence
bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh
```

## Validation Commands

```bash
bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh --check
bash .octon/framework/cognition/_ops/runtime/scripts/validate-generated-runtime-artifacts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-repo-instance-boundary.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-repo-instance-boundary.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-packet10-generated-tracking.sh
bash .octon/framework/cognition/_ops/runtime/scripts/test-sync-runtime-artifacts-fixtures.sh
```
