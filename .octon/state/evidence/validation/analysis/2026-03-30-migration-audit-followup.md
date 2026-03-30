# Migration Audit Follow-Up: Unified Execution Constitution Closure Certification Cutover

## Scope

Remediation verification for finding `MIG-UEC-001` from
`2026-03-30-migration-audit.md`.

## Remediation Applied

- updated the active `required_ablation_suite` entries in
  `/.octon/instance/governance/contracts/retirement-registry.yml`
- replaced
  `/.octon/framework/assurance/runtime/_ops/scripts/validate-execution-constitution-closeout.sh`
  with
  `/.octon/framework/assurance/governance/_ops/scripts/assert-unified-execution-closure.sh`
  for:
  - `legacy-per-run-decision-lineage`
  - `helper-authored-run-projections`
  - `run-local-disclosure-mirrors`
  - `lab-local-harness-card-mirrors`

## Verification

- `bash .octon/framework/assurance/governance/_ops/scripts/assert-unified-execution-closure.sh`
  Result: PASS
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh`
  Result: PASS
- `rg -n "validate-execution-constitution-closeout\\.sh" .octon/instance/governance/contracts/retirement-registry.yml .octon/instance/governance/closure .octon/framework/assurance/governance .github/workflows/pr-autonomy-policy.yml .github/workflows/pr-auto-merge.yml .github/workflows/unified-execution-constitution-closure.yml .octon/state/evidence/validation/publication/unified-execution-constitution-closure`
  Result: PASS (`0` matches)
- `git diff --check`
  Result: PASS

## Result

- resolved findings: `1`
- open findings in follow-up scope: `0`

`MIG-UEC-001` is closed.
