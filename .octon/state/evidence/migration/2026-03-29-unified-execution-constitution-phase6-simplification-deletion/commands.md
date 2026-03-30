# Phase 6 Command Log

- `sed -n '1,260p' .octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/{README.md,architecture/implementation-plan.md,architecture/simplification-deletion-model.md,architecture/acceptance-criteria.md,resources/unified-execution-constitution-audit.md}`
- `sed -n '1,260p' .octon/instance/ingress/AGENTS.md`
- `sed -n '1,260p' .octon/framework/agency/{README.md,manifest.yml,runtime/agents/README.md}`
- `find .octon/framework/agency/runtime/agents -maxdepth 2 -type f | sort`
- `rg -n "SOUL|autonomy:auto-merge|autonomy:no-automerge|ai-gate:required|ai-gate:blocker" .github/workflows .octon/framework/agency .octon/framework/scaffolding`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-phase6-simplification-deletion.sh`
- `bash .octon/framework/agency/_ops/scripts/validate/validate-agency.sh`
- `bash .octon/framework/agency/_ops/scripts/validate/validate-autonomy-labels.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `yq -e '.' .github/workflows/{ai-review-gate.yml,pr-auto-merge.yml,pr-triage.yml,agency-validate.yml,architecture-conformance.yml}`
- `bash -n .octon/framework/agency/_ops/scripts/{ai-gate/aggregate-decision.sh,git/git-pr-ship.sh,github/sync-github-labels.sh,validate/validate-autonomy-labels.sh}`
- `git diff --check`
