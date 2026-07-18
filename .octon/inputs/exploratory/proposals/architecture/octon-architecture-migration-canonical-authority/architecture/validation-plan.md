# Validation Plan

| Proof | Method | Evidence classification before/after | Retained result |
| --- | --- | --- | --- |
| Closed candidate-spawn census | immutable-tree discovery plus `validate-authorization-boundary-coverage.sh` | `STATICALLY_INSPECTED` design → exact-commit `STATICALLY_INSPECTED` implementation | all 919 launcher keys partitioned; four candidate seams mapped to one consuming guard; zero unowned raw candidate spawn paths |
| Candidate guard dominance | four in-module dynamic suites plus authorization positive/negative/material-effect fixtures | `UNVERIFIED` → `DYNAMICALLY_EXECUTED` / `ADVERSARIALLY_TESTED` | every census seam launches only after one same-path guard consumption; injected raw or unguarded candidate spawn is rejected |
| Scope matrix | adversarial test | `UNVERIFIED` → `ADVERSARIALLY_TESTED` | boundary cases for paths, refs, URIs, repos, actors, and capabilities |
| Substitution/revocation matrix | adversarial test | `UNVERIFIED` → `ADVERSARIALLY_TESTED` | wrong binary/config/policy/candidate/Harness/epoch/receipt denials |
| One-shot guard | dynamic execution and fault injection | `UNVERIFIED` → `DYNAMICALLY_EXECUTED` / `ADVERSARIALLY_TESTED` | N-way and crash-point consumption receipts |
| SI-01 operability | dynamic execution | `UNVERIFIED` → `DYNAMICALLY_EXECUTED` | guarded non-privileged launch and zero routine prompt record |

Run proposal structural, architecture, implementation-readiness, authority
coverage, execution-governance, and packet-owned test validators. Planned tests
are not evidence until executed against the exact implementation commit.

Proposal acceptance authorizes creation of that exact implementation candidate;
it does not claim the implementation checks passed. UE-001/UE-002 become
mandatory after authorization and block implementation completion, conformance,
cutover, and promotion until their retained exact-commit evidence passes.

Publication-scope fixtures substitute wrong issuer, repository, source
identity/ref, `S`, target ref, `O`, route-policy digest, operation, expiry,
revocation epoch, and consequence scope. Every mismatch denies before T1.
