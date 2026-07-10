# Architectural Review Schema Extensions

Phase-2 child of the Architecture Review Method Suite Program. Status:
**draft**. Candidate proposal lineage only — this packet authorizes nothing and
grants no authority.

## Purpose

This child gives the Architectural Review Mechanism a **method-aware contract
layer**. Concretely, at implementation it adds two durable schema files and
extends one validator and one README inside the existing mechanism's contract
surface:

1. `.octon/framework/constitution/contracts/assurance/architectural-review-report-v2.schema.json`
   — a strict **additive superset** of `architectural-review-report-v1`: every
   v1 required field and constraint is preserved, plus two new required fields —
   `method` (one of the six canonical suite method slugs) and `lenses_applied`
   (the lens profile actually applied).
2. `.octon/framework/constitution/contracts/assurance/architectural-review-routing-decision-v2.schema.json`
   — a strict additive superset of `architectural-review-routing-decision-v1`
   with the same two additive required fields. This completes the schema-level
   `method` record that phase-1's `missing_method_record` fail-closed condition
   anticipated.
3. `.octon/framework/constitution/contracts/assurance/README.md`
   — lists the two v2 schemas beside their v1 counterparts; existing entries
   unchanged.
4. `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh`
   — gains **v2 awareness**: it validates the additive `method` field against the
   live `naming.yml` method catalog and `lenses_applied` against `lens-bank.yml`
   lens ids, asserts the support receipt stays at schema v1, and fails closed on
   `unknown_method`, `undefined_lens`, and `receipt_schema_drift` — each proven by
   a negative control.

`.octon/framework/constitution/contracts/assurance/architectural-review-support-receipt-v1.schema.json`
is **left untouched**: the support receipt never gains method or lens fields.

## Load-Bearing Design Decisions (inherited from the parent, re-grounded here)

- **Additive supersets, not replacements.** The v2 schemas keep every v1 field
  and constraint and add `method` + `lenses_applied`. The v1 schemas are
  **retained**, not deleted; method-agnostic producers stay valid and Balanced
  applies as the default method when none is recorded. See
  `architecture/schema-coexistence-decision.md`.
- **Support receipt is out of bounds.** The lifecycle-gating support receipt
  schema stays at v1 verbatim. The receipts validator asserts this and fails
  closed if a receipt drifts (`receipt_schema_drift`). Method/lens recording
  belongs to the report and routing-decision artifacts, not the gate receipt.
- **Method enum bound to phase-1.** The v2 `method` enum equals the `naming.yml`
  `methods` catalog slugs verified by
  `architecture-review-method-taxonomy-and-routing`. The receipts validator
  cross-checks against the live catalog so schema drift fails closed
  (`unknown_method`), per child-packet-contract obligation 4 (enforcement
  surface).
- **Lenses bound to phase-0.** `lenses_applied` ids must be declared lens ids in
  `lens-bank.yml` (phase-0). An undefined lens id fails closed
  (`undefined_lens`).
- **No new authority.** No new mechanism, gate, routed workflow mode, evidence
  root, or command facade. The method and lenses_applied fields record which
  method and lenses were used; the pre-integration support receipt remains the
  only lifecycle-gating review artifact.

## Scope And Boundaries

- Write scopes (registry-declared):
  `.octon/framework/constitution/contracts/assurance/` and
  `.octon/framework/assurance/runtime/_ops/scripts/` (plus the assurance test
  fixture tree for negative-control fixtures).
- **Not** in scope: the `naming.yml` methods list and `review-routing.yml`
  `method_selection` block (phase-1, consumed as a verified dependency); the lens
  bank (phase-0, consumed as a verified dependency);
  `architectural-review-support-receipt-v1.schema.json` (untouched); the
  Greenfield and companion method docs (phase-2 siblings); review workflow
  method-id recording and generated projection refresh (phase-3).
  Architecture-readiness and surface-architecture audit doctrine are out of scope
  and unchanged.
- Creates no new mechanism, lifecycle gate, routed workflow mode, evidence root,
  or command facade. Grants no review output any authority.

## Dependencies

- Upstream: `architecture-review-method-taxonomy-and-routing` (phase-1) and
  `architecture-lens-bank-foundation` (phase-0), both bound at the `verification`
  gate. The v2 `method` enum equals the phase-1 `naming.yml` methods catalog
  slugs; `lenses_applied` ids are drawn from the phase-0 `lens-bank.yml`. This
  child completes the schema-level enforcement that phase-1's
  `missing_method_record` condition anticipated.
- Downstream: `architectural-review-suite-integration` (phase-3) binds to these
  v2 schemas at its `verification` gate when it records the selected method id in
  review workflow run evidence.

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
`.octon/state/evidence/validation/proposals/architectural-review-schema-extensions/`.
Parent program evidence never satisfies this child's receipts. Where any
statement here disagrees with the live repository, the repository wins and this
packet's docs need revision.
