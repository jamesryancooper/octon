# Target Architecture

Autonomous recovery should emit compact, replayable evidence:

- validator diagnostics include the failing path, accepted value, stale cause,
  recovery class, and minimal repair hint;
- retries append bounded deltas rather than full repeated summaries;
- failure evidence is grouped by blocker class, child, route, and disposition;
- child receipts remain direct references rather than duplicated parent prose;
- generated projection refresh records source digest and freshness result only
  at the required level of detail.
