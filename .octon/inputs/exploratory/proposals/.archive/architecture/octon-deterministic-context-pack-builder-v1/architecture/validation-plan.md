# Validation Plan

## Validation posture

This step is accepted only if Octon can prove that context assembly is no longer implicit. Validation must cover structure, runtime contract behavior, replay, governance correctness, and support-target honesty.

## 1. Structural validation

Validator:
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh`

It must check at minimum:
- `context-pack-v1` additive fields are present when consequential execution uses the builder
- instruction-layer manifest binds the same `context_pack_ref` and hash
- grant and receipt carry coherent context-pack receipt refs
- canonical Run Journal fixtures use hyphenated context-pack lifecycle names and reject dot-named canonical entries
- illegal source classes are not marked authoritative
- generated operator read models do not become builder authority inputs
- retained `model-visible-context.json` bytes hash to the recorded `model_visible_context_sha256`
- retained `model-visible-context.sha256` exists and matches the exact retained bytes
- retained `source-manifest.json`, `omissions.json`, `redactions.json`, and `invalidation-events.json` resolve from receipt refs and match pack and model-visible manifests
- replay reconstruction refs include both the retained model-visible serialization and its hash sidecar

## 2. Determinism tests

The durable validator and regression tests must prove:
- identical source inputs + identical policy => identical `model_visible_context_sha256`
- source-order variation at input collection time does not perturb canonical output order
- duplicate sources normalize deterministically
- omission ordering is deterministic

## 3. Governance negative controls

Negative controls in the fixture set must prove:
- stale pack => authorization denial
- invalidated pack => authorization denial
- missing receipt => authorization denial
- raw additive input marked authoritative => validator / authorization failure
- generated operator read model included as authority => validator / authorization failure
- model-visible hash mismatch => validator / authorization failure
- request id mismatch => validator / authorization failure
- policy ref mismatch => validator / authorization failure
- source digest mismatch => validator / authorization failure
- missing model-visible hash sidecar => validator / authorization failure
- missing source manifest => validator / authorization failure
- missing replay reconstruction hash ref => validator / authorization failure
- retained source-manifest mismatch => validator / authorization failure
- missing or digest-drifted valid source file => authorization failure
- dot-named canonical journal event => validator failure

## 4. Replay checks

Replay or reconstruction tests must prove:
- retained evidence is enough to reconstruct the same model-visible hash
- reconstruction uses retained `model-visible-context.json`, not source-manifest lines alone
- source manifests prove eligibility and source freshness; they are not a substitute for retained model-visible bytes
- a rebuilt pack records the linkage to the old pack and invalidation reason
- compaction events preserve evidence lineage

## 5. Support-target checks

Validate that:
- support-target universe is unchanged
- required evidence for supported model adapters remains truthful
- no stage-only surface is silently promoted by context-policy changes
- context policy respects admitted tuples and exclusions

## 6. Operator-clarity checks

Using reference fixtures, confirm a maintainer can answer in one place:
- what the model saw
- what was omitted
- whether the pack was fresh
- which policy governed the build
- whether the pack was rebuilt or invalidated

## 7. CI integration

The active conformance path must block on:
- validator failure
- regression test failure
- fixture hash mismatch
- unauthorized schema drift

The implemented path wires `/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh` to invoke `test-context-pack-builder.sh`, which in turn runs the durable validator and all positive/negative fixtures. No non-`.octon` workflow edit is required for this packet.

## Required retained evidence

Minimum retained evidence for archive readiness:
- schema validation output
- deterministic fixture results
- at least one retained pack + receipt + model-visible serialization + model-visible hash
- at least one negative authorization fixture
- negative controls for missing retained hash sidecar, missing source manifest, missing replay hash ref, retained manifest mismatch, and missing/digest-drifted source files
- regression test output
- two consecutive clean context-pack builder validation passes
- one clean architecture conformance pass after validator wiring
