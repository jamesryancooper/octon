# Coverage Traceability Matrix

| Source or current surface | Observed fact | Gap exposed | Implemented response |
|---|---|---|---|
| Umbrella architecture | only `framework/**` and `instance/**` are authored authority; `generated/**` is derived-only | context builder must not mint a new authority plane | keep contract in framework + repo-local policy in instance + evidence in state |
| `context-pack-v1` | deterministic assembly contract exists | contract is too shallow and lacks runtime realization | extended contract + added builder spec + receipt |
| `execution-request-v3` | `context_pack_ref` required | ref is too weak without receipt/hash | bound builder receipt, model-visible ref, and hash into request/grant/receipt chain |
| `execution-authorization-v1` | context-pack provenance participates in authority routing | provenance is under-specified | added repo-local policy + receipt + full authorization-time validation for retained hash sidecar, manifests, replay refs, source digests, and denial semantics |
| `instruction-layer-manifest-v2` | per-run instruction evidence exists | actual context assembly not fully bound | extended manifest with pack, receipt, model-visible ref/hash, policy, rebuild, and compaction refs |
| `runtime-event-v1` and `run-event-v2` | dot-named compatibility events existed; canonical run events needed full context lifecycle | lifecycle coverage and canonical naming were incomplete | added canonical `context-pack-*` event family plus compatibility alias mapping |
| support targets | bounded support universe + evidence expectations | context-specific proof not explicit | strengthened required evidence without widening the support universe |
| overlay registry + instance manifest | governance policy and assurance runtime overlays are legal | no current policy/validator surface | added context-packing policy, validator, tests, durable fixtures, and conformance wiring |
| external context-engineering research | context should be policy-bound, progressive, and budget-aware | current repo has contract but not complete implementation | packet adopts strongest repo-compatible implementation shape |
