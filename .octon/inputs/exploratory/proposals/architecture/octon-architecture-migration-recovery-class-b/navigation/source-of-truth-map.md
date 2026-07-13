# Proposal Reading and Precedence Map

## Authority Boundary

Current canonical repository authority outranks this proposal. The intake
controls accepted operator-intent lineage while remaining non-authoritative
pending promotion; reconciliation controls the RP-08 packet boundary,
engineering refinement, and proof sequence without reopening accepted intent.
RP-08 may classify observations and drive only transitions already authorized
by the frozen authority, store, route, signer, and provider contracts. It cannot
mint authority, change risk class, widen a route, or turn an observation into
policy.

## External Sources

| Concern | Source | Role |
| --- | --- | --- |
| Constitutional authority | `.octon/framework/constitution/**` and `.octon/instance/**` | Governs authority, evidence, ownership, topology, and policy. |
| Proposal lifecycle | `.octon/inputs/exploratory/proposals/README.md` and proposal standards | Governs packet shape and lifecycle. |
| Reconciled packet boundary | Reconciliation `reconciled-proposal-packet-map.yml` RP-08 and `safe-intermediate-states.md` SI-06 | Controls scope, safe state, proof, and exclusions. |
| Reconciled requirements | FD-002/012/016, RF-011/018/026/028, PO-FD-002/012/016, UE-004/007, ROD-002, ED-003 | Controls traceability and future gates. |
| Frozen dependencies | RP-03 T1/external/T2 API, RP-06 class/route predicate and verdict, RP-07 signed evidence/head/reserve | Inputs that RP-08 consumes and cannot redefine. |

## Proposal-Local Precedence

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/packet-contract.yml`
4. `resources/traceability.yml`
5. `architecture/target-architecture.md`
6. `architecture/acceptance-criteria.md`
7. `architecture/implementation-plan.md`
8. remaining architecture and navigation documents
9. `README.md`

## Planned Durable Ownership

| Concern | Planned owner | Boundary |
| --- | --- | --- |
| SQL operation/attempt schema, T1/T2 transitions, outbox, idempotency, capacity | RP-03 | RP-08 calls frozen APIs; no schema, transition, writer, or `runtime_bus` redefinition. |
| Expected-old fast-forward effect and provider observation primitive | RP-05 under ED-003 | RP-08 consumes observation/receipt and owns classification/reconciliation only. |
| Immutable A/B/C and B/no-PR-versus-protected-PR predicate | RP-06 | RP-08 binds exact predicate/version digest and cannot modify or reinterpret it during proof. |
| Signed observations/checkpoints/head/reserve/completeness | RP-07 | RP-08 verifies/consumes; no unsigned fallback or signature reinterpretation. |
| Provider-specific result classification and `UNKNOWN` reconciler | RP-08 | Observes exact provider state/receipts and selects only legal RP-03 transitions. |
| Conditional cleanup lifecycle, eligibility, status, and recovery | RP-08 | Consumes RP-06 route-specific landed facts and RP-05 expected-tip primitive; never deletes closed-unmerged work. |
| Local-main mirror result classification | RP-08 | RP-06 owns orchestration; local main remains non-authoritative. |
| `attempt_performed`, `state_satisfied`, `not_performed`, `failed`, `unknown`, `manual_intervention` semantics | RP-08 | Claims remain evidence-strength honest; no universal exactly-once. |
| Run status and continuous-operation policy | RP-08 | Read model is non-authoritative; schedules only bounded mission/run contracts through existing routes. |
| Trust-root activation | RP-09 | Explicitly excluded from RP-08 and SI-06. |
| Complete two-project/30-day product proof | RP-14 | UE-014 remains cross-referenced, not closed by RP-08 component proof. |

## Frozen Route Rule

RP-08 reproduces the exact RP-06 predicate digest in every route result. Class A
continues autonomously within its admitted boundary; admitted Class B uses the
brokered automatic route or deterministic protected PR; Class C never takes a
lower route. Only a stable pre-effect review/high-contention predicate selects
PR. Invalid, stale, revoked, raced, mismatched, collided, `ATTEMPTING`, or
`UNKNOWN` authority/effects deny or reconcile; the frozen attempt cannot switch
route and any new attempt requires fresh authority.

## Operational Surfaces

- provider probes and signed observations are evidence, not authority;
- generated run-health views are non-authoritative status projections and must
  source-link to RP-03/RP-06/RP-07 records;
- mission scheduling/continuation does not replace Run Contracts or authorize
  material effects;
- `.octon/generated/proposals/registry.yml` is left to parent integration; and
- retained proof belongs at
  `.octon/state/evidence/validation/proposals/octon-architecture-migration-recovery-class-b/`.

## Conflict Rule

If provider state, authenticated receipt, RP-03 operation state, RP-06 route
digest, or RP-07 signed head/completeness disagree, the operation remains
`UNKNOWN` or becomes honest `manual_intervention`. It is never retried, marked
performed, routed to PR, or published through a broader interpretation.
