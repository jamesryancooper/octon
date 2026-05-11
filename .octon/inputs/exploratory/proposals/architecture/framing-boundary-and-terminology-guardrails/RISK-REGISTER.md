# Risk Register

_Status: Draft child risk register_

| Risk | Severity | Mitigation |
| --- | ---: | --- |
| Terminology churn obscures runtime truth | Medium | Keep compatibility wording until the cutover child proves replacement evidence. |
| Entry artifacts imply live workflow runtime behavior | High | Require proof-before-claim rules and overclaim validators. |
| Governed Agent Runtime is retired before consumers migrate | Medium | Block retirement until final migration/cutover packet. |
| Proposal-local source material is mistaken for authority | High | Keep `inputs/**` non-authoritative and require promotion evidence outside proposal paths. |
| Child packet overclaims live Governed Workflow Runtime support | High | Block canonical claims until durable contracts, validators, receipts, and cutover evidence exist. |
| Parent program appears to own child lifecycle truth | Medium | Keep child manifests, receipts, promotion targets, and validation verdicts child-owned. |
