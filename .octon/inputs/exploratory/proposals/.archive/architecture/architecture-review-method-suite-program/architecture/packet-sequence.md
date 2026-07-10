# Packet Sequence

Execution mode: `gated-parallel` — children inside a phase may run in
parallel; a child with declared dependencies may not begin implementation
until each dependency passes its `verification` gate. Phases are operator
pacing groups; dependencies are the hard gates.

## Phase 0 (start immediately)

1. `architecture-lens-bank-foundation` — seed reference child. The lens
   bank and its reference validator are the foundation: every method
   profile and every method doc cites lens ids defined here.

## Phase 1 (after the lens bank verifies)

2. `architecture-review-method-taxonomy-and-routing` — **hard dependency:**
   `architecture-lens-bank-foundation` must pass verification first, because
   naming v2 method entries and routing v2 method-selection semantics point
   at lens profiles that must already exist and validate.

## Phase 2 (after taxonomy/routing verifies; parallel)

3. `greenfield-reference-architecture-review-method` — **hard dependency:**
   taxonomy-and-routing, which owns the naming slot and routing semantics
   the method doc plugs into.
4. `companion-architecture-review-methods` — same hard dependency; runs in
   parallel with the Greenfield child.
5. `architectural-review-schema-extensions` — same hard dependency; the v2
   schemas encode method slugs and lens ids that naming v2 fixes first.

## Phase 3 (after phase-2 verification of declared dependencies)

6. `architectural-review-suite-integration` — **hard dependencies:** all
   three phase-2 children; workflow method-recording, feature-note text,
   lifecycle advisory text, and projection refresh must reflect the final
   landed method docs and schemas, and the closing validator sweep must run
   against the complete suite.
7. `architecture-review-command-facades` — conditional; **hard dependency:**
   suite-integration. Created only if operator demand for direct method
   invocation is demonstrated; otherwise routed to a program-local no-action
   record at closeout.

## Gate Rules

- Dependency gate is `verification` for every declared dependency: the
  dependency child must have passed its own verification loop, with
  child-owned receipts, before the dependent child begins implementation.
- Parent evidence never satisfies a child gate. Each child carries its own
  creation, review, implementation, and verification receipts at its
  canonical sibling path.
- A blocked or rejected child does not block siblings without a declared
  dependency on it; the parent records the disposition and re-sequences via
  registry revision.
- Creation ahead of gates is permitted (a child packet may be drafted before
  its dependency verifies); implementation may not begin ahead of gates.
