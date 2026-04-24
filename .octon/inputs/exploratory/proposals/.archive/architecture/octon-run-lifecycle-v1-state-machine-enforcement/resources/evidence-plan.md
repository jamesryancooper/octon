# Evidence Plan

## Retained implementation evidence

| Evidence | Location |
|---|---|
| lifecycle transition schema | `framework/engine/runtime/spec/run-lifecycle-transition-v1.schema.json` |
| lifecycle reconstruction schema | `framework/engine/runtime/spec/run-lifecycle-reconstruction-v1.schema.json` |
| lifecycle validator | `framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh` |
| lifecycle test harness | `framework/assurance/runtime/_ops/tests/test-run-lifecycle-v1.sh` |
| fixture run roots | `framework/assurance/runtime/_ops/fixtures/run-lifecycle-v1/**` |
| retained validator output | `state/evidence/validation/assurance/run-lifecycle-v1/**` |

## Per-Run evidence after promotion

Each consequential Run should retain or reference:

- `run-contract.yml`
- `run-manifest.yml`
- `events.ndjson`
- `events.manifest.yml`
- `runtime-state.yml`
- `rollback-posture.yml`
- context-pack evidence
- authority decision and grant bundle
- effect-token records and consumption receipts
- checkpoints and stage attempts
- observability/intervention records
- assurance reports
- journal closeout snapshot
- RunCard/disclosure
- evidence-store completeness record
- review and risk disposition record

## Evidence non-substitution rule

Transport artifacts, stdout, CI uploads, generated summaries, and proposal files do not satisfy closeout unless reindexed into canonical retained evidence roots.
