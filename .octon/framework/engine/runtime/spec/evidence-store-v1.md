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
- engagement preparation evidence:
  `/.octon/state/evidence/engagements/<engagement-id>/**`
- orientation evidence: `/.octon/state/evidence/orientation/<orientation-id>/**`
- Project Profile source-fact evidence:
  `/.octon/state/evidence/project-profiles/<profile-id>/source-facts/**`
- Decision Request evidence: `/.octon/state/evidence/decisions/<decision-id>/**`
- immutable external index: `/.octon/state/evidence/external-index/**`
- lab evidence: `/.octon/state/evidence/lab/**`

Mutable control state under `/.octon/state/control/**` remains authoritative for
live control truth, but it is not sufficient closeout evidence by itself.

## Control And Evidence Boundary

Run lifecycle state is controlled by `/.octon/state/control/**` journal and
manifest files. Retained evidence under `/.octon/state/evidence/**` proves,
replays, and discloses the run, but it does not become the live lifecycle
control plane.

Transition and reconstruction records may cite both control refs and retained
evidence refs. Those refs must remain role-separated:

- control refs establish the current journal head, lifecycle state, authority
  route, rollback posture, and materialized `runtime-state.yml`;
- retained evidence refs establish replay inputs, immutable snapshots,
  disclosure inputs, and closeout completeness; and
- generated/operator refs may summarize evidence but never satisfy control or
  evidence requirements by themselves.

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
- effect-token evidence: canonical token records plus mint, consume, reject,
  expiry, or revocation receipts for material effects
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

The mirror may satisfy retained evidence and disclosure requirements only after
the hash match is recorded. It must not be used to repair or overwrite the live
control journal.

## Minimum Support And Release Bundle

System-level support or closure claims must additionally retain:

- authored `harness-card-v2`
- active release disclosure under
  `/.octon/state/evidence/disclosure/releases/<release-id>/**`
- support-universe coverage and proof-plane coverage for the active release
- release-lineage selection of the active release
- support-target proof bundles or equivalent per-tuple proof refs

## Minimum Engagement Preparation Bundle

Engagement preparation is not run execution evidence. The compiler must retain
enough evidence to explain why a Work Package is ready, staged, blocked,
denied, or waiting on a Decision Request:

- adoption preflight and classification evidence under
  `/.octon/state/evidence/engagements/<engagement-id>/{preflight/**,adoption-preflight/**,classification/**}`
- per-engagement Objective Brief evidence under
  `/.octon/state/evidence/engagements/<engagement-id>/objective/**`
- orientation evidence under `/.octon/state/evidence/orientation/<orientation-id>/**`
- Project Profile source facts under
  `/.octon/state/evidence/project-profiles/<profile-id>/source-facts/**`
- Work Package compilation evidence under
  `/.octon/state/evidence/engagements/<engagement-id>/work-packages/<work-package-id>/**`
- Decision Request evidence under
  `/.octon/state/evidence/decisions/<decision-id>/**`
- run-contract readiness evidence under
  `/.octon/state/evidence/engagements/<engagement-id>/run-contract-readiness/**`

Generated engagement or Work Package read models may summarize those roots, but
they never satisfy evidence requirements by themselves.

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
