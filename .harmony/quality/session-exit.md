---
title: Session Exit Checklist
description: Steps to complete before ending a session or context reset.
---

# Session Exit Checklist

Complete before ending a session, context reset, or handoff.

## Required Steps

- [ ] **Run native-first interop checks** (when interop files changed)
  - `bash .harmony/capabilities/services/_ops/scripts/validate-service-independence.sh --mode services-core`
  - `bash .harmony/capabilities/services/_ops/scripts/validate-service-independence.sh --mode platform-core`
  - `bash .harmony/capabilities/services/_ops/scripts/validate-service-independence.sh --mode adapters` (if adapters changed)
  - `bash .harmony/capabilities/services/_ops/scripts/validate-service-independence.sh --mode conformance` (if adapters changed)
  - `bash .harmony/capabilities/services/_ops/scripts/validate-service-independence.sh --mode degradation` (if compaction/adapter behavior changed)

- [ ] **Run filesystem interface validation** (when filesystem interface files changed)
  - `bash .harmony/capabilities/services/_ops/scripts/validate-filesystem-interfaces.sh`

- [ ] **Update `continuity/log.md`** with session summary
  - Date header
  - Session focus
  - What was completed
  - What's next
  - Any blockers

- [ ] **Update `continuity/tasks.json`** status
  - Mark completed tasks as `completed` with `completed_at`
  - Mark incomplete work as `in_progress` or `blocked`
  - Add any new tasks discovered

- [ ] **Update `continuity/entities.json`** if applicable
  - Record state of any artifacts being actively modified
  - Note in-flight changes that aren't committed

- [ ] **Document in-flight state**
  - If mid-task, describe current position in `continuity/log.md`
  - Include any uncommitted reasoning or partial work

## Conditional Steps

### If a decision was made

- [ ] Add to `cognition/context/decisions.md`
- [ ] Optionally create full ADR in `docs/decisions/` or `ideation/scratchpad/`

### If compaction policy changed or was exercised

- [ ] Verify memory flush threshold behavior (80% warning, 90% mandatory flush)
- [ ] Ensure flush evidence report exists in `.harmony/output/reports/`
- [ ] If flush failed, verify HITL waiver evidence before proceeding

### If `.harmony` architecture surfaces changed

- [ ] Run `bash .harmony/quality/_ops/scripts/validate-harness-structure.sh`
- [ ] Run `bash .harmony/quality/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
- [ ] If validator reports drift, update `audit-subsystem-health` skill artifacts before exit

### If something failed

- [ ] Add to `cognition/context/lessons.md`
- [ ] Note in `continuity/log.md`

### If new patterns discovered

- [ ] Consider adding to `conventions.md`
- [ ] Or add to `cognition/context/lessons.md` as anti-pattern

## Session Summary Template

Use this format in `continuity/log.md`:

```markdown
## YYYY-MM-DD

**Session focus:** [one-line summary]

**Completed:**
- [task 1]
- [task 2]

**In-flight:**
- [partial work, current state]

**Next:**
- [priority item for next session]

**Blockers:**
- [if any]

**Decisions:**
- [if any, reference D### in decisions.md]

**Lessons:**
- [if any failures worth noting]
```
