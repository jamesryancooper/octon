# Source Context

Parent program:
`.octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery`

Source findings:

- invalid enum drift, stale receipts, stale digests, freshness drift, cleanup
  residue, and continuable step exhaustion should not require human input when
  repair is safe and validator-backed;
- soft blockers require bounded recovery and no-progress thresholds;
- hard blockers remain narrow and fail-closed.

This file is proposal-local context only.
