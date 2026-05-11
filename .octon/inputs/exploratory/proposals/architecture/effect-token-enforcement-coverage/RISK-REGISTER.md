# Risk Register

_Status: Draft child risk register_

| Risk | Severity | Mitigation |
| --- | ---: | --- |
| Material path bypass remains uncovered | High | Require inventory coverage and negative tests before support claims widen. |
| Validator exists without runtime enforcement | High | Require runtime crate tests and implementation-conformance receipt. |
| Token verification blocks valid supported paths | Medium | Use fixtures for current supported tuples and denial reason review. |
| Proposal-local source material is mistaken for authority | High | Keep `inputs/**` non-authoritative and require promotion evidence outside proposal paths. |
| Child packet overclaims live Governed Workflow Runtime support | High | Block canonical claims until durable contracts, validators, receipts, and cutover evidence exist. |
| Parent program appears to own child lifecycle truth | Medium | Keep child manifests, receipts, promotion targets, and validation verdicts child-owned. |
