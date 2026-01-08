# Continuity Plane Documentation

This directory contains the specification for the Harmony Continuity Plane — the architectural plane responsible for preserving process knowledge: decisions, handoffs, progress, and session context.

## Documents

| Document | Description |
|----------|-------------|
| [continuity-plane.md](./continuity-plane.md) | Complete Continuity Plane specification |
| [three-planes-integration.md](./three-planes-integration.md) | Cross-plane integration architecture |

## Quick Summary

**Core Question:** "What did we decide and what happened?"

The Continuity Plane preserves:
- **Decisions** (ADRs, CDRs) — architectural and content decisions with rationale
- **Handoffs** — session-scoped context transfers between agents/humans
- **Progress** — append-only event logs tracking work
- **Backlogs** — active work items with acceptance criteria

## Position in Three-Plane Architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   Content Plane          Continuity Plane      Knowledge Plane  │
│   ┌─────────────┐        ┌─────────────┐       ┌─────────────┐ │
│   │ "What we    │        │ "What we    │       │ "What the   │ │
│   │  publish"   │        │  decided"   │       │  system is" │ │
│   │             │        │  ◄── HERE   │       │             │ │
│   │ • Docs      │        │             │       │ • Specs     │ │
│   │ • Entities  │        │ • Decisions │       │ • Contracts │ │
│   │ • Pages     │        │ • Handoffs  │       │ • Code      │ │
│   │             │        │ • Progress  │       │ • Tests     │ │
│   └─────────────┘        └─────────────┘       └─────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Storage Location

```text
.continuity/
├── backlog.yaml           # Active work items
├── plan.md                # Current plan snapshot
├── risks.md               # Known risks
├── decisions/             # ADRs and CDRs (immutable)
├── handoffs/              # Session handoff briefs
└── events/                # Progress logs (append-only)
```

## Lifecycle Rules

| Artifact | Lifecycle | Rule |
|----------|-----------|------|
| Decisions | Immutable | Cannot modify after merge; supersede with new file |
| Handoffs | Session-scoped | One per session, immutable |
| Progress Events | Append-only | Per-session NDJSON files |
| Backlogs | Mutable | Schema-validated, git history preserved |

## Related Documentation

- [Content Plane](../content-plane/README.md) — Published content infrastructure
- [Knowledge Plane](../knowledge-plane/knowledge-plane.md) — System knowledge graph
- [Continuity Pillar](../../pillars/continuity/README.md) — The "why" behind this plane

