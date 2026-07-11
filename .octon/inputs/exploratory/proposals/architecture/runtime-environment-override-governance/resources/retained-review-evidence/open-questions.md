# Open Questions

Review id: `20260709-super-root-balanced-review`. These are unresolved questions recorded for the operator and follow-up routes; none block retention of this review.

1. **F-01 disposition (human governance decision):** should the OCTON_* authority-affecting environment overrides become a contracted break-glass affordance (with retained receipts and protected-mode prohibition), or be removed in favor of explicit receipted flags confined to the publication path? Ownership: human governance (`roles.yml:7-13`).
2. **Immutable store operations (F-03):** what is the authoritative operational contract for the `immutable://` evidence store — location, backup, verification cadence, disaster recovery? Boundary-sensitive replay depends on it.
3. **Retention durations (F-06):** are per-class retention durations intended to be enforced mechanically, or is policy-documented retention the deliberate posture? If deliberate, state it explicitly in the retention contract.
4. **Historical RunCards (F-08):** after future support-target refactors, are historical RunCards frozen-as-of-issuance (needing only a declaration) or should a retroactive reference audit exist?
5. **Federation enforcement depth [U]:** trust v6 machinery is largely stage-only; its enforcement depth is untested by any live federation compact. What evidence will the first live compact be required to produce before acceptance?
6. **Reversibility classification audit [U]:** proceed-on-silence safety rests on correct reversibility classification of action classes (`mission-autonomy.yml:91-102`). What periodically re-verifies those classifications against actual rollback outcomes?
7. **Quorum posture (F-10):** at what point (contributor count, external adoption) does the default quorum of 1 get revisited?
