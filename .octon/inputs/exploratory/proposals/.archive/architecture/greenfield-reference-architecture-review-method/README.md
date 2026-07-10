# Greenfield Reference Architecture Review Method

Phase-2 child of the Architecture Review Method Suite Program. Status:
**draft**. Candidate proposal lineage only — this packet authorizes nothing and
grants no authority.

## Purpose

This child authors one native methodology doc inside the existing Architectural
Review Mechanism:

- `.octon/framework/cognition/practices/methodology/architectural-review/greenfield-reference-architecture-review-method.md`

The doc is the output contract for the **Greenfield Reference Architecture
Review** method — the method a reviewer selects to answer *"if this system or
subsystem did not exist, what should we build first?"* The method is already
**named** (`naming.yml` `methods.catalog`) and **routable** (`review-routing.yml`
`method_selection`) after phase-1; this child supplies the missing output
contract and wires the doc into the catalog.

Per `architecture/method-doc-authoring-spec.md`, the doc specifies:

1. The method question, use cases, required inputs, and non-goals.
2. Five required output sections — (1) domain/job model, (2) reference
   architecture, (3) quality/security/ops model, (4) authority/evidence model,
   (5) evolution plan.
3. Initial-build sequencing, a minimum viable architecture, and an explicit
   **what-not-to-build-yet** list.
4. The **clean-sheet complementarity** with Balanced (Greenfield produces the
   reference design as the deliverable, not as a comparison tool, and issues no
   what-to-change verdict).
5. Escalation rules and constitutional routing.
6. The **lens-profile reference** bound to `lens-bank.yml`
   `method_profiles.greenfield-reference-architecture-review-method` (14 required
   + 3 optional lens ids), with no private lens catalog.
7. The **reference-architecture-only output boundary** stated fail-closed:
   Greenfield output is evidence or proposal input, never implementation
   authority.

Two additive navigation edits wire the doc in: the `naming.yml` greenfield
catalog entry gains a `doc:` reference (matching Balanced's), and the mechanism
README references section links the doc. Both are additive and navigation only.

## Load-Bearing Design Decisions (inherited from the parent, re-grounded here)

- **Reference architecture only, fail-closed.** The single most load-bearing
  boundary: Greenfield output is a *reference* design — evidence or proposal
  input. It is never implementation authority, never a lifecycle gate, and never
  a what-to-change verdict against an existing system. This is stated in the doc
  as a fail-closed output boundary. (method-taxonomy.md §2; child-packet-contract
  greenfield charter)
- **No fantasy architecture.** Greenfield output must respect Octon governance,
  support-claim boundaries, evidence obligations, validation, and operability
  from day one. The five required sections force an authority/evidence model and
  a quality/security/ops model into every reference design, so the method cannot
  produce an ungoverned design.
- **Lenses from the shared bank only.** The doc cites the verified `lens-bank.yml`
  greenfield profile by lens id and defines no private lens catalog
  (child-packet-contract suite design rule). The 14 required + 3 optional lens
  ids are consumed verbatim from the phase-0 artifact.
- **Distinct from Balanced and the companions.** Greenfield does not decide what
  to change in an existing system (that is Balanced), does not exhaustively score
  options (Tradeoff), and does not absorb any companion method's output contract.
  Its clean-sheet relationship with Balanced is stated explicitly: both use the
  `clean-sheet-reference` lens, but Balanced uses it as a *comparison tool*
  against current reality while Greenfield makes the clean-sheet reference the
  *deliverable*.
- **Methodology-doc-only child.** This child touches only methodology docs, so
  its validation floor is a **doc-consistency check** against `naming.yml` and
  `lens-bank.yml` (child-packet-contract obligation 4), not a negative control.
  It ships no enforcement surface.

## Scope And Boundaries

- Write scope (registry-declared):
  `.octon/framework/cognition/practices/methodology/architectural-review/`.
- **In scope:** the new Greenfield method doc; the additive `doc:` reference on
  the existing `naming.yml` greenfield catalog entry; and a README references
  link.
- **Not** in scope: the four companion method docs
  (`companion-architecture-review-methods`, phase-2); the
  `architectural-review-report-v2` / `routing-decision-v2` schemas
  (`architectural-review-schema-extensions`, phase-2); the naming methods list,
  routing `method_selection`, and README canonical-names table authored by
  phase-1 (consumed as verified dependencies; only the greenfield catalog entry
  gains a `doc:` reference); the phase-0 lens bank (consumed, not modified);
  Balanced doctrine; review workflow method-recording and generated projection
  refresh (`architectural-review-suite-integration`, phase-3);
  architecture-readiness and surface-architecture audit doctrine.
- Creates no new mechanism, lifecycle gate, routed workflow mode, evidence root,
  or command facade. Grants no review output any authority.

## Dependencies

- Upstream: `architecture-review-method-taxonomy-and-routing` (phase-1), bound at
  the `verification` gate — it owns the naming slot
  (`greenfield-reference-architecture-review-method`) and the routing
  `method_selection` semantics this doc plugs into. Transitively,
  `architecture-lens-bank-foundation` (phase-0) owns the greenfield lens profile
  the doc cites.
- Downstream: `architectural-review-suite-integration` (phase-3) records the
  selected method id in run evidence and refreshes generated projections; it
  binds to the landed method docs (this child and the companion-methods child) at
  its `verification` gate.

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
under
`.octon/state/evidence/validation/proposals/greenfield-reference-architecture-review-method/`.
Parent program evidence never satisfies this child's receipts. Where any
statement here disagrees with the live repository, the repository wins and this
packet's docs need revision.
