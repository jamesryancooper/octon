# Bind Evidence

Bind the supplied `run_id`, reject empty or unsafe run ids, and reconstruct the
available lifecycle facts from retained control and evidence roots.

Read candidates:

- `.octon/state/control/execution/runs/<run-id>/run-manifest.yml`
- `.octon/state/control/execution/runs/<run-id>/runtime-state.yml`
- `.octon/state/control/execution/runs/<run-id>/rollback-posture.yml`
- `.octon/state/control/execution/runs/<run-id>/checkpoints/**`
- `.octon/state/control/execution/runs/<run-id>/lifecycle-events.ndjson`
- `.octon/state/control/execution/runs/<run-id>/program-events.ndjson`
- `.octon/state/evidence/runs/<run-id>/**`
- `.octon/state/evidence/runs/workflows/<run-id>/**`

Write `evidence-map.yml` and `known-limits.yml` under
`.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/`.

Do not infer missing facts. Record absent control or evidence files as known
limits.
