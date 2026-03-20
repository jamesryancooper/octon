---
title: Session Exit Checklist
description: Steps to complete before ending a session or context reset.
---

# Session Exit Checklist

Complete before ending a session, context reset, or handoff.

## Required Steps

- [ ] **Run native-first interop checks** (when interop files changed)
  - `bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode services-core`
  - `bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode platform-core`
  - `bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode adapters` (if adapters changed)
  - `bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode conformance` (if adapters changed)
  - `bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode degradation` (if compaction/adapter behavior changed)

- [ ] **Run filesystem interface validation** (when filesystem interface files changed)
  - `bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-filesystem-interfaces.sh`

- [ ] **Run continuity memory validation** (when continuity artifacts or memory policy changed)
  - `bash .octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`

- [ ] **Update `/.octon/state/continuity/repo/log.md`** with session summary
  - Date header
  - Session focus
  - What was completed
  - What's next
  - Any blockers

- [ ] **Update `/.octon/state/continuity/repo/tasks.json`** status
  - Mark completed tasks as `completed` with `completed_at`
  - Mark incomplete work as `in_progress` or `blocked`
  - Add any new tasks discovered

- [ ] **Update `/.octon/state/continuity/repo/entities.json`** if applicable
  - Record state of any artifacts being actively modified
  - Note in-flight changes that aren't committed

- [ ] **Update `/.octon/state/continuity/scopes/<scope-id>/**`** when the
  work's primary home is a declared scope
  - Keep scope-local log, tasks, entities, and next-state aligned to the repo
    continuity handoff contract

- [ ] **Document in-flight state**
  - If mid-task, describe current position in `/.octon/state/continuity/repo/log.md`
  - Include any uncommitted reasoning or partial work

## Conditional Steps

### If a decision was made

- [ ] Add or update an ADR in `/.octon/instance/cognition/decisions/`
- [ ] Update `/.octon/instance/cognition/decisions/index.yml`
- [ ] Run `bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`

### If compaction policy changed or was exercised

- [ ] Verify memory flush threshold behavior (80% warning, 90% mandatory flush)
- [ ] Ensure flush evidence report exists in `.octon/state/evidence/validation/analysis/`
- [ ] If flush failed, verify ACP waiver evidence before proceeding

### If `.octon` architecture surfaces changed

- [ ] Run `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- [ ] Run `bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
- [ ] Run `bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-convergence-contract.sh`
- [ ] Run `bash .octon/framework/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`
- [ ] Run `bash .octon/framework/assurance/runtime/_ops/scripts/validate-developer-context-policy.sh`
- [ ] Run `bash .octon/framework/assurance/runtime/_ops/scripts/validate-context-overhead-budget.sh`
- [ ] Verify material run evidence includes `instruction-layer-manifest.json` and receipt telemetry fields (`instruction_layers`, `context_acquisition`, `context_overhead_ratio`)
- [ ] Run `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`
- [ ] If validator reports drift, update `audit-subsystem-health` skill artifacts before exit

### If commit/PR governance artifacts changed

- [ ] Run `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile commit-pr`
- [ ] If validator reports drift, update standards/template/workflow files to restore alignment

### If assurance weight artifacts changed

- [ ] Run `bash .octon/framework/assurance/runtime/_ops/scripts/compute-assurance-score.sh --weights .octon/framework/assurance/governance/weights/weights.yml --scores .octon/framework/assurance/governance/scores/scores.yml`
- [ ] Run `bash .octon/framework/assurance/runtime/_ops/scripts/assurance-gate.sh --scorecard <generated-scorecard.yml> --weights .octon/framework/assurance/governance/weights/weights.yml --scores .octon/framework/assurance/governance/scores/scores.yml`
- [ ] Verify `.octon/state/evidence/validation/assurance/effective/<context>.md` and `.octon/state/evidence/validation/assurance/results/<context>.md` were generated
- [ ] Attach scorecard path and gate outcome in `/.octon/state/continuity/repo/log.md`

### If something failed

- [ ] Add to `/.octon/instance/cognition/context/shared/lessons.md`
- [ ] Note in `/.octon/state/continuity/repo/log.md`

### If new patterns discovered

- [ ] Consider adding to `conventions.md`
- [ ] Or add to `/.octon/instance/cognition/context/shared/lessons.md` as anti-pattern

## Session Summary Template

Use this format in `/.octon/state/continuity/repo/log.md`:

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
