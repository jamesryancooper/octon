# Proposal Program Delivery Workflow

## Purpose

`proposal-program-delivery` coordinates an accepted proposal program through durable child implementation, target-owned receipt verification, generated publication freshness, packet terminal readiness, archive handoff, Change closeout handoff, final sync proof, and final hygiene proof.

The workflow emits an aggregate proposal program delivery receipt. That aggregate receipt never replaces child packet receipts, packet closeout receipts, archive receipts, Change closeout receipts, branch authorization receipts, cleanup authorization receipts, terminal current-state proof, or worktree hygiene proof.

## Authority Boundaries

- Target-owned proposal packet lifecycles own implementation, implementation conformance, post-implementation drift/churn, and packet closeout evidence.
- The proposal archive lifecycle owns implemented archive routing.
- `closeout-change` or `closeout-worktree` owns Git mutation, hosted landing, final sync, source branch cleanup, and Change closeout outcomes.
- `repo-hygiene-cleanup` owns deletion of local run residue and requires cleanup authorization before deletion.
- Owning publisher scripts own generated publication refresh.
- Generated prompts, proposal-local summaries, generated outputs, dashboards, chat, model memory, and host state are non-authoritative.

## Inputs

- `profile_path`: Path to a profile conforming to `proposal-program-delivery-profile-v1`.
- `target_program_path`: Accepted proposal program path supplied by the caller.
- `target_outcome`: Requested terminal outcome, usually `cleaned`.
- `delivery_run_id`: Stable run identifier for evidence and receipt paths.

## Required Controls

The workflow is fail-closed. It rejects stale, missing, ambiguous, parent-summary-only, or authority-overclaiming proof. It must replan from the current repository state after material mutations before it advances downstream stages.

Required validators include:

- `validate-proposal-program-delivery-profile.sh`
- `validate-proposal-program-delivery-receipt.sh`
- `validate-proposal-program-delivery-workflow.sh`
- Target packet implementation conformance validators
- Target packet post-implementation drift/churn validators
- Generated publication freshness validators
- Product feature catalog and capability publication state validators

## Stage Summary

1. Bind the profile, target program, requested route, PR policy, and stash policy.
2. Validate accepted program state and derive current child packet scope.
3. Run or resume child packet lifecycles through their target-owned workflows.
4. Validate child receipts directly; a parent summary is never sufficient.
5. Validate implementation conformance, drift/churn, generated publication freshness, and governed mechanism integration coverage.
6. Route lifecycle residue cleanup, packet closeout, archive handoff, and Change closeout to their owning lifecycles.
7. Validate branch landing authorization, branch cleanup authorization, final sync equality, terminal current-state proof, and worktree hygiene proof.
8. Emit and validate the aggregate delivery receipt.

## Terminal Outcomes

The workflow may report only the highest outcome with current passing evidence:

- `implemented`: all target packet implementation and implementation evidence passes.
- `archive-ready`: packet closeout passes and authorizes archive readiness.
- `landed`: Change closeout proves hosted landing through the selected route.
- `synced`: local `main`, `origin/main`, and `landed_ref` are equal.
- `cleaned`: source branch cleanup, authorized hygiene cleanup, terminal proof, and worktree hygiene all pass after the final mutation.

If any required receipt is missing or stale, the workflow emits `blocked` with a blocker class and stops before claiming the downstream outcome.
