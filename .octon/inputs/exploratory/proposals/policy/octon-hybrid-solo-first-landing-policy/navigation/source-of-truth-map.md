# Source Of Truth Map

## Authoritative Inputs

- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/default-work-unit.md`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/*`

## Proposed Authority Changes

The durable policy authority remains under `.octon/framework/product/contracts`.
Git helper behavior remains subordinate execution tooling under
`.octon/framework/execution-roles/_ops/scripts/git`. Validators under
`.octon/framework/assurance/runtime/_ops` prove route claims and hosted landing
evidence.

## Linked Projection Work

`.github/**` workflows and the live GitHub default-branch ruleset are projection
surfaces. They must be updated through a repo-local follow-up packet after the
Octon-internal model can fail closed under the current PR-required ruleset and
pass in route-neutral shadow mode.
