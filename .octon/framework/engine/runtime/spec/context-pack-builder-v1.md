# Context Pack Builder v1

## Purpose

Context Pack Builder v1 is the Governed Agent Runtime assembly and proof
mechanism for Working Context. It deterministically produces retained context
evidence before `authorize_execution(...)` decides whether a consequential or
boundary-sensitive Run may proceed.

The builder is not a Control Plane, approval authority, memory subsystem, or
policy interpreter. It is subordinate to `authorize_execution(...)` and can only
produce evidence that authorization validates.

Change Package compilation may prepare a context-pack request before material
authorization. That request is preparation control state under
`/.octon/state/control/engagements/<engagement-id>/context/context-pack-request.yml`.
It is not a context-pack receipt and cannot satisfy authorization until the
Context Pack Builder emits retained run context evidence and a valid
`context-pack-receipt-v1`.

Mission plan compilation may prepare context-pack requests for ready PlanNode
leaves; planning refs may enter a context pack only with source-class
preservation: mission authority remains authority, planning control remains
control, planning evidence remains evidence, generated planning views remain
derived, and proposal-local or raw-input planning material remains
non-authoritative. A planning context-pack request is not a receipt and cannot
satisfy authorization until the builder emits retained run context evidence.

Lifecycle route execution also builds context-pack evidence before dispatch
authorization. The lifecycle executor emits a route-scoped context pack under
`/.octon/state/evidence/runs/<run-id>/context/` and mutable pointers under
`/.octon/state/control/execution/runs/<run-id>/context/` before writing the
delegation proof for the selected lifecycle route. This pack is authorization
evidence only: it can bind prompt bundle handles, generated route handles,
bootstrap ingress digests, observed receipt digests, and proposal-local target
digests, but it cannot make proposal-local, generated, raw, skill, host, or
chat context authoritative.

## Required Boundary

For any consequential or boundary-sensitive Run, authorization must fail closed
unless a valid context evidence chain is present or the runtime can build a new
pack before authorization. If a caller supplies an existing binding, the runtime
must validate the supplied pack and receipt as-is. It must not silently rebuild
over an invalid supplied binding.

Fail closed when any required item is missing, stale, invalidated,
unverifiable, mismatched to the request, mismatched to the policy, or unable to
reconstruct the retained model-visible hash.

## Policy Loading

The builder loads:

`/.octon/instance/governance/policies/context-packing.yml`

The active policy ref is recorded in the pack, receipt, model-visible
serialization, request/grant/receipt bindings, and instruction-layer manifest.
If the policy is absent or unparsable, the builder fails closed. Proposal-local
exploratory artifacts must not become runtime dependencies after promotion.

## Candidate Discovery

Candidate sources are collected from durable runtime authority and evidence
surfaces relevant to the Run:

1. constitutional and framework authority under `/.octon/framework/**`
2. instance governance and workspace authority under `/.octon/instance/**`
3. mutable control truth under `/.octon/state/control/**`
4. retained proof under `/.octon/state/evidence/**`
5. permitted continuity input under `/.octon/state/continuity/**`
6. capability schemas and runtime-effective handles when policy permits
7. raw inputs only as explicitly non-authoritative input
8. generated surfaces only as derived handles or derived evidence

Generated read models, raw additive inputs, labels, comments, chat transcript
text, host UI state, and proposal-local files are never authority sources.

## Classification

Every source entry records:

- `path`
- `sha256`
- `surface_class`
- `source_class`
- `authority_label`
- `trust_class`
- `source_role`
- `inclusion_mode`
- `bytes_included`
- `estimated_tokens`
- `model_visible`
- `included_range`, `summary_ref`, or `handle_ref` when applicable
- `policy_ref` or `policy_reason`

The durable pack keeps source classes distinct:

- `authority_sources`
- `control_sources`
- `evidence_sources`
- `continuity_sources`
- `generated_runtime_effective_handles`
- `capability_schema_sources`
- `derived_sources`
- `non_authoritative_inputs`

`framework/**` and `instance/**` authored authority may be eligible as authority
sources. `generated/**` is derived-only. `inputs/**` is non-authoritative unless
explicitly admitted as untrusted input.

## Deterministic Ordering

The builder normalizes each path or stable URI, de-duplicates exact duplicate
source refs, and sorts candidates by:

1. source bucket order listed above
2. normalized repo-relative path or stable URI, lexicographically
3. SHA-256 digest as a final tie-breaker

Duplicate or shadowed sources are omitted with
`duplicate_or_shadowed`. Unsupported or denied classes are omitted with the
policy reason that caused exclusion.

## Inclusion Modes

Allowed inclusion modes are:

- `full`
- `excerpt`
- `summary`
- `handle-only`
- `digest-only`
- `omitted`
- `redacted`

`full` means the exact model-visible bytes are retained in
`model-visible-context.json`. `excerpt` records `included_range`. `summary`
records `summary_ref`. `handle-only` records `handle_ref`. `digest-only` records
only the digest and classification metadata. If source body bytes are not
embedded in the retained model-visible serialization, the source must not be
marked `full` and `bytes_included` must be `0`.

Lifecycle route context uses the policy's stage-specific defaults:

- lifecycle authority, bootstrap ingress, and durable route contracts:
  `digest-only`
- skill and prompt source material: `digest-only` unless an explicit full
  expansion policy trigger is present
- generated route bundles, generated extension catalogs, and generated prompt
  projections: `handle-only`
- retained evidence, control pointers, and raw logs: `handle-only`
- proposal-local target files and proposal-local receipts:
  `digest-only` with `non_authoritative` authority label

When a lifecycle proposal-program route needs repo authority, promotion-target,
or child write-scope orientation, it should prefer the validated derived bundle
under `/.octon/generated/proposals/repo-authority/` before reading the full
structural topology registry, active proposal manifests, or proposal-program
child registry. The bundle artifacts are `repo-authority-graph.yml`,
`promotion-target-index.yml`, and `write-scope-index.yml`; they remain
generated read models and must validate with
`validate-repo-authority-write-scope-index.sh` before use. Missing, stale,
digest-mismatched, or authority-conflicting bundle state fails closed and must
not be repaired from generated output.

Any lifecycle context source that cannot be classified into one of those modes
is omitted with an omission reason or blocks authorization when required.

## Omission Taxonomy

Every omitted or excluded candidate records one of:

- `over_budget`
- `stale`
- `non_authoritative_disallowed`
- `unsupported_surface_class`
- `trust_rejected`
- `duplicate_or_shadowed`
- `unresolved_handle`
- `explicit_policy_exclusion`
- `redacted_secret_or_sensitive`
- `support_target_disallowed`

Omissions are retained in `omissions.json` and linked from the pack and receipt.

## Redaction

Redaction is a deterministic transformation. The redaction record must include
the source ref, redaction reason, redacted range or field path, replacement
marker, policy ref, and digest of the retained redacted representation.
Redactions are retained in `redactions.json`. A redacted source is never treated
as if its original body bytes were model-visible.

## Budgets

Budgets are applied after classification and deterministic ordering. Required
authority and evidence sources are admitted before optional context. Optional
sources that do not fit are omitted with `over_budget`. Budget decisions must be
stable for identical inputs and policy.

## Freshness And Invalidation

The builder records generated time, freshness mode, and valid-until state in
the pack and receipt. Freshness may be receipt-bound or TTL-bound according to
the policy. Required source freshness failures are authorization blockers.

Invalidation triggers include source digest drift, policy digest drift, request
binding mismatch, expired freshness, missing retained evidence, trust downgrade,
and explicit operator or governance invalidation. Invalidation events are
retained in `invalidation-events.json` and journaled as
`context-pack-invalidated` when they occur.

## Rebuild And Compaction

A rebuild is a new pack and receipt for the same Run or request lineage. The
new receipt records rebuild refs and the prior pack remains retained evidence.
Compaction is legal only when the compacted model-visible serialization is
retained, hashed, and referenced. Both actions are journaled through the Run
Journal as canonical `context-pack-rebuilt` or `context-pack-compacted` events.

## Semantic Cache And Layer Reuse

Lifecycle route context may use digest-bound semantic cache and context layer
artifacts to avoid repeated model-visible full text. These artifacts are
retained evidence or generated/read-model projections only; they never replace
raw evidence, context-pack receipts, run contracts, execution authorization,
proposal review receipts, or durable authority sources.

The reusable artifact family is governed by
`semantic-cache-context-reuse-v1.schema.json`, emitted by
`generate-semantic-cache-context-reuse.sh`, and validated by
`validate-semantic-cache-context-reuse.sh`:

- `proposal-semantic-cache.yml` records source summaries keyed by source
  digest, policy digest, route purpose, trust class, and request binding.
- `context-pack-layer-cache.yml` records reusable context-pack layers for
  stable governance, prompt capsules, generated freshness handles, and
  parent-to-child handoff capsules.
- `cache-invalidation-events.yml` records invalidation triggers and
  fail-closed decisions.

Readers may prefer a compact artifact only when all of the following hold:

- source refs are reachable or explicitly handle-only, and recorded SHA-256
  digests still match reachable sources;
- policy ref and policy digest still match the active context-packing policy;
- route purpose, trust class, and request binding match the current request;
- freshness state is `fresh`, no active invalidation event is present, and
  retained evidence refs remain reachable by the owning evidence contract;
- generated and raw/proposal-local sources keep derived or non-authoritative
  labels and are not treated as policy, support, runtime, or closure authority;
- the retained model-visible hash and token estimate for a cache hit are
  present, and cache-hit overhead is at or below 2000 estimated tokens.

Fail closed on source digest drift, policy digest drift, request binding
mismatch, expired freshness, missing retained evidence, trust downgrade,
explicit governance invalidation, model-visible hash absence, replay ref
absence, or any authority-boundary violation.

## Canonical Model-Visible Serialization

The v1 model-visible payload is retained at:

`/.octon/state/evidence/runs/<run-id>/context/model-visible-context.json`

Its hash is retained at:

`/.octon/state/evidence/runs/<run-id>/context/model-visible-context.sha256`

The canonical serialization is a stable JSON document with:

- `schema_version: model-visible-context-v1`
- `serialization_format: context-pack-builder-v1/model-visible-context-json`
- `run_id`
- `context_pack_id`
- `context_policy_ref`
- `builder_version`
- sorted source records
- sorted source manifest lines
- omission and redaction manifests
- freshness facts
- replay pointers

The `model_visible_context_sha256` value is the SHA-256 digest of the exact
retained bytes of `model-visible-context.json`, prefixed with `sha256:`. It is
not reconstructed from source-manifest lines alone.

## Retained Evidence

The runtime retains, at minimum:

- `context-pack.json`
- `context-pack-receipt.json`
- `model-visible-context.json`
- `model-visible-context.sha256`
- `source-manifest.json`
- `omissions.json`
- `redactions.json`
- `invalidation-events.json`

Mutable control truth points at the active pack under:

- `/.octon/state/control/execution/runs/<run-id>/context/active-context-pack.yml`
- `/.octon/state/control/execution/runs/<run-id>/context/status.yml`

Control truth is not a substitute for retained evidence.

## Receipt Binding

`context-pack-receipt-v1` binds:

- receipt id
- pack id and pack ref
- run id and request id
- builder spec and version
- context policy ref
- source manifest, omission, redaction, and invalidation refs
- pack hash
- model-visible context ref and hash
- freshness and validity state
- invalidation state
- rebuild and compaction refs
- replay reconstruction refs
- authorization binding refs

Execution request, grant, execution receipt, and
`instruction-layer-manifest-v2` must preserve the context refs and hash. A grant
may narrow authority, but it must not substitute a different context pack to
widen authority.

## Authorization Validation

Before authorization allows a consequential or boundary-sensitive Run, the
runtime validates:

- pack, receipt, source manifest, model-visible serialization, and hash file
  exist
- pack and receipt digests match their bindings
- run id, request id, support tuple, target, action, workflow, builder spec,
  builder version, and policy refs agree
- model-visible hash matches the exact retained JSON bytes and retained hash
  file
- source counts and required-source statuses agree
- source digests have not drifted where source files remain resolvable
- validity, freshness, and invalidation states are valid
- generated and raw surfaces are not authority sources
- replay reconstruction refs can reproduce the same model-visible hash

Failures deny authorization for material execution.

## Run Journal

The canonical append-only Run Journal is written only through `runtime_bus`.
Canonical context lifecycle event types are hyphenated:

- `context-pack-requested`
- `context-pack-built`
- `context-pack-bound`
- `context-pack-rejected`
- `context-pack-compacted`
- `context-pack-invalidated`
- `context-pack-rebuilt`

`runtime-event-v1` dot names such as `run.context_pack_built` are compatibility
aliases only. Canonical journal writers must not emit dot-named context-pack
events.

## Replay

Replay reconstructs the exact model-visible hash from retained
`model-visible-context.json` and verifies it against
`model-visible-context.sha256`, the pack, and the receipt. Replay may use source
manifest and source digests to detect drift, but those records are not the
model-visible serialization.

## Related Contracts

- `/.octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json`
- `/.octon/framework/constitution/contracts/runtime/run-event-v2.schema.json`
- `context-pack-receipt-v1.schema.json`
- `execution-request-v3.schema.json`
- `execution-grant-v1.schema.json`
- `execution-receipt-v3.schema.json`
- `runtime-event-v1.schema.json`
- `execution-authorization-v1.md`
- `authorization-boundary-coverage-v1.md`
- `policy-receipt-v2.schema.json`
- `semantic-cache-context-reuse-v1.schema.json`
- `token-budget-ledger-v1.md`
