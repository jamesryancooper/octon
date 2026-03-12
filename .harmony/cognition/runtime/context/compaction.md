---
title: Compaction Strategy
description: Canonical compaction thresholds, flush sequence, and fail-closed behavior.
---

# Compaction Strategy

## Trigger Thresholds

- Warning threshold: context budget usage `>= 80%`.
- Mandatory flush threshold: context budget usage `>= 90%`.
- Mandatory flush also applies on any explicit compaction request.

## Mandatory Flush Sequence

1. Classify session artifacts by memory class.
2. Redact sensitive values.
3. Persist durable summary only.
4. Emit memory flush evidence artifact.

Evidence output:

- `.harmony/output/reports/analysis/<date>-memory-flush-evidence.md`

## Fail-Closed Rule

- If mandatory flush fails, compaction is blocked.
- Continue only with explicit ACP waiver and waiver evidence.

## Preserve During Compaction

- Approved architectural decisions.
- Unresolved blockers and incident context.
- Current task status and next actions.
- Files touched and relevant contract/schema versions.

## Discard During Compaction

- Raw command output already summarized elsewhere.
- Superseded plans replaced by accepted decisions.
- Repetitive intermediate debugging traces.
