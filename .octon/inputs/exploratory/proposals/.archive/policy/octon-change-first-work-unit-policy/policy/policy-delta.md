# Policy Delta

## Canonical Policy

Create a durable Change-first default work unit contract under `.octon/framework/product/contracts/`.

The human-readable contract should define:

- Change as the default work unit;
- Change Package as the compiled internal execution bundle for a Change;
- Run Contract as execution authority for a run;
- PR as optional publication or review output;
- branch as an isolation mechanism;
- direct-main, branch-without-PR, and branch-with-PR routing criteria;
- minimum durable history for PR and no-PR Changes;
- validation and review gates as Change-scoped obligations.

The machine-readable companion should expose the route model in `policy/routing-model.md` so workflows and validators can reference the policy without copying prose.

Create a `change-receipt-v1` schema beside the policy contract. It should make Change identity, selected route, durable history, validation evidence, review evidence or waiver, rollback handle, closeout outcome, and blockers available to direct-main, branch-only, PR-backed, and stage-only paths.

Complete the pre-1.0 rename from Work Package to Change Package as part of promotion. Active authoritative surfaces should use Change Package for the internal runtime bundle and should not retain Work Package aliases or shims.

Promotion must make this policy discoverable through the architecture and constitutional registries before downstream Git, closeout, skill, or GitHub surfaces are treated as aligned.

## Downstream Contract Updates

Update `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml` so it no longer implies that a branch or PR is the default execution unit. It should reference the canonical policy and keep only worktree-specific mechanics: clean tree requirements, branch creation, sync, direct-main preconditions, rollback handles, and publication behavior.

Update architecture and constitutional registries so the new default work unit contract is discoverable as product policy, while Git adapters remain implementation-specific.

Update closeout workflows so closeout records are Change receipts first. PR URLs should be optional fields required only when the selected route creates a PR.

Update skill and workflow manifests that currently imply PR-first behavior so they route through the Change policy before selecting GitHub publication, local commit, branch-only continuation, or stage-only checkpoint. The implementation target is a route-neutral `closeout-change` skill that delegates to direct-main, branch-only, PR-backed, or stage-only subflows; `closeout-pr` remains the PR-backed subflow.

Use `implementation/implementation-map.md` as the exhaustive promotion checklist for contracts, standards, workflows, adapters, manifests, practice documents, validators, and repo-local host projections.

## Required Semantic Replacements

Replace PR-centered language where it defines policy:

- "work unit is PR" becomes "work unit is Change";
- "open PR by default" becomes "select route from Change risk and publication need";
- "PR evidence" becomes "Change evidence";
- "PR review gate" becomes "Change review gate, satisfiable by PR-backed or local review paths";
- "branch required for all work" becomes "branch required when isolation, risk, collaboration, or repo constraints require it".
- "Work Package" becomes "Change Package" where it names the internal execution bundle.

Keep PR-centered language where it is implementation-specific:

- GitHub adapter behavior;
- PR body templates;
- PR review standards;
- GitHub CI handling;
- publishing workflows selected by policy.

## Non-Targets

This proposal does not make exploratory proposal files authoritative.

This proposal does not remove PR support.

This proposal does require a complete pre-1.0 Work Package to Change Package cutover in active authoritative surfaces. Historical archive material may retain old vocabulary as history, but no active compatibility aliases or shims are part of the target state.

This proposal does not make direct-to-main unconditional. Direct-main is an allowed route, not a bypass for validation, evidence, or rollback requirements.

This proposal does not mix `.octon/**` and non-`.octon/**` promotion targets in `proposal.yml`. Repo-local `.github/**` alignment is required by the implementation map and should be carried by a linked `repo-local` proposal before `.github/**` edits are claimed under proposal lifecycle.
