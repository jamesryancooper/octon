# Implementation Plan

1. Define the `run-program-to-clean-delivery` capability boundary and decide
   whether it is a proposal-program runner profile, delivery profile, command,
   or combined wrapper.
2. Extend runner planning so default route selection, bounded retries, stale
   receipt refresh, child sequencing, and resume behavior are deterministic.
3. Integrate proposal-program lifecycle output with Proposal Program Delivery
   while preserving ownership of child packet, archive, generated publication,
   hygiene, Change closeout, branch cleanup, and terminal proof routes.
4. Harden receipt and metadata flow so publishable landing/cleanup evidence
   exists before local terminal proof is synthesized, and generated proposal
   metadata refreshes are route-owned.
5. Add validators and tests that prove clean delivery completion and negative
   controls for authority bypass.
6. Add a thin command/skill/docs surface that invokes the governed route and
   reports blockers with the next owning route.

Each implementation step must happen through the matching child packet and its
own review, implementation, conformance, drift/churn, closeout, and archive
receipts.
