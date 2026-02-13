---
title: Three Planes Integration
description: Integration contract for Content, Continuity, and Knowledge planes using the active `.harmony/` continuity model.
---

# Three Planes Integration

Harmony separates concerns into three planes while keeping explicit integration points.

## Plane Roles

| Plane | Core Question | Primary Surface |
|---|---|---|
| Content Plane | What do we publish? | `.harmony/cognition/architecture/content-plane/` and related product content artifacts |
| Continuity Plane | What happened and what is next? | `.harmony/continuity/{log.md,tasks.json,entities.json,next.md}` |
| Knowledge Plane | What is the system and how is it implemented? | specs/contracts/code/tests/telemetry links and architecture records |

## Integration Contract

### Content -> Continuity

- Content changes should be reflected in continuity task state when they are active work.
- Material publishing decisions should be logged in `log.md` and reflected in `next.md` when follow-up exists.

### Continuity -> Knowledge

- Active tasks in `tasks.json` should reference relevant specs, contracts, or architecture docs when available.
- Entity records in `entities.json` should link to authoritative technical knowledge sources.

### Knowledge -> Continuity

- Architectural decisions and verification outcomes should be captured in continuity history (`log.md`) and future actions (`next.md`).
- Breaking or risky system changes should update task metadata (risk, blockers, required approvals).

## Data Flow

```text
Knowledge updates / implementation changes
                |
                v
  .harmony/continuity/log.md (history)
                |
                +--> .harmony/continuity/tasks.json (state)
                |
                +--> .harmony/continuity/entities.json (ownership/context)
                |
                +--> .harmony/continuity/next.md (immediate execution plan)
```

## Consistency Requirements

- `next.md` must only reference active, unblocked tasks from `tasks.json`.
- `entities.json` ownership should align with task ownership when work is entity-specific.
- `log.md` entries should provide enough context to understand why task/entity state changed.

## Governance Hooks

- Human approval checkpoints and risk-tiering are enforced through workflow and policy docs, while continuity captures the resulting execution trail.
- Post-change verification should be represented by both evidence in knowledge artifacts and status progression in `tasks.json`.

## Anti-Patterns

- Treating continuity files as optional notes instead of operational state.
- Recording decisions only in prose without updating structured continuity state.
- Allowing task progression without corresponding log entries.

## Related Docs

- `.harmony/continuity/architecture/continuity-plane.md`
- `.harmony/cognition/knowledge-plane/knowledge-plane.md`
- `.harmony/cognition/architecture/content-plane/README.md`
- `.harmony/START.md`
