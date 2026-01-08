---
title: Three Planes Integration
description: How the Content, Continuity, and Knowledge planes integrate to form Harmony's unified architecture.
---

# Three Planes Integration

This document defines how Harmony's three architectural planes—Content, Continuity, and Knowledge—integrate, interact, and maintain clear boundaries while sharing infrastructure.

---

## Architecture Overview

```text
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           HARMONY THREE-PLANE ARCHITECTURE                           │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│    ┌─────────────────────────────────────────────────────────────────────────┐     │
│    │                              USER LAYER                                  │     │
│    │                                                                          │     │
│    │   INTERNAL ACTORS                      EXTERNAL ACTORS                   │     │
│    │   ─────────────────                    ─────────────────                 │     │
│    │   • Developers                         • End Users (consumers)           │     │
│    │   • Agents                             • Clients (customers)             │     │
│    │   • Content Authors                    • Partners                        │     │
│    │   • Verifiers                          • Public Visitors                 │     │
│    │   • Decision-Makers                                                      │     │
│    │                                                                          │     │
│    └─────────────────────────────────────────────────────────────────────────┘     │
│                                      │                                             │
│                                      ▼                                             │
│    ┌─────────────────────────────────────────────────────────────────────────┐     │
│    │                           QUERY LAYER                                    │     │
│    │                    Unified Query API (SQL + Graph)                       │     │
│    └─────────────────────────────────────────────────────────────────────────┘     │
│                                      │                                             │
│           ┌──────────────────────────┼──────────────────────────┐                  │
│           │                          │                          │                  │
│           ▼                          ▼                          ▼                  │
│    ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐        │
│    │  CONTENT PLANE  │◄─────►│CONTINUITY PLANE │◄─────►│ KNOWLEDGE PLANE │        │
│    │                 │       │                 │       │                 │        │
│    │  "What we       │       │  "What we       │       │  "What the      │        │
│    │   publish"      │       │   decided"      │       │   system is"    │        │
│    │                 │       │                 │       │                 │        │
│    │ ┌─────────────┐ │       │ ┌─────────────┐ │       │ ┌─────────────┐ │        │
│    │ │ content/    │ │       │ │.continuity/ │ │       │ │ (generated) │ │        │
│    │ │ • entities  │ │       │ │ • decisions │ │       │ │ • specs     │ │        │
│    │ │ • docs      │ │       │ │ • handoffs  │ │       │ │ • contracts │ │        │
│    │ │ • pages     │ │       │ │ • progress  │ │       │ │ • code refs │ │        │
│    │ │ • prompts   │ │       │ │ • backlogs  │ │       │ │ • tests     │ │        │
│    │ └─────────────┘ │       │ └─────────────┘ │       │ │ • traces    │ │        │
│    │                 │       │                 │       │ │ • SBOM      │ │        │
│    └────────┬────────┘       └────────┬────────┘       │ └─────────────┘ │        │
│             │                         │                └────────┬────────┘        │
│             │                         │                         │                  │
│             └─────────────────────────┼─────────────────────────┘                  │
│                                       │                                            │
│                                       ▼                                            │
│    ┌─────────────────────────────────────────────────────────────────────────┐     │
│    │                      SHARED INFRASTRUCTURE                               │     │
│    │                                                                          │     │
│    │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │     │
│    │  │   Schema     │  │  Reference   │  │ Cross-Plane  │  │   Compiled   │ │     │
│    │  │   Registry   │  │  Resolution  │  │   Linking    │  │   Indexes    │ │     │
│    │  │              │  │              │  │              │  │              │ │     │
│    │  │ content/_    │  │ ref:plane:   │  │ cross_plane_ │  │ .harmony/    │ │     │
│    │  │ schemas/     │  │ type:id      │  │ refs table   │  │ *.sqlite     │ │     │
│    │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │     │
│    │                                                                          │     │
│    └─────────────────────────────────────────────────────────────────────────┘     │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## User Types

### Internal Actors (System Builders)

| Actor | Primary Planes | Activities |
|-------|----------------|------------|
| **Developers** | Knowledge, Continuity | Write code, verify specs, make decisions |
| **Agents** | All three | Automate tasks, record progress, query knowledge |
| **Content Authors** | Content | Create docs, entities, compositions |
| **Verifiers** | Knowledge, Continuity | Run tests, validate contracts, record evidence |
| **Decision-Makers** | Continuity | Author ADRs, approve changes, set direction |

### External Actors (System Users)

| Actor | Primary Plane | Interaction |
|-------|---------------|-------------|
| **End Users** | Content (via apps) | Consume published content through products |
| **Clients** | Content (via APIs) | Integrate with content APIs, receive updates |
| **Partners** | Content, Knowledge | Access documentation, contracts, integration specs |
| **Public Visitors** | Content | View public docs, marketing, product pages |

> **Note**: External actors typically interact with the **outputs** of the three planes (published content, API contracts, documentation) rather than the planes directly. The planes serve internal system management while enabling external value delivery.

---

## Plane Definitions

### Content Plane (HCP)
**Core Question:** "What do we publish?"

The Content Plane is a flat-file-first content compiler that validates, resolves, indexes, and transforms content files into queryable artifacts and multi-destination outputs.

| Aspect | Details |
|--------|---------|
| **Storage** | `content/` directory in git |
| **Artifacts** | Entities, documents, pages, prompts, compositions |
| **Lifecycle** | Mutable with versions; schema-validated |
| **Primary Users** | Content authors, publishing agents |

### Continuity Plane
**Core Question:** "What did we decide and what happened?"

The Continuity Plane preserves process knowledge—decisions, handoffs, progress, and session context—enabling institutional memory across time and team changes.

| Aspect | Details |
|--------|---------|
| **Storage** | `.continuity/` directory in git |
| **Artifacts** | Decisions (ADR/CDR), handoffs, progress events, backlogs |
| **Lifecycle** | Type-specific rules (immutable, append-only, session-scoped) |
| **Primary Users** | Agents, decision-makers, team members |

### Knowledge Plane
**Core Question:** "What is the system and how does it behave?"

The Knowledge Plane links specifications, contracts, code, tests, builds, telemetry, and SBOM into a unified queryable graph for traceability and impact analysis.

| Aspect | Details |
|--------|---------|
| **Storage** | Generated graph/index from code + CI/CD + telemetry |
| **Artifacts** | Specs, contracts, code modules, tests, traces, SBOM |
| **Lifecycle** | Mutable with provenance; automated ingestion |
| **Primary Users** | Engineers, verifiers, planners |

---

## Boundary Definitions

### What Each Plane Owns

| Artifact | Owning Plane | Reasoning |
|----------|--------------|-----------|
| **Product documentation** | Content | Published narrative content |
| **API reference docs** | Content | Published documentation |
| **Entity data** (pricing, features) | Content | Structured content for publishing |
| **Blog posts** | Content | Published prose |
| **ADRs** (decision records) | Continuity | Process decisions with rationale |
| **Session handoffs** | Continuity | Context transfer artifacts |
| **Progress logs** | Continuity | Work history and audit trail |
| **Work backlogs** | Continuity | Active work management |
| **Specifications** (behavioral) | Knowledge | System behavior definitions |
| **API contracts** (OpenAPI) | Knowledge | Interface definitions |
| **Code module links** | Knowledge | Implementation references |
| **Test results/coverage** | Knowledge | Verification evidence |
| **Runtime traces** | Knowledge | Operational telemetry |
| **SBOM** | Knowledge | Dependency graph |

### Resolving the ADR Overlap

ADRs are stored in and owned by the **Continuity Plane** because:
- They represent **decisions made** (process)
- They contain **rationale and alternatives** (institutional memory)
- They follow **immutability rules** (Continuity lifecycle)

However, the **Knowledge Plane indexes** ADR effects:
- Links ADR → affected contracts
- Links ADR → affected code modules
- Enables impact queries ("What decisions affect X?")

```text
┌─────────────────────────────────────────────────────────────────┐
│                     ADR OWNERSHIP MODEL                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  CONTINUITY PLANE (owns)         KNOWLEDGE PLANE (indexes)      │
│  ┌─────────────────────┐         ┌─────────────────────┐       │
│  │ ADR-0042            │         │                     │       │
│  │ ─────────────────── │ INFORMS │  Contract:          │       │
│  │ • id                │────────►│  checkout-api       │       │
│  │ • title             │         │                     │       │
│  │ • status            │         ├─────────────────────┤       │
│  │ • rationale ◄───────┼─────────│                     │       │
│  │ • alternatives      │MOTIVATED│  Spec:              │       │
│  │ • consequences      │   BY    │  checkout-perf      │       │
│  │ • date              │         │                     │       │
│  │ • decision_makers   │         ├─────────────────────┤       │
│  │                     │         │                     │       │
│  │ Queryable by:       │ AFFECTS │  CodeModule:        │       │
│  │ "Why did we...?"    │────────►│  checkout/total.ts  │       │
│  │                     │         │                     │       │
│  └─────────────────────┘         └─────────────────────┘       │
│                                                                 │
│  Source of truth for             Indexes effects for            │
│  the decision itself             impact analysis                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Cross-Plane Reference System

### Universal Reference Format

```text
ref:<plane>:<type>:<id>[@version]

Planes:
  - content      → Content Plane
  - continuity   → Continuity Plane  
  - knowledge    → Knowledge Plane

Examples:
  ref:content:doc:getting-started
  ref:content:entity:pricing:widget-pro
  ref:continuity:decision:ADR-0042
  ref:continuity:handoff:2025-12-15-abc123
  ref:knowledge:spec:checkout-api
  ref:knowledge:module:src/checkout/total.ts
  ref:knowledge:test:checkout.spec.ts
```

### Cross-Plane Linking Schema

```sql
-- Central cross-plane reference table
CREATE TABLE cross_plane_refs (
  id TEXT PRIMARY KEY,
  
  -- Source (where the reference originates)
  src_plane TEXT NOT NULL CHECK (src_plane IN ('content', 'continuity', 'knowledge')),
  src_type TEXT NOT NULL,
  src_id TEXT NOT NULL,
  
  -- Destination (what is being referenced)
  dst_plane TEXT NOT NULL CHECK (dst_plane IN ('content', 'continuity', 'knowledge')),
  dst_type TEXT NOT NULL,
  dst_id TEXT NOT NULL,
  
  -- Relationship metadata
  edge_type TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  created_by TEXT,
  metadata JSON,
  
  -- Constraints
  UNIQUE(src_plane, src_type, src_id, dst_plane, dst_type, dst_id, edge_type)
);

-- Indexes for efficient lookups
CREATE INDEX idx_cpr_src ON cross_plane_refs(src_plane, src_type, src_id);
CREATE INDEX idx_cpr_dst ON cross_plane_refs(dst_plane, dst_type, dst_id);
CREATE INDEX idx_cpr_edge ON cross_plane_refs(edge_type);
```

### Edge Types

| Edge Type | From | To | Meaning |
|-----------|------|-----|---------|
| `DOCUMENTS` | Content | Continuity | Content explains decision |
| `REFERENCES` | Content | Knowledge | Content cites spec/module |
| `INFORMS` | Continuity | Knowledge | Decision shapes system |
| `AFFECTS` | Continuity | Knowledge | Decision impacts code |
| `MOTIVATED_BY` | Knowledge | Continuity | Spec driven by decision |
| `VERIFIED_BY` | Knowledge | Continuity | Test evidence in progress |
| `DESCRIBES` | Content | Knowledge | Doc describes spec |

---

## Integration Flows

### Flow 1: Content → Knowledge (Publishing Flow)

```text
┌────────────────┐      ┌────────────────┐      ┌────────────────┐
│  CONTENT       │      │    BUILD       │      │   KNOWLEDGE    │
│  PLANE         │─────►│    PROCESS     │─────►│   PLANE        │
│                │      │                │      │                │
│ docs/specs/    │      │ • Parse spec   │      │ Spec node      │
│ checkout.md    │      │ • Validate     │      │ created with   │
│                │      │ • Extract IDs  │      │ links to code  │
└────────────────┘      └────────────────┘      └────────────────┘

Example: A spec document in content/ is parsed, and a Spec node is 
created in the Knowledge Plane, linked to implementing code modules.
```

### Flow 2: Process → Continuity (Decision Flow)

```text
┌────────────────┐      ┌────────────────┐      ┌────────────────┐
│  PROCESS       │      │  CONTINUITY    │      │   KNOWLEDGE    │
│  (PR/Meeting)  │─────►│  PLANE         │─────►│   PLANE        │
│                │      │                │      │                │
│ "We decided    │      │ ADR-0042       │      │ ADR INFORMS    │
│  to use        │      │ created with   │      │ Contract:      │
│  SQLite"       │      │ rationale      │      │ query-api      │
└────────────────┘      └────────────────┘      └────────────────┘

Example: A decision made in a PR or meeting becomes an ADR in 
Continuity, which is then linked to affected Knowledge artifacts.
```

### Flow 3: Knowledge → Continuity (Rationale Lookup)

```text
┌────────────────┐      ┌────────────────┐      ┌────────────────┐
│  DEVELOPER     │      │   KNOWLEDGE    │      │  CONTINUITY    │
│  QUESTION      │─────►│   PLANE        │─────►│  PLANE         │
│                │      │                │      │                │
│ "Why is this   │      │ Contract:      │      │ Returns        │
│  contract      │      │ checkout-api   │      │ ADR-0042 with  │
│  shaped this   │      │ ─────────────► │      │ full rationale │
│  way?"         │      │ MOTIVATED_BY   │      │                │
└────────────────┘      └────────────────┘      └────────────────┘

Example: Engineer queries why a contract is designed a certain way;
Knowledge Plane follows MOTIVATED_BY edge to find the decision.
```

### Flow 4: Continuity → Knowledge (Impact Analysis)

```text
┌────────────────┐      ┌────────────────┐      ┌────────────────┐
│  DECISION      │      │  CONTINUITY    │      │   KNOWLEDGE    │
│  CHANGE        │─────►│  PLANE         │─────►│   PLANE        │
│                │      │                │      │                │
│ "ADR-0042 is   │      │ Find all       │      │ Returns:       │
│  being         │      │ AFFECTS/       │      │ • 5 contracts  │
│  superseded"   │      │ INFORMS edges  │      │ • 12 modules   │
│                │      │                │      │ • 8 tests      │
└────────────────┘      └────────────────┘      └────────────────┘

Example: When superseding a decision, Continuity queries Knowledge 
to understand full impact (blast radius) of the change.
```

### Flow 5: Continuity → Insight (Learning Flow)

```text
┌────────────────┐      ┌────────────────┐      ┌────────────────┐
│  CONTINUITY    │      │    INSIGHT     │      │  CONTINUITY    │
│  PLANE         │─────►│    PROCESS     │─────►│  PLANE         │
│                │      │                │      │                │
│ • Progress     │      │ Postmortem     │      │ New ADR        │
│ • Sessions     │      │ analysis       │      │ capturing      │
│ • Decisions    │      │ extracts       │      │ learnings      │
│                │      │ patterns       │      │                │
└────────────────┘      └────────────────┘      └────────────────┘

Example: Insight process analyzes Continuity data (progress logs,
decisions) and creates new decisions based on learnings.
```

---

## Query Patterns

### Within-Plane Queries

**Content Plane:**
```sql
-- Find all pricing entities
SELECT * FROM documents WHERE type = 'entity' AND subtype = 'pricing';

-- What references this entity?
SELECT src_type, src_id FROM refs WHERE dst_id = 'pricing:widget-pro';
```

**Continuity Plane:**
```sql
-- All decisions made this quarter
SELECT * FROM decisions 
WHERE date >= '2025-10-01' AND status = 'accepted';

-- Progress for a session
SELECT * FROM progress_events WHERE session_id = 'abc123' ORDER BY ts;
```

**Knowledge Plane:**
```sql
-- What tests verify this spec?
SELECT t.id, t.status FROM tests t
JOIN spec_coverage sc ON sc.test_id = t.id
WHERE sc.spec_id = 'checkout-api';

-- Modules affected by vulnerability
SELECT m.* FROM modules m
JOIN sbom_usage su ON su.module_id = m.id
WHERE su.component_id = 'lodash@4.17.20';
```

### Cross-Plane Queries

**"Why is this contract shaped this way?"**
```sql
SELECT d.id, d.title, d.rationale, d.date
FROM continuity.decisions d
JOIN cross_plane_refs cpr 
  ON cpr.src_plane = 'continuity' 
  AND cpr.src_type = 'decision' 
  AND cpr.src_id = d.id
WHERE cpr.dst_plane = 'knowledge'
  AND cpr.dst_type = 'contract'
  AND cpr.dst_id = 'checkout-api'
  AND cpr.edge_type = 'INFORMS';
```

**"What decisions affect checkout modules?"**
```sql
SELECT d.id, d.title, cpr.dst_id as affected_module
FROM continuity.decisions d
JOIN cross_plane_refs cpr 
  ON cpr.src_plane = 'continuity' 
  AND cpr.src_id = d.id
WHERE cpr.dst_plane = 'knowledge'
  AND cpr.dst_type = 'module'
  AND cpr.dst_id LIKE '%checkout%'
  AND cpr.edge_type = 'AFFECTS';
```

**"What content documents this decision?"**
```sql
SELECT c.id, c.title, c.path
FROM content.documents c
JOIN cross_plane_refs cpr 
  ON cpr.src_plane = 'content' 
  AND cpr.src_id = c.id
WHERE cpr.dst_plane = 'continuity'
  AND cpr.dst_id = 'ADR-0042'
  AND cpr.edge_type = 'DOCUMENTS';
```

---

## Lifecycle Comparison Matrix

| Aspect | Content Plane | Continuity Plane | Knowledge Plane |
|--------|---------------|------------------|-----------------|
| **Source** | Authored files | Authored + generated | Generated from code/CI |
| **Storage** | `content/` | `.continuity/` | `.harmony/knowledge/` |
| **Mutability** | Mutable (versioned) | Type-specific rules | Mutable (provenance) |
| **Conflict Strategy** | Git merge | Per-session isolation | Idempotent upsert |
| **Deletion** | Soft-delete | Never (supersede) | Archive with history |
| **Validation** | Schema + envelope | Schema + lifecycle | Automated ingestion |
| **Build Output** | SQLite + JSON | SQLite + JSON | Graph + SQLite |

### Lifecycle Rules by Artifact Type

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LIFECYCLE RULES MATRIX                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CONTENT PLANE                                                              │
│  ├── Entities ────────── Mutable, schema-validated, versioned               │
│  ├── Documents ───────── Mutable, envelope-required, versioned              │
│  ├── Compositions ────── Mutable, reference-resolved, versioned             │
│  └── Prompts ─────────── Mutable, compiled deterministically                │
│                                                                             │
│  CONTINUITY PLANE                                                           │
│  ├── Decisions ───────── IMMUTABLE after merge (supersede to change)        │
│  ├── Handoffs ────────── Session-scoped SNAPSHOTS (one per session)         │
│  ├── Progress Events ─── APPEND-ONLY (per-session NDJSON files)             │
│  ├── Backlogs ────────── Mutable with full git history                      │
│  └── Plans/Risks ─────── Snapshot, overwrite (git provides history)         │
│                                                                             │
│  KNOWLEDGE PLANE                                                            │
│  ├── Specs ───────────── Derived from content, auto-updated                 │
│  ├── Contracts ───────── Ingested from OpenAPI, versioned                   │
│  ├── Code Modules ────── Indexed from AST, updated on change                │
│  ├── Tests ───────────── Results ingested from CI                           │
│  ├── Traces ──────────── Ingested from telemetry (TTL applies)              │
│  └── SBOM ────────────── Generated at build, versioned                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Pillar Alignment

| Pillar | Primary Plane | Secondary Planes | Role |
|--------|---------------|------------------|------|
| **Direction** | Continuity | Content | Specs become decisions; validated requirements preserved |
| **Focus** | Content | Continuity | Kit docs in Content; kit decisions in Continuity |
| **Velocity** | Knowledge | Continuity | Tests/traces verify; progress tracks flow |
| **Trust** | Knowledge | Continuity | Contracts enforce; decisions explain governance |
| **Continuity** | **Continuity** | All | Primary plane for institutional memory |
| **Insight** | (Process) | Continuity, Knowledge | Draws from both; creates new decisions |

---

## Implementation Checklist

### Phase 1: Foundation
- [ ] Create `.continuity/` directory structure
- [ ] Define Continuity schemas in `content/_schemas/continuity/`
- [ ] Implement cross-plane reference resolution
- [ ] Add cross_plane_refs table to build output

### Phase 2: Integration
- [ ] Update Content Plane build to emit cross-plane links
- [ ] Update Knowledge Plane ingestion to index ADR effects
- [ ] Implement unified query API with plane routing
- [ ] Add CI validation for lifecycle rules

### Phase 3: Tooling
- [ ] CLI commands for cross-plane queries
- [ ] Agent context loading from Continuity
- [ ] Handoff generation tooling
- [ ] Decision impact analysis

---

## Related Documentation

- [Content Plane](../content-plane/README.md) — Published content infrastructure
- [Continuity Plane](./continuity-plane.md) — Process knowledge preservation
- [Knowledge Plane](../knowledge-plane/knowledge-plane.md) — System knowledge graph
- [Pillars Overview](../../pillars/README.md) — The six pillars framework

