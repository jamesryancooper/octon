# Risk Register

| Risk | Severity | Mitigation |
|---|---:|---|
| Token implementation becomes a parallel authority system. | High | Tokens derive only from `authorize_execution`; policy remains in Control Plane. |
| Forged token-shaped values pass. | High | Ledger-backed verifier, token digest, and `VerifiedEffect<T>` guard. |
| Material path inventory misses a bypass. | High | Complete inventory, code search, owner signoff, negative tests. |
| Enforcement breaks legitimate flows. | Medium | Shadow mode, stage-only fallback, scope fixes, retained denial evidence. |
| Support-target claims accidentally widen. | High | No live tuple additions; support-target validator checks no widening. |
| Generated token status becomes authority. | High | Generated non-authority tests and source-of-truth map. |
| Evidence volume grows. | Medium | Evidence compaction only with lineage and token receipt preservation. |
| CI wiring omitted due to proposal scope rules. | Medium | Add linked repo-local workflow patch if validator discovery is not automatic. |
| API signature churn causes broad refactor. | Medium | Start with live material families and compatibility quarantine. |
| Replay repeats side effects. | High | Replay token lifecycle in dry-run/simulation mode only unless separately authorized. |
