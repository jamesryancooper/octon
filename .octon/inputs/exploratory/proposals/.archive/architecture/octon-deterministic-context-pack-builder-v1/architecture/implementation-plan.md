# Implementation Plan

## Posture

This packet is **implemented** and **runtime-hardening-oriented**. The repo already has the right super-root, contract families, authorization boundary, and evidence classes. The implemented move tightened the existing context assembly path until it became:
- deterministic
- evidence-bearing
- authorization-bound
- support-target-safe
- validator-enforced

## Phase 0 — Packet acceptance and emitter/consumer location

1. Accepted the scope as a focused runtime/context hardening packet rather than a general target-state rewrite.
2. Located the current surfaces that emit or consume:
   - context packs
   - instruction-layer manifests
   - execution requests / grants / receipts
   - runtime events
   - run control and run evidence roots
3. Confirmed durable spec, schema, policy, support-target, and validator landing zones.
4. Froze field names and receipt paths before schema edits.

**Exit criterion:** emitter/consumer locations are identified and no unresolved ambiguity remains about which runtime code owns context-pack emission.

## Phase 1 — Constitutional contract hardening

1. Extend `context-pack-v1.schema.json` additively with:
   - `surface_class`
   - `trust_class`
   - `source_role`
   - `inclusion_mode`
   - `model_visible`
   - `bytes_included`
   - `estimated_tokens`
   - top-level `context_policy_ref`
   - top-level `model_visible_context_ref`
   - top-level `model_visible_context_sha256`
   - optional receipt / rebuild / invalidation refs
2. Extend `instruction-layer-manifest-v2.schema.json` with additive context-pack evidence fields.
3. Keep the existing contract family and version unless breakage makes a version bump unavoidable.

**Incomplete if omitted:** the packet would leave the core contract too shallow for closure-grade runtime enforcement.

## Phase 2 — Runtime builder and receipt surfaces

1. Add `context-pack-builder-v1.md`.
2. Add `context-pack-receipt-v1.schema.json`.
3. Define canonical state/control and retained evidence emission roots for packs and receipts.
4. Define deterministic ordering, canonical model-visible serialization, omission reasons, invalidation semantics, compaction, replay, and rebuild rules.

**Incomplete if omitted:** `context_pack_ref` would remain a weak pointer instead of a replayable runtime artifact.

## Phase 3 — Governance policy

1. Add `/.octon/instance/governance/policies/context-packing.yml`.
2. Encode:
   - source-class legality
   - non-authoritative input rules
   - generated-surface exclusions
   - token and byte budgets
   - freshness policy
   - compaction rules
   - support-target-specific overrides
3. Decide whether `support-targets.yml` should require `context-pack-receipt` for supported model adapters and boundary-sensitive host adapters.

**Incomplete if omitted:** the builder would still lack repo-local falsifiable policy.

## Phase 4 — Authorization / receipt / event binding

1. Update `execution-request-v3` as needed to clarify context-pack receipt expectations.
2. Update `execution-grant-v1` and `execution-receipt-v3` to bind builder receipt and model-visible hash.
3. Update canonical `run-event-v2`, runtime alias maps, and `runtime-event-v1` compatibility aliases for the full context-pack lifecycle.
4. Make authorization parse and validate the supplied or built pack, receipt, source manifest, model-visible serialization, retained hash file, request binding, policy binding, and replay refs.
5. Make authorization fail closed for consequential or boundary-sensitive Runs when:
   - context pack is missing
   - context pack receipt is missing
   - model-visible serialization or hash file is missing or mismatched
   - context pack is stale or invalid
   - the pack violates repo-local context policy
   - generated or raw inputs are treated as authority

**Incomplete if omitted:** the step would not actually strengthen governed execution, only documentation.

## Phase 5 — Assurance and CI hardening

1. Add `validate-context-pack-builder.sh`.
2. Add `test-context-pack-builder.sh`.
3. Retain the deterministic fixture set under `/.octon/framework/assurance/runtime/_ops/fixtures/context-pack-builder-v1`.
4. Ensure the validator is reachable from the active conformance path. If the current repo-level workflow does not auto-discover the new validator, open a separate linked repo-local follow-on packet for workflow wiring.
5. Retain deterministic fixture expectations:
   - identical inputs => identical model-visible hash
   - shuffled source discovery => identical model-visible hash
   - forbidden source class => validator failure
   - stale context pack => authorization failure
   - invalidated context pack => authorization failure
   - request id, policy ref, source digest, model hash, replay, and dot-named journal mismatches => failure

## Phase 6 — Reference proof and closeout

1. Produce at least one retained synthetic or real fixture proving:
   - instruction-layer manifest carries the pack binding
   - authorization grant carries the pack receipt / hash
   - execution receipt carries the same
   - canonical Run Journal trail shows pack lifecycle using hyphenated event names
2. Retain architecture transition evidence under the canonical architecture validation root.
3. Keep archive readiness dependent on retained validation evidence outside this packet.

## Preferred change path

One coherent branch touching the constitutional contract, runtime builder/receipt, governance policy, and assurance surfaces together. This preserves semantic alignment and avoids pseudo-coverage.

## Minimal fallback

Only if branch risk becomes unacceptable:
- add repo-local context-packing policy
- add validator
- add receipt schema
- defer instruction-layer and grant/receipt binding to a follow-on packet

This fallback is **not** recommended because it leaves the step materially under-realized.
