# Risk Register

| Risk | Severity | Mitigation | Closeout test |
|---|---:|---|---|
| Coverage proof misses a material path | High | Side-effect inventory + static scan + negative controls. | Uncovered path report is empty. |
| Runtime refactor changes behavior | High | Behavior parity tests and staged cutover. | Existing command smoke tests pass. |
| Obligation renumbering breaks references | Medium-high | Stable alias map for one release if needed. | Reference scan passes. |
| Generated maps are mistaken for authority | High | Non-authority labels, source traceability, validators. | Generated-as-authority negative test denies. |
| Support claims become overbroad | High | Support proof bundle validator; no live expansion. | SupportCard excludes stage-only/non-live surfaces. |
| Compatibility shims become permanent | Medium-high | Owner/consumer/expiry metadata and retirement validator. | Retirement report has no unmanaged shim. |
| Active docs become too thin | Medium | Generated maps and where-to-place guide. | Operator/agent navigation map exists. |
| Runtime modularity adds complexity | Medium | Phase contracts and module boundaries. | Maintainability validator passes. |
| Proposal path dependency remains | High | Dependency scan before archive. | No durable target references active proposal path as authority. |
