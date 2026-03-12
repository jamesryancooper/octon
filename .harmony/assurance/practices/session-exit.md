---
title: Session Exit Checklist
description: Steps to complete before ending a session or context reset.
---

# Session Exit Checklist

Complete before ending a session, context reset, or handoff.

## Required Steps

- [ ] **Run native-first interop checks** (when interop files changed)
  - `bash .harmony/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode services-core`
  - `bash .harmony/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode platform-core`
  - `bash .harmony/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode adapters` (if adapters changed)
  - `bash .harmony/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode conformance` (if adapters changed)
  - `bash .harmony/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode degradation` (if compaction/adapter behavior changed)

- [ ] **Run filesystem interface validation** (when filesystem interface files changed)
  - `bash .harmony/capabilities/runtime/services/_ops/scripts/validate-filesystem-interfaces.sh`

- [ ] **Run continuity memory validation** (when continuity artifacts or memory policy changed)
  - `bash .harmony/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`

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

- [ ] Add to `cognition/runtime/context/decisions.md`
- [ ] Optionally create full ADR in `docs/decisions/` or `ideation/scratchpad/`

### If compaction policy changed or was exercised

- [ ] Verify memory flush threshold behavior (80% warning, 90% mandatory flush)
- [ ] Ensure flush evidence report exists in `.harmony/output/reports/analysis/`
- [ ] If flush failed, verify ACP waiver evidence before proceeding

### If `.harmony` architecture surfaces changed

- [ ] Run `bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- [ ] Run `bash .harmony/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
- [ ] Run `bash .harmony/assurance/runtime/_ops/scripts/validate-audit-convergence-contract.sh`
- [ ] Run `bash .harmony/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`
- [ ] Run `bash .harmony/assurance/runtime/_ops/scripts/validate-developer-context-policy.sh`
- [ ] Run `bash .harmony/assurance/runtime/_ops/scripts/validate-context-overhead-budget.sh`
- [ ] Verify material run evidence includes `instruction-layer-manifest.json` and receipt telemetry fields (`instruction_layers`, `context_acquisition`, `context_overhead_ratio`)
- [ ] Run `bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`
- [ ] If validator reports drift, update `audit-subsystem-health` skill artifacts before exit

### If commit/PR governance artifacts changed

- [ ] Run `bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile commit-pr`
- [ ] If validator reports drift, update standards/template/workflow files to restore alignment

### If assurance weight artifacts changed

- [ ] Run `bash .harmony/assurance/runtime/_ops/scripts/compute-assurance-score.sh --weights .harmony/assurance/governance/weights/weights.yml --scores .harmony/assurance/governance/scores/scores.yml`
- [ ] Run `bash .harmony/assurance/runtime/_ops/scripts/assurance-gate.sh --scorecard <generated-scorecard.yml> --weights .harmony/assurance/governance/weights/weights.yml --scores .harmony/assurance/governance/scores/scores.yml`
- [ ] Verify `.harmony/output/assurance/effective/<context>.md` and `.harmony/output/assurance/results/<context>.md` were generated
- [ ] Attach scorecard path and gate outcome in `continuity/log.md`

### If something failed

- [ ] Add to `cognition/runtime/context/lessons.md`
- [ ] Note in `continuity/log.md`

### If new patterns discovered

- [ ] Consider adding to `conventions.md`
- [ ] Or add to `cognition/runtime/context/lessons.md` as anti-pattern

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
