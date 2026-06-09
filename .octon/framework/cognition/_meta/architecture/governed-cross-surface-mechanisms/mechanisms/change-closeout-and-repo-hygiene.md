# Change Closeout And Repo Hygiene Mechanism

## Non-Authority Status

This detail page is architecture documentation. It is not Change closeout
authority, repo hygiene cleanup authority, deletion authorization, branch
landing authorization, branch cleanup authorization, or retained evidence.

## Authority Surfaces

- default work unit policy:
  `.octon/framework/product/contracts/default-work-unit.yml`
- Change closeout state machine:
  `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- Change receipt schema:
  `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- branch landing and cleanup authorization schemas:
  `.octon/framework/product/contracts/branch-landing-authorization-v1.schema.json`
  and `.octon/framework/product/contracts/branch-cleanup-authorization-v1.schema.json`
- closeout skills:
  `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`,
  `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md`,
  and `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md`
- repo hygiene policy:
  `.octon/instance/governance/policies/repo-hygiene.yml`
- retained closeout and cleanup evidence:
  `.octon/state/evidence/**`

## Boundary

Change closeout owns one coherent Change and its selected route. Closeout
Worktree inventories, partitions, delegates, and reports; it does not directly
stage, commit, push, land, delete, reset, restore, or clean residue. Repo
hygiene owns post-closeout residue classification and cleanup-safe deletion.

Proposal lifecycle, lifecycle interaction receipts, generated projections, raw
inputs, host state, chat state, tool availability, and model memory do not
select Change routes, authorize hosted landing, authorize source branch
cleanup, authorize repo hygiene deletion, or complete the Change receipt.

Detection never authorizes deletion.

## Validators

- `.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh`
