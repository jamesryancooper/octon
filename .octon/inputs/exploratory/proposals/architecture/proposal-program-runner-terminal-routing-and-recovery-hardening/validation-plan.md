# Validation Plan

Before implementation:

- Run proposal standard validation for the parent and every child.
- Run proposal-program structure validation for the parent.
- Run implementation readiness validation before implementation prompt
  generation.
- Run strict review gates only after review receipts exist.

After implementation:

- Run focused lifecycle executor tests for workflow retry and archive
  observation.
- Run proposal-program kernel tests for scheduler ordering, recovery,
  aggregate blockers, promotion evidence binding, freshness preflight, parent
  review freshness, and cleanup suppression.
- Run proposal validators for every child packet.
- Run generated-state publication validators only after canonical publication
  scripts refresh derived outputs.
- Run a handoff-only proposal-program lifecycle check before
  `--execute-routes`.
