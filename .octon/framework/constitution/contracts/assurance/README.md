# Constitutional Assurance Contracts

`/.octon/framework/constitution/contracts/assurance/**` defines the
constitutional proof-plane contract for consequential execution and system
claims.

## Wave 4 Status

Wave 4 promotes assurance from a mostly structural/governance gate into a
multi-plane model while preserving the existing blocking gates.

- structural and governance gates remain the current blocking baseline
- functional, behavioral, maintainability, recovery, and evaluator proof
  planes become first-class peers with authored suites and CI enforcement
- behavioral claims require lab, replay, scenario, or shadow-run evidence
- consequential completion and support claims must carry interpretable proof
  refs rather than prose-only assertions

## Canonical Files

- `family.yml`
- `proof-plane-report-v1.schema.json`
- `proof-suite-execution-v1.schema.json`
- `evaluator-review-v1.schema.json`

## Canonical Roots

- proof-plane docs: `/.octon/framework/assurance/{structural,functional,behavioral,governance,maintainability,recovery,evaluators}/**`
- proof-plane suites: `/.octon/framework/assurance/{functional,behavioral,maintainability,recovery}/suites/**`
- evaluator adapters: `/.octon/framework/assurance/evaluators/adapters/**`
- lab-authored scenarios and replay contracts: `/.octon/framework/lab/**`
- observability-authored measurement and intervention contracts:
  `/.octon/framework/observability/**`
- retained lab evidence: `/.octon/state/evidence/lab/**`
- retained run assurance evidence: `/.octon/state/evidence/runs/<run-id>/assurance/**`
