# Evidence Store v1

This contract defines the canonical retained evidence store required for
consequential run closeout, replayability, support proofing, and release
disclosure.

Retained evidence and publishable evidence are related but not identical.
`/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml`
defines the disclosure tiers used to distinguish private raw evidence,
repo-publishable evidence, operator/release disclosure, and generated read
models while preserving the canonical roots below.

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

Canonical retention does not by itself make an artifact safe to publish or
eligible for release disclosure. Raw transcripts, model I/O, traces, browser
artifacts, local operator captures, and similar private raw evidence may remain
necessary for replay or auditability while being represented in repo-publishable
evidence only through redacted summaries, digests, stable locators, or retained
pointers. A raw-copy move from private local evidence into publishable evidence
is forbidden unless a stricter contract explicitly classifies the artifact as
publishable.

## Local Run Residue

### External localization of inactive operational evidence

When protected terminal or explicitly inactive operational evidence must leave
the checkout, use the governed external localization policy and helper. The
platform application-data archive is outside the repository and `.git`.
Localization is copy-before-remove, digest-bound, idempotent, independently
verified, and separate from cleanup authorization. Active, referenced,
manual-review-undisposed, stale, unverifiable, or rollback-incomplete groups
remain in place. External archives are retained evidence only and never become
control-plane or authored authority.

Publication, validation, service-build, closeout, and agent-quorum runs may
leave untracked local files under `/.octon/state/**` after the claim-bearing
receipts, generated locks, or active state have already been retained. Those
files are not automatically durable evidence merely because they are under a
canonical evidence root.

Agents must classify local residue before retention or cleanup:

- retained evidence: tracked evidence, or untracked evidence referenced by
  tracked locks, active control state, closeout receipts, or governance
  receipts;
- active control state: tracked control or continuity state, or untracked
  control state referenced by tracked state or receipts;
- generated scratch output: rebuildable `/.octon/generated/.tmp/**` material;
- stale unreferenced publication attempt: an untracked superseded publication
  receipt that no tracked file references;
- local run residue: untracked `publish-*`, `service-build-*`, or
  `runtime-agent-quorum-*` artifacts that no tracked file references; and
- manual-review artifact: any untracked `/.octon/state/**` file outside known
  local-residue patterns, including build-to-delete or other claim-adjacent
  evidence roots.

The classifier for this local hygiene pass is
`/.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`.
It is dry-run by default and may remove only untracked, unreferenced cleanup
candidates after explicit confirmation. Referenced or manual-review artifacts
must be retained, promoted, or escalated; they must not be deleted as local
residue and must not satisfy closeout evidence unless a durable retained
evidence reference points to them.

Dry-run and authorization summaries must expose cleanup candidates separately
from retained evidence, control state, and continuity state. At minimum, the
summary reports local-run, generated-scratch, stale-publication, and local
metadata cleanup counts, plus protected and manual-review counts for retained
evidence, control state, and continuity state. These counts are routing and
inspection evidence only; they do not authorize deletion, replace retained
receipts, or mutate control truth.

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

When a RunCard, closeout receipt, support proof, or release disclosure depends
on evidence that is not itself publishable, the retained bundle must include a
repo-publishable representation with a digest, locator, or pointer back to the
private raw evidence. Generated read models may help operators inspect the run,
but they do not satisfy run evidence, disclosure, or closeout completeness by
themselves.

## Compact Evidence Views

Run evidence bundles may include compact evidence views to reduce repeated
model-visible raw-log context:

- `evidence-index.yml`
- `retained-run-evidence-index.yml`
- `raw-log-summary.yml`
- `failing-slice-manifest.yml`

These artifacts are retained evidence aids, not authority, policy, support
proof, closure proof, or replacements for raw/full evidence. They must carry
source refs, source digests, byte sizes, estimated token counts, reader
preferences, freshness state, replay/reconstruction data, and explicit failure
behavior. Readers should prefer these compact refs by default and dereference
raw/full evidence bodies only for summary hash mismatches, failing-slice
reconstruction failures, validator disputes, replay audit requests, or an
equivalent escalation receipt.

`raw-log-summary.yml` records deterministic source-level summaries for retained
stdout, stderr, recovery, and status logs. `failing-slice-manifest.yml` records
line ranges that can be reconstructed from the retained source ref after
verifying the source digest. A stale, missing, or digest-mismatched compact view
fails closed; it must not be used to repair, overwrite, delete, or replace the
raw retained evidence.

`retained-run-evidence-index.yml` records discovery-only refs to implemented or
archived-implemented proposal packet evidence, materialization validation,
rollback posture, and source digests. It must include retrieval metrics for
indexed refs, terminal evidence refs, control refs, substitute workflow refs,
retained evidence refs, proposal-local refs, and generated refs. Metrics are
evidence-only inspection aids and must fail closed when they disagree with the
indexed refs.

## Structured Closeout And Publication Views

Closeout and publication routes may retain compact structured views beside the
canonical receipts and raw evidence they summarize:

- `closeout-projection.yml`
- `publication-summary.yml`
- `structured-receipt.yml`
- `expanded-report-request.yml`

These artifacts are compact retained evidence aids or generated/read-model
inputs only. They are never authority, policy, support proof, closure proof, or
replacements for the canonical Change receipt, wrapper report, publication
receipt, run journal snapshot, raw log, or rollback evidence.

Each structured view must include:

- `schema_version`
- `artifact_kind`
- `authority_status`
- `producer`
- `consumer`
- `reader_preference`
- `model_visible_token_estimate`
- `source_refs`
- `source_digests`
- `evidence_refs`
- `validation`
- `freshness`
- `failure_behavior`
- `authority_boundary`

Closeout projections must stay compact enough for default model-visible
closeout context and declare `model_visible_token_estimate <= 4000`.
Expanded reports are generated only on demand from
`expanded-report-request.yml` after source refs and digests validate. A route
must dereference full/raw evidence only for missing evidence refs, digest
mismatch, stale freshness, authorization ambiguity, rollback gaps,
support-proof conflicts, replay audit, or equivalent escalation evidence.

The failure behavior for every structured view is fail-closed for missing
source refs, digest mismatch, stale freshness, and authority-boundary conflict.
Structured views must explicitly record that proposal inputs and generated
outputs are non-authoritative, raw evidence is not replaced, and engine-owned
authorization is not bypassed.

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
enough evidence to explain why a Change Package is ready, staged, blocked,
denied, or waiting on a Decision Request:

- adoption preflight and classification evidence under
  `/.octon/state/evidence/engagements/<engagement-id>/{preflight/**,adoption-preflight/**,classification/**}`
- per-engagement Objective Brief evidence under
  `/.octon/state/evidence/engagements/<engagement-id>/objective/**`
- orientation evidence under `/.octon/state/evidence/orientation/<orientation-id>/**`
- Project Profile source facts under
  `/.octon/state/evidence/project-profiles/<profile-id>/source-facts/**`
- Change Package compilation evidence under
  `/.octon/state/evidence/engagements/<engagement-id>/change-packages/<change-package-id>/**`
- Decision Request evidence under
  `/.octon/state/evidence/decisions/<decision-id>/**`
- run-contract readiness evidence under
  `/.octon/state/evidence/engagements/<engagement-id>/run-contract-readiness/**`

Generated engagement or Change Package read models may summarize those roots, but
they never satisfy evidence requirements by themselves.

## Minimum Mission Planning Evidence Bundle

Mission planning evidence is preparation evidence, not run execution evidence.
The Mission Plan Compiler retains enough evidence to prove why a plan revision,
readiness result, compile result, drift finding, or planning closeout is valid:

- plan revision evidence under
  `/.octon/state/evidence/control/execution/planning/<plan-id>/revisions/**`
- compile receipts under
  `/.octon/state/evidence/control/execution/planning/<plan-id>/compile/**`
- drift records under
  `/.octon/state/evidence/control/execution/planning/<plan-id>/drift/**`
- readiness, duplicate, dependency, policy, and authority-boundary checks under
  `/.octon/state/evidence/control/execution/planning/<plan-id>/checks/**`
- planning closeout evidence under
  `/.octon/state/evidence/control/execution/planning/<plan-id>/closeout.yml`

Planning evidence may link to run evidence, but it never substitutes for
`/.octon/state/evidence/runs/<run-id>/**`, run disclosure, Run Journal
snapshots, authorization receipts, effect-token receipts, or rollback evidence.
Generated planning views may summarize these roots only as derived operator read
models.

## Completeness Rules

Run or release closeout is valid only when:

- all required retained artifacts are present in canonical roots
- claim-bearing artifacts that support publication, closeout, support proof,
  release disclosure, or archive readiness carry the applicable evidence
  disclosure tier classification
- the retained journal snapshot matches the live control journal at closeout
- disclosure artifacts are generated from retained evidence, not from transport
  artifacts or chat/operator summaries
- generated read models are cited only as derived operator context and never as
  authority, policy, support proof, or evidence completeness inputs
- external immutable payloads are reachable through a retained content-addressed
  index entry
- missing required evidence blocks closure, promotion, or live claim activation

## Related Contracts

- `/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml`
- `/.octon/framework/constitution/contracts/retention/evidence-store-v1.schema.json`
- `/.octon/framework/constitution/contracts/retention/run-evidence-classification-v2.schema.json`
- `/.octon/framework/constitution/contracts/disclosure/run-card-v2.schema.json`
- `/.octon/framework/constitution/contracts/disclosure/harness-card-v2.schema.json`
- `/.octon/framework/constitution/contracts/disclosure/support-universe-coverage-v2.schema.json`
- `/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `/.octon/framework/engine/runtime/spec/promotion-activation-v1.md`
