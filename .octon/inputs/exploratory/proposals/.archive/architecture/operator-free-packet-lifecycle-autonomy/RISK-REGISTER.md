# Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Wrapper autonomy bypasses child route ownership | Weakens governance while appearing smoother | Require every child to preserve target-owned receipts and route-owned effects. |
| Blocked receipt validation becomes permissive | False success or receipt forgery | Validate blocked receipts structurally, but require all pass fields for `cleaned`. |
| Branch cleanup runs before landing proof | Source branch evidence can be lost | State machine must block cleanup until hosted landing, sync, and equality proof pass. |
| Generated freshness auto-detection treats generated output as authority | Generated authority drift | Require owning generators, source traceability, and generated non-authority validation. |
| Worktree automation deletes evidence | Irrecoverable evidence loss | Bucket protected retained evidence separately and require cleanup authorization. |
| Terminal proof changes the landed ref | Landing proof becomes unstable | Use a local/non-authority terminal evidence sink that does not require source-branch commits. |
| Git preflight normalizes escalation too broadly | Overbroad mutation permission | Emit scoped rerun diagnostics and keep authorization gates intact. |
