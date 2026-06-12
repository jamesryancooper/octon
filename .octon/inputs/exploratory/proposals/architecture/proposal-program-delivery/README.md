# Governed Proposal Delivery: Proposal Program Delivery

## Findings

High: Octon has strong target-owned lifecycles for proposal programs, proposal
packets, conformance, drift/churn, publication, governed mechanism integration,
Change closeout, worktree closeout, and repo hygiene, but lacks one native
delivery runner that sequences those lifecycles to a final cleaned proof.

High: Putting delivery into `proposal-program` would move Git mutation,
branch cleanup, repo hygiene, and Change closeout responsibility into the wrong
owner. Putting it into `closeout-change` would make Change closeout understand
proposal child dependency order and proposal acceptance.

High: The missing surface is a receipt-validating delivery workflow that
coordinates target-owned lifecycles, replans from current repo state, and emits
one aggregate receipt without minting new authority.

Medium: Operator ergonomics need a thin entrypoint, `/proposal-program-delivery`,
that binds target, route, outcome, PR policy, stash policy, and terminal proof
requirements into a schema-backed delivery profile.

## Recommendation

Implement Governed Proposal Delivery with Proposal Program Delivery as the
first mode. Add a profile schema, receipt schema, native workflow, validators,
tests, product feature documentation, lifecycle hooks, and thin command/skill
entrypoint.

The implementation must preserve current ownership boundaries. Delivery may
select, sequence, validate, and aggregate; it must not authorize proposal,
Git, publication, cleanup, archive, branch, closeout, or terminal proof
effects by itself.

## Profile Selection Receipt

- release_state: pre-1.0
- change_profile: atomic
- rationale: The future implementation is a cross-domain governed workflow and
  validator surface. This packet creation step is proposal-only, but the future
  durable change should land as one coherent atomic change.
- proposal_authority: non-authoritative input packet only

## Packet Contents

This packet defines the target architecture, implementation plan, acceptance
criteria, promotion targets, source lineage, readiness receipt, risk register,
non-goals, validation plan, and scaffolded post-implementation receipts. It
does not implement the delivery runner or authorize delivery execution.
