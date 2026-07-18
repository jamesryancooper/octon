# Packet Sequence

```text
RP-00 → RP-01, RP-02
RP-01 → RP-03, RP-10
RP-01 + RP-02 + RP-03 → RP-04
RP-04 → RP-05
RP-01 + RP-03 + RP-05 → RP-06
RP-03 + RP-04 + RP-06 → RP-07
RP-06 + RP-07 → RP-08
RP-06 + RP-07 + RP-08 → RP-09
RP-01 + RP-02 + RP-10 → RP-11
RP-07 + RP-11 → RP-12
RP-08 + RP-11 → RP-13
RP-08 + RP-09 + RP-10 + RP-11 → RP-14 core proof
RP-12 + RP-13 → RP-14 optional-claim proof and full program closeout
```

## Exact Child IDs

- RP-00 `octon-architecture-migration-containment`
- RP-01 `octon-architecture-migration-canonical-authority`
- RP-02 `octon-architecture-migration-candidate-isolation`
- RP-03 `octon-architecture-migration-transactional-runtime-store`
- RP-04 `octon-architecture-migration-local-broker`
- RP-05 `octon-architecture-migration-sanitized-git`
- RP-06 `octon-architecture-migration-verification-publication`
- RP-07 `octon-architecture-migration-signed-evidence`
- RP-08 `octon-architecture-migration-recovery-class-b`
- RP-09 `octon-architecture-migration-self-development-trust-activation`
- RP-10 `octon-architecture-migration-workspace-projects`
- RP-11 `octon-architecture-migration-harness-factory`
- RP-12 `octon-architecture-migration-extension-supply-chain`
- RP-13 `octon-architecture-migration-bounded-child-agents`
- RP-14 `octon-architecture-migration-solo-dogfood-promotion`

RP-01 freezes authority/guard semantics before RP-03 changes persistence; they
must not mutate that interface concurrently. RP-01/RP-02 remain DAG peers after
RP-00, but their exact `lifecycle_executor/src/codex.rs` contributions serialize
under the program integration lock with RP-01 guard invocation first, then RP-02
isolation; RP-11 integrates its adapter/Harness slice only after both. All other
module-disjoint RP-01/RP-02 work may proceed in parallel. The RP-10/RP-11 non-authority product branch may proceed alongside
the broker spine after dependencies. RP-07 authenticity/capacity precedes RP-08
terminal recovery claims. RP-12 and RP-13 remain distinct children. The graph is
gated-parallel, not optimistic parallel execution.

The graph is unchanged by the brokered no-PR revision. RP-00 containment leaves
eligible no-PR work classified, blocked, and preserved. Production
`brokered-class-b-no-pr` cannot enable until RP-05, RP-06, RP-07, and RP-08 each
exit their own gates. Stable pre-route contention may deterministically select
PR; an actual expected-old collision, `ATTEMPTING`, or `UNKNOWN` cannot switch an
attempt to PR and requires reconciliation or a fresh tuple before any new route.
