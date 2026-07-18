# Recovery, Reconciliation, and Complete Class B Vertical

This is the accepted RP-08 architecture proposal for
`octon-architecture-migration-recovery-class-b`. It is a temporary,
non-authoritative implementation aid. It does not authorize effects,
publication, policy changes, support promotion, scheduling, or implementation.

## Outcome

Octon gains one recoverable provider-effect behavior over interfaces owned by
earlier packets:

- RP-03's frozen T1/external/T2 API durably records `ATTEMPTING` before send and
  `RESULT` or `UNKNOWN` afterward;
- RP-08 classifies provider-specific observations and reconciles every
  `UNKNOWN` before any retry;
- outcomes distinguish `attempt_performed`, `state_satisfied`,
  `not_performed`, `failed`, `unknown`, and honest `manual_intervention`;
- RP-06's immutable Class A/B/C and B/no-PR-versus-PR predicate is consumed by
  exact digest and never changed during proof;
- outages block only affected consequences while preserving candidate work,
  signed evidence, and safe Class A progress; and
- one concise status surface, scheduled maintenance run, and bounded reversible
  scratch effect prove the SI-06 Class B vertical without routine prompts.

SQLite is not claimed atomic with Git/GitHub. There is no blind retry,
universal exactly-once claim, policy mutation, ambient credential fallback, or
trust-root automation.

## Program Position

- logical packet: `RP-08`
- workgroup: `RWG-08`
- parent program: `octon-architecture-migration-program`
- dependencies: RP-06 verification/publication and RP-07 signed evidence
- transitive consumed interface: RP-03 transactional T1/external/T2 state
- downstream consumer: RP-09 self-development/trust activation; RP-14
  independently replays the complete solo vertical

RP-05 supplies the ED-003 expected-old fast-forward/provider observation
primitive, but is not a direct DAG dependency. RP-08 owns provider-specific
outcome classification, reconciliation, operation terminal/manual-intervention
semantics, route-freeze enforcement, conditional cleanup lifecycle/status, run
status, continuous-operation policy, and vertical proof.

The route freezes before effect. An operation already `ATTEMPTING` or `UNKNOWN`
cannot switch to PR. Expected-old/base/head mismatch invalidates the tuple and
requires fresh authority; only stable pre-route contention or a valid review
predicate may select PR. Every failed, denied, collided, unknown, unmerged, or
cleanup-deferred outcome preserves the exact candidate.

## Promotion Scope

The proposal is `octon-internal`; every promotion target is under
`.octon/**`. Provider state, run-health views, and signed observations are
evidence/projections, not authority. The immutable RP-06 predicate remains the
only class/route policy source.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `resources/packet-contract.yml`
5. `resources/traceability.yml`
6. `architecture/current-state-gap-map.md`
7. `architecture/target-architecture.md`
8. `architecture/file-change-map.md`
9. `architecture/cutover-plan.md`
10. `architecture/rollback-plan.md`
11. `architecture/acceptance-criteria.md`
12. `architecture/validation-plan.md`
13. `architecture/implementation-plan.md`
14. `architecture/operator-disclosure.md`
15. `support/implementation-grade-completeness-review.md`

## Current Gate

The accepted packet's exact design receipt freezes accepted
dependency digests, provider/observation/probe/budget mechanisms, and the
proposal-level ROD-002 encoding without reopening operator intent. UE-004/007
remain post-implementation activation proof, and UE-014 remains RP-14-owned.
Independent proposal and architecture re-review pass at the accepted digest.
