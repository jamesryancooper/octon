# Architecture Review Method Suite Program

Parent proposal program. Status: **draft**. Candidate lineage only — the
parent finalizes the suite design, coordinates seven planned child packets,
and authorizes nothing.

## Purpose

The non-authoritative intake unit
`.octon/inputs/additive/.incoming/architecture-review-method-suite/` captured
a conversation-derived direction: keep Balanced Architecture Review as the
default general architecture-review method, add focused companion methods,
and introduce a shared architecture lens bank so reviews stay deep without
becoming unbounded or duplicative.

This program is the architect-level conversion of that intake into a
coordinated proposal program. The architect decisions that shape everything
else:

1. **The suite is the method layer of the existing Architectural Review
   Mechanism**, not a new mechanism. Routed modes in `review-routing.yml`
   (pre/post-integration, current-state-mechanism, the audits) are review
   *occasions*; suite methods are *how* a review is conducted within an
   occasion. Balanced stays the default method.
2. **All five companions are first-class methods, none are new routed
   workflow modes in this program.** Methods are methodology surfaces with
   naming entries, lens profiles, and output contracts. New workflow
   directories, evidence roots, and command facades are deferred; existing
   review/workflow contracts gain only a recorded method identifier.
3. **Clean-sheet stays a lens; Greenfield is a method.** Clean-sheet is the
   intentionally unconstrained comparison tool inside Balanced Review.
   Greenfield Reference Architecture Review is a constrained initial-build
   method for new systems, subsystems, or major replacement candidates, and
   its output is reference architecture — evidence or proposal input, never
   implementation authority.
4. **One shared lens bank, machine-readable, with per-method profiles.**
   Methods own the question, scope, routing, and output contract; lenses are
   reusable analysis tools selected from `lens-bank.yml`. No per-method lens
   catalogs.
5. **No duplication of adjacent doctrine.** Architecture-readiness evaluation
   and surface-architecture audit doctrine remain unchanged; the suite
   composes with them through explicit boundary statements and escalation
   rules.

Design details live in `architecture/intake-evaluation.md`,
`architecture/method-taxonomy.md`, `architecture/lens-bank-design.md`, and
`architecture/integration-and-disposition.md`.

## Children (planned, not yet created)

All children are planned sibling packets at
`.octon/inputs/exploratory/proposals/architecture/<child-id>/` — declared in
`resources/child-packet-index.yml`, described in
`resources/child-packet-index.md`, sequenced in
`architecture/packet-sequence.md`, and bound by
`architecture/child-packet-contract.md`:

phase-0: `architecture-lens-bank-foundation` (seed reference);
phase-1: `architecture-review-method-taxonomy-and-routing`;
phase-2: `greenfield-reference-architecture-review-method`,
`companion-architecture-review-methods`,
`architectural-review-schema-extensions`;
phase-3: `architectural-review-suite-integration`,
`architecture-review-command-facades` (conditional — no-action with rationale
is an acceptable closure).

## Boundaries

- Children never nest under this parent; each is independently valid at its
  canonical sibling path with its own receipts.
- Parent evidence never satisfies child receipts, promotion targets,
  validation verdicts, or archive metadata.
- The parent implements nothing, mutates no authority or control truth, and
  publishes no generated outputs.
- No required child creates a lifecycle gate, a routed workflow mode, a
  command facade, or any authority for review outputs beyond the existing
  pre-integration support receipt.
- Closeout per `architecture/program-closeout-plan.md`.

## Non-Authority Statement

This program is candidate proposal lineage only. It coordinates future
child-owned work. It does not create authority, authorize implementation,
satisfy child receipts, widen support claims, or change runtime or control
truth. The intake unit it draws from is non-authoritative raw input and is
cited as source lineage, never as authority.
