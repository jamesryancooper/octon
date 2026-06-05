# Source Traceability Matrix

| Postmortem finding | Child packet | Expected future output |
|---|---|---|
| Invalid schema or enum drift should be repaired without human intervention when the accepted value is known. | `autonomous-blocker-taxonomy`, `validator-affordances`, `runner-recovery-behavior` | Recovery class, validator accepted-values diagnostic, minimal repair route, gate rerun. |
| Stale child receipts or review digests should be refreshed and revalidated. | `validator-affordances`, `evidence-and-receipt-hardening`, `runner-recovery-behavior` | Stale cause diagnostics, child-owned receipt refresh rules, targeted rerun evidence. |
| Publication freshness and generated projection drift should not pause for human intervention. | `validator-affordances`, `runner-recovery-behavior`, `token-efficiency-preservation` | Freshness recovery class, targeted publication/projection refresh, compact freshness receipt. |
| Local run-state cleanup residue must be delegated rather than deleted ad hoc. | `cleanup-routing`, `evidence-and-receipt-hardening` | Receipt-backed cleanup route and retained cleanup authorization evidence. |
| Bounded `max-steps-exhausted` should be continuable in end-to-end mode. | `runner-recovery-behavior`, `escalation-policy-update` | Continuation policy and hard-stop distinction. |
| Retryable preflight failures should use bounded retries or fallback evidence before escalation. | `runner-recovery-behavior`, `escalation-policy-update` | Retry budget, no-progress threshold, escalation rule. |
| Noisy failure evidence slows diagnosis and wastes context. | `evidence-and-receipt-hardening`, `token-efficiency-preservation` | Compact event summaries, grouped failure slices, minimal recovery deltas. |
| Hard blockers must remain narrow and fail-closed. | `autonomous-blocker-taxonomy`, `escalation-policy-update` | Updated hard-blocker examples and negative controls. |
| Parent summaries must not become child receipts. | `evidence-and-receipt-hardening`, `runner-recovery-behavior` | Child-owned receipt references required for child terminal claims. |
