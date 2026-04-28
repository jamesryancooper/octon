# Promotion Readiness Checklist

## Governance

- [x] Proposal manifests valid.
- [x] Promotion targets under `.octon/**`.
- [x] No proposal path as runtime/policy authority.
- [x] Authored authority only under `framework/**` or `instance/**`.
- [x] State roots are operational control/evidence/continuity only.

## Runtime

- [x] Mission Runner requires v1 Engagement and Work Package.
- [x] Mission Runner requires active Autonomy Window.
- [x] Lease/budget/breaker/context/support/capability/rollback/evidence/Decision Request gates enforced.
- [x] Execution goes through run lifecycle and authorization.
- [x] Continuation Decisions emitted.
- [x] Run-level and mission-level closeout separated.

## Product

- [x] Operator can inspect mission status, queue, Autonomy Window, and Decision Requests.
- [x] Operator can pause, resume, revoke, and close.
- [x] Operator can see why continuation is blocked.
- [x] Deferred external autonomy is not claimed as live support.

## Evidence

- [x] Mission Evidence Profiles exist.
- [x] Continuation Decision inputs retained.
- [x] Mission Run Ledger links to, but does not replace, run journals.
- [x] Mission closeout evidence gates success/failure/abandonment and rollback/disclosure/replay posture before closure.
