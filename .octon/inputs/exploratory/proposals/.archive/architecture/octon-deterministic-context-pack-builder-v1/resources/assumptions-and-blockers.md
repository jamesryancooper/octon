# Assumptions and Blockers

## Assumptions

1. The inspected public repo surfaces accurately represent the active contract family and proposal governance rules.
2. The runtime emitters for request/grant/receipt/instruction-layer artifacts are still owned by the authority-engine-aligned implementation described in the runtime README.
3. Additive strengthening of `context-pack-v1` is preferable to introducing a `v2` contract unless a deeper breaking change proves necessary.
4. The repo wants to keep support-target scope stable while strengthening evidence.

## Current blockers

None.

## Resolved blockers

1. **Emitter location uncertainty**
   - Resolved by implementing builder emission in `authority_engine/src/implementation/execution.rs` and v2 instruction manifest emission in `authority_engine/src/implementation/policy.rs`.

2. **Context pack current emitter unknown**
   - Resolved by adding deterministic build, validation, retained evidence, control truth, and Run Journal binding subordinate to `authorize_execution(...)`.

3. **Potential legacy consumer assumptions**
   - Resolved additively by retaining compatibility fields while binding richer `context_evidence_binding` objects into request, grant, receipt, and instruction-layer artifacts.

4. **Proposal-scope legality**
   - Resolved without non-`.octon` workflow edits. The active `.octon` architecture conformance script now runs the context-pack builder regression suite.

5. **Canonical journal event typing**
   - Resolved by adding canonical `context-pack-*` event types to `run-event-v2`, preserving `runtime-event-v1` dot names as aliases only, updating alias/state reconstruction docs, and adding Rust plus shell negative coverage.

6. **Authorization-time evidence validation**
   - Resolved by validating supplied or built pack, receipt, source manifest, omission/redaction/invalidation manifests, model-visible serialization, retained hash sidecar, request binding, policy binding, source counts, source digests, freshness, validity, invalidation, and replay refs before material authorization.

7. **Model-visible replay fidelity**
   - Resolved by retaining `model-visible-context.json`, hashing its exact bytes into `model-visible-context.sha256`, and replaying from that retained serialization rather than source-manifest lines.

8. **Retained evidence completeness**
   - Resolved by making missing hash sidecars, missing retained manifests, missing replay hash refs, retained source-manifest mismatches, and missing or digest-drifted valid sources fail closed in runtime tests and shell fixtures.
