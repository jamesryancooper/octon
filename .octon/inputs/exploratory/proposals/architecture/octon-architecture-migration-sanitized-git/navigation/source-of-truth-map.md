# Proposal Reading And Precedence Map

## Authority Boundary

This packet is non-authoritative. Current constitutional, product, execution,
runtime, and provider governance outrank it. Reconciliation artifacts are
controlling planning input only and cannot authorize implementation.

## External Sources

| Concern | Durable source | RP-05 use |
| --- | --- | --- |
| Constitutional authority and fail-closed posture | .octon/framework/constitution/ | Must not be widened |
| Change route authority | .octon/framework/product/contracts/default-work-unit.yml | Consumed; owned outside RP-05 |
| Git and worktree contract | .octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml | RP-05 updates only Git primitive boundaries |
| Authorized effect types | .octon/framework/engine/runtime/crates/authorized_effects/ | Narrow Git request/result typing |
| Side-effect inventory and coverage | .octon/framework/engine/runtime/spec/material-side-effect-inventory.yml and authorization-boundary-coverage.yml | Register broker-only effect path |
| Broker core, IPC, credentials, store writer | RP-04 durable implementation | Frozen dependency; not RP-05-owned |
| Verification and publication route | RP-06 durable implementation | Separate consumer; not RP-05-owned |
| Retained proof | .octon/state/evidence/validation/proposals/octon-architecture-migration-sanitized-git/ | Child-owned evidence only |

## Proposal-Local Precedence

1. proposal.yml
2. architecture-proposal.yml
3. resources/packet-contract.yml
4. architecture/target-architecture.md
5. architecture/acceptance-criteria.md
6. architecture/implementation-plan.md
7. architecture/file-change-map.md
8. architecture/validation-plan.md
9. architecture/cutover-plan.md
10. architecture/rollback-and-recovery.md
11. architecture/operator-experience-and-disclosure.md
12. resources/traceability.yml
13. navigation/artifact-catalog.md
14. README.md

## Ownership Map

| Topic | Normal owner |
| --- | --- |
| Broker Git request/result contract | RP-05 |
| Candidate-object transfer contract | RP-05 |
| Git command/config/environment/transport allowlist | RP-05 |
| Expected-old fast-forward implementation | RP-05 |
| Grant or operation authority | RP-01/RP-03/RP-04 |
| Credential custody and broker supervision | RP-04 |
| Verifier identity and exact-SHA verdict | RP-06 |
| A/B/C and Class-B/PR predicate | RP-06 |
| Provider outcome classification and unknown reconciliation | RP-08 |
| Final support claim | RP-14 |

## Projections And Evidence

- .github/** is an affected host projection family, never an RP-05 promotion
  target.
- Generated proposal registry content remains discovery-only and is not edited
  by this child.
- Provider observations and scratch effects are retained evidence, not
  authority.
- Parent summaries may cite child proof but never satisfy child gates.

## Conflict Rule

If implementation requires RP-05 to modify broker authority, store semantics,
verification policy, support admission, or a non-.octon target, stop and route
the change to its owning packet. Do not widen this packet or create a second
control plane.
