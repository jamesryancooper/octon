# Risk Register

| Risk | Impact | Likelihood | Mitigation | Residual posture |
|---|---:|---:|---|---|
| Journal schema becomes too complex | Runtime friction and incomplete adoption | Medium | Start with required core fields; payload side refs for complex data. | Accept bounded complexity. |
| Dual v1/v2 event period creates drift | Confusing evidence and validators | Medium | Explicit alias map and v2 required for consequential Runs after cutover. | Manage through migration. |
| Runtime-state still treated as truth | Incorrect resume/replay/disclosure | Medium | Validator raises drift when state conflicts with journal. | Fail closed. |
| Generated summaries become de facto authority | Control-plane bypass | Medium | Negative tests and operator-read-model constraints. | Fail closed. |
| Replay repeats side effects | External harm or duplicate mutations | Low/Medium | Dry-run/sandbox default; fresh grant required for live effects. | Fail closed. |
| Event volume grows large | Storage/cost burden | Medium | Evidence compaction with lineage; no deletion of canonical control journal while active. | Monitor and compact evidence only. |
| Hash-chain corruption blocks closeout | Run cannot close cleanly | Low | Drift incident and recovery validator; preserve corrupted evidence for diagnosis. | Fail closed. |
| Support-target admission becomes too strict | Slower adapter promotion | Medium | This is intended; use staged admissions. | Accept. |
| Validator misses a material path | False confidence | Medium | Authorization-boundary material path inventory and negative tests. | Reduce through coverage. |
| Proposal expands scope | Delay and architectural incoherence | Medium | Explicit non-goals and cutover checklist. | Guard. |
