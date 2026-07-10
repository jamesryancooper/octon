# Architecture Lens Bank Foundation

Phase-0 **seed-reference** child of the Architecture Review Method Suite Program.
Status: **draft**. Candidate proposal lineage only — this packet authorizes
nothing and grants no authority.

## Purpose

This child authors the one shared **architecture lens bank** that the rest of the
Architecture Review Method Suite depends on. Concretely, at implementation it
adds three durable artifacts inside the existing Architectural Review Mechanism:

1. `.octon/framework/cognition/practices/methodology/architectural-review/architecture-lens-bank.md`
   — lens doctrine: the 18-lens catalog (12 core, 6 extended), a per-method
   profile table, the clean-sheet vs Greenfield complementarity statement, the
   Balanced sequence→lens-id appendix, and four sprawl controls.
2. `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml`
   — the machine-readable contract: lens ids + tiers for all 18 lenses, and
   required/optional lens profiles for all six suite methods.
3. `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh`
   — a validator (plus fixtures) that fails closed when a method doc references
   an undefined lens id or a bank-known method lacks a profile.

## Load-Bearing Design Decisions (inherited from the parent, re-grounded here)

- **One bank, no private catalogs.** `lens-bank.yml` is the suite's only lens
  catalog. Methods reference lens ids; they never define their own lists.
- **Methods own questions; lenses are tools.** The bank encodes only lens ids,
  tiers, and per-method profiles. Questions, scope, routing, and output
  contracts stay in method docs.
- **Balanced doctrine is unchanged.** Balanced's required lens set equals its
  existing 11-step required sequence expressed as lens ids; the Balanced doc is
  not edited (see `resources/lens-bank-authoring-spec.md` for the proof).
- **Clean-sheet is a lens; Greenfield is a method.** The complementarity
  statement is authored into the lens bank doc.
- **Machine-readable, fail-closed.** Lens profiles are a validated
  cross-reference surface; a prose-only catalog would drift silently, so the bank
  ships with a validator carrying two negative controls.

## Scope And Boundaries

- Write scopes (registry-declared):
  `.octon/framework/cognition/practices/methodology/architectural-review/` and
  `.octon/framework/assurance/runtime/_ops/scripts/` (plus the assurance test
  fixture tree for fixtures).
- **Not** in scope: the `naming.yml` v2 methods-list refactor and
  `review-routing.yml` `method_selection` (phase-1); the Greenfield and companion
  method docs (phase-2); the review report/routing-decision v2 schemas (phase-2);
  review workflow method-recording and generated projection refresh (phase-3).
  Architecture-readiness and surface-architecture audit doctrine are out of scope
  and unchanged.
- Creates no new mechanism, lifecycle gate, routed workflow mode, evidence root,
  or command facade. Grants no review output any authority.

## Dependencies

- Upstream: none. This is the phase-0 seed; `dependencies: []`.
- Downstream: `architecture-review-method-taxonomy-and-routing` (phase-1) binds
  to this bank at the `verification` gate and reconciles the canonical companion
  method slugs with the provisional slugs used in `lens-bank.yml` here.

## Lifecycle

Draft until governed review and acceptance. Advances through review,
implementation, and verification per `architecture/implementation-plan.md` and
`architecture/acceptance-criteria.md`; rolls back manually per
`architecture/rollback-plan.md`. Allowed terminal states: closed, superseded, or
rejected (child-packet-contract obligation 8).

## Non-Authority Statement

This packet is candidate proposal lineage only. The intake unit and parent
program design docs it draws from are non-authoritative and cited as source
lineage, never authority. The durable authority after promotion is the framework
artifacts in `architecture/file-change-map.md`; child lifecycle evidence lands
under `.octon/state/evidence/validation/proposals/architecture-lens-bank-foundation/`.
Parent program evidence never satisfies this child's receipts.
