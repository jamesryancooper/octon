# Acceptance Criteria

Accepting and implementing this child requires all of the following. Each maps to
a gap in `architecture/current-state-gap-map.md` and a check in
`architecture/validation-plan.md`.

- **AC-1 — v2 report schema authored.** `architectural-review-report-v2.schema.json`
  exists as a strict additive superset of `architectural-review-report-v1`:
  `schema_version` const `architectural-review-report-v2`, all v1 required fields
  and constraints preserved, and two new required fields — `method` (enum of the
  six canonical suite method slugs) and `lenses_applied` (array, `minItems: 1`,
  `uniqueItems: true`). (G1, G2)
- **AC-2 — v2 routing-decision schema authored.**
  `architectural-review-routing-decision-v2.schema.json` exists as a strict
  additive superset of `architectural-review-routing-decision-v1` with the same
  two additive required fields, completing the schema-level `method` record that
  phase-1's `missing_method_record` anticipated. (G3)
- **AC-3 — Method enum bound to phase-1.** The v2 `method` enum equals the six
  `naming.yml` `methods` catalog slugs, and the receipts validator fails closed
  (NC-1, `unknown_method`) when a v2 artifact declares a method not in the live
  catalog. (G4)
- **AC-4 — Lenses bound to phase-0.** The receipts validator fails closed (NC-2,
  `undefined_lens`) when a v2 artifact's `lenses_applied` contains an id not
  declared in `lens-bank.yml`. (G5)
- **AC-5 — Support receipt untouched and guarded.**
  `architectural-review-support-receipt-v1.schema.json` is byte-for-byte
  unchanged, and the receipts validator fails closed (NC-3, `receipt_schema_drift`)
  when a support receipt drifts from schema v1 or carries a `method` field. (G6)
- **AC-6 — Fail-closed with negative controls.** The receipts validator passes on
  the `pass` fixture (valid v2 report + routing-decision) and fails (non-zero
  exit) on all three negative-control fixtures: `fail-unknown-method` (NC-1),
  `fail-undefined-lens` (NC-2), and `fail-receipt-schema-drift` (NC-3). (G4, G5,
  G6)
- **AC-7 — v1 coexistence preserved.** The v1 report and routing-decision schemas
  are retained and still validate v1 artifacts without `method`/`lenses_applied`;
  the v1→v2 coexistence posture is recorded in
  `architecture/schema-coexistence-decision.md`. (G7)
- **AC-8 — Schema index extended without rewrite.** The contracts/assurance README
  lists the two v2 schemas beside their v1 counterparts; existing entries are
  unchanged. (G8)
- **AC-9 — Additive-only, no regression, no authority granted.** No v1 schema
  field is removed, renamed, or re-typed; no new mechanism, gate, routed workflow
  mode, evidence root, or command facade is created; the method/lens fields grant
  no review output any authority; and the remaining
  `validate-architectural-review-*.sh` suite still passes.
- **AC-10 — Evidence retained.** Schema well-formedness + additive-superset
  proofs, receipts-validator runs (positive + three negative controls), the
  method-enum and lens-id binding proofs, the v1 coexistence proof, the
  support-receipt-unchanged `git diff`, and the no-regression runs are retained
  under the child's promotion evidence root.

## Closure Condition

This child reaches `closed` only when AC-1 through AC-10 hold, all validators pass
(with the three negative controls demonstrably failing closed), and the
verification receipt is retained. Allowed alternative terminal states are
`superseded` or `rejected` with recorded rationale (child-packet-contract
obligation 8). No unresolved acceptance criterion may remain at closeout.
