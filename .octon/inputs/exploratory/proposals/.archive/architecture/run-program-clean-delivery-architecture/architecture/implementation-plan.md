# Implementation Plan

This packet does not implement durable changes. It defines the future
implementation envelope that later child packets must honor.

## Workstreams

1. Preserve wrapper/profile composition.
   - Reuse the proposal-program lifecycle runner for program route planning,
     child sequencing, checkpointing, recovery, and blocker aggregation.
   - Reuse Proposal Program Delivery for delivery-readiness preflight,
     child receipt validation, closeout/archive routing, Change closeout
     handoff, cleanup/sync proof, and aggregate receipt emission.
   - Reject a new top-level authority route unless implementation evidence
     proves an existing owner cannot express the required stop condition.

2. Bind exact durable surfaces.
   - Treat `proposal-program.contract.yml` as additive extension source only.
   - Treat generated effective extension outputs as derived publication handles
     validated by publication/freshness validators.
   - Treat Proposal Program Delivery workflow files as the delivery sequencing
     home.
   - Treat `proposal-program-readiness-projection-v1.md` as diagnostic-only
     readiness semantics.

3. Implement stop-condition reporting in the owning packet.
   - Runner routing packet owns continuation, retry, and route-decision
     receipt behavior.
   - Workflow handoff packet owns delivery profile and stage handoff changes.
   - Evidence metadata packet owns publishable/local evidence metadata shape.
   - Validators packet owns executable negative controls and regression tests.
   - Operator surface packet owns command and skill UX.

4. Preserve target-owned authority.
   - Child packets retain child review, readiness, implementation,
     conformance, drift/churn, closeout, and archive receipts.
   - closeout-change or closeout-worktree retains Change receipt, landing,
     hosted mutation, final sync, and branch cleanup authority.
   - repo-hygiene-cleanup retains deletion authority.
   - Publisher scripts retain generated effective refresh authority.
   - Terminal proof validators retain `cleaned` proof authority.

5. Require negative controls.
   - Parent program summary must fail when used as child receipt evidence.
   - Proposal Program Delivery aggregate receipt must fail when used as
     archive, Change, cleanup, child, or terminal proof authorization.
   - Readiness projection must fail when it claims dispatch, implementation,
     closeout, archive, correction, or generated publication authority.
   - Local/private terminal evidence must fail when used as hosted/shared
     closeout proof.
   - Direct generated effective edits must fail generated publication
     freshness checks.

## Required Future Deltas

| Child packet | Required delta | Explicit non-goal |
| --- | --- | --- |
| `run-program-clean-delivery-runner-routing` | Add deterministic continuation and stop-condition routing over existing proposal-program runner state. | Do not mutate delivery workflow semantics directly. |
| `run-program-clean-delivery-workflow-handoff` | Tighten Proposal Program Delivery profile, stages, and Change closeout handoff around the stop taxonomy. | Do not own child receipts, archive metadata, Git mutation, or cleanup deletion. |
| `run-program-clean-delivery-evidence-metadata` | Ensure publishable landing/cleanup evidence and local terminal proof metadata are separated and digest-backed. | Do not make local/private evidence hosted authority. |
| `run-program-clean-delivery-validators` | Add or tighten validators and fixtures for stop conditions and negative controls. | Do not broaden promotion targets or implement operator UX. |
| `run-program-clean-delivery-operator-surface` | Expose the wrapper/profile command and skill instructions after validators exist. | Do not bypass lifecycle, delivery, closeout, archive, cleanup, publication, or terminal proof owners. |

## Rollback Route

Before implementation, rollback is rejection, supersession, or archive of this
packet. After implementation, rollback belongs to the implementing child
packet and must revert only that child packet's durable targets through its
Change closeout route. Generated outputs must be regenerated through owning
publisher scripts, not hand-reverted.

## Closeout Refusal Criteria

Any later implementation or delivery route must refuse `implemented`,
`archive-ready`, `landed`, `synced`, or `cleaned` when:

- a required child-owned receipt is missing, stale, failing, or replaced by
  parent summary evidence;
- generated effective publication state is stale, direct-edited, quarantined,
  or missing its generation lock and receipt linkage;
- Change closeout has not retained the required Change, landing, sync, branch
  cleanup, or rollback evidence for the claimed outcome;
- repo hygiene deletion is claimed without cleanup authorization;
- terminal current-state proof is missing, stale, or does not prove local main,
  origin/main, landed ref equality, and clean worktree state;
- a validator or negative control fails;
- an authority owner conflict remains unresolved.
