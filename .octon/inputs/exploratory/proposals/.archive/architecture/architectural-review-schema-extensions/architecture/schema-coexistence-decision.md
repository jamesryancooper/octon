# Schema Coexistence Decision (v1 → v2)

This is the explicit v1→v2 coexistence posture required by the per-child charter
("declare the v1→v2 coexistence posture explicitly"). It is a load-bearing design
decision recorded at packet creation and confirmed against the live repository.

## Decision

Introduce `architectural-review-report-v2` and
`architectural-review-routing-decision-v2` **as strict additive supersets** of
their v1 schemas, **retain** the v1 schemas unchanged, and **leave the
support-receipt schema at v1 untouched**. Both schema versions coexist
indefinitely; there is no forced migration and no v1 deprecation in this child.

## Posture Rules

1. **v2 is a superset of v1.** Every field and constraint in v1 is present in v2
   unchanged (including `additionalProperties: false` and the `review_mode` /
   `selected_mode` enums). v2 only adds the two required fields `method` and
   `lenses_applied` and bumps the `schema_version` const. An artifact valid under
   v2 minus its two new fields is valid under v1.
2. **v1 stays valid.** The v1 report and routing-decision schemas remain on disk.
   A method-agnostic producer may emit v1 artifacts with no `method`/`lenses_applied`;
   these validate against v1. Because `additionalProperties: false` holds in v1, a
   v1 artifact **cannot** silently carry the new fields — recording a method
   requires declaring `schema_version` v2.
3. **Default method semantics.** When no method is recorded (a v1 artifact),
   Balanced Architecture Review is the default method per the phase-1
   `naming.yml` `methods.default`. v2 does not change this default; it only makes
   an explicit method recordable and checkable.
4. **Support receipt is method-agnostic forever (in this child).**
   `architectural-review-support-receipt-v1.schema.json` is byte-for-byte
   unchanged. The lifecycle-gating receipt never carries `method`/`lenses_applied`;
   the receipts validator fails closed (`receipt_schema_drift`) if a receipt
   drifts from v1 or acquires a method field. Method/lens recording is a property
   of the report and routing-decision artifacts, not the gate receipt.
5. **Producers choose their version.** A producer selects v1 (method-agnostic) or
   v2 (method-aware) by the `schema_version` it declares; the receipts validator
   validates whichever it finds. No consumer is required to upgrade in this child.

## Why Not Mutate v1 In Place

Mutating v1 to add required `method`/`lenses_applied` would invalidate every
existing v1 artifact at once (a breaking change) and would violate the additive,
no-regression discipline the parent program requires of every child. Supersetting
keeps existing evidence valid while making method/lens recording available and
enforceable for producers that opt in. This mirrors the additive v1→v2 posture the
phase-1 child used for `naming.yml` and `review-routing.yml`.

## Live Confirmation

Verified at HEAD: `architectural-review-report-v1.schema.json`,
`architectural-review-routing-decision-v1.schema.json`, and
`architectural-review-support-receipt-v1.schema.json` all exist with
`additionalProperties: false`; the six method slugs are live in `naming.yml`
`methods`; and the 18 lens ids are live in `lens-bank.yml`. No divergence blocks
this coexistence posture.
