# Cutover Checklist

This is an additive surface refactor with no live-state migration: v1 models are
bumped to v2 by adding fields, and Balanced remains the default so routing
behavior is unchanged for callers that make no method selection. "Cutover" here
is the single atomic landing of the additive diffs, validators, and fixtures.

## Pre-Cutover

- [ ] Implementation authorized (accepted status, accepted proposal-review
      receipt authorizing the executable prompt, strict Pre-Integration
      Architecture Review receipt present).
- [ ] Upstream `architecture-lens-bank-foundation` (phase-0) has passed its
      `verification` gate; `lens-bank.yml` `suite_methods` verified.
- [ ] Write scope confirmed limited to
      `.octon/framework/cognition/practices/methodology/architectural-review/`
      and `.octon/framework/assurance/runtime/_ops/scripts/` (+ fixture tree).
- [ ] `resources/naming-routing-authoring-spec.md` and
      `architecture/slug-reconciliation-decision.md` reconciled against the live
      lens bank (six canonical slugs still match `suite_methods`).

## Cutover (atomic)

- [ ] `naming.yml` bumped to v2 with the `methods` block; all existing keys
      preserved verbatim.
- [ ] `review-routing.yml` bumped to v2 with `method_selection` and the two new
      `fail_closed_conditions`; existing routes/conditions preserved.
- [ ] README canonical-names table extended with six method rows + selection note
      + links.
- [ ] Balanced doc navigation cross-references added (no doctrine change).
- [ ] Naming and routing validators extended with NC-A/NC-B/NC-C.
- [ ] Passing + three negative-control fixtures authored.

## Post-Cutover Validation

- [ ] Naming and routing validators pass on the shipped models.
- [ ] NC-A, NC-B, and NC-C fixtures fail closed (non-zero exit).
- [ ] Every `naming.yml` method slug present in `lens-bank.yml` `suite_methods`.
- [ ] Phase-0 lens-reference validator still passes.
- [ ] `git diff` shows no slug renamed, no alias retired, no existing route
      changed, and Balanced doctrine text unchanged.
- [ ] Remaining `validate-architectural-review-*.sh` suite still passes.
- [ ] Evidence retained under the child promotion evidence root.

## Closure

- [ ] All acceptance criteria AC-1..AC-8 satisfied; verification receipt
      retained; child moved to `closed`.
