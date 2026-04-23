# Evidence Store v1

This contract defines the canonical retained evidence store required for
consequential run closeout, replayability, support proofing, and release
disclosure.

## Canonical Roots

Retained evidence lives under these roots:

- run evidence: `/.octon/state/evidence/runs/<run-id>/**`
- control evidence: `/.octon/state/evidence/control/execution/**`
- run disclosure: `/.octon/state/evidence/disclosure/runs/<run-id>/**`
- release disclosure: `/.octon/state/evidence/disclosure/releases/<release-id>/**`
- immutable external index: `/.octon/state/evidence/external-index/**`
- lab evidence: `/.octon/state/evidence/lab/**`

Mutable control state under `/.octon/state/control/**` remains authoritative for
live control truth, but it is not sufficient closeout evidence by itself.

## Retained Versus Transport Artifacts

CI uploads, caches, local previews, stdout captures, and other transport
artifacts are not canonical evidence unless they are reindexed into the
retained roots above. A transport artifact may support debugging, but it does
not satisfy disclosure, replay, or closure requirements on its own.

## Minimum Consequential Run Bundle

Each consequential run must retain enough material to regenerate its RunCard
from retained evidence only:

- run journal control truth: `events.ndjson` and `events.manifest.yml`
- bound lifecycle control: `run-contract.yml`, `run-manifest.yml`,
  `runtime-state.yml`, `rollback-posture.yml`, checkpoints, and stage attempts
- authority evidence: decision artifact, grant bundle, and any approval,
  exception, or revocation refs used by the run
- replay and trace evidence: replay manifest, replay pointers, trace pointers,
  and external index entries when payloads are externalized
- assurance evidence: required proof-plane reports for the admitted workload
  class
- observability evidence: measurement summary and intervention log
- disclosure evidence: canonical `run-card-v2`
- classification evidence: canonical run evidence classification

The claim-bearing run disclosure root is
`/.octon/state/evidence/disclosure/runs/<run-id>/run-card.yml`. Run-local
mirrors under `/.octon/state/evidence/runs/<run-id>/disclosure/**` may remain
for lineage or convenience only.

## Run Journal Snapshot Rule

Closeout must retain an evidence mirror of the canonical control journal:

- `/.octon/state/evidence/runs/<run-id>/run-journal/events.snapshot.ndjson`
- `/.octon/state/evidence/runs/<run-id>/run-journal/events.manifest.snapshot.yml`
- `/.octon/state/evidence/runs/<run-id>/run-journal/redactions.yml`

The evidence mirror is not the live control source, but it must hash-match the
control journal at closeout and remain explicitly linked from the canonical
journal manifest.

## Minimum Support And Release Bundle

System-level support or closure claims must additionally retain:

- authored `harness-card-v2`
- active release disclosure under
  `/.octon/state/evidence/disclosure/releases/<release-id>/**`
- support-universe coverage and proof-plane coverage for the active release
- release-lineage selection of the active release
- support-target proof bundles or equivalent per-tuple proof refs

## Completeness Rules

Run or release closeout is valid only when:

- all required retained artifacts are present in canonical roots
- the retained journal snapshot matches the live control journal at closeout
- disclosure artifacts are generated from retained evidence, not from transport
  artifacts or chat/operator summaries
- external immutable payloads are reachable through a retained content-addressed
  index entry
- missing required evidence blocks closure, promotion, or live claim activation

## Related Contracts

- `/.octon/framework/constitution/contracts/retention/evidence-store-v1.schema.json`
- `/.octon/framework/constitution/contracts/retention/run-evidence-classification-v2.schema.json`
- `/.octon/framework/constitution/contracts/disclosure/run-card-v2.schema.json`
- `/.octon/framework/constitution/contracts/disclosure/harness-card-v2.schema.json`
- `/.octon/framework/constitution/contracts/disclosure/support-universe-coverage-v2.schema.json`
- `/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `/.octon/framework/engine/runtime/spec/promotion-activation-v1.md`
