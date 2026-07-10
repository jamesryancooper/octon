# Operator Disclosure

## What Changes For Operators

Very little changes operationally when this child lands. No new command, skill,
gate, routed workflow mode, or evidence root is created. Existing v1 review
reports and routing decisions remain valid and are not disturbed. What is new is
that a review report or routing decision may now be emitted at **v2**, which
records the method the review used and the lens profile actually applied.

## What Becomes Available

- Two **method-aware schemas** under
  `.octon/framework/constitution/contracts/assurance/`:
  `architectural-review-report-v2` and
  `architectural-review-routing-decision-v2`, each a strict additive superset of
  its v1 schema carrying required `method` and `lenses_applied` fields.
- **Machine-checked method and lens recording**: the receipts validator asserts a
  v2 artifact's `method` is one of the six canonical suite method slugs and its
  `lenses_applied` ids are declared in the lens bank, failing closed on an unknown
  method (`unknown_method`) or an undefined lens (`undefined_lens`).
- A **support-receipt drift guard**: the receipts validator fails closed
  (`receipt_schema_drift`) if a support receipt drifts from schema v1 or picks up
  a method field — the support receipt stays method-agnostic.

## What Operators Must Not Assume

- Recording a method or lenses grants **no** review-output authority. Review
  outputs remain evidence or proposal input; the pre-integration support receipt
  remains the only lifecycle-gating review artifact.
- v1 is **retained**. A producer that emits a v1 report or routing decision (no
  method recorded) is still valid; Balanced Architecture Review is the default
  method when none is recorded. v2 is opt-in for method-aware producers.
- The **support receipt schema is unchanged**. This child does not add method or
  lens fields to `architectural-review-support-receipt-v1.schema.json`.
- The wiring that makes review **workflows** record the selected method id in run
  evidence is authored by the phase-3 child
  (`architectural-review-suite-integration`). This child ships the schemas that
  wiring will conform to; it does not itself change any workflow contract.
- No existing route, alias, evidence root, or the pre-integration gate changed.

## Support And Evidence

Schema well-formedness and additive-superset proofs, the receipts-validator
positive and three negative-control runs, the method-enum and lens-id binding
proofs, the v1 coexistence proof, and the support-receipt-unchanged `git diff`
are retained under
`.octon/state/evidence/validation/proposals/architectural-review-schema-extensions/`.
This packet is non-authoritative proposal lineage; the durable authority after
promotion is the framework artifacts listed in `architecture/file-change-map.md`.
