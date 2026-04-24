# Context Pack Builder Conformance Card

## Purpose

Quick operator and reviewer card for the deterministic Context Pack Builder v1 landing.

## Conformance checks

| Check | Pass condition |
|---|---|
| Constitutional placement | Context contract remains under `framework/constitution/contracts/runtime/**`; no rival context plane exists. |
| Runtime placement | Builder and receipt live under `framework/engine/runtime/spec/**`; runtime bindings point to canonical run roots. |
| Governance placement | Repo-local context policy lives under `instance/governance/policies/**`. |
| Evidence placement | Retained pack, receipt, model-visible serialization, hash, source manifest, omissions, redactions, and invalidations live under `state/evidence/runs/**`. |
| Control placement | Active pack state lives under `state/control/execution/runs/**`. |
| Generated discipline | Any read model or projection stays under `generated/**` and is never authority. |
| Authorization binding | Consequential Runs cannot proceed with stale, missing, or invalid context-pack proof. |
| Supplied binding validation | Runtime parses and validates retained pack, receipt, model-visible serialization, hash sidecar, source manifest, omissions, redactions, invalidation events, replay refs, and source digests before authorization. |
| Replayability | Model-visible context hash can be reconstructed from retained `model-visible-context.json` bytes. |
| Journal naming | Canonical Run Journal entries use `context-pack-*` event names; `run.context_pack_*` is alias-only. |
| Support-target honesty | No support-universe widening; evidence requirements remain truthful. |
| Assurance enforcement | Dedicated validator, regression test, and fixture set exist outside this packet. |

## Failure indicators

- `context_pack_ref` exists but no receipt, model-visible serialization, or model-visible hash exists
- retained `model-visible-context.sha256` is missing or does not hash the exact model-visible bytes
- receipt refs for source manifest, omissions, redactions, invalidation events, or replay reconstruction are missing
- retained source manifest disagrees with receipt sources, pack source manifest, or model-visible source manifest
- a source marked `verification_status: valid` is missing or digest-drifted
- instruction-layer manifest and grant/receipt disagree
- raw additive input appears as authoritative builder input
- generated operator map becomes runtime truth
- stale packs still authorize consequential work
- canonical `events.ndjson` contains `run.context_pack_*`
