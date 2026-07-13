# Validation Plan

| Proof | Method | Evidence classification before/after | Retained result |
| --- | --- | --- | --- |
| Evaluator and spawn census | static inspection plus executable call-graph fixture | `UNVERIFIED` → `STATICALLY_INSPECTED` | exact source identity and uncovered-path report |
| Scope matrix | adversarial test | `UNVERIFIED` → `ADVERSARIALLY_TESTED` | boundary cases for paths, refs, URIs, repos, actors, and capabilities |
| Substitution/revocation matrix | adversarial test | `UNVERIFIED` → `ADVERSARIALLY_TESTED` | wrong binary/config/policy/candidate/Harness/epoch/receipt denials |
| One-shot guard | dynamic execution and fault injection | `UNVERIFIED` → `DYNAMICALLY_EXECUTED` / `ADVERSARIALLY_TESTED` | N-way and crash-point consumption receipts |
| SI-01 operability | dynamic execution | `UNVERIFIED` → `DYNAMICALLY_EXECUTED` | guarded non-privileged launch and zero routine prompt record |

Run proposal structural, architecture, implementation-readiness, authority
coverage, execution-governance, and packet-owned test validators. Planned tests
are not evidence until executed against the exact implementation commit.

Publication-scope fixtures substitute wrong issuer, repository, source
identity/ref, `S`, target ref, `O`, route-policy digest, operation, expiry,
revocation epoch, and consequence scope. Every mismatch denies before T1.
