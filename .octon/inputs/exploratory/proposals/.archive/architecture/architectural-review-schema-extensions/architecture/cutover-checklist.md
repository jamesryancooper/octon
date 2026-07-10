# Cutover Checklist

This is an additive contract-surface refactor with no live-state migration: two
v2 schemas are added as supersets of retained v1 schemas, the README and receipts
validator are extended, and v1 producers remain valid. "Cutover" here is the
single atomic landing of the additive schemas, README/validator edits, and
fixtures.

## Pre-Cutover

- [ ] Implementation authorized (accepted status, accepted proposal-review
      receipt authorizing the executable prompt, strict Pre-Integration
      Architecture Review receipt present).
- [ ] Upstream `architecture-review-method-taxonomy-and-routing` (phase-1) and
      `architecture-lens-bank-foundation` (phase-0) have passed their
      `verification` gates; `naming.yml` `methods` catalog and `lens-bank.yml`
      lens ids verified.
- [ ] Write scope confirmed limited to
      `.octon/framework/constitution/contracts/assurance/` and
      `.octon/framework/assurance/runtime/_ops/scripts/` (+ fixture tree).
- [ ] `resources/schema-extension-authoring-spec.md` reconciled against the live
      naming catalog and lens bank (six method slugs and the lens ids still
      match).

## Cutover (atomic)

- [ ] `architectural-review-report-v2.schema.json` added as an additive superset
      with required `method`/`lenses_applied`.
- [ ] `architectural-review-routing-decision-v2.schema.json` added as an additive
      superset with required `method`/`lenses_applied`.
- [ ] v1 report/routing-decision schemas and the support-receipt schema left
      untouched.
- [ ] contracts/assurance README lists the two v2 schemas.
- [ ] Receipts validator extended with v2 awareness + NC-1/NC-2/NC-3.
- [ ] `pass` + three negative-control fixtures authored.

## Post-Cutover Validation

- [ ] Both v2 schemas parse as well-formed JSON Schema and diff v1 as additive
      supersets only.
- [ ] Receipts validator passes on the `pass` fixture.
- [ ] `fail-unknown-method`, `fail-undefined-lens`, and
      `fail-receipt-schema-drift` fixtures fail closed (non-zero exit).
- [ ] Every v2 `method` enum value present in `naming.yml` `methods` catalog;
      every `pass` fixture lens id present in `lens-bank.yml`.
- [ ] v1 report/routing-decision artifacts still validate against the retained v1
      schemas.
- [ ] `git diff` shows the support-receipt schema unchanged and the README only
      extended.
- [ ] Phase-0 lens-reference and phase-1 naming validators still pass; remaining
      `validate-architectural-review-*.sh` suite still passes.
- [ ] Evidence retained under the child promotion evidence root.

## Closure

- [ ] All acceptance criteria AC-1..AC-10 satisfied; verification receipt
      retained; child moved to `closed`.
