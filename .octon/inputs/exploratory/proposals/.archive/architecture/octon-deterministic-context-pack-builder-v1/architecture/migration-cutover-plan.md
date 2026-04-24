# Migration Cutover Plan

## Cutover posture

The implemented cutover was **additive-first, fail-closed-last**. Octon already referenced `context_pack_ref`; the migration first made the emitted pack richer and more provable, then moved authorization and conformance validation to require stronger receipts for consequential Runs.

## Stage 1 — Additive schema and spec landing

- land additive edits to `context-pack-v1`
- land new `context-pack-builder-v1.md`
- land new `context-pack-receipt-v1.schema.json`
- land additive instruction-layer, grant, receipt, canonical run-event, alias-map, and compatibility-event fields
- land repo-local context policy
- keep compatibility additive while runtime emitters are upgraded

## Stage 2 — Emitter upgrade

- upgrade runtime emitters to produce:
  - enriched context pack
  - builder receipt
  - retained model-visible serialization
  - model-visible hash over exact retained bytes
  - context state/control binding
  - context retained evidence
- emit canonical `context-pack-*` Run Journal events through `runtime_bus`

## Stage 3 — Validator and CI hardening

- turn `validate-context-pack-builder.sh` into blocking mode
- require deterministic fixture success
- require instruction-layer and grant/receipt coherence
- reject dot-named context-pack events in canonical replay or journal fixtures

## Stage 4 — Authorization hard-enforcement

For consequential or boundary-sensitive Runs:
- deny authorization when context-pack receipt is missing
- deny authorization when context pack is stale or invalid
- deny authorization when illegal source classes are included
- deny authorization when supplied binding identity, policy, digest, source count, freshness, validity, or replay refs disagree
- deny authorization when model-visible hash cannot be reconstructed

Runtime builds a new pack only when required context evidence is absent; invalid supplied bindings fail closed and are not silently rebuilt.

## No-big-bang rules

- no top-level class-root migration
- no support-universe widening
- no generated-surface authority
- no temporary dependence on proposal-local files
- no context assembly sidecar outside canonical runtime and evidence roots

## Rollback posture

If rollout fails after Stage 2 or Stage 3:
- revert validator enforcement first
- retain emitted evidence for failed attempts
- keep additive schema fields on disk if they do not break consumers
- do not delete retained evidence or journaled context lifecycle records
