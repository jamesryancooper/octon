---
title: Continuity Plane
description: The Continuity Plane preserves process knowledge—decisions, handoffs, progress, and session context—enabling agents and humans to maintain context across time and team changes.
---

# Continuity Plane: Preserving Process Knowledge

Related docs: [Content Plane](../content-plane/README.md), [Knowledge Plane](../knowledge-plane/knowledge-plane.md), [Three Planes Integration](./three-planes-integration.md), [Continuity Pillar](../../pillars/continuity/README.md)

The Continuity Plane is the unified store for **process knowledge**—the decisions made, context transferred, progress recorded, and rationale preserved. It ensures that agents and humans can pick up where others left off, understand why things are the way they are, and maintain institutional memory across sessions and team changes.

---

## The Three Planes of Harmony

Before diving into Continuity Plane specifics, it's essential to understand how it relates to Harmony's three-plane architecture:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                        THE THREE PLANES OF HARMONY                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐          │
│   │  CONTENT PLANE  │   │ CONTINUITY PLANE│   │ KNOWLEDGE PLANE │          │
│   │                 │   │                 │   │                 │          │
│   │  "What we       │   │  "What we       │   │  "What the      │          │
│   │   publish"      │   │   decided"      │   │   system is"    │          │
│   │                 │   │                 │   │                 │          │
│   │  • Docs         │   │  • Decisions    │   │  • Specs        │          │
│   │  • Entities     │   │  • Handoffs     │   │  • Contracts    │          │
│   │  • Pages        │   │  • Progress     │   │  • Code         │          │
│   │  • Prompts      │   │  • Backlogs     │   │  • Tests        │          │
│   │  • Exports      │   │  • Sessions     │   │  • Traces       │          │
│   │                 │   │                 │   │  • SBOM         │          │
│   └────────┬────────┘   └────────┬────────┘   └────────┬────────┘          │
│            │                     │                     │                   │
│            └─────────────────────┼─────────────────────┘                   │
│                                  │                                         │
│                    ┌─────────────┴─────────────┐                           │
│                    │   SHARED INFRASTRUCTURE    │                           │
│                    │  • Schema Registry         │                           │
│                    │  • Reference Resolution    │                           │
│                    │  • Query Infrastructure    │                           │
│                    │  • Cross-Plane Linking     │                           │
│                    └───────────────────────────┘                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Plane Comparison

| Dimension | Content Plane | Continuity Plane | Knowledge Plane |
|-----------|---------------|------------------|-----------------|
| **Core Question** | "What do we publish?" | "What did we decide?" | "What is the system?" |
| **Domain** | Published content | Process knowledge | System knowledge |
| **Time Focus** | Present state | Temporal narrative | Present + verified history |
| **Primary Artifacts** | Docs, entities, pages, prompts | Decisions, handoffs, progress, backlogs | Specs, contracts, code, tests, traces |
| **Lifecycle** | Mutable with versions | Append-only / immutable | Mutable with provenance |
| **Primary Users** | Content authors, agents | Agents, team members | Engineers, verifiers |
| **Key Query** | "What content exists for X?" | "Why was X decided?" | "What implements/verifies X?" |

---

## Core Question

> **"What HAPPENED and what's NEXT?"**

The Continuity Plane answers questions about process and temporal context:

- What decisions were made and why?
- What was the context when work was handed off?
- What progress has been made in this session?
- What's the current state of the backlog?
- Who worked on what and when?

This contrasts with:
- **Content Plane**: "What content do we have?" (documents, entities, compositions)
- **Knowledge Plane**: "What is the system?" (specs, contracts, code, tests, traces)

---

## Objectives

- **Preserve institutional memory**: Decisions, rationale, and context survive time and team changes.
- **Enable seamless handoffs**: Agents and humans can pick up where others left off.
- **Maintain audit trails**: Every significant action and decision is recorded.
- **Support the LEARN phase**: Provide the raw material for Insight (postmortems, retros).
- **Reduce context reconstruction**: No more "ask Bob" or re-discovering why decisions were made.

---

## Scope

The Continuity Plane indexes and preserves:

| Category | Artifacts | Lifecycle |
|----------|-----------|-----------|
| **Decisions** | ADRs, CDRs, architectural choices | Immutable after acceptance |
| **Handoffs** | Session briefs, context transfers | Session-scoped snapshots |
| **Progress** | Event logs, status updates | Append-only |
| **Backlogs** | Work items, acceptance criteria | Mutable with history |
| **Sessions** | Agent sessions, work periods | Time-bounded, append-only |
| **Rationale** | "Why" documentation, alternatives considered | Immutable after capture |

---

## Core Concepts

### Decision Record
A structured capture of an architectural or process decision, including context, alternatives considered, rationale, and consequences. Types include:
- **ADR** (Architectural Decision Record): Decisions about system architecture
- **CDR** (Content Decision Record): Decisions about content strategy/structure

### Handoff Brief
A session-scoped snapshot of context transferred between agents or team members. Contains current state, open questions, blockers, and recommended next steps.

### Progress Event
An append-only log entry recording an action taken, file touched, or status change. Forms the audit trail for session activity.

### Backlog Item
A work unit with status, acceptance criteria, and verification evidence. Mutable during active work, with full history preserved.

### Session
A bounded period of work by an agent or human, with associated progress events, decisions, and handoffs.

---

## Repository Layout

```text
.continuity/
├── README.md                           # Continuity Plane overview
├── backlog.yaml                        # Active backlog (mutable)
├── plan.md                             # Current plan snapshot
├── risks.md                            # Known risks snapshot
│
├── decisions/                          # Decision records (immutable after merge)
│   ├── ADR-0001-use-sqlite-index.md
│   ├── ADR-0002-three-plane-arch.md
│   └── CDR-0001-pricing-model.yaml
│
├── handoffs/                           # Session handoff briefs (session-scoped)
│   ├── 2025-12-15-session-abc123.md
│   └── 2025-12-16-session-def456.md
│
├── events/                             # Progress logs (append-only)
│   ├── session-abc123.ndjson
│   └── session-def456.ndjson
│
└── _schemas/                           # Continuity-specific schemas
    ├── backlog.schema.ts
    ├── decision.schema.ts
    ├── handoff.schema.ts
    └── progress-event.schema.ts
```

---

## Lifecycle Rules

The Continuity Plane enforces strict lifecycle rules to maintain integrity:

| Artifact Type | Mutability | Rule |
|---------------|------------|------|
| **Decisions** | Immutable after merge | New decisions create new files; superseded decisions marked as such |
| **Handoffs** | Session-scoped, immutable | One handoff per session; `handoff.md` may be a "latest" pointer |
| **Progress Events** | Append-only | Per-session files prevent conflicts; no edits, only appends |
| **Backlogs** | Mutable with history | Schema-validated; history preserved via git |
| **Plans/Risks** | Snapshot, overwrite | Point-in-time snapshots; git provides history |

### Lifecycle Enforcement

```yaml
# Example CI check for lifecycle rules
continuity:
  rules:
    - path: ".continuity/decisions/**"
      on_modify: reject  # Decisions are immutable
      on_create: require_schema_validation
    
    - path: ".continuity/events/**"
      on_modify: reject  # Events are append-only
      on_create: require_ndjson_format
      
    - path: ".continuity/handoffs/**"
      on_modify: reject  # Handoffs are session-scoped snapshots
      on_create: require_session_id
```

---

## Data Model

### Node Types

```text
┌─────────────────────────────────────────────────────────────────┐
│                   CONTINUITY PLANE NODES                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Decision   │  │   Handoff    │  │   Session    │          │
│  │              │  │              │  │              │          │
│  │ • id         │  │ • session_id │  │ • id         │          │
│  │ • type (ADR/ │  │ • from_actor │  │ • actor      │          │
│  │   CDR)       │  │ • to_actor   │  │ • start_ts   │          │
│  │ • status     │  │ • context    │  │ • end_ts     │          │
│  │ • rationale  │  │ • next_steps │  │ • status     │          │
│  │ • date       │  │ • blockers   │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ProgressEvent │  │ BacklogItem  │  │   Rationale  │          │
│  │              │  │              │  │              │          │
│  │ • session_id │  │ • item_id    │  │ • decision_id│          │
│  │ • timestamp  │  │ • title      │  │ • context    │          │
│  │ • actor      │  │ • status     │  │ • alternatives│         │
│  │ • action     │  │ • criteria   │  │ • consequences│         │
│  │ • artifacts  │  │ • evidence   │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Edge Types (Internal)

| Edge | From | To | Meaning |
|------|------|----|---------|
| `MADE_IN` | Decision | Session | Decision was made during session |
| `HANDED_OFF_FROM` | Handoff | Session | Handoff originated from session |
| `SUPERSEDES` | Decision | Decision | New decision replaces old |
| `BLOCKED_BY` | BacklogItem | BacklogItem | Work dependency |
| `VERIFIED_BY` | BacklogItem | ProgressEvent | Evidence of completion |

---

## Cross-Plane Integration

### Where ADRs Live

ADRs (Architectural Decision Records) bridge the Continuity and Knowledge planes:

```text
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   CONTINUITY PLANE                     KNOWLEDGE PLANE          │
│   ┌─────────────────┐                  ┌─────────────────┐      │
│   │                 │   ADR authored   │                 │      │
│   │  Session        │   ─────────────► │  Spec           │      │
│   │  Handoff        │                  │  Contract       │      │
│   │  Progress       │   ADR.INFORMS    │  CodeModule     │      │
│   │  Decision ◄─────┼──────────────────┼─► TestCase      │      │
│   │  Backlog        │                  │  Trace          │      │
│   │                 │                  │                 │      │
│   └─────────────────┘                  └─────────────────┘      │
│                                                                 │
│   "Why we decided"                     "What it affects"        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Continuity Plane owns the ADR as:**
- A decision record (rationale, context, alternatives)
- Part of institutional memory
- Queryable by "why" questions

**Knowledge Plane indexes the ADR's effects:**
- `ADR INFORMS Contract` — links decision to affected interfaces
- `ADR AFFECTS CodeModule` — links decision to implementation
- Impact analysis includes ADR in blast radius

### Cross-Plane Edge Types

| Edge | From Plane | To Plane | Meaning |
|------|------------|----------|---------|
| `INFORMS` | Continuity (ADR) | Knowledge (Contract/Spec) | Decision shapes system design |
| `AFFECTS` | Continuity (ADR) | Knowledge (CodeModule) | Decision impacts implementation |
| `MOTIVATED_BY` | Knowledge (Spec) | Continuity (Decision) | Spec driven by decision |
| `DOCUMENTS` | Content (Doc) | Continuity (Decision) | Content explains decision |
| `REFERENCES` | Content (Entity) | Continuity (Rationale) | Entity links to reasoning |

---

## The Integration Story

### Flow Diagram

```text
                    ┌────────────────────────────────────┐
                    │         CONTENT PLANE              │
                    │   (Published docs, entities)       │
                    └─────────────┬──────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    ▼                           ▼
    ┌───────────────────────────┐ ┌───────────────────────────┐
    │     CONTINUITY PLANE      │ │     KNOWLEDGE PLANE       │
    │  (Decisions, handoffs)    │ │  (Specs, code, tests)     │
    └─────────────┬─────────────┘ └─────────────┬─────────────┘
                  │                             │
                  └──────────────┬──────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │   CROSS-PLANE QUERIES   │
                    │  "Why is X this way?"   │
                    │  "What does Y affect?"  │
                    └─────────────────────────┘
```

### Integration Patterns

| Flow | Direction | Example |
|------|-----------|---------|
| **Content → Knowledge** | Published specs indexed | `docs/specs/checkout.md` → `Spec:checkout` node |
| **Process → Continuity** | Decisions preserved | PR discussion → `ADR-0042` in `.continuity/decisions/` |
| **Knowledge ← Continuity** | Impact lookup | "What modules does ADR-0042 affect?" → `CodeModule` list |
| **Continuity ← Knowledge** | Rationale lookup | "Why is this contract shaped this way?" → `ADR` link |
| **Content ← Continuity** | Documentation | Docs reference decisions for context |
| **Knowledge → Insight** | Learning input | Traces + tests feed postmortems |
| **Continuity → Insight** | Learning input | Decisions + progress feed retros |

### Query Examples

**1) "Why is this contract shaped this way?"**
```sql
-- Start from Knowledge Plane (Contract), traverse to Continuity (ADR)
SELECT d.id, d.title, d.rationale, d.date
FROM decisions d
JOIN cross_plane_refs cpr ON cpr.src_id = d.id
WHERE cpr.dst_plane = 'knowledge'
  AND cpr.dst_type = 'contract'
  AND cpr.dst_id = 'checkout-api'
  AND cpr.edge_type = 'INFORMS';
```

**2) "What is affected by this decision?"**
```sql
-- Start from Continuity (Decision), find Knowledge impacts
SELECT cpr.dst_type, cpr.dst_id, km.name
FROM cross_plane_refs cpr
LEFT JOIN knowledge_modules km ON km.id = cpr.dst_id
WHERE cpr.src_plane = 'continuity'
  AND cpr.src_id = 'ADR-0042'
  AND cpr.edge_type IN ('INFORMS', 'AFFECTS');
```

**3) "What progress was made this session?"**
```sql
-- Pure Continuity query
SELECT timestamp, actor, action, json_extract(data, '$.files_written') as files
FROM progress_events
WHERE session_id = 'abc123'
ORDER BY timestamp;
```

**4) "What decisions relate to authentication?"**
```sql
-- Cross-plane: find decisions related to auth specs/modules
SELECT DISTINCT d.id, d.title, d.status
FROM decisions d
JOIN cross_plane_refs cpr ON cpr.src_id = d.id
WHERE (cpr.dst_id LIKE '%auth%' OR cpr.dst_id LIKE '%login%')
  AND d.status = 'accepted';
```

---

## Pillar Mapping

The Continuity Plane directly implements the **Continuity** pillar and supports others:

| Pillar | Relationship to Continuity Plane |
|--------|----------------------------------|
| **Direction** | Specs-as-decisions flow into Continuity; validated requirements become ADRs |
| **Focus** | Kit documentation lives in Content; decisions about kits live in Continuity |
| **Velocity** | Progress tracking enables flow; handoffs prevent context loss |
| **Trust** | Audit trails provide accountability; decisions explain governance |
| **Continuity** | **Primary plane** — directly implements institutional memory |
| **Insight** | Draws from Continuity data for postmortems and retros |

### Insight ↔ Continuity Relationship

The **Insight** pillar is not a plane but a **process** that operates on Continuity data:

```text
┌─────────────────────────────────────────────────────────────────┐
│                    LEARN PHASE FLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   CONTINUITY PLANE              INSIGHT PROCESS                 │
│   ┌─────────────────┐          ┌─────────────────┐             │
│   │                 │          │                 │             │
│   │  Decisions      │─────────►│  Postmortems    │             │
│   │  Progress       │  feeds   │  Retros         │             │
│   │  Sessions       │─────────►│  Evals          │             │
│   │  Handoffs       │          │  Learnings      │             │
│   │                 │          │                 │             │
│   └─────────────────┘          └────────┬────────┘             │
│                                         │                      │
│                                         │ creates              │
│                                         ▼                      │
│                                ┌─────────────────┐             │
│                                │  New Decisions  │             │
│                                │  Updated Specs  │             │
│                                │  Process Changes│             │
│                                └─────────────────┘             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Lifecycle Comparison

| Aspect | Content Plane | Continuity Plane | Knowledge Plane |
|--------|---------------|------------------|-----------------|
| **Creation** | Author/agent creates | Decision/event triggers | Build/deploy generates |
| **Mutation** | Edit via PR | Depends on type (see rules) | Update on change |
| **Deletion** | Soft-delete with redirect | Never (supersede instead) | Archive with history |
| **Versioning** | Git + envelope metadata | Git + immutability rules | Graph versioning |
| **Conflict handling** | Merge/rebase | Per-session files | Idempotent upsert |

---

## Query Pattern Comparison

| Query Type | Content Plane | Continuity Plane | Knowledge Plane |
|------------|---------------|------------------|-----------------|
| **Existence** | "What docs exist for X?" | "What decisions exist for X?" | "What specs exist for X?" |
| **Lookup** | `ref:doc:getting-started` | `ref:decision:ADR-0042` | `Spec:checkout` |
| **Relationship** | "What references this entity?" | "What does this decision affect?" | "What implements this spec?" |
| **History** | Git log / versions | Append-only events | Provenance graph |
| **Impact** | "Blast radius of content change" | "Blast radius of decision" | "Blast radius of code change" |

---

## Ownership Comparison

| Aspect | Content Plane | Continuity Plane | Knowledge Plane |
|--------|---------------|------------------|-----------------|
| **Primary owner** | Content authors | Agents, decision-makers | Engineering systems |
| **Write access** | Authors, agents | Session owner, decision-makers | CI/CD, verifiers |
| **Governance** | Editorial review | Immutability rules | Automated verification |
| **Retention** | Content lifecycle | Permanent (institutional memory) | Configurable (traces TTL) |

---

## Integration Layer Design

### Shared Schema Registry

All three planes share a unified schema registry:

```text
content/_schemas/
├── shared/                    # Cross-plane schemas
│   ├── reference.schema.ts    # Universal ref:type:id format
│   ├── envelope.schema.ts     # Shared metadata envelope
│   └── cross-plane-ref.schema.ts
│
├── content/                   # Content Plane schemas
│   ├── entity/
│   ├── prose/
│   └── composition/
│
├── continuity/                # Continuity Plane schemas
│   ├── decision.schema.ts
│   ├── handoff.schema.ts
│   ├── progress-event.schema.ts
│   └── backlog.schema.ts
│
└── knowledge/                 # Knowledge Plane schemas (for ingestion)
    ├── spec-link.schema.ts
    └── module-link.schema.ts
```

### Reference Resolution

Universal reference format works across planes:

```text
ref:<plane>:<type>:<id>[@version]

Examples:
  ref:content:doc:getting-started
  ref:continuity:decision:ADR-0042
  ref:knowledge:spec:checkout-api
  ref:knowledge:module:src/checkout/total.ts
```

### Query Infrastructure

Unified query surface with plane-aware routing:

```typescript
// Unified query API
const result = await harmony.query({
  // Pure Continuity query
  continuity: `
    SELECT * FROM decisions 
    WHERE status = 'accepted' AND date > '2025-01-01'
  `,
  
  // Cross-plane join
  crossPlane: `
    SELECT d.title, k.module_name
    FROM continuity.decisions d
    JOIN knowledge.modules k ON k.decision_id = d.id
    WHERE d.id = 'ADR-0042'
  `
});
```

### Cross-Plane Linking Table

```sql
CREATE TABLE cross_plane_refs (
  id TEXT PRIMARY KEY,
  src_plane TEXT NOT NULL,      -- 'content' | 'continuity' | 'knowledge'
  src_type TEXT NOT NULL,
  src_id TEXT NOT NULL,
  dst_plane TEXT NOT NULL,
  dst_type TEXT NOT NULL,
  dst_id TEXT NOT NULL,
  edge_type TEXT NOT NULL,      -- 'INFORMS' | 'AFFECTS' | 'DOCUMENTS' | etc.
  created_at TEXT NOT NULL,
  metadata JSON
);

CREATE INDEX idx_cross_plane_src ON cross_plane_refs(src_plane, src_type, src_id);
CREATE INDEX idx_cross_plane_dst ON cross_plane_refs(dst_plane, dst_type, dst_id);
CREATE INDEX idx_cross_plane_edge ON cross_plane_refs(edge_type);
```

---

## Agent Coordination

The Continuity Plane supports agent coordination through defined roles:

| Role | Continuity Responsibilities |
|------|----------------------------|
| **Orchestrator** | Creates sessions, assigns work, manages handoffs |
| **Implementer** | Records progress events, requests decisions |
| **Archivist** | Maintains decision records, ensures handoff quality |
| **Verifier** | Validates decisions are followed, records evidence |

### Session Workflow

```text
┌─────────────────────────────────────────────────────────────────┐
│                    AGENT SESSION LIFECYCLE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. SESSION START                                               │
│     ├─ Read previous handoff (if exists)                        │
│     ├─ Load relevant decisions                                  │
│     └─ Initialize progress log                                  │
│                                                                 │
│  2. WORK EXECUTION                                              │
│     ├─ Append progress events (files read/written, actions)     │
│     ├─ Request decisions when needed (creates ADR draft)        │
│     └─ Update backlog status                                    │
│                                                                 │
│  3. SESSION END                                                 │
│     ├─ Generate handoff brief                                   │
│     ├─ Summarize progress                                       │
│     └─ Note blockers and next steps                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Example Artifacts

### Decision Record (ADR)

```yaml
# .continuity/decisions/ADR-0042-use-sqlite-index.md
---
$schema: harmony://schemas/continuity/decision@1
type: adr
id: ADR-0042
status: accepted
title: "Use SQLite for build-time content index"
date: 2025-01-15
decision_makers: [human:james, agent:architect]
risk_tier: medium

context: |
  Content queries currently rely on grep patterns, which don't support
  relational queries or efficient joins. As content volume grows, we need
  a proper query layer.

decision: |
  Use SQLite as the build-time index for the Content Plane. The index
  is regenerated deterministically on each build from canonical content.

rationale: |
  - SQLite is embeddable, zero-config, and fast for read-heavy workloads
  - Deterministic regeneration means the index is always consistent with source
  - Standard SQL enables complex queries without custom DSLs

alternatives_considered:
  - option: "JSON files with jq queries"
    rejected_reason: "Limited relational capability, slower for complex queries"
  - option: "PostgreSQL"
    rejected_reason: "Requires server infrastructure; overkill for build-time"
  - option: "In-memory graph"
    rejected_reason: "Not persistent across builds; harder to debug"

consequences:
  positive:
    - Enables proper relational queries over content
    - Supports impact analysis via dependency joins
    - Standard tooling (DB browsers, SQL clients) for debugging
  negative:
    - Build step required to regenerate index
    - Not suitable for runtime mutations

affects:
  - ref:knowledge:module:packages/harmony-content/src/index.ts
  - ref:knowledge:spec:content-query-api
  - ref:content:doc:content-plane-overview
---
```

### Handoff Brief

```yaml
# .continuity/handoffs/2025-12-15-session-abc123.md
---
$schema: harmony://schemas/continuity/handoff@1
session_id: abc123
from_actor: agent:implementer
to_actor: human:reviewer
timestamp: 2025-12-15T18:00:00Z
---

## Context

Implemented the pricing card component as part of the checkout flow refactor.

## Completed

- [x] Created `PricingCard.tsx` component
- [x] Added unit tests (100% coverage)
- [x] Updated Storybook stories

## In Progress

- [ ] Integration with checkout flow (blocked)

## Blockers

- Need ADR on pricing calculation rounding strategy
- Waiting for design review on mobile layout

## Recommended Next Steps

1. Review PR #456 for initial component
2. Schedule design sync for mobile layout
3. Draft ADR for rounding strategy

## Files Touched

- `src/components/PricingCard.tsx` (created)
- `src/components/PricingCard.test.tsx` (created)
- `src/components/PricingCard.stories.tsx` (created)

## Related Decisions

- ref:continuity:decision:ADR-0040 (checkout-refactor)
- ref:continuity:decision:CDR-0001 (pricing-model)
```

### Progress Events (NDJSON)

```json
{"ts":"2025-12-15T10:15:00Z","session_id":"abc123","actor":"agent:implementer","action":"session_start","context":{"handoff_read":"2025-12-14-session-xyz789"}}
{"ts":"2025-12-15T10:20:00Z","session_id":"abc123","actor":"agent:implementer","action":"file_read","files":["src/components/Pricing.tsx","src/types/pricing.ts"]}
{"ts":"2025-12-15T10:45:00Z","session_id":"abc123","actor":"agent:implementer","action":"file_created","files":["src/components/PricingCard.tsx"]}
{"ts":"2025-12-15T11:30:00Z","session_id":"abc123","actor":"agent:implementer","action":"tests_passed","coverage":{"statements":100,"branches":95}}
{"ts":"2025-12-15T12:00:00Z","session_id":"abc123","actor":"agent:implementer","action":"blocker_identified","blocker":"Need ADR on pricing rounding","severity":"medium"}
{"ts":"2025-12-15T18:00:00Z","session_id":"abc123","actor":"agent:implementer","action":"session_end","handoff_created":"2025-12-15-session-abc123"}
```

---

## Alignment with Harmony Principles

| Principle | How Continuity Plane Serves It |
|-----------|-------------------------------|
| **Continuity through Institutional Memory** | Direct implementation — preserves decisions, context, rationale |
| **Quality through Determinism** | Immutable decisions, append-only logs ensure audit trail integrity |
| **Guided Autonomy** | Agents have clear context and constraints from preserved decisions |
| **Convivial Design** | Reduces "ask Bob" patterns; knowledge accessible to all |

---

## Related Documentation

- [Three Planes Integration](./three-planes-integration.md) — Cross-plane architecture
- [Content Plane](../content-plane/README.md) — Published content infrastructure
- [Knowledge Plane](../knowledge-plane/knowledge-plane.md) — System knowledge graph
- [Continuity Pillar](../../pillars/continuity/README.md) — The "why" behind this plane
- [Insight Pillar](../../pillars/insight.md) — Learning from Continuity data

