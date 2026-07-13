# Target Architecture

## Decision

Octon will implement SI-06 as one recoverable Class B behavior over frozen
dependency contracts. RP-08 owns provider-specific observation classification,
unknown-outcome reconciliation, honest effect-attempt outcomes, concise run
status, continuous-operation policy, scheduled maintenance, and one bounded
reversible scratch effect. It does not own authorization, class policy, store
schema/transitions, effect execution, signatures, or trust-root activation.

## Frozen Inputs

- **RP-03:** one canonical SQLite/WAL operation record and APIs for T1
  reserve/consume/`ATTEMPTING` plus outbox, and T2 result/`UNKNOWN`/terminal
  transition. SQLite is not atomic with an external provider.
- **RP-05 / ED-003:** broker-only single-repository atomic expected-old
  fast-forward primitive, provider observation, and authenticated operation
  receipt when the provider supports it.
- **RP-06:** immutable exact-digest A/B/C and Class B no-PR/protected-PR
  predicate, exact-SHA verdict, revocation/expiry/race rules, and publication
  route.
- **RP-07:** signed observations/checkpoints, current monotonic head, terminal
  reserve, completeness, and degraded evidence state.

Every RP-08 decision record binds the exact versions/digests of these inputs.
Changed or missing inputs deny; they are never refreshed mid-attempt.

## Class And Route Behavior

| Class / condition | Behavior | Prompt posture |
| --- | --- | --- |
| Admitted Class A | Complete autonomously inside the declared safe local boundary. | No routine prompt. |
| Eligible admitted Class B | T1, broker effect, T2/reconciliation, signed verdict, automatic no-PR publication. | No routine prompt. |
| Valid Class B not eligible for no-PR | Deterministic protected PR using the frozen RP-06 predicate; preserve exact candidate. | No routine prompt unless the effect state is irreducibly ambiguous under the settled ROD-002 rule. |
| Class C | Require its stronger authorized route; lower-route/no-PR downgrade denies. | Only the stronger route's explicit authority process. |
| Invalid, stale, revoked, raced, wrong-target, or mismatched authority | Deny and require fresh authorization. Never convert to PR. | One actionable denial, not approval laundering. |

RP-08 reproduces the frozen predicate digest and result; it does not tune the
predicate to improve metrics.

## Attempt And Reconciliation State Machine

### T1 Before External Send

RP-03 atomically verifies/reserves the operation and idempotency identity,
consumes the single-use authority as defined there, reserves terminal evidence,
records `ATTEMPTING`, and emits the exact outbox request. If T1 does not commit,
the broker is not called.

### External Call

The broker receives an exact one-shot handle and performs the RP-05 provider
primitive. RP-08 never receives credentials. The signed observation includes
repository, ref, expected-old, desired-new, operation/attempt/idempotency ids,
provider request/receipt id when available, and response class.

### T2 After Call

RP-08 classifies the direct result and asks RP-03 to record one of:

- `attempt_performed`: authenticated provider evidence binds this attempt to
  the committed desired effect;
- `state_satisfied`: exact desired state is observed, but causation by this
  attempt is not proved; do not retry and do not claim performance;
- `not_performed`: provider evidence proves no effect occurred and retry may be
  considered only through a fresh authorized attempt;
- `failed`: provider produced a definitive attempt-bound failure with no
  ambiguous remote effect;
- `unknown`: response/receipt/observation cannot establish a safe terminal;
  or
- `manual_intervention`: bounded automated probes are exhausted or observations
  conflict, and one operator judgment is required.

Terminality is per operation/attempt, not a universal run effect state.

### Restart And Unknown Reconciliation

Startup and scheduled reconciliation scan every `ATTEMPTING` and `UNKNOWN`
operation before accepting a retry for the same idempotency scope. Each provider
reconciler uses bounded, read-only, authenticated probes against the exact
repository/ref/expected-old/desired-new/operation identity:

1. validate current RP-06 route/verdict and RP-07 signed-head/completeness;
2. fetch authenticated operation receipt/audit identity when available;
3. observe exact current provider state and target preconditions;
4. classify evidence strength without inferring causation from equality;
5. record a legal T2 outcome through RP-03; and
6. retry only if `not_performed` is proved and fresh authority admits a new
   attempt.

A lost response followed by desired state yields `attempt_performed` only with
an attempt-bound receipt/audit identity. Otherwise it yields
`state_satisfied`. A divergent state, concurrent actor, target race, or
conflicting receipt ends `manual_intervention` unless the provider evidence
proves a safer terminal. Blind resend is prohibited.

## Deterministic Protected-PR Fallback

Protected PR is a route for valid work that the immutable RP-06 predicate says
is ineligible for automatic no-PR landing. It uses the same exact candidate,
verdict, signed evidence, and target state. It does not repair invalid authority,
weaken class, obscure `UNKNOWN`, or treat PR creation as effect success. If PR
creation itself becomes unknown, it uses the same reconciliation rules.

## Narrow Degraded Operation

Failure blocks only what depends on it:

- provider/broker outage: preserve candidate and T1/outbox; reconcile on
  automatic recovery before retry;
- verifier outage: preserve candidate/effect evidence; block verdict-dependent
  publication;
- signer/evidence/head/reserve outage: follow RP-07 and block evidence-dependent
  effect/success while preserving candidate and raw evidence;
- store outage: stop new consequential transitions; safe already-complete Class
  A work may remain visible but cannot manufacture durable effect state;
- PR/no-PR publication outage: preserve exact candidate and verdict; resume
  through the same frozen route; and
- irreducible ambiguity: emit `manual_intervention` with one concise choice and
  no ambient credentials.

Automatic broker restart/reconnect/reconciliation targets restoration within
five seconds for the admitted local support tuple, with zero operator steps.
No fallback exposes credentials to candidates or restores unsanitized Git,
unsigned evidence, YAML authority, or candidate-controlled verification.

## Run Status

One non-authoritative read model derives from canonical refs/digests and shows:

- class and frozen route/predicate digest;
- operation/attempt/idempotency identity and state;
- `ATTEMPTING`, `UNKNOWN`, reconciling, terminal, or
  `manual_intervention` status;
- attribution strength (`attempt_performed`, `state_satisfied`, or none);
- verifier/signature/head/reserve/provider health;
- candidate preservation and current publication/PR route;
- next automatic action, bounded retry/probe budget, or one operator action;
  and
- source freshness and explicit non-authority label.

Healthy and automatically recovering states generate no routine prompt.

## Continuous Operation And Proof Vertical

RP-08 reuses mission queue/continuation and Run Contracts; it adds no scheduler
or infinite agent loop. `continuous-operation.yml` defines bounded maintenance
windows, concurrency, probe/retry budgets, pause/revoke behavior, status, and
closeout. Every scheduled item creates/adopts a normal governed run.

The proof vertical contains:

- a representative immutable A/B/C route matrix;
- scheduled read-only maintenance through existing mission machinery; and
- one bounded reversible external effect against a disposable scratch provider
  target, with exact expected-old/desired-new and automatic rollback.

Production targets and trust-root activation are prohibited. RP-14 later
replays this component with two projects and 30-day burden/product budgets.

## SI-06 Boundary

Entry is SI-05 plus RP-07 signed evidence/capacity/retention. Required proof is
unknown reconciliation, target-race/duplicate/lost-response/provider-outage/
broker-crash handling, deterministic PR escalation, and zero routine prompts.
Only admitted Class B inside the proved tuple is permitted. Trust-root
automation and broader support claims are prohibited. Rollback disables Class B,
preserves work, and uses protected PR without disabling signing while claiming
autonomous success.

## Simplicity Constraints

One credentialless `effect_reconciler` library consumes existing store/broker/verifier/evidence
interfaces. It cannot open broker credentials, dispatch effects, or become a
second runtime-store writer. Mission continuation schedules bounded governed runs; run-health
generation remains a projection. No scheduler, store, policy engine, credential
service, or generic workflow platform is added.
