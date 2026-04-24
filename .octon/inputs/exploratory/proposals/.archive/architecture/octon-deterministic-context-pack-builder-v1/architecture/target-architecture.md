# Target Architecture

## Architectural decision

Octon should implement **deterministic Context Pack Builder v1** as an engine-runtime capability that remains subordinate to:
- the constitutional runtime contract family under `/.octon/framework/constitution/contracts/runtime/**`
- engine-owned `authorize_execution(...)`
- repo-local support-target governance
- retained run evidence and mutable run control roots

The builder must not become a second control plane. It is a runtime assembly and proof surface.

## Design objective

For every consequential or boundary-sensitive Run, Octon must be able to answer all of the following with retained evidence:

1. Which sources were eligible for Working Context?
2. Which sources were actually included?
3. Which sources were excluded or omitted, and why?
4. Which included content was model-visible vs summarized vs handle-only?
5. Which trust and authority classes were assigned?
6. What exact model-visible context digest did the reasoning engine receive?
7. Which repo-local policy controlled the build?
8. Was the pack fresh at authorization time?
9. If the pack later became stale or invalid, how was that recorded?
10. Can replay reconstruct the same model-visible Working Context?

## Canonical surface placement

### Authored authority

**Framework authority**
- `/.octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json`
- `/.octon/framework/constitution/contracts/runtime/run-event-v2.schema.json`
- `/.octon/framework/constitution/contracts/runtime/family.yml`
- `/.octon/framework/constitution/contracts/runtime/state-reconstruction-v2.md`
- `/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `/.octon/framework/engine/runtime/spec/context-pack-receipt-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-request-v3.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-receipt-v3.schema.json`
- `/.octon/framework/engine/runtime/spec/runtime-event-v1.schema.json`
- `/.octon/framework/engine/runtime/README.md`

**Instance authority**
- `/.octon/instance/governance/policies/context-packing.yml`
- optional evidence-strengthening edits to `/.octon/instance/governance/support-targets.yml`

### Mutable control truth

Runtime must bind the active pack under the current Run control root, for example:
- `/.octon/state/control/execution/runs/<run-id>/context/active-context-pack.yml`
- `/.octon/state/control/execution/runs/<run-id>/context/status.yml`

These records describe the current pack and its validity state. They are mutable operational truth, not durable historical proof.

### Retained evidence

Runtime must retain pack artifacts under the bound Run evidence root, for example:
- `/.octon/state/evidence/runs/<run-id>/context/context-pack.json`
- `/.octon/state/evidence/runs/<run-id>/context/context-pack-receipt.json`
- `/.octon/state/evidence/runs/<run-id>/context/model-visible-context.json`
- `/.octon/state/evidence/runs/<run-id>/context/model-visible-context.sha256`
- `/.octon/state/evidence/runs/<run-id>/context/source-manifest.json`
- `/.octon/state/evidence/runs/<run-id>/context/omissions.json`
- `/.octon/state/evidence/runs/<run-id>/context/redactions.json`
- `/.octon/state/evidence/runs/<run-id>/context/invalidation-events.json`

These are retained proof surfaces and must be replay-stable.

### Generated read models

Any operator-facing or runtime-effective projection generated from the pack must remain derived-only under `generated/**` and must never outrank the retained evidence or control truth.

## Builder behavior

### 1. Candidate source collection

Candidate sources may be collected only from allowed classes:
- authored authority
- mutable control truth
- retained evidence
- continuity state
- generated runtime-effective handles where resolver-verified
- capability schemas from admitted Capability Packs
- non-authoritative inputs only when policy allows and only with explicit trust labels

Raw additive inputs, generated operator read models, proposal-local artifacts, and compatibility projections may not silently become authoritative or model-visible without explicit legal treatment.

### 2. Deterministic classification

Every candidate source entry must be tagged with at minimum:
- `path`
- `sha256`
- `surface_class`
- `authority_label`
- `trust_class`
- `source_role`
- `inclusion_mode`
- `bytes_included`
- `estimated_tokens`
- `model_visible`

### 3. Deterministic ordering

Builder order must be deterministic and documented. The builder spec should define a stable order such as:
1. workspace charter / run contract / mission contract
2. governing constitutional and instance authority
3. run control truth required for current execution
4. retained evidence needed for correctness or replay
5. admitted capability schema or tool descriptors
6. continuity/handoff material
7. non-authoritative inputs when explicitly allowed

Stable ordering must be falsifiable by tests.

### 4. Budget and omission handling

The builder must apply repo-local QoS rules:
- max bytes / estimated tokens by source class
- absolute ceiling
- omission strategy
- compaction or summarization rules
- policy for full content vs excerpt vs handle-only inclusion

Omitted items must still be recorded with reason classes such as:
- over_budget
- stale
- non_authoritative_disallowed
- unsupported_surface_class
- trust_rejected
- duplicate_or_shadowed
- unresolved_handle
- explicit_policy_exclusion

### 5. Model-visible hash

The builder must emit:
- a canonical serialization hash for the complete pack artifact
- a retained `model-visible-context.json` serialization
- a separate `model_visible_context_sha256` covering the exact retained bytes visible to the reasoning engine

Replay reconstructs this hash from retained `model-visible-context.json`, not
from source-manifest lines alone.

### 6. Freshness and invalidation

The existing `freshness` block should remain, but the builder receipt must additionally record:
- builder policy ref
- freshness mode or TTL class
- invalidation triggers
- invalidated_at / invalidation_reason when applicable
- rebuilt_from_ref when the pack is regenerated

Authorization must fail closed for consequential Runs when the context pack is stale, invalidated, or unverifiable.

### 7. Instruction-layer binding

The instruction-layer manifest must record:
- `context_pack_ref`
- `context_pack_receipt_ref`
- `model_visible_context_ref`
- `model_visible_context_sha256`
- `context_policy_ref`
- `compaction_or_rebuild_refs` when used

This keeps the instruction layer and the actual Working Context in one evidence chain.

### 8. Grant / receipt binding

Execution grant and execution receipt should carry:
- `context_pack_ref`
- `context_pack_receipt_ref`
- `model_visible_context_ref`
- `model_visible_context_sha256`
- `context_validity_state`
- optional `context_rebuild_ref` when authorization occurred after rebuild

### 9. Runtime journal binding

Runtime events should cover:
- `context-pack-requested`
- `context-pack-built`
- `context-pack-bound`
- `context-pack-rejected`
- `context-pack-compacted`
- `context-pack-invalidated`
- `context-pack-rebuilt`

These are canonical `run-event-v2` Run Journal event names. Dot-named
`runtime-event-v1` entries remain compatibility aliases only and must be
normalized before entering the canonical journal.

## Repo-local policy shape

`/.octon/instance/governance/policies/context-packing.yml` should define:
- allowed and disallowed source classes
- trust handling rules
- model-visible inclusion rules
- max bytes / token budgets by class
- freshness TTLs or receipt-bound freshness
- rules for non-authoritative input use
- rules for generated surfaces
- support-target-specific overrides
- compaction and omission reason taxonomy

## Why this is the strongest plausible implementation now

This design:
- reuses the existing constitutional contract instead of replacing it
- binds directly into existing execution authorization semantics
- strengthens the current instruction-layer evidence surface
- keeps all runtime truth inside `state/control/**` and `state/evidence/**`
- does not widen the support universe
- adds one repo-local policy instead of inventing a new top-level subsystem
- turns context assembly into a validator-enforced runtime artifact rather than an implicit prompting step
