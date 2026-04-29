# Rollback Plan

## Triggers

- Imported proof used as authority.
- Attestation accepted as approval.
- Generated trust view consumed by runtime or policy.
- Blind `.octon/` copy path detected.
- Support-target claim widened through external proof.
- Runtime authorization bypass.

## Steps

1. Disable v6 CLI trust/compatibility commands.
2. Mark v6 trust policies denied/stage-only.
3. Retain `state/evidence/trust/**` evidence.
4. Remove or stale generated trust projections.
5. Revert framework schema activation if not promoted.
6. Record rollback evidence.
7. Re-run architecture and runtime validation.
