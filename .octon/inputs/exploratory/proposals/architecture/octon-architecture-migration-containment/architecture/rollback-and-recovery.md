# Rollback and Recovery

## Principle

Rollback may undo non-safety wording, inventory formatting, or a faulty
projection update. It may not restore candidate-controlled provider writes,
any Octon-owned human or agent direct-main route, unregistered privilege, or an
overstated claim.

## Prepared Rollback Handles

- immutable pre-cutover snapshots of durable `.octon/**` targets;
- exact provider configuration observation with redaction and freshness;
- preserved candidate branch/commit and protected-PR route;
- per-projection prior revision and owner;
- claim-correction before/after map;
- deterministic inventory and validation commands.

## Recovery by Failure Class

| Failure | Recovery |
| --- | --- |
| Inventory generator or validator defect | Keep privileged routes disabled, restore the prior validator only for diagnosis, repair forward, and do not assert inventory completeness. |
| Protected-PR bridge unavailable | Preserve candidate work, stop privileged implementation, restore service to the bridge through its owner; do not restore direct-main. |
| Provider projection mutation fails partway | Keep all candidate-head writers disabled, observe current provider state, reconcile to the stricter contained posture, and record uncertainty. |
| Claim correction is too narrow | Retain the narrower claim until direct proof supports a governed widening; do not restore unsupported wording. |
| Generated support view is stale | Block publication and regenerate from durable declarations and retained evidence through the owning generator. |
| Burden measurement fails | Record the measurement gap and block the affected baseline claim; do not infer results. |

## Rollback Proof

A disposable drill must show that reverting allowed non-safety changes leaves:

- every Octon-owned human or agent direct-main route unreachable;
- candidate-head privileged writers disabled;
- protected PR available or the route safely stopped;
- candidate work preserved;
- support claims no broader than direct proof;
- one authority source and no new writer/control plane.

If any condition fails, rollback is rejected and recovery proceeds by forward
repair under containment.
