# Validation

receipt_id: validation-proposal-churn-retained-run-evidence-efficiency-20260708T000000Z
run_id: proposal-churn-retained-run-evidence-efficiency-20260708T000000Z
verdict: pass
recorded_at: 2026-07-08T21:01:54Z

## Results

| Command | Result |
| --- | --- |
| `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-churn-retained-run-evidence-efficiency` | pass |
| `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-churn-retained-run-evidence-efficiency --require-implementation-authorization` | pass |
| `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/proposal-churn-retained-run-evidence-efficiency/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/proposal-churn-retained-run-evidence-efficiency --mode pre-integration-architecture-review --require-pass` | pass |
| `bash -n .octon/framework/assurance/runtime/_ops/scripts/generate-retained-run-evidence-index.sh` | pass |
| `bash -n .octon/framework/assurance/runtime/_ops/scripts/validate-retained-run-evidence-index.sh` | pass |
| `bash -n .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh` | pass |
| `bash .octon/framework/assurance/runtime/_ops/tests/test-retained-run-evidence-index.sh` | pass |
| `bash .octon/framework/assurance/runtime/_ops/tests/test-generate-retained-run-evidence-index.sh` | pass |
| `bash .octon/framework/assurance/runtime/_ops/tests/test-cleanup-local-run-artifacts.sh` | pass |
| `git diff --check` | pass |

## Negative Controls

- Generated refs claiming authority fail retained-run evidence index validation.
- Proposal-local refs claiming authority fail retained-run evidence index validation.
- Retrieval metric mismatch fails retained-run evidence index validation.
- Cleanup dry-run output separates cleanup candidates from retained evidence, control state, and continuity state.

## Notes

Lifecycle promotion, terminal delivery validation, and final worktree hygiene are recorded by their owning delivery and closeout receipts.
