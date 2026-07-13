# Proposal Reading And Precedence Map

## Authority Boundary

Current constitutional, product, run-specific, and provider governance
outrank this proposal. The intake controls accepted operator-intent lineage
while remaining non-authoritative pending promotion; reconciliation controls
the RP-06 packet boundary, engineering refinement, and proof sequence without
reopening accepted intent. This packet cannot issue authority, perform effects,
or admit support.

## External Sources

| Concern | Durable source | RP-06 use |
| --- | --- | --- |
| Execution authority | RP-01 authority interface and current execution authorization contracts | Consumed without widening |
| Operation and attempt state | RP-03 transactional API | Consumed without schema ownership |
| Git effect | RP-05 broker Git adapter | Consumed; no Git credential in verifier |
| Change route authority | .octon/framework/product/contracts/default-work-unit.yml | Consumed; route semantics projected through packet-owned immutable policy |
| Host adapter | .octon/framework/engine/runtime/adapters/host/github-control-plane.yml | RP-06 specialization owner |
| Support declarations | .octon/instance/governance/support-targets.yml | Consumed; final admission belongs to RP-14 |
| Retained child proof | .octon/state/evidence/validation/proposals/octon-architecture-migration-verification-publication/ | Child-owned evidence only |

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
| Verifier identity/version and verdict contract | RP-06 |
| A/B/C and Class-B/PR predicate digest | RP-06 |
| Provider verification/publication specialization | RP-06 |
| Authenticated check binding and route UX | RP-06 |
| Generic executor adapter | RP-11 |
| Authority issuance | RP-01 |
| Attempt persistence | RP-03 |
| Git effect and provider credential | RP-04/RP-05 |
| Outcome reconciliation | RP-08 |
| Trust activation | RP-09 |
| Final provider/support claim | RP-14 |

## Projection Boundary

- .github/** is an affected repo-local host projection family, not an
  octon-internal target.
- Before any workflow projection changes, an accepted .octon-authored source
  or generator must own templates, source digests, publication receipts, and
  drift validation.
- If that source/generator cannot be established within declared .octon
  targets, implementation remains blocked by target-family split.
- Generated outputs and host checks never become authority.

## Conflict Rule

Stop if implementation would give the verifier a mutation credential, let the
publisher issue its own verdict, modify RP-05 Git semantics, change RP-03
transitions, widen support, or directly target .github. Route the change to its
owner rather than adding another verifier, publisher, or control plane.
