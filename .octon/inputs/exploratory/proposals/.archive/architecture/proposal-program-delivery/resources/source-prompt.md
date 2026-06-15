# Source Prompt

The operator requested a targeted architecture proposal packet for Governed
Proposal Delivery with a first concrete mode named Proposal Program Delivery.

Key requested shape:

- canonical name: Governed Proposal Delivery;
- first mode: Proposal Program Delivery;
- slug: `proposal-program-delivery`;
- workflow path:
  `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`;
- thin command or skill: `/proposal-program-delivery`.

The requested process runs a proposal program from parent review through child
execution, program closeout/archive, generated freshness, Change closeout, repo
hygiene, branch-no-pr landing and cleanup, local main sync, and final cleaned
proof.

The operator explicitly required preserving ownership boundaries:

- `proposal-program` owns parent/child proposal lifecycle orchestration and
  child-owned receipts, not Git or cleanup authority.
- `closeout-change` owns singular Change route selection, branch-no-pr landing,
  branch cleanup, final sync, and Change receipts, not child dependency order or
  proposal acceptance.
- Lifecycle postmortems remain advisory evidence and cannot authorize closeout.
- The delivery workflow coordinates target-owned surfaces by selecting the next
  lifecycle, passing scoped context, validating receipts, replanning from state,
  and aggregating evidence.

The operator requested schema-backed profile and receipt contracts:

- `proposal-program-delivery-profile-v1`;
- `proposal-program-delivery-receipt-v1`.

The operator requested hard gates for fresh parent and child proposal receipts,
child-owned receipt coverage, implementation conformance, post-implementation
drift/churn, generated publication freshness, governed mechanism integration
verification when applicable, lifecycle residue cleanup, branch landing
authorization, branch cleanup authorization, terminal current-state proof,
clean worktree proof, and synced local main.
