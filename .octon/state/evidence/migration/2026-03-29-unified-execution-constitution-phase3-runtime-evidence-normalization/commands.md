# Phase 3 Command Log

- `sed -n '1,260p' .octon/instance/ingress/AGENTS.md`
- `sed -n '1,260p' .octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/{README.md,architecture/implementation-plan.md,architecture/runtime-evidence-model.md,architecture/acceptance-criteria.md,resources/unified-execution-constitution-audit.md}`
- `rg -n "run-manifest|runtime-state|replay-pointers|external-index|evidence class|git-inline|pointered|external-immutable|handoff" .octon/framework .octon/instance .octon/state`
- `sed -n '1,260p' .octon/framework/constitution/contracts/runtime/{README.md,family.yml,runtime-state-v1.schema.json,run-continuity-v1.schema.json,replay-pointers-v1.schema.json}`
- `sed -n '1,260p' .octon/framework/constitution/contracts/retention/{README.md,family.yml,external-replay-index-v1.schema.json,replay-storage-class-v1.schema.json}`
- `sed -n '1,260p' .octon/framework/orchestration/runtime/_ops/scripts/write-run.sh`
- `sed -n '1,240p' .octon/framework/orchestration/runtime/runs/_ops/scripts/validate-runs.sh`
- `bash -n .octon/framework/orchestration/runtime/_ops/scripts/orchestration-runtime-common.sh`
- `bash -n .octon/framework/orchestration/runtime/_ops/scripts/write-run.sh`
- `bash .octon/framework/orchestration/runtime/_ops/scripts/write-run.sh backfill-wave4 --run-id run-wave3-runtime-bridge-20260327`
- `bash .octon/framework/orchestration/runtime/_ops/scripts/write-run.sh backfill-wave4 --run-id run-wave4-benchmark-evaluator-20260327`
- `bash .octon/framework/orchestration/runtime/runs/_ops/scripts/validate-runs.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-lifecycle-normalization.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-unified-execution-phase3-runtime-evidence-normalization.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-execution-constitution-closeout.sh`
- `cargo check -p octon_kernel`
- `git diff --check`
