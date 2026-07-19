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

Before execution, validate the exact protocol receipt, frozen packet digests,
implemented child receipts, clean exact commit, evidence-root writer census,
current policy/Harness/retention/support/provider digests, corpus identity, and
disabled optional lanes. This is proof-run entry validation, not UE/FD proof.

The protocol stratifies equal-floor no-PR and PR cohorts, reports p50/p95
latency, and computes a route confusion matrix. It includes malicious head,
credential scan, exact CAS race, one/bounded-history, PR `S -> Q`, lost provider
result, closed-unmerged/expected-tip cleanup, false-cleaned, local mirror, and
preserved-work fixtures. Any unauthorized effect or missing preserved-S proof
fails the affected claim rather than being averaged away.

Recompute every protocol/run/mission ID, duration, exclusion, nearest-rank
percentile, paired route result, thirty-day sample count, provider freshness,
claim-state all-of result, retained quota, file hash, and secret classification.
Inject an index CAS loss, partial file write, stale child receipt, implementation
drift, provider drift, corpus omission, invalid interval, missing daily sample,
failed zero budget, incomplete manifest, and premature handoff. Each must retain
failure evidence and prevent a complete or promotable claim.

UE-011/014/015, FD-001/023/024, dogfood, fault, provider, burden, conformance,
and drift evidence must be produced against the exact implemented identity
before proof completion or downstream promotion. Static proposal validation
cannot satisfy those future gates and their absence does not make the selected
proof design incomplete.
