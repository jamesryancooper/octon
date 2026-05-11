# Risk Register

_Status: Draft child risk register_

| Risk | Severity | Mitigation |
| --- | ---: | --- |
| Replay claims exceed available evidence | High | Require reconstruction validators and explicit unsupported outcome receipts. |
| Idempotency is asserted but not enforced | High | Require idempotency keys, duplicate checks, and receipt validation. |
| Compensation is mistaken for transaction rollback | High | Use narrow compensation posture and reject universal transactionality. |
| Proposal-local source material is mistaken for authority | High | Keep `inputs/**` non-authoritative and require promotion evidence outside proposal paths. |
| Child packet overclaims live Governed Workflow Runtime support | High | Block canonical claims until durable contracts, validators, receipts, and cutover evidence exist. |
| Parent program appears to own child lifecycle truth | Medium | Keep child manifests, receipts, promotion targets, and validation verdicts child-owned. |
