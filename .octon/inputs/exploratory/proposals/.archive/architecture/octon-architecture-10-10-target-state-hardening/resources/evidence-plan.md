# Evidence Plan

## Retained evidence roots

Use existing canonical evidence roots. Do not create proposal-local evidence
surfaces as closure authorities.

| Evidence class | Target root |
| --- | --- |
| Run evidence | `.octon/state/evidence/runs/**` |
| Disclosure evidence | `.octon/state/evidence/disclosure/**` |
| Validation evidence | `.octon/state/evidence/validation/**` |
| Publication receipts | `.octon/state/evidence/validation/publication/**` |
| Control mutation evidence | `.octon/state/evidence/control/execution/**` |
| Lab/proof evidence | `.octon/state/evidence/lab/**` |
| External evidence index | `.octon/state/evidence/external-index/**` |

## Required evidence for implementation closure

1. Architecture health report.
2. Authorization coverage report.
3. Material side-effect negative-control report.
4. Support partition migration receipt.
5. Support-pack-admission invariant report.
6. Publication freshness report.
7. Pack/extension publication report.
8. Run lifecycle transition report.
9. Operator boot validation report.
10. Compatibility retirement report.
11. Support tuple proof bundles.
12. Representative RunCard, HarnessCard, SupportCard.
13. Replay and recovery bundles.
14. Promotion receipt.

## Evidence quality requirements

- Every artifact must cite canonical source/control/evidence paths.
- Generated summaries may cite evidence but cannot substitute for it.
- CI artifacts must be retained or indexed if used for closure.
- Evidence must distinguish live support from stage-only and unadmitted claims.
- Evidence must preserve denial/stage-only reason codes.
