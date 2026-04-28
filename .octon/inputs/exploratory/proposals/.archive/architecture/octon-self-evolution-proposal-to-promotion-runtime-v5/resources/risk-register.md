# Risk Register

| Risk | Severity | Mitigation |
|---|---:|---|
| Self-authorization through generated summaries | Critical | Negative controls; generated summaries forbidden as authority |
| Proposal packet becomes runtime dependency | Critical | Proposal standard enforcement; promotion strips proposal-path dependencies |
| Lab success treated as approval | High | Lab Gate requires Decision Request / approval before promotion |
| Promotion writes outside declared targets | High | Promotion runtime validates target set and fails closed |
| Recertification skipped | High | Closure blocked until recertification evidence exists |
| V1-V4 missing surfaces tempt backfill | Medium | Compatibility shims only; fail closed for missing runtime layers |
| Over-broad v5 scope | Medium | MVP centered on candidate/proposal/promotion/recertification pipeline |
