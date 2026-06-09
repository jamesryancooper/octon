# Risk Register

_Status: Draft child risk register_

| Risk | Severity | Mitigation |
| --- | ---: | --- |
| Cutover happens before runtime proof exists | High | Block on every required predecessor child receipt and promotion evidence. |
| Compatibility consumers break unexpectedly | Medium | Use retirement register, compatibility notes, and rollback plan. |
| Canonical docs claim more than runtime supports | High | Run support boundary and future capability overclaim validators before promotion. |
| Proposal-local source material is mistaken for authority | High | Keep `inputs/**` non-authoritative and require promotion evidence outside proposal paths. |
| Child packet overclaims live Governed Workflow Runtime support | High | Block canonical claims until durable contracts, validators, receipts, and cutover evidence exist. |
| Parent program appears to own child lifecycle truth | Medium | Keep child manifests, receipts, promotion targets, and validation verdicts child-owned. |
