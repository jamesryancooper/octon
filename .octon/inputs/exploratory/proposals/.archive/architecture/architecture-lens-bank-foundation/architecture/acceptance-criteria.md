# Acceptance Criteria

Accepting and implementing this child requires all of the following. Each maps
to a gap in `architecture/current-state-gap-map.md` and a check in
`architecture/validation-plan.md`.

- **AC-1 — Lens doctrine authored.** `architecture-lens-bank.md` exists under
  the mechanism directory with the 18-lens catalog in two tiers (12 core, 6
  extended), each lens stating its question, evidence artifact, and when to
  apply, plus the clean-sheet vs Greenfield complementarity statement. (G1, G7)
- **AC-2 — Machine-readable bank authored.** `lens-bank.yml` exists with all 18
  lens ids and tiers and `method_profiles` for all six methods (Balanced +
  five companions), matching the source R/O/— table. The doc's human profile
  table matches the YAML. (G2, G5)
- **AC-3 — Fail-closed validator with negative controls.**
  `validate-architectural-review-lens-references.sh` exists, passes on the
  shipped bank, and fails (non-zero exit) on both negative-control fixtures:
  an undefined lens id in a method reference, and a bank-known method missing a
  profile. (G3)
- **AC-4 — Balanced expressed as lens ids without doctrine change.** The lens
  bank doc records the Balanced sequence→lens-id mapping; the resulting Balanced
  required set equals its existing required sequence (the 10 `R` lens ids); and
  `balanced-architecture-review-method.md` is unedited. (G4)
- **AC-5 — Sprawl controls authored.** The four sprawl-control rules
  (new-lens admission, no private catalogs, validator fail-closed, retirement
  discipline) are authored in the lens bank doc. (G6)
- **AC-6 — Additive-only, no authority granted.** No new mechanism, gate, routed
  workflow mode, evidence root, or command facade is created; `naming.yml`,
  `review-routing.yml`, the contract schemas, and the review workflows are
  untouched; and the lens bank grants no review output any authority.
- **AC-7 — Evidence retained.** Validator runs (positive + both negative
  controls), the doc/registry consistency check, and the Balanced-unchanged
  proof are retained under the child's promotion evidence root.

## Closure Condition

This child reaches `closed` only when AC-1 through AC-7 hold, all validators
pass (with the two negative controls demonstrably failing closed), and the
verification receipt is retained. Allowed alternative terminal states are
`superseded` or `rejected` with recorded rationale (child-packet-contract
obligation 8). No unresolved acceptance criterion may remain at closeout.
