# Validation Plan

| Evidence | Proof method | Planned transition |
| --- | --- | --- |
| Setup, onboarding, missions, recovery, burden | dogfood and dynamic execution | `UNVERIFIED` → `DYNAMICALLY_EXECUTED` |
| Unauthorized effect, prompt, fallback, false escalation negatives | adversarial test and fault injection | `UNVERIFIED` → `ADVERSARIALLY_TESTED` |
| Current provider behavior and drift | provider observation plus independent reproduction | `UNVERIFIED` → `PROVIDER_OBSERVED` / `DYNAMICALLY_EXECUTED` |
| Claim/evidence completeness | independent static inspection | `UNVERIFIED` → `STATICALLY_INSPECTED` |
| Upstream RP-00 ROD-006 no-Octon-direct-main posture | accepted decision binding inspection | accepted input → exact RP-14 protocol binding |
| Support and optional-capability promotion | exact claim evidence plus downstream authority review | evidence-gated claim-scoped acceptance or continued disablement |

Every result binds the implementation commit, environment, provider identity,
time, test corpus, child receipt references, and evidence digest. Failed or
incomplete proof is retained and cannot be reported as success.

The protocol stratifies equal-floor no-PR and PR cohorts, reports p50/p95
latency, and computes a route confusion matrix. It includes malicious head,
credential scan, exact CAS race, one/bounded-history, PR `S -> Q`, lost provider
result, closed-unmerged/expected-tip cleanup, false-cleaned, local mirror, and
preserved-work fixtures. Any unauthorized effect or missing preserved-S proof
fails the affected claim rather than being averaged away.
