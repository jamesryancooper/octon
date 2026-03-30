# Phase 4 Command Log

- `sed -n '1,260p' .octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/{README.md,architecture/implementation-plan.md,architecture/verification-evaluation-lab-model.md,architecture/acceptance-criteria.md,resources/unified-execution-constitution-audit.md}`
- `find .octon/framework/assurance -maxdepth 3 -type f | sort`
- `find .octon/framework/lab -maxdepth 4 -type f | sort`
- `find .octon/state/evidence/lab -maxdepth 4 -type f | sort`
- `find .octon/framework/assurance/evaluators -maxdepth 4 -type f | sort`
- `bash -n .octon/framework/orchestration/runtime/_ops/scripts/write-run.sh`
- `bash -n .octon/framework/assurance/evaluators/runtime/_ops/scripts/run-evaluator-adapter.sh`
- `bash -n .octon/framework/assurance/runtime/_ops/scripts/run-phase4-proof-suite.sh`
- `bash -n .octon/framework/assurance/runtime/_ops/scripts/validate-phase4-proof-lab-enforcement.sh`
- `yq -e '.' .github/workflows/{ai-review-gate.yml,architecture-conformance.yml}`
- `bash .octon/framework/orchestration/runtime/_ops/scripts/write-run.sh backfill-wave4 --run-id run-wave3-runtime-bridge-20260327`
- `bash .octon/framework/orchestration/runtime/_ops/scripts/write-run.sh backfill-wave4 --run-id run-wave4-benchmark-evaluator-20260327`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-phase4-proof-lab-enforcement.sh`
- `bash .octon/framework/orchestration/runtime/runs/_ops/scripts/validate-runs.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `git diff --check`
