# Rollback And Recovery Plan

## Principle

Rollback disables Class B, preserves candidate work, frozen attempts, and signed
evidence, and uses only a fresh policy-selected protected PR or a prior certified implementation behind the
same authority/store/broker/verifier/signer boundaries. It never restores
blind retry, ambient credentials, unsanitized Git, YAML/log-only authority,
unsigned evidence, candidate-controlled verification, or policy mutation.

## Stage Rollback

| Stage | Safe rollback |
| --- | --- |
| Inert contracts | Remove unactivated entries; no operation state changes. |
| Shadow classifier | Disable shadow reads; retain diagnostics as non-live evidence. |
| Retry-disabled scanner | Keep Class B disabled and preserve unknown operations/candidates for diagnosis. |
| Scratch vertical | Stop scratch route, reconcile every attempted/reversal effect, retain signed proof. |
| Activated | Disable autonomous Class B/no-PR; preserve exact candidates and frozen attempts. A later PR requires a fresh pre-effect decision. |

## Recovery Cases

- Lost/duplicate response: remain `UNKNOWN`; probe exact provider receipt/state
  before any new attempt.
- Target race/concurrent actor: preserve candidate; record
  `state_satisfied` only if exact desired state holds, otherwise
  `manual_intervention`; never change the existing attempt to PR.
- Broker crash: auto-restart, scan T1/outbox/unknown, reconcile before accepting
  effects; never expose credentials to candidate.
- Store outage/corruption: stop consequential transitions and use RP-03
  recovery; no local log substitutes for canonical state.
- Verifier/signer/evidence outage: block dependent publication/success and
  preserve candidate/evidence; do not weaken RP-06/RP-07.
- PR creation/update unknown: reconcile provider PR identity/state before retry;
  do not create duplicates blindly.
- Scheduled/reversal failure: pause mission, reconcile the exact effect, and
  end honestly terminal/manual-intervention.

Mirror or cleanup rollback cannot falsify landed status. Cleanup failure retains
the source candidate and `landed/cleanup-deferred`; a target race requires a new
tuple rather than PR routing.

## ROD-002 Manual Intervention

Only bounded probes exhausted with irreducible conflicting/insufficient
evidence may produce `manual_intervention`. The notification shows exact state,
observations, preserved work, prohibited actions, and one safe choice. Silence
does not authorize retry or success.

## Rehearsal Gate

Inject every T1/send/T2/outbox/receipt/checkpoint/status/PR/reversal fault and
show a verified terminal, preserved unknown/manual-intervention, or safe prior
state. No rollback may disable signing while retaining an autonomous success
claim.
