# Target Architecture

## Target State

After this child is implemented, the Architectural Review Mechanism's contract
surface under `.octon/framework/constitution/contracts/assurance/` carries a
method-aware layer. Two files are added and two are changed additively:

- **New** `architectural-review-report-v2.schema.json`: a strict additive
  superset of `architectural-review-report-v1`. It keeps every v1 required field
  (`schema_version`, `review_id`, `review_mode`, `subject_ref`, `verdict`,
  `findings`, `dispositions`, `evidence_refs`, `validator_refs`,
  `non_authority_classification`, `recorded_at`) and every constraint
  (`additionalProperties: false`), sets `schema_version` const to
  `architectural-review-report-v2`, and adds two new **required** fields:
  - `method`: enum of the six canonical suite method slugs.
  - `lenses_applied`: array of lens-id strings, `minItems: 1`, `uniqueItems: true`.
- **New** `architectural-review-routing-decision-v2.schema.json`: a strict
  additive superset of `architectural-review-routing-decision-v1` with the same
  two additive required fields (`method`, `lenses_applied`), `schema_version`
  const `architectural-review-routing-decision-v2`, and all v1 fields and
  constraints preserved. This completes the schema-level `method` record that
  phase-1's `missing_method_record` fail-closed condition anticipated.
- **Changed** `README.md` (contracts/assurance): the schema list gains the two v2
  schema entries beside their v1 counterparts. Existing entries unchanged.
- **Changed** `validate-architectural-review-receipts.sh`: gains v2 awareness
  (see §Validator Behavior).

`architectural-review-support-receipt-v1.schema.json` and the v1 report and
routing-decision schemas are **retained unchanged**.
`.octon/framework/assurance/runtime/_ops/scripts/` keeps its files; the receipts
validator is extended, with fixtures under the assurance test tree.

## The Two Additive Fields

- `method` (required in v2): the single method the review run used, recorded as a
  canonical slug. Allowed values are exactly the six `naming.yml` `methods`
  catalog slugs: `balanced-architecture-review-method` (default),
  `greenfield-reference-architecture-review-method`, `tradeoff-review-method`,
  `failure-mode-review-method`, `evolution-fitness-review-method`,
  `boundary-authority-review-method`.
- `lenses_applied` (required in v2): the lens profile actually applied, as a
  non-empty, de-duplicated array of lens ids. Every id must be a declared lens id
  in `lens-bank.yml` (the 18 core/extended lenses). This makes the "lens profile
  actually applied" claim from `method-taxonomy.md` machine-checkable.

## Validator Behavior (`validate-architectural-review-receipts.sh` v2 awareness)

The validator remains the checker for the support receipt (v1) and additionally
becomes able to validate a report or routing-decision artifact:

1. **Support receipt path (unchanged behavior + drift guard):** when validating a
   support receipt it still requires `schema_version ==
   architectural-review-support-receipt-v1` and all existing v1 checks, and fails
   closed (`receipt_schema_drift`) if the receipt declares any other
   `schema_version` or carries a `method`/`lenses_applied` field.
2. **v2 report / routing-decision path (new):** when the artifact's
   `schema_version` ends in `-v2`, it asserts:
   - `method` is present and is one of the live `naming.yml` `methods` catalog
     slugs — an unrecognized value fails closed (`unknown_method`);
   - `lenses_applied` is a non-empty array whose every id is declared in
     `lens-bank.yml` — an undefined id fails closed (`undefined_lens`).
3. **v1 report / routing-decision path (coexistence):** a v1 artifact validates
   without `method`/`lenses_applied`; the validator does not require the fields
   for v1.

## Invariants

1. **Additive supersets only.** v2 keeps every v1 field and constraint and adds
   exactly `method` and `lenses_applied`. No v1 field is removed, renamed, or
   re-typed.
2. **v1 retained, not deleted.** The v1 report and routing-decision schemas stay
   on disk and valid; method-agnostic producers remain conformant and Balanced is
   the default method when none is recorded.
3. **Support receipt untouched.** `architectural-review-support-receipt-v1.schema.json`
   is byte-for-byte unchanged; the validator asserts receipts stay at v1.
4. **Method enum bound to phase-1.** Every v2 `method` value equals a `naming.yml`
   `methods` catalog slug; the receipts validator enforces this against the live
   catalog (NC — `unknown_method`).
5. **Lenses bound to phase-0.** Every `lenses_applied` id is a declared
   `lens-bank.yml` lens id; the receipts validator enforces this (NC —
   `undefined_lens`).
6. **Fail-closed with negative controls.** Three negative controls prove
   `unknown_method`, `undefined_lens`, and `receipt_schema_drift` each fail closed
   (non-zero exit).
7. **No authority granted to review outputs.** Recording the method and lenses is
   descriptive; review outputs remain evidence or proposal input; the
   pre-integration support receipt remains the only lifecycle-gating review
   artifact.
8. **Doc/data agreement.** The contracts/assurance README lists the two v2 schemas
   and agrees with the on-disk schema files.

## Boundary With Adjacent Doctrine

Architecture-readiness evaluation and surface-architecture audit doctrine are out
of scope and unchanged. The v2 `review_mode`/`selected_mode` enums are inherited
verbatim from v1 (no route added or removed). Constitutional conflicts continue
to route to Constitutional Challenge (existing kernel gate); recording a method on
a report does not change that routing.

## What This Child Deliberately Does Not Build

- The `naming.yml` **methods list** and `review-routing.yml` **method_selection**
  block (owned by `architecture-review-method-taxonomy-and-routing`, phase-1).
  This child binds to them as verified dependencies; it does not author or modify
  them.
- The **lens bank** (owned by `architecture-lens-bank-foundation`, phase-0). This
  child binds `lenses_applied` to its lens ids; it does not modify it.
- Any change to `architectural-review-support-receipt-v1.schema.json` — the
  support receipt stays v1.
- Review workflow **method-id recording** in run evidence and any generated
  projection refresh (owned by `architectural-review-suite-integration`,
  phase-3). This child ships the schemas those recordings will conform to; it does
  not wire them into workflow contracts.
