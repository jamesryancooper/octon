# Concept Coverage Matrix

| Builder capability | Implemented repo evidence | Final state | Packet motion | Durable landing zone |
|---|---|---|---|---|
| Deterministic assembly contract | Builder spec defines ordering, inclusion, omission, freshness, invalidation, canonical serialization, and replay | implemented | add runtime builder spec | `/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md` |
| Constitutional source classification | Source entries carry surface, trust, role, inclusion, visibility, budget, and policy fields | implemented | strengthen source-entry metadata additively | `/.octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json` |
| Model-visible payload hash | Pack and receipt bind `model_visible_context_ref` plus `model_visible_context_sha256` | implemented | add top-level builder evidence fields | `context-pack-v1` + `context-pack-receipt-v1` |
| Omission ledger | Omission taxonomy is defined in the builder spec, policy, validator, and retained manifests | implemented | keep and strengthen with reason classes and budget linkage | `context-pack-v1` + receipt |
| Freshness and invalidation | Receipt and runtime validation enforce freshness, validity, invalidation, rebuild, and compaction refs | implemented | add invalidation triggers, rebuild status, policy binding | runtime receipt + policy |
| Instruction-layer binding | Manifest v2 binds pack ref, receipt ref, model-visible ref/hash, policy, compaction, and rebuild refs | implemented | add context-pack receipt/hash refs | `instruction-layer-manifest-v2.schema.json` |
| Authorization-time binding | Runtime parses and validates pack, receipt, source manifest, model-visible serialization, hash file, request identity, policy, freshness, and replay refs | implemented | add builder receipt/hash/invalidation refs | grant + receipt schema edits |
| Runtime event coverage | Canonical `run-event-v2` admits `context-pack-*`; `runtime-event-v1` dot names are alias-only | implemented | add requested/built/bound/rejected/invalidated/rebuilt/compacted coverage | `run-event-v2`, `family.yml`, `state-reconstruction-v2.md`, `runtime-event-v1.schema.json` |
| Repo-local policy | Context packing policy exists and preserves generated/raw authority boundaries | implemented | add context packing policy | `/.octon/instance/governance/policies/context-packing.yml` |
| Determinism validator | Validator, durable fixtures, negative cases, and architecture conformance wiring exist | implemented | add validator + tests + CI gate | assurance runtime + workflow |
| Support-target proof | Required evidence was strengthened narrowly without support-universe widening | implemented | strengthen evidence requirements without widening universe | `/.octon/instance/governance/support-targets.yml` |
| State/control/evidence emission | Runtime emits active control state and retained evidence under canonical run roots | implemented | specify control and evidence emission paths | runtime builder spec + receipt schema |
