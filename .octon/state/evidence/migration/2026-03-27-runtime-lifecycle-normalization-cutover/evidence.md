# Wave 3 Evidence

This bundle captures the Wave 3 runtime lifecycle normalization cutover,
including constitutional runtime contracts, canonical run lifecycle writers,
mission read-model bridge updates, and validation receipts.

Key proof points:

- consequential execution binds canonical run control and evidence roots before
  side effects through `bind_run_lifecycle(...)`
- canonical lifecycle files now include `runtime-state.yml`,
  `rollback-posture.yml`, control/evidence checkpoints, `replay-pointers.yml`,
  `trace-pointers.yml`, and `retained-run-evidence.yml`
- generated mission summaries and mission views now emit `run_evidence_refs`
  and treat per-run evidence as the execution-time source of truth
- the live mission bridge now points at a real transitional mission-backed run
  root: `run-wave3-runtime-bridge-20260327`
- extension publication, capability publication, and the broad
  `validate-runtime-effective-state.sh` sweep all pass after the state refresh
