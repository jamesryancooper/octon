# Architecture Review Method Taxonomy And Routing

Phase-1 child of the Architecture Review Method Suite Program. Status:
**draft**. Candidate proposal lineage only — this packet authorizes nothing and
grants no authority.

## Purpose

This child gives the Architectural Review Mechanism an explicit **method layer**
in its naming and routing models. Concretely, at implementation it changes four
durable methodology files and two validators inside the existing mechanism:

1. `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml`
   → `architectural-review-naming-v2`: adds a `methods` list declaring all six
   suite methods by canonical slug, with **Balanced** as the declared default.
   No existing slug is renamed and no alias is retired.
2. `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml`
   → `architectural-review-routing-v2`: adds a `method_selection` block (default
   method, per-route allowed methods, escalation map) and two fail-closed
   conditions — `unknown_method` and `missing_method_record`.
3. `.octon/framework/cognition/practices/methodology/architectural-review/README.md`
   — extends the canonical-names table with the six method rows and a short
   method-selection note.
4. `.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md`
   — **minimal navigation cross-references only** (to the method taxonomy and
   the lens bank); Balanced doctrine text is not changed.
5. `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh`
   and `validate-architectural-review-routing.sh` — extended with method-list /
   method-selection checks and at least one negative control per new fail-closed
   rule.

## Load-Bearing Design Decisions (inherited from the parent, re-grounded here)

- **Six methods, one default.** The methods list enumerates Balanced plus the
  five companions. Balanced Architecture Review stays the default method when no
  selection is made, so existing routing behavior is preserved.
- **Canonical slugs are fixed here.** This child owns the canonical companion
  method slugs. It adopts the `-method`-suffixed slugs already seeded
  (provisionally) in `lens-bank.yml` by `architecture-lens-bank-foundation`, so
  the verified lens bank binds cleanly with **no change to the phase-0
  artifact**. This diverges from the non-suffixed slugs in the parent
  `method-taxonomy.md`; that divergence is recorded as a program design-revision
  note (see `architecture/slug-reconciliation-decision.md`), because the live
  lens bank outranks a stale parent design claim (child-packet-contract
  obligation 3).
- **Fail-closed method routing.** Selecting an undefined method
  (`unknown_method`) or emitting a routing decision without a required method
  record (`missing_method_record`) fails closed. These are validated with
  negative controls, per child-packet-contract obligation 4 (enforcement
  surface).
- **Additive version bumps only.** naming v1→v2 and routing v1→v2 add fields;
  they rename nothing and retire nothing. Existing canonical modes, routes,
  aliases, evidence roots, and the pre-integration gate are untouched.
- **No new authority.** No new mechanism, gate, routed workflow mode, evidence
  root, or command facade. Method selection is routing semantics; the
  pre-integration support receipt remains the only lifecycle-gating review
  artifact.

## Scope And Boundaries

- Write scopes (registry-declared):
  `.octon/framework/cognition/practices/methodology/architectural-review/` and
  `.octon/framework/assurance/runtime/_ops/scripts/` (plus the assurance test
  fixture tree for negative-control fixtures).
- **Not** in scope: the Greenfield and companion method docs (phase-2); the
  `architectural-review-report-v2` / `routing-decision-v2` schemas (phase-2);
  review workflow method-recording and generated projection refresh (phase-3);
  any modification of the phase-0 lens bank beyond binding to its slugs.
  Architecture-readiness and surface-architecture audit doctrine are out of
  scope and unchanged.
- Creates no new mechanism, lifecycle gate, routed workflow mode, evidence root,
  or command facade. Grants no review output any authority.

## Dependencies

- Upstream: `architecture-lens-bank-foundation` (phase-0), bound at the
  `verification` gate. The naming v2 methods list and routing v2
  `method_selection` block cite the verified lens bank; the six method slugs
  equal its `suite_methods` slugs. See
  `architecture/slug-reconciliation-decision.md`.
- Downstream: `greenfield-reference-architecture-review-method`,
  `companion-architecture-review-methods`, and
  `architectural-review-schema-extensions` (all phase-2) bind to this taxonomy
  and routing at their `verification` gates.

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
`.octon/state/evidence/validation/proposals/architecture-review-method-taxonomy-and-routing/`.
Parent program evidence never satisfies this child's receipts. Where any
statement here disagrees with the live repository, the repository wins and this
packet's docs need revision.
