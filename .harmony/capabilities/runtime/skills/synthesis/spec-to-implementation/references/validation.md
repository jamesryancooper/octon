---
title: Validation Reference
description: Acceptance criteria for the spec-to-implementation skill.
---

# Validation Reference

## Acceptance Criteria

### Requirements Coverage

| Check | Requirement |
| ----- | ----------- |
| Every requirement mapped | Each requirement from spec appears in at least one task |
| Traceability table complete | Requirements → Tasks mapping is explicit |
| No orphan tasks | Every task traces back to a requirement |

### Task Quality

| Check | Requirement |
| ----- | ----------- |
| Independently deliverable | Each task can produce a testable result |
| Has acceptance criteria | Derived from spec, not invented |
| Has complexity estimate | S, M, or L |
| Has domain assignment | database, api, frontend, infra, etc. |
| Dependencies explicit | Listed or "none" |

### Plan Completeness

- [ ] Executive summary present
- [ ] Requirements traceability table
- [ ] Task table with all required fields
- [ ] Dependency diagram
- [ ] Milestone definitions
- [ ] Risk register
- [ ] Assumptions and open questions
- [ ] Human review step completed

### Quality Gates

| Gate | Pass Condition |
| ---- | -------------- |
| No untraced requirements | Every spec requirement maps to tasks |
| No circular dependencies | Dependency graph is acyclic |
| Milestones are incremental | Each milestone produces working software |
| Risks have mitigations | Every identified risk has a mitigation strategy |

## Verification Checklist

1. Plan exists at `.harmony/output/plans/YYYY-MM-DD-*-implementation-plan.md`
2. Every spec requirement is covered by at least one task
3. No circular dependencies in task graph
4. Each milestone delivers a testable increment
5. Assumptions are listed explicitly
6. Plan was presented for human review
7. Log exists at `_ops/state/logs/spec-to-implementation/{{run_id}}.md`
