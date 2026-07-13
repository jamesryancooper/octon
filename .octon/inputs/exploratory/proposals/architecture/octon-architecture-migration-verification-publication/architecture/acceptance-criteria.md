# Acceptance Criteria

These are future proof conditions, not current claims.

| ID | Criterion | Required proof |
| --- | --- | --- |
| AC-RP06-001 | One candidate-immutable verifier identity/version produces the only accepted publication verdict. | Deployment identity and candidate-mutation negatives |
| AC-RP06-002 | The verdict binds repository, source, target, target-pre, run, grant, harness, policy, evidence, time, expiry, and revocation. | Exact verdict schema fixtures |
| AC-RP06-003 | Duplicate/conflicting context, wrong producer/event/repository/SHA/target/policy, expired, or revoked verdicts deny. | UE-006 adversarial matrix |
| AC-RP06-004 | Verifier identity cannot merge, write content/refs, issue broker authority, or hold the RP-05 effect credential. | Permission and same-credential negatives |
| AC-RP06-005 | Publisher cannot mint, alter, or substitute its own verdict. | Confused-deputy and self-verification negatives |
| AC-RP06-006 | One immutable typed policy owns A/B/C and Class-B/PR classification and is digest-bound before execution. | Policy mutation and digest tests |
| AC-RP06-007 | Invalid authority denies and is never laundered through protected PR. | Route matrix |
| AC-RP06-008 | Eligible Class B invokes the exact RP-05 expected-old primitive; valid review-required work routes deterministically to PR. | Integrated route fixtures |
| AC-RP06-009 | Agent direct-main is unreachable and candidate work remains preserved when publication blocks. | Route reachability and preservation proof |
| AC-RP06-010 | Optional provider worker owns no canonical state/policy and cannot mint or widen an operation. | FD-007 permissions and duplicate/lost/delayed worker tests |
| AC-RP06-011 | Provider rules, check producers, Apps, permissions, environments, and secret consumers match the declared adapter at implementation and promotion time. | UE-015 redacted provider observation |
| AC-RP06-012 | Normal eligible routes require zero prompts and explain outcome/blocker concisely. | Route UX scenario tests |
| AC-RP06-013 | A current .octon-authored source/generator owns any changed .github projection and retains freshness evidence. | Projection source, digest, and publication receipt |
| AC-RP06-014 | FD-023 specialization passes provider conformance without claiming generic adapter or secondary-provider support. | Specialization conformance receipt consumed by RP-14 |
| AC-RP06-015 | Production autonomous Class B remains disabled until RP-07 and RP-08 exit. | Feature/route enablement negative control |

## Exit Criteria

Exit requires dependency proof, durable encoding and traceability of
settled/retired ROD-002 lineage, ED-004 conformance, PO-FD-007/010/011,
UE-006/015, candidate-immutability, route and provider drift proof, accepted
projection-source disposition, implementation conformance, and drift/churn
review. It does not require another operator vote on the route model.

## Claim Limit

RP-06 proves verification and deterministic routing only. It does not prove
signed retained evidence, recovery, trust activation, generic provider
replacement, or a support claim.
