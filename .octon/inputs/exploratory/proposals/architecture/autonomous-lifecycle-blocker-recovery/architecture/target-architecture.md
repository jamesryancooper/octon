# Target Architecture

## Objective

Proposal-program lifecycle runners should autonomously recover routine and soft
blockers when the repair is safe, declared, bounded, and validator-backed.
Human or operator escalation remains reserved for genuinely hard blockers.

## Recovery Classes

- `routine-autonomous`: deterministic, in-scope repairs such as accepted enum
  normalization, stale receipt refresh, publication freshness refresh, generated
  projection refresh, cleanup delegation, and continuable step-budget resume.
- `soft-blocker`: bounded recovery requiring retry, repair, or delegated cleanup
  evidence, but not human input unless repeated attempts converge to no safe
  route.
- `hard-blocker`: destructive action without authority, ambiguous ownership,
  missing child-owned authority, parent summary as sole child proof,
  unsupported scope expansion, external permission or review requirements, or
  validation failures that cannot be safely repaired in scope.

## Expected Runtime Shape

The future runner uses machine-readable validator diagnostics and recovery
classes to choose a bounded recovery route:

1. classify the issue;
2. select a permitted recovery action;
3. apply only the smallest in-scope repair or delegated cleanup;
4. rerun the failed validator or gate;
5. append compact recovery evidence;
6. continue when `errors=0 warnings=0`;
7. escalate only when the issue is hard or bounded recovery is exhausted.

## Authority Boundaries

Proposal inputs remain non-authoritative. Generated outputs remain derived.
Parent program summaries may coordinate and summarize only. Child receipts,
child validation verdicts, child archive metadata, and child terminal outcomes
remain child-owned.

## Token Efficiency

Recovery evidence should be compact and targeted:

- validator diagnostics point to the failing path and accepted repair;
- stale receipt refreshes avoid broad context reloads;
- event logs record bounded deltas rather than repeated full summaries;
- failure summaries group repeated failures by blocker class, child, route, and
  final disposition;
- replayable evidence is retained where authority requires it, without
  duplicating verbose logs unnecessarily.
