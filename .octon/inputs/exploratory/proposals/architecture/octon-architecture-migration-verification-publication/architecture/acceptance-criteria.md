# Acceptance Criteria

Accepted proposal review may authorize creation of only the exact design in
`resources/verification-publication-design-and-dependency-receipt.yml`. These
are implementation-entry and future proof conditions, not current claims.

| ID | Criterion | Required proof |
| --- | --- | --- |
| AC-RP06-001 | One candidate-immutable verifier identity/version produces the only accepted publication verdict. | Deployment identity and candidate-mutation negatives |
| AC-RP06-002 | The verdict binds repository, authenticated source identity/ref, `S`, target ref, `O`, run, grant/issuer, operation, consequence, verifier deployment, harness, route/history policy, validation inputs/results, evidence, time, expiry, and revocation. | Exact verdict schema fixtures |
| AC-RP06-003 | Before T1, the RP-06-owned gate authenticates the RP-07-governed role signature, producer/deployment identity, complete tuple, immutable policy digest, expiry, and revocation; forged, duplicate/conflicting, wrong-context, or invalid verdicts deny. | UE-006 adversarial matrix and pre-T1 gate proof |
| AC-RP06-004 | Verifier identity cannot merge, write content/refs, issue broker authority, or hold the RP-05 effect credential. | Permission and same-credential negatives |
| AC-RP06-005 | Publisher cannot mint, alter, or substitute its own verdict. | Confused-deputy and self-verification negatives |
| AC-RP06-006 | One immutable typed policy owns A/B/C and Class-B/PR classification and is digest-bound before execution. | Policy mutation and digest tests |
| AC-RP06-007 | Invalid authority denies and is never laundered through protected PR. | Route matrix |
| AC-RP06-008 | Eligible Class B defaults to `brokered-class-b-no-pr` and invokes exact RP-05 CAS; valid review-required or stable pre-route high-contention work routes deterministically to PR. | Integrated route fixtures |
| AC-RP06-009 | Agent direct-main is unreachable and candidate work remains preserved when publication blocks. | Route reachability and preservation proof |
| AC-RP06-010 | Brokered Git publication has no FD-007 worker call path or credential: only the RP-04-hosted RP-05 effect can mutate refs. Any separately claimed non-Git worker owns no canonical state/policy and cannot mint or widen an operation. | Git worker-unreachability/credential negatives plus separately gated FD-007 tests |
| AC-RP06-011 | Provider rules, check producers, Apps, permissions, environments, and secret consumers match the declared adapter at implementation and promotion time. | UE-015 redacted provider observation |
| AC-RP06-012 | Normal eligible routes require zero prompts and explain outcome/blocker concisely. | Route UX scenario tests |
| AC-RP06-013 | A current .octon-authored source/generator owns any changed .github projection and retains freshness evidence. | Projection source, digest, and publication receipt |
| AC-RP06-014 | FD-023 specialization passes provider conformance without claiming generic adapter or secondary-provider support. | Specialization conformance receipt consumed by RP-14 |
| AC-RP06-015 | Production autonomous Class B remains disabled until RP-07 and RP-08 exit. | Feature/route enablement negative control |
| AC-RP06-016 | History shape freezes before `V`: one curated commit is automatic default and any bounded `O..S` series is explicitly admitted and fully validated. | One/multi-commit positive and negative matrix |
| AC-RP06-017 | Substantive exact-candidate/integrated validation passes before target movement; route-name/static checks and post-main-only checks cannot authorize. | Pre-effect harness and post-main negative fixtures |
| AC-RP06-018 | Inherited-red correction uses identical harness/policy on `O`/`S`, binds both result sets, introduces no new failures, strictly reduces baseline failures, and passes changed scope. | Correction-lane matrix |
| AC-RP06-019 | Protected PR binds exact source ref, base/head, checks, requested changes, unresolved threads, draft/conflict/mergeability/review/freshness state; merge atomically enforces expected head, expected base or exact tested merge-result/merge-group SHA, and required review/check state at effect time. Movement requires a fresh tuple; absent provider capability disables automated merge and preserves work. | Complete PR state, atomic merge capability, check-then-merge negative, and race matrix |
| AC-RP06-020 | A checked `S` squashed to `Q` is accepted only with provider association and independent tree/patch equivalence proof. | `S -> Q` positive and mismatch fixtures |
| AC-RP06-021 | Source-ref, PR-create/update, and merge are separate T1-bound effects; lost results enter RP-08 `UNKNOWN` with no retry or route switch. | Subeffect fault matrix |
| AC-RP06-022 | Independent post-land verification precedes fast-forward-only local-main mirror orchestration; local main never authorizes integration. | Post-land/mirror concurrency suite |
| AC-RP06-023 | RP-08 cleanup receives route-specific landed facts; closed-unmerged work remains ineligible and cleanup failure is never reported `cleaned`. | Cleanup contract and preservation suite |
| AC-RP06-024 | Invalid authority, actual collision, outage, `ATTEMPTING`, or `UNKNOWN` produces zero technical-failure-to-PR conversions. | Route-confusion matrix |

## Exit Criteria

Exit requires dependency proof, durable encoding and traceability of
settled/retired ROD-002 lineage, ED-004 conformance, PO-FD-007/010/011,
UE-006/015, candidate-immutability, route and provider drift proof, accepted
projection-source disposition, implementation conformance, and drift/churn
review. It does not require another operator vote on the route model.

Proposal acceptance does not wait for those runtime/provider results. RP-01/
RP-03/RP-05 verification and exact provider/tool/App/ruleset/environment/
runner/scratch preflight gate source entry. UE-006/015 and all dynamic results
gate conformance, completion, projection publication, enablement, or promotion.

## Claim Limit

RP-06 proves verification and deterministic routing only. It does not prove
signed retained evidence, recovery, trust activation, generic provider
replacement, or a support claim.
