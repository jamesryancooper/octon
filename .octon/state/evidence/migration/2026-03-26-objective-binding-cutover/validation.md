# Validation Receipts

## Passed

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-objective-binding-cutover.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-mission-authority.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile mission-autonomy`
- `bash .octon/framework/orchestration/runtime/runs/_ops/scripts/validate-runs.sh`
- `bash .octon/framework/orchestration/runtime/_ops/tests/test-shared-runtime-primitives.sh`
- `bash .octon/framework/orchestration/runtime/_ops/tests/test-first-end-to-end-slice.sh`
- `bash .octon/framework/orchestration/runtime/_ops/scripts/validate-orchestration-runtime.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-authoritative-doc-triggers.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`

## Transient Failure And Remediation

- First run of `validate-runtime-effective-state.sh` failed because
  `validate-extension-publication-state.sh` and
  `validate-capability-publication-state.sh` reported stale root-manifest
  hashes after `/.octon/octon.yml` changed.
- Remediation:
  - `bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh`
  - `bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
- After republishing the effective extension and capability state, both
  publication validators and the full runtime-effective gate passed cleanly.

## Wave 1 Completion Notes

- `write-run.sh` now seeds
  `state/control/execution/runs/<run-id>/run-contract.yml` and
  `stage-attempts/initial.yml` when a run is created.
- `framework/orchestration/runtime/runs/**` is now documented and validated as
  an orchestration-facing projection over the canonical Wave 1 run root.
- Final harness validation required one last fix: authoritative-doc trigger
  classification for
  `framework/constitution/contracts/objective/README.md` and
  `state/control/execution/runs/README.md`.
- After that fix, the final comprehensive harness alignment check passed with
  `errors=0`.
