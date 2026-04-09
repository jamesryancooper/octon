# Acceptance and Closure Criteria

## Per-Blocker Acceptance Tests
| Blocker | Acceptance tests | Required validators | Required evidence | Stop condition |
|---|---|---|---|---|
| A | For every admitted tuple, declaration, admission, dossier refs, effective matrix, run contracts, and run cards agree on route, mission requirement, packs, and claim effect. | `validate-support-target-canonicality.sh`, strengthened `validate-cross-artifact-support-tuple-consistency.sh`, `validate-run-contract-support-binding.sh` | support-target canonicality report, regenerated effective matrix, support-universe coverage bundle | zero tuple mismatches |
| B | No active authority or retained evidence artifact references deleted compatibility aggregates; only canonical per-artifact family refs remain. | `validate-canonical-authority-purity.sh`, strengthened authority-linkage validator | authority-purity report, deleted-or-rehomed aggregate receipts | zero compatibility refs |
| C | No active claim-bearing runtime/disclosure artifact contains banned stale envelope wording; HarnessCard known-limits truthfully reflect remaining blockers until zero. | strengthened wording validator, `validate-claim-calibrated-disclosure.sh`, `validate-known-limits-coherence.sh` | disclosure wording report, regenerated RunCards/HarnessCard, blocker ledger | zero stale wording violations |
| D | Every active claim-bearing stage-attempt validates as `stage-attempt-v2`; no mixed-family run remains inside the active claim set. | strengthened stage-attempt-family validator, `validate-stage-attempt-disclosure-separation.sh` | stage-attempt canonicality report, migration receipts or retirement receipts | zero active non-v2 stage attempts |
| E | Seeded blocker-class fixtures fail the expected validators; live cutover branch passes all validators twice; blocker ledger is zero. | `run-closure-negative-controls.sh`, `validate-blocker-ledger-zero.sh`, all closure workflows | sufficiency report, pass-1 report, pass-2 parity report | zero open blocker ledger |

## Mandatory Acceptance Gates for an Unqualified Complete Verdict
1. **Support-target coherence** is exact.
2. **Canonical authority purity** is exact.
3. **Claim-calibrated disclosure** is exact.
4. **Stage-attempt family normalization** is proven for the active run set.
5. **Projection parity** is proven.
6. **Closure-validator sufficiency** is demonstrated on seeded negative controls.
7. **Two consecutive clean passes** are recorded.
8. **Zero unresolved blocker ledger** is recorded.
9. **Truthful active release claim** is published only after items 1–8 are true.

## Global Stop Condition
Octon may honestly claim an unqualified complete verdict only when all nine mandatory gates above are true at once.

If any one fails, Octon cannot honestly claim unqualified completion.
