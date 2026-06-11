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
- `.octon/state/evidence/runs/<run-id>/retained-run-evidence-index.yml`

Write `evidence-map.yml` and `known-limits.yml` under
`.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/`.

The binder emits lifecycle-postmortem evidence-map/known-limits v2 while keeping
the original retained/missing fields for compatibility. In addition to direct
control refs, bind retained-run evidence index locator refs when present under
retained run evidence roots. Locator refs are discovery and replay aids only;
they never replace source evidence, authorize lifecycle transition or closeout,
or satisfy child receipts.

Prefer direct control refs when they exist. When direct control refs are
missing, bind:

- `substitute_refs` for retained workflow evidence that can reconstruct a
  missing direct program control ref, such as workflow `program-events.ndjson`
  or workflow `program-lifecycle-checkpoint.yml`;
- `terminal_state_refs` for compact terminal evidence such as `summary.md`,
  `aggregate-terminal-blockers.yml`, `blocker-ledger.yml`, route decision, plan,
  scheduler, planner, context capsule, and publication-freshness summary refs;
- `diagnostic_refs` for historical evidence such as raw-log summary and
  failing-slice manifest;
- `associated_refs` for bounded retained closeout receipts or reports whose
  content explicitly names the run id.

Do not infer missing facts. Record absent control or evidence files as known
limits. A missing direct control ref is an evidence gap unless a listed
substitute ref exists; diagnostic failing-slice evidence is historical and must
not override terminal blocker ledgers.

The emitted evidence map must preserve explicit authority boundaries:

- generated refs use `authority_use: derived-only`;
- proposal-local refs use `authority_use: non-authoritative`;
- retained evidence and retained workflow substitutes use
  `authority_use: evidence-only`;
- control refs use `authority_use: control-truth`;
- postmortem output does not approve closeout, lifecycle transition, redesign,
  support widening, generated publication, or invariant change.
