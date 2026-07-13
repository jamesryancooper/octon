# Validation Plan

## Draft Packet Checks

Run base, architecture, implementation-readiness, and draft review-gate
validators. Draft structural pass is expected; implementation authorization
must remain blocked.

## Static And Contract Checks

- validate effect-reconciliation, run-lifecycle, mission/continuous-operation,
  run-health, and registry contracts;
- prove RP-08 source does not define RP-03 transitions/schema, RP-05 effect,
  RP-06 predicate, or RP-07 signature policy;
- compare frozen predicate/version/digest before/after every test;
- scan for direct provider calls, blind retries, ambient credentials, universal
  `exactly once`, PR laundering, generated status authority, and infinite loops;
- require every provider probe/outcome/status field to source-link canonical
  operation, route, and signed evidence.

## PO-FD-002 / PG-08-CLASS-ROUTES

Run at least 20 deterministic A/B/C route fixtures covering safe local A,
eligible B no-PR, valid B protected PR, C stronger route, protected/trust
scope, ambiguity, stale/revoked/raced/mismatched authority, predicate drift,
and duplicate context. Assert:

- all routine admitted A/B routes require zero operator prompts;
- every C/lower-route and invalid-authority downgrade denies;
- valid PR fallback preserves exact candidate/verdict/evidence;
- invalid authority never becomes a PR;
- no unauthorized effect occurs; and
- result records reproduce the exact frozen predicate digest.

## PO-FD-012 / PG-08-EFFECT-RECOVERY

For each T1/outbox/send/provider/T2/checkpoint boundary, kill before/during/after
and restart. Add lost response, duplicate delivery/response, timeout, target
race, concurrent actor, expected-old mismatch, provider receipt present/absent,
broker restart, DB busy/restart, and PR-create unknown fixtures. Assert:

- no send without committed T1;
- no retry while `ATTEMPTING`/`UNKNOWN`;
- duplicate reconcilers/deliveries are idempotent;
- attempt-bound receipt may prove `attempt_performed`;
- desired state without causation yields only `state_satisfied`;
- proved no-effect may allow a fresh separately authorized attempt;
- conflicts exhaust to honest `manual_intervention`; and
- terminal/manual-intervention evidence remains signed and complete.

This closes the RP-08 portions of UE-004 and UE-007 only through retained
scratch-provider evidence.

## PO-FD-016 / PG-08-DEGRADED-MODE

Independently fail provider, broker IPC/process, credential access, verifier,
RP-03 store, RP-07 signer/head/reserve/evidence, run-health projection, and
PR/no-PR publication. Assert each failure:

- blocks only the affected consequence;
- preserves candidate, safe Class A state, operation intent, and signed evidence;
- exposes no credential or ambient provider path;
- recovers/reconciles before retry;
- gives one concise reason/next action; and
- never restores YAML/log-only/unsanitized/unsigned/candidate-verifier paths.

Measure admitted broker restart/reconnect/reconcile status within five seconds
and zero operator steps.

## SI-06 And Continuous Operation

- run scheduled maintenance via existing mission/Run Contract machinery under
  bounded time/concurrency/probe budgets;
- run and reverse one expected-old scratch effect;
- inject failures during schedule, send, T2, reconcile, closeout, and reverse;
- assert no production/trust-root target and no infinite agent loop;
- capture prompt count, PR fallback, recovery time, mediation time, candidate
  preservation, and operator intervention; and
- package but do not claim RP-14 UE-014 two-project/30-day product results.

## Status And UX

Snapshot healthy, attempting, unknown, reconciling, state-satisfied,
attempt-performed, protected-PR, degraded, and manual-intervention views. Verify
one-screen readability, source digest/freshness, non-authority label, preserved
work, next automatic action, and exactly one actionable operator choice only at
an irreducibly ambiguous effect state under the settled ROD-002 rule.

## Retained Evidence

Retain exact commit, dependency/predicate digests, support tuple, commands,
fixtures, fault points, transitions, provider observations/receipts, signed
checkpoints, route/prompt/unauthorized-effect metrics, status snapshots,
scheduled/reversible-effect receipts, rollback rehearsal, and explicit
limitations under the packet evidence root. Use only disposable provider targets.
