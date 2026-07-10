# Cutover Checklist

This is an additive new-surface change with no live-state migration: the lens
bank does not exist today, so there is no coexistence window and no rival
version to strangle. "Cutover" here is the single atomic landing of the new
artifacts.

## Pre-Cutover

- [ ] Implementation authorized (accepted status, accepted proposal-review
      receipt authorizing the executable prompt, strict Pre-Integration
      Architecture Review receipt present).
- [ ] Write scope confirmed limited to
      `.octon/framework/cognition/practices/methodology/architectural-review/`
      and `.octon/framework/assurance/runtime/_ops/scripts/` (+ fixture tree).
- [ ] `resources/lens-bank-authoring-spec.md` reconciled against the live
      mechanism (no divergence beyond the recorded provisional-slug note).

## Cutover (atomic)

- [ ] `lens-bank.yml` authored with all 18 lens ids/tiers and six method
      profiles.
- [ ] `architecture-lens-bank.md` authored with catalog, profile table,
      complementarity statement, Balanced appendix, and sprawl controls.
- [ ] `validate-architectural-review-lens-references.sh` authored with both
      fail-closed rules.
- [ ] Passing + two negative-control fixtures authored.

## Post-Cutover Validation

- [ ] Lens-reference validator passes on the shipped bank.
- [ ] Both negative-control fixtures fail closed (non-zero exit).
- [ ] Doc/registry consistency check passes (18 ids + tiers + 6 profiles agree).
- [ ] `git diff` shows `balanced-architecture-review-method.md` unchanged.
- [ ] Existing naming/routing validators still pass (no regression).
- [ ] Evidence retained under the child promotion evidence root.

## Closure

- [ ] All acceptance criteria AC-1..AC-7 satisfied; verification receipt
      retained; child moved to `closed`.
