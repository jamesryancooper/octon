# Validation Evidence

validation_id: retained-run-evidence-index-materialization-validation-20260618T190000Z
validated_at: 2026-06-18T19:00:00Z
verdict: pass

## Commands

- `bash .octon/framework/assurance/runtime/_ops/tests/test-generate-retained-run-evidence-index.sh`
  - result: pass
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --skip-registry-check`
  - result: pass
  - warnings: one artifact-catalog coverage warning
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization`
  - result: pass
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization`
  - result: pass
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --require-implementation-authorization`
  - result: pass before implementation evidence promotion

## Notes

The fixture test covers successful retained index materialization, fail-closed
behavior for missing implementation-run `verdict: pass`, and digest mismatch
failure after a source receipt changes.
