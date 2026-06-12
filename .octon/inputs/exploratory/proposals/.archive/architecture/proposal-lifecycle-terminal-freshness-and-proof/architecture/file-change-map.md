# File Change Map

| Target | Expected Change | Owner |
| --- | --- | --- |
| `.octon/framework/product/contracts/lifecycle-correction-branch-aggregate-receipt-v1.schema.json` | Add strict aggregate correction-branch receipt schema. | Product contracts |
| `.octon/framework/product/contracts/lifecycle-terminal-current-state-proof-v1.schema.json` | Add strict terminal current-state proof schema. | Product contracts |
| `.octon/framework/product/contracts/change-receipt-v1.schema.json` | Reference terminal proof and correction aggregation when required for completed or cleaned claims. | Product contracts |
| `.octon/framework/product/contracts/change-closeout-state-machine.*` | Add terminal freshness, correction aggregation, and current-state proof gate language. | Product contracts |
| `.octon/framework/product/contracts/default-work-unit.yml` | Align route evidence requirements with the new terminal proof contracts. | Product governance |
| `.octon/framework/orchestration/runtime/workflows/meta/closeout/` | Require terminal proof before applicable cleaned reports. | Workflow runtime |
| `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/` | Recheck artifact freshness after archive mutations. | Workflow runtime |
| `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/` | Recheck artifact freshness and publication state after promotion mutations. | Workflow runtime |
| `.octon/framework/orchestration/runtime/workflows/meta/validate-proposal/` | Surface terminal freshness validation in proposal validation evidence. | Workflow runtime |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/` | Add correction-branch aggregation and terminal proof invocation guidance. | Capability skills |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/` | Add wrapper-safe terminal proof and scoped child-validation references. | Capability skills |
| `.octon/framework/execution-roles/practices/standards/validator-runtime-resolution.md` | Add canonical validator/runtime resolution practice. | Execution-role standards |
| `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md` | Add compact validator-log evidence quality rules. | Execution-role standards |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh` | Add terminal generated-freshness validator. | Assurance validators |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-correction-branch-aggregate-receipt.sh` | Add aggregate correction receipt validator. | Assurance validators |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-terminal-current-state-proof.sh` | Add terminal current-state proof validator. | Assurance validators |
| `.octon/framework/assurance/runtime/_ops/tests/` | Add and extend negative-control coverage. | Assurance tests |
