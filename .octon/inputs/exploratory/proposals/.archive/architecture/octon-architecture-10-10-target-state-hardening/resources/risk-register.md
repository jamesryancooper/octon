# Risk Register

| Risk ID | Risk | Severity | Mitigation |
| --- | --- | --- | --- |
| R-001 | Authorization coverage remains partial. | Critical | Add coverage tests for every material side-effect class. |
| R-002 | Support partitioning breaks existing refs. | High | Use staged move, update refs, retain migration evidence. |
| R-003 | Pack/admission validator creates false positives. | Medium | Start report-only, then promote to blocking after fixtures. |
| R-004 | Generated/effective freshness gates block legitimate runs. | Medium | Add clear reason codes and regeneration path. |
| R-005 | Root manifest refactor removes necessary defaults. | High | Keep manifest anchors; delegate only bulky policy. |
| R-006 | Ingress simplification drops needed closeout logic. | Medium | Move, do not delete, closeout logic into dedicated workflow. |
| R-007 | Extension dependency lock normalization hides important detail. | Medium | Use grouped content-addressed manifests with expandable refs. |
| R-008 | Proof bundles become heavy and discourage use. | Medium | Generate compact cards plus detailed retained evidence refs. |
| R-009 | Compatibility shims persist indefinitely. | High | Validator requires owner, successor, review, retirement trigger. |
| R-010 | Architecture health command becomes another opaque layer. | Medium | Emit markdown and JSON summaries with cited canonical refs. |
| R-011 | Proposal scope becomes too broad. | High | Preserve no-new-control-plane and no-support-widening guardrails. |
| R-012 | Runtime packaging remains underdeveloped. | High | Add first-run fixture and install/build validation as acceptance criteria. |
