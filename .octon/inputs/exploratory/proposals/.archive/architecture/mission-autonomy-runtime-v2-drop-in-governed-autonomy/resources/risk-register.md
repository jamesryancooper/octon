# Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Mission Runner becomes rival control plane | Undermines run lifecycle | Require all execution through run contracts and authorization. |
| Autonomy Window becomes blanket permission | Unsafe effects | Define as wrapper only; gates still apply. |
| Mission Queue becomes execution authority | Run contract bypass | Queue items compile into run-contract candidates only. |
| Continuation Decision treated as authorization | Engine boundary bypass | Continuation Decision cites grants; cannot mint grants. |
| Mission Run Ledger replaces run journal | Forensics loss | Ledger indexes refs; run journals remain canonical. |
| Connector hooks widen support | Unsafe MCP/API/browser actions | Default stage-only/blocked; require support, policy, authorization. |
| Infinite-agent behavior | Unbounded risk/cost | Lease, budget, breaker, progress, context, and closeout gates. |
| v1 absent | Scope creep | Document dependency; use fail-closed shims only. |
| Generated status becomes authority | Hidden control plane | Projection-only with traceability validation. |
