# File Change Map

## Durable target artifacts

| Target artifact | Class | Existing/New | Why it is touched | Migration required? | Required for genuine usability? |
|---|---|---|---|---|---|
| `/.octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json` | framework authority | existing/edit | Strengthen source-entry metadata and add closure-grade top-level builder fields additively | additive | yes |
| `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json` | framework authority | existing/edit | Bind context-pack receipt, model-visible hash, and builder-policy references into instruction evidence | additive | yes |
| `/.octon/framework/constitution/contracts/runtime/run-event-v2.schema.json` | framework authority | existing/edit | Admit canonical hyphenated context-pack lifecycle event types into the append-only Run Journal contract | additive | yes |
| `/.octon/framework/constitution/contracts/runtime/family.yml` | framework authority | existing/edit | Map compatibility dot-named context-pack events to canonical hyphenated Run Journal events | additive | yes |
| `/.octon/framework/constitution/contracts/runtime/state-reconstruction-v2.md` | framework authority | existing/edit | Document alias normalization and state reconstruction for context-pack lifecycle events | additive | yes |
| `/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md` | framework runtime spec | new | Define deterministic builder algorithm, ordering, trust, omission, and emission rules | no | yes |
| `/.octon/framework/engine/runtime/spec/context-pack-receipt-v1.schema.json` | framework runtime spec | new | Define retained proof of the actual builder output and its model-visible digest | no | yes |
| `/.octon/framework/engine/runtime/spec/execution-request-v3.schema.json` | framework runtime spec | existing/edit | Clarify that `context_pack_ref` must resolve to a builder output and support optional context validity metadata | additive | maybe |
| `/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json` | framework runtime spec | existing/edit | Retain builder receipt/hash/validity references at authorization time | additive | yes |
| `/.octon/framework/engine/runtime/spec/execution-receipt-v3.schema.json` | framework runtime spec | existing/edit | Persist final context-pack receipt/hash linkage into consequential execution proof | additive | yes |
| `/.octon/framework/engine/runtime/spec/runtime-event-v1.schema.json` | framework runtime spec | existing/edit | Preserve dot-named builder lifecycle events as compatibility aliases only | additive | yes |
| `/.octon/framework/engine/runtime/README.md` | framework runtime docs | existing/edit | Record the builder and receipt as anchored runtime spec surfaces | no | maybe |
| `/.octon/framework/engine/runtime/crates/authority_engine/src/implementation/api.rs` | runtime implementation | existing/edit | Add request/grant/receipt context-evidence binding structs and fields | additive | yes |
| `/.octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs` | runtime implementation | existing/edit | Carry context-pack refs into effect-token journal governing refs when tokens are emitted under a bound context pack | additive | yes |
| `/.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs` | runtime implementation | existing/edit | Build, validate, bind, journal, and retain deterministic context packs under `authorize_execution(...)`; supplied bindings fail closed unless retained hash sidecar, manifests, replay refs, and source digests validate | additive | yes |
| `/.octon/framework/engine/runtime/crates/authority_engine/src/implementation/policy.rs` | runtime implementation | existing/edit | Emit instruction-layer-manifest-v2 with context-pack receipt and model-visible hash bindings | additive | yes |
| `/.octon/framework/engine/runtime/crates/authority_engine/src/implementation/runtime_state.rs` | runtime implementation | existing/edit | Surface active context-pack evidence in bound runtime state when present | additive | yes |
| `/.octon/framework/engine/runtime/crates/authority_engine/src/implementation/tests.rs` | runtime implementation tests | existing/edit | Prove canonical journal event names, supplied-binding denial, retained model-visible hash reconstruction, retained manifest validation, source digest validation, and stale/invalid denial | additive | yes |
| `/.octon/framework/engine/runtime/crates/authority_engine/src/phases/receipt.rs` | runtime implementation | existing/edit | Stop substituting schema-path defaults and persist real context evidence refs in execution artifacts | additive | yes |
| `/.octon/instance/governance/policies/context-packing.yml` | instance authority via enabled governance overlay | new | Repo-specific context QoS, trust, freshness, and non-authoritative input policy | no | yes |
| `/.octon/instance/governance/support-targets.yml` | instance authority | existing/edit | Strengthen required evidence posture for context-pack receipts where justified without widening support | additive | maybe |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh` | framework assurance runtime | existing/edit | Wire the context-pack builder validator into the active architecture conformance path | additive | yes |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh` | framework assurance runtime | new | Enforce deterministic builder semantics, retained receipt completeness, hash-sidecar validation, manifest consistency, replay refs, and evidence completeness | no | yes |
| `/.octon/framework/assurance/runtime/_ops/tests/test-context-pack-builder.sh` | framework assurance runtime | new | Regression coverage for validator and fixture expectations, including missing hash sidecar, missing source manifest, replay-ref, retained-manifest, and authority-boundary negatives | no | yes |
| `/.octon/framework/assurance/runtime/_ops/fixtures/context-pack-builder-v1` | framework assurance runtime | new | Positive and negative fixture set for deterministic builder validation and supplied-binding evidence failure modes | no | yes |

## Derived refresh artifacts

These files were refreshed because support-target evidence changed. They remain generated or retained publication proof, not authority sources.

| Artifact | Class | Why it changed |
|---|---|---|
| `/.octon/generated/effective/capabilities/pack-routes.effective.yml` | generated effective handle | Recomputed from strengthened support-target evidence. |
| `/.octon/generated/effective/capabilities/pack-routes.lock.yml` | generated lock | Points at the fresh pack-route publication receipt. |
| `/.octon/generated/effective/runtime/route-bundle.yml` | generated effective handle | Recomputed from the refreshed pack-route lock and support matrix. |
| `/.octon/generated/effective/runtime/route-bundle.lock.yml` | generated lock | Points at the fresh runtime-route publication receipt. |
| `/.octon/state/evidence/validation/publication/capabilities/*-pack-routes-*.yml` | retained publication evidence | Proof of the derived pack-route refresh. |
| `/.octon/state/evidence/validation/publication/runtime/*-runtime-route-bundle-*.yml` | retained publication evidence | Proof of the derived runtime-route refresh. |

## Explicitly unchanged roots

- `/.octon/state/continuity/**` top-level layout
- `/.octon/generated/**` top-level families, except derived effective-handle refreshes listed above
- `/.octon/framework/constitution/contracts/authority/**`
- `/.octon/framework/capabilities/**` except indirect builder consumption of admitted capability schema
- Mission authority surfaces
- support-universe membership

## Workflow integration

No non-`.octon` workflow edit was required. The active `.octon` architecture conformance script now invokes the context-pack builder regression suite directly.
