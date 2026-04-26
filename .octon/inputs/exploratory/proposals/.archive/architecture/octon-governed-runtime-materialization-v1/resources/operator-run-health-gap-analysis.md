# Operator Run-Health Gap Analysis

## Current strength

Octon already has:

- a run lifecycle contract with states such as bound, authorized, running,
  paused, staged, revoked, failed, rolled back, succeeded, denied, and closed;
- canonical run roots for run contracts, manifests, events, runtime state,
  checkpoints, rollback posture, and evidence;
- operator read-model rules that allow generated read models while forbidding
  them from becoming authority.

## Gap

A serious solo operator still needs a compact per-run health answer. Today, the
operator may need to inspect multiple canonical artifacts to understand whether
a run is healthy, blocked, stale, unsupported, revoked, evidence-incomplete, or
ready for closure.

## Proposed health dimensions

| Dimension | Source |
| --- | --- |
| Lifecycle state | run journal and runtime state |
| Objective/run contract | run manifest/contract |
| Support posture | support-envelope reconciliation result |
| Route/capability-pack posture | generated effective route/pack outputs |
| Authorization posture | grant/decision/revocation/approval records |
| Evidence completeness | evidence-store validation |
| Rollback readiness | rollback posture |
| Intervention state | intervention log/runtime state |
| Closure readiness | lifecycle + evidence + disclosure rules |

## Missing vs incomplete

This capability is **incomplete**, not contrary to the architecture. It should be
added as a generated read model because the repository already permits generated
operator read models when they cite sources, mark freshness, and remain
non-authoritative.

## Operator value

Run health is especially valuable for solo builders because it answers "what
should I do next?" without requiring them to become the runtime's detective.
