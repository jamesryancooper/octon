# Evidence Plan

## Evidence classes

| Evidence class | Purpose | Retained root |
|---|---|---|
| Promotion evidence | Proves proposal landed in durable targets. | `state/evidence/validation/publication/**` |
| Runtime evidence | Proves grants, receipts, checkpoints, replay. | `state/evidence/runs/**` |
| Control evidence | Proves approvals, exceptions, revocations, interventions. | `state/evidence/control/execution/**` |
| Lab evidence | Proves scenario, shadow, replay, benchmark behavior. | `state/evidence/lab/**` |
| Support dossier | Proves support tuple admission. | `instance/governance/support-dossiers/**` |
| Disclosure bundle | Proves RunCard/HarnessCard claims. | `state/evidence/disclosure/**` |

## Required evidence before implementation closure

- proposal validation output
- hard-cutover validator output
- schema validation output
- support-target tuple validation output
- workflow reduction audit
- runtime conformance proof
- rollback/recovery drill evidence
- browser/API denial-or-proof evidence
- raw frontier-model baseline benchmark evidence
- generated RunCard/HarnessCard from evidence only

## Evidence exclusions

The following do not count:

- proposal prose;
- generated summaries alone;
- screenshots without replay metadata;
- chat transcripts;
- labels, comments, checks, or UI state without canonical control artifact;
- human assertions without retained evidence.
