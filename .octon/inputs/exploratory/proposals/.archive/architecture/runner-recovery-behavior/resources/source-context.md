# Source Context

Parent program:
`.octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery`

Source findings:

- invalid enum drift, stale receipts, stale digests, publication freshness
  drift, generated projection drift, cleanup residue, and step exhaustion
  should recover autonomously when safe;
- preflight failures need bounded retries or fallback evidence before
  escalation;
- hard blockers must remain fail-closed;
- runner evidence should be compact.

This file is proposal-local context only.
