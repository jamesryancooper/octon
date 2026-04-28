# Risk Register

| Risk | Severity | Mitigation |
| --- | --- | --- |
| Stewardship becomes infinite loop | Critical | Epoch, trigger, admission, idle, renewal, progress gates |
| Stewardship becomes rival control plane | Critical | Explicit handoff to v1/v2; no material execution directly |
| Campaigns become second mission system | High | Campaign gate and no-go default |
| Generated read models treated as authority | High | Root placement validation and generated non-authority docs |
| Proposal paths leak into runtime | High | Promotion-readiness checks and validation |
| Missing v1/v2 dependencies cause scope creep | High | Minimal compatibility shim rule |
| Overbroad event ingestion | Medium | MVP limits triggers to scheduled-review/human-objective first |
| Silent renewal widens scope | High | Renewal Decision and human review gate |
| Evidence bloat | Medium | Stewardship Evidence Profiles |
