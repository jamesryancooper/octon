# Recovery Proof Plane

Recovery assurance proves rollback, checkpoint, replay, and resumability
expectations for consequential runs.

Canonical retained outputs live under:

- `/.octon/state/evidence/runs/<run-id>/assurance/recovery.yml`

Recovery proof must reference the bound rollback posture, checkpoint family,
and replay manifest rather than reconstructed operator memory.

Authored suites live under `suites/**`.
