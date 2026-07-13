# Implementation Plan

Advisory until accepted review, durable encoding of settled/retired ROD-002
lineage, strict architecture review, and exact dependency exits.

## Workstream 1 — Freeze Inputs And Decisions

1. Record exact RP-03/RP-05/RP-06/RP-07 interface/version/digests.
2. Encode the accepted ROD-002 irreducible-ambiguity-only notification/manual-
   intervention rule without modifying the RP-06 class/route predicate or
   requesting another operator vote.
3. Apply ED-003: atomic expected-old provider operation, authenticated receipt
   when available, explicit attribution semantics, targeted scratch proof.
4. Inventory every effect retry, post-effect check, PR fallback, status, mission
   schedule, and direct provider probe at the implementation commit.

## Workstream 2 — Contracts And Reconciler

1. Define strict provider observation/classification/reconciliation contract.
2. Add the credentialless `effect_reconciler` library with provider adapter trait, bounded probes,
   classification precedence, idempotent restart scan, and legal RP-03 calls.
3. Encode outcomes `attempt_performed`, `state_satisfied`, `not_performed`,
   `failed`, `unknown`, and `manual_intervention` with evidence-strength rules.
4. Deny retry unless reconciliation proves `not_performed` and fresh authority
   admits a new attempt.

## Workstream 3 — Route And PR Integration

1. Bind immutable RP-06 predicate/verdict digest to run admission, effect, T2,
   status, and closeout.
2. Route eligible B automatically; route valid ineligible B to deterministic
   protected PR with the exact candidate/verdict/evidence.
3. Deny C downgrade and invalid/stale/revoked/raced/mismatched authority; never
   launder through PR.
4. Treat unknown PR creation/update as another effect requiring reconciliation.

## Workstream 4 — Status And Degraded Mode

1. Extend run-health schema/generator/validator with class, route digest,
   operation/attempt, attribution, unknown/reconciling/manual-intervention,
   dependency health, preserved work, and next action.
2. Implement automatic broker reconnect and restart scan before accepting work.
3. Encode provider/broker/verifier/store/signer/evidence/PR-local degraded
   behavior without ambient credentials or unsafe fallback.
4. Keep status projection freshness-checked and non-authoritative.

## Workstream 5 — Continuous Operation And SI-06 Fixture

1. Define bounded continuous-operation policy over existing mission queue,
   continuation, Run Contracts, revocation, pause, and closeout.
2. Schedule one read-only maintenance job and one reversible scratch provider
   effect; prohibit production and trust-root targets.
3. Bind time/concurrency/probe/retry/evidence budgets and honest closeout.
4. Begin RP-14-compatible metrics for prompt/escalation, recovery, mediation,
   candidate preservation, and operator time without claiming UE-014 closure.

## Workstream 6 — Fault And Route Proof

1. Kill before/after T1, outbox claim, send, provider apply, response, T2, signed
   checkpoint, status, PR creation, and reverse effect.
2. Inject lost/duplicate response, timeout, target race, concurrent actor,
   provider outage, broker crash, verifier/store/signer/evidence failure, and
   stale predicate.
3. Run 20 representative A/B/C route and ambiguity fixtures with prompt and
   unauthorized-effect accounting.
4. Prove rollback, automatic recovery, PR fallback, and no-policy-mutation.

## Workstream 7 — Atomic Activation And Handoff

1. Rehearse on scratch targets with production Class B disabled.
2. Activate the frozen route, reconciler, evidence, and status gates together.
3. Retire direct/blind retry and ambiguous outcome paths.
4. Retain PO-FD-002/012/016 and UE-004/007 evidence; hand SI-06 to RP-09 and
   component/metrics package to RP-14 for UE-014.

## Change Discipline

Any required change to store transitions, provider effect, route predicate, or
signed evidence routes back to its owning packet. Failed provider attribution
proof narrows claims or yields `manual_intervention`; it never justifies a blind
retry or universal exactly-once statement.
