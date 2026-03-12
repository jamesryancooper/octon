# First Implementation Plan

## Summary

- target package: `design-package-audit-workflow-package`
- default audit mode: `rigorous`
- current package status at closeout: `archived` (`implemented`)

## Workstreams

- Contract alignment:
  align `workflow.yml`, workflow `registry.yml`, and package artifact
  expectations to the same `reports/workflows` bundle contract.
- Stage-mapping alignment:
  document and test how package stages `02/03/04/05` map onto the durable
  `remediation-track` workflow stage behavior.
- Assurance repair:
  fix validator blind spots and ensure regression tests assert output-root
  coherence, temporary-package dependency failures, and rigorous-mode receipts.
- Runner verification:
  define executor prerequisites and failure-classification semantics, then rerun
  mock and real-executor workflows until rigorous mode completes stages `08`
  and `09` without manual repair.
- Documentation refresh:
  update workflow docs so they match the package's target contract and durable
  authority model.

## Sequence

1. Repair metadata drift between workflow contract and workflow registry.
2. Make the package-stage to workflow-stage mapping explicit in workflow docs
   and tests.
3. Fix the failing negative test in
   `test-validate-audit-design-package-workflow.sh`.
4. Add rigorous-mode, lifecycle, and failure-contract coverage to the runner
   suite.
5. Re-run validator and runner suites.
6. Re-run a real executor smoke for `audit-design-package`.

## Acceptance

- package standard validator passes
- architecture-validation pipeline validator passes
- architecture-validation pipeline regression suite passes
- workflow runner mock suite passes in both short and rigorous mode
- workflow runner asserts mutation-receipt, stage-log, and prompt-packet
  contracts
- at least one real-executor rigorous run completes or a classified
  executor-environment blocker is captured in bundle receipts
