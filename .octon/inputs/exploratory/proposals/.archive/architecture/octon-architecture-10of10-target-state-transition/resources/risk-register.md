# Risk Register

| Risk | Severity | Why it matters | Mitigation |
|---|---:|---|---|
| Runtime still reads generated/effective by path | Critical | Stale or unreceipt-backed output can affect execution | Freshness handle and direct-read tests |
| Support partition migration breaks existing refs | High | Proof bundles/support cards may point to moved files | Staged cutover, compatibility shims, path-normalization validator |
| Pack route generated/effective migration confuses authority | High | Generated/effective is runtime-facing, not authored authority | Explicit source refs, receipts, non-widening test |
| Root manifest thinning removes needed runtime data | Medium | Runtime may lose anchors | Move only dense detail; keep root pointers |
| Extension active-state compaction hides useful debug info | Medium | Operators need inspectability | Keep full dependency closure in generation lock and artifact map |
| New validators become documentary only | High | No practical architecture improvement | Wire into architecture-health and CI/doctor gates |
| Operator read models become pseudo-authority | High | Violates generated-vs-authored discipline | Non-authority disclaimers and runtime exclusion tests |
| Transitional shims persist forever | Medium | Architecture remains overgrown | Retirement register owners/triggers/dates |
| Proposal path retained after promotion | Medium | Violates proposal standard | Backreference validator before archive |
| Expanding target state widens live support | Critical | Breaks bounded-claim discipline | No live support expansion in this proposal |
