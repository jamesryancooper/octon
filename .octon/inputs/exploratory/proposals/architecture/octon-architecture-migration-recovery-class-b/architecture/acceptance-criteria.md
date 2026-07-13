# Acceptance Criteria

RP-08 exits only when every criterion is proven at an exact commit under the
packet evidence root.

## Ownership And State

- **RP08-AC-001 — Frozen ownership.** RP-08 changes no RP-03 schema/transition/
  writer semantics, RP-05 effect primitive, RP-06 predicate/verdict, or RP-07
  signature/head policy; every consumed interface binds an exact digest.
- **RP08-AC-002 — One behavior.** One provider outcome classifier/reconciler and
  one honest outcome vocabulary are live; no shell retry or parallel canonical
  effect state remains.

## Class Routes

- **RP08-AC-003 — Route matrix.** Representative Class A and admitted Class B
  work completes or routes deterministically without routine prompts; Class C
  and lower-route/downgrade/ambiguity attacks deny.
- **RP08-AC-004 — Predicate immutability.** Proof reproduces the exact RP-06
  predicate/version/digest before and after; no metric-driven policy mutation
  occurs.
- **RP08-AC-005 — PR fallback.** Valid-but-no-PR-ineligible Class B preserves the
  exact candidate and opens/updates a protected PR automatically; invalid,
  stale, revoked, raced, or mismatched authority denies instead of PR routing.

## Effect Recovery

- **RP08-AC-006 — T1 before send.** Kill before/after every T1/outbox boundary
  proves no provider call occurs without durable `ATTEMPTING`, idempotency,
  authority consumption, and terminal reserve.
- **RP08-AC-007 — No retry while unknown.** Lost/timeout/crash/duplicate response
  leaves `UNKNOWN` and restart reconciles before any new attempt; blind resend
  is unreachable.
- **RP08-AC-008 — Honest attribution.** Attempt-bound authenticated receipt may
  yield `attempt_performed`; exact state without causal proof yields
  `state_satisfied`; conflicts exhaust to `manual_intervention`, never an
  inflated claim.
- **RP08-AC-009 — Race and concurrency.** Expected-old mismatch, target race,
  concurrent actor, duplicate broker delivery, and duplicate reconciler cannot
  duplicate effect or overwrite a stronger observation.
- **RP08-AC-010 — Per-attempt terminality.** Every operation/attempt reaches an
  honest terminal or `manual_intervention`; no universal run terminality or
  exactly-once claim is emitted.

## Degraded Mode And UX

- **RP08-AC-011 — Narrow outage.** Provider/broker/verifier/store/signer/evidence
  outages block only affected consequences, preserve candidate/Class A state,
  and expose no ambient credential or unsafe fallback.
- **RP08-AC-012 — Automatic recovery.** Admitted broker restart/reconnect/status
  recovery completes within five seconds with zero operator steps and resumes
  reconciliation before work.
- **RP08-AC-013 — Concise status.** One screen shows class/route digest,
  operation/attempt, attribution, unknown/reconcile state, dependencies,
  preserved work, next automatic action, or one ROD-002 action with freshness
  and non-authority labeling.

## SI-06 Continuous Vertical

- **RP08-AC-014 — Scheduled maintenance.** One bounded scheduled maintenance
  run uses existing mission/Run Contract machinery, respects concurrency/time/
  probe budgets, and closes without an infinite loop or new scheduler.
- **RP08-AC-015 — Reversible scratch effect.** One non-production expected-old
  effect completes, reconciles, and reverses through the same contracts; faults
  at send/T2/reversal preserve an honest outcome.
- **RP08-AC-016 — Zero-prompt proof.** The canonical A/B/C and failure matrix
  produces zero routine A/B prompts, zero unauthorized effects, deterministic
  PR fallback, and one concise notification only for configured irreducible
  ambiguity.
- **RP08-AC-017 — SI-06 rollback.** Disabling Class B preserves candidates and
  signed evidence and uses protected PR; signing, authority, and store
  boundaries remain intact.

## Gates

- **RP08-AC-018 — Policy/evidence closure.** Settled/retired ROD-002 lineage is
  traceably encoded in the immutable policy without another operator vote;
  UE-004 and UE-007 pass. UE-014 is handed to RP-14 as a cross-owned integrated
  gate.
- **RP08-AC-019 — Lifecycle receipts.** Accepted review and strict architecture
  review precede implementation; completeness, conformance, and drift/churn
  pass before closeout.
