# Runtime Content Layer

This section defines the **optional runtime content layer** that extends the canonical Content Plane when build-time-only content delivery is insufficient. The runtime layer is designed to gracefully extend—not replace—the canonical content model.

---

## Position in Three-Plane Architecture

The Runtime Content Layer extends the **Content Plane** specifically. It does not affect the Continuity Plane or Knowledge Plane, which have their own data models and storage patterns.

```text
┌─────────────────────────────────────────────────────────────────┐
│                     RUNTIME LAYER SCOPE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Content Plane              Continuity Plane    Knowledge Plane│
│   ┌─────────────────┐        ┌────────────┐     ┌────────────┐ │
│   │ Canonical       │        │ Decisions  │     │ Specs      │ │
│   │ content/        │        │ Handoffs   │     │ Contracts  │ │
│   │                 │        │ Progress   │     │ Tests      │ │
│   │ Runtime Layer   │        │            │     │ Traces     │ │
│   │ ◄── Extends     │        │ (No runtime│     │ (No runtime│ │
│   │     here        │        │  layer)    │     │  layer)    │ │
│   └─────────────────┘        └────────────┘     └────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

See [Three Planes Integration](../../../continuity/architecture/three-planes-integration.md) for complete architecture overview.

---

## Canonical vs Runtime Content

### Definitions

| Term | Plane | Definition |
|------|-------|------------|
| **Canonical Content** | Content | Content stored in `content/` as the authoritative source of truth. Git-tracked, schema-validated, and compiled into the Harmony Content Graph (HCG). |
| **Continuity Artifacts** | [Continuity](../../../continuity/architecture/continuity-plane.md) | Content stored in `.continuity/` with special lifecycle rules (append-only logs, immutable decisions, session-scoped handoffs). Owned by Continuity Plane. |
| **Runtime Content** | Content (extension) | Dynamic data that overlays canonical content at request time. May include live overrides, personalization, time-sensitive updates, or data fetched from external systems. |

### Content roots summary

HCP treats the following as **content roots** (indexing content from multiple planes):

| Root | Plane | Type | Description |
|------|-------|------|-------------|
| `content/` | Content | Canonical content | Public, internal, and agent-facing content organized by surface |
| `.continuity/` | [Continuity](../../../continuity/architecture/continuity-plane.md) | Continuity artifacts | Backlog, plans, handoffs, progress events, decisions—with lifecycle rules |
| `.harmony/content/` | Content | Compiled artifacts | SQLite indexes, JSON exports, dependency graphs (generated, not source) |

### The distinction

- **Canonical content** (Content Plane) is the **source of truth** for published content. It lives in git, is versioned, auditable, and deterministically compiled.
- **Runtime content** (Content Plane extension) is an **overlay**. It extends canonical content with dynamic data but does not replace the underlying source of truth.
- **Continuity artifacts** (Continuity Plane) have **special lifecycle semantics** (append-only, session-scoped, immutable-after-merge). They are owned by the Continuity Plane but indexed by the Content Plane build pipeline.

---

## When Runtime Content is Justified

Runtime content becomes necessary when the boundary conditions in [boundary-conditions.md](./boundary-conditions.md) are crossed—specifically when **content must update without deployment**. The following breakdown identifies legitimate runtime use cases by surface.

### Public / External-Facing (strongest case)

| Use Case | Rationale |
|----------|-----------|
| **Time-sensitive updates** | Pricing changes, flash sales, legal/compliance hot-fixes that can't wait for CI/deploy |
| **Personalization** | User-context-aware content: A/B tests, geo-specific content, user preferences |
| **High-frequency publishing** | Content that changes hourly/daily without wanting full deploys |
| **Third-party integrations** | Stock prices, inventory counts, live event data, external API data |
| **Feature flags** | Content variations controlled by runtime configuration |

### Internal (moderate case)

| Use Case | Rationale |
|----------|-----------|
| **Incident response** | Runbooks and operational docs during active incidents (can't wait for CI/deploy) |
| **Real-time dashboards** | Internal metrics or status pages with live data |
| **Rapidly evolving policies** | HR/compliance docs during policy rollouts |
| **Operational state** | On-call schedules, system status, deployment state |

### Agent (selective case)

| Use Case | Rationale |
|----------|-----------|
| **Context injection** | Runtime-fetched entity data (current pricing, inventory) for agent grounding |
| **Dynamic prompt assembly** | Prompts that pull live config or feature flags |
| **Session state** | Active conversation context, user preferences, conversation history |
| **Coordination state** | Real-time lease status, active task assignments across agents |

---

## The Hybrid Model

### Core principle

The runtime layer **extends** canonical content—it does not replace it. This preserves the benefits of git-based content (versioning, auditability, deterministic builds) while enabling dynamic capabilities where needed.

```text
Canonical (git) → Compiled (HCG) → Runtime (overlay) → Consumer
                                         ↓
                    (scheduled sync back to git for persistence)
```

### How the spec supports hybrid gracefully

The Content Plane design already accommodates runtime extension:

1. **Canonical content stays in git** — Source of truth remains versioned and auditable
2. **HCG provides queryable indexes** — SQLite/JSON artifacts can be deployed and read at runtime
3. **Thin read-only API** — [boundary-conditions.md](./boundary-conditions.md) escalation path already includes this as step 2
4. **IR is destination-neutral** — Compiled Intermediate Representation can be consumed by any runtime layer
5. **References are stable** — `ref:<type>:<id>[@locale]` syntax works across canonical and runtime contexts

### Layered architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                     CANONICAL LAYER                              │
│   content/ + .continuity/ → git (source of truth)                     │
│   Versioned, schema-validated, auditable                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ (build via HCP)
┌─────────────────────────────────────────────────────────────────┐
│                    COMPILED LAYER (HCG)                          │
│   .harmony/content/content.sqlite + content.json + graph.json   │
│   Deterministic, regenerated each build                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ (deploy/replicate)
┌─────────────────────────────────────────────────────────────────┐
│                    RUNTIME READ LAYER                            │
│   SQLite (Turso/D1/LiteFS) or replicated HCG                    │
│   Read-heavy, global edge distribution                          │
│   Serves: public pages, API reads, mobile sync, agent context   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ (overlay for dynamic needs)
┌─────────────────────────────────────────────────────────────────┐
│                    RUNTIME WRITE LAYER (optional)                │
│   Server DB (Postgres/Supabase/PlanetScale)                     │
│   Multi-writer, real-time, complex access control               │
│   Serves: live overrides, personalization, A/B, events          │
│   Syncs back to canonical via scheduled PRs or event triggers   │
└─────────────────────────────────────────────────────────────────┘
```

### Data flow patterns

**Pattern 1: Read-only runtime (most common)**:

```text
git → HCP build → SQLite/JSON → Edge CDN → Consumer
```

No runtime writes. Content updates require a build and deploy. Suitable for most public content.

**Pattern 2: Runtime overlay (personalization, A/B)**:

```text
git → HCP build → SQLite → Runtime API → merge(canonical, overlay) → Consumer
                              ↑
                         Runtime DB (overrides, user prefs, experiments)
```

Canonical content provides the base; runtime DB provides overrides merged at request time.

**Pattern 3: Runtime-first with sync-back (high-frequency updates)**:

```text
Runtime DB (live edits) → Consumer
      ↓ (scheduled/triggered)
   Sync job → git PR → Review → Merge → Canonical
```

Content is edited in runtime DB for speed, then synced back to git for persistence and auditability.

---

## Storage Choices for Runtime Content

Storage choice depends on **access patterns and operational requirements**. There is no single correct answer—choose based on your specific needs.

### When SQLite works well

SQLite is excellent for **read-heavy, low-write-concurrency** scenarios:

| Scenario | Why SQLite Works |
|----------|------------------|
| Read-only API over compiled HCG | No write contention; single-file deployment |
| Single-node deployments | No replication complexity |
| Edge/CDN deployments | File-based, easy to replicate to edge locations |
| Mobile offline sync | Embedded database, no server dependency |
| Build artifact consumption | Deterministic, extremely fast reads |

**Modern SQLite extensions** significantly expand SQLite's reach:

| Tool | Capability |
|------|------------|
| **Turso/libSQL** | Distributed SQLite at the edge with replication |
| **LiteFS** | Streaming replication for SQLite (Fly.io) |
| **Litestream** | Continuous SQLite replication to S3/GCS |
| **Cloudflare D1** | Edge SQLite with global distribution |

### When a server database is better

A server database (Postgres, CockroachDB, PlanetScale, Supabase) becomes necessary for:

| Scenario | Why Server DB |
|----------|---------------|
| **Concurrent writes from multiple sources** | SQLite has single-writer limitation |
| **Real-time collaborative editing** | Requires transactions + subscriptions |
| **Multi-tenant content isolation** | Row-level security, per-tenant schemas |
| **High-frequency writes** | User events, telemetry, live content updates |
| **Multi-region strong consistency** | Distributed transactions across regions |
| **Real-time subscriptions** | Postgres LISTEN/NOTIFY, Supabase Realtime |
| **Complex access control** | Per-user content visibility, RBAC |

### Decision matrix

| Requirement | SQLite | Server DB |
|-------------|--------|-----------|
| Read-heavy workload | ✅ Excellent | ✅ Good |
| Write-heavy workload | ⚠️ Limited | ✅ Excellent |
| Concurrent writers | ❌ Single writer | ✅ Multi-writer |
| Edge deployment | ✅ Native | ⚠️ Requires edge proxy |
| Real-time subscriptions | ❌ Not native | ✅ Native (Postgres, Supabase) |
| Operational simplicity | ✅ No server | ⚠️ Requires infrastructure |
| Cost | ✅ Minimal | ⚠️ Scales with usage |

---

## Tiered Runtime Storage Model

The recommended approach is a **tiered model** where each layer serves its appropriate use case:

### Tier definitions

| Tier | Storage | Access Pattern | Use Cases |
|------|---------|----------------|-----------|
| **Tier 0** | Git + HCG | Build-time only | Canonical content, no runtime needs |
| **Tier 1** | SQLite (edge) | Read-only, replicated | Public pages, API reads, agent context |
| **Tier 2** | Server DB (read) | Read-heavy, centralized | Complex queries, aggregations, search |
| **Tier 3** | Server DB (write) | Read-write, multi-user | Live overrides, personalization, events |

### Practical breakdown by surface

| Surface | Tier 0 (Build) | Tier 1 (Edge Read) | Tier 2 (Central Read) | Tier 3 (Write) |
|---------|----------------|--------------------|-----------------------|----------------|
| **Public** | Marketing pages, docs | CDN-served pages | Search, filtering | Personalization, A/B, live pricing |
| **Internal** | ADRs, runbooks, policies | Internal portals | Dashboards | Incident docs, real-time status |
| **Agent** | Prompts, context packs | Agent context injection | Semantic search | Session state, conversation history |
| **Continuity** | Backlog, decisions | Handoff retrieval | Progress analytics | Real-time agent coordination |

### When to escalate tiers

Follow the boundary conditions in [boundary-conditions.md](./boundary-conditions.md):

1. **Stay at Tier 0** (build-only) until you hit a threshold
2. **Move to Tier 1** (edge read) when you need:
   - Global distribution
   - Sub-100ms read latency
   - Offline/mobile support
3. **Move to Tier 2** (central read) when you need:
   - Complex queries across large datasets
   - Aggregations and analytics
   - Full-text semantic search
4. **Move to Tier 3** (write) when you need:
   - Content updates without deployment
   - Multiple concurrent editors
   - Real-time collaboration or subscriptions

---

## Implementation Considerations

### Sync-back to canonical

When using runtime writes (Tier 3), content SHOULD be synced back to git to preserve the source-of-truth model:

**Recommended patterns:**

| Pattern | Trigger | Use Case |
|---------|---------|----------|
| **Scheduled sync** | Cron (hourly/daily) | Low-urgency content updates |
| **Event-triggered sync** | On content publish | Time-sensitive updates |
| **Manual sync** | User action | Editorial workflow with review |
| **Threshold sync** | After N changes | Batch efficiency |

**Sync workflow:**

1. Runtime DB change detected
2. Generate diff against canonical
3. Create PR with changes
4. Automated or human review
5. Merge to canonical
6. Next build incorporates changes

### Conflict resolution

When runtime and canonical diverge:

| Strategy | When to Use |
|----------|-------------|
| **Canonical wins** | Runtime is ephemeral; git is truth |
| **Runtime wins** | Runtime is fresher; sync replaces canonical |
| **Merge with review** | Both have value; human decides |
| **Last-write wins** | Low-stakes content; accept data loss risk |

Default recommendation: **Canonical wins** for structure/schema; **Runtime wins** for dynamic fields (prices, counts, timestamps).

### Schema consistency

Runtime content MUST adhere to the same schemas as canonical content:

- Runtime DB tables SHOULD mirror HCG SQLite schema
- Runtime overrides SHOULD be validated against Zod schemas
- Schema migrations MUST be coordinated across canonical and runtime

### Observability

Runtime layer SHOULD emit:

- Content read latency metrics
- Cache hit/miss rates
- Sync-back success/failure rates
- Schema validation errors
- Stale content alerts (canonical updated but runtime not refreshed)

---

## Avoiding CMS Creep

The runtime layer is an **escape hatch**, not a default. Watch for warning signs that you're building a CMS:

| Warning Sign | Mitigation |
|--------------|------------|
| Building a visual editor | Use git-backed editors (Keystatic/Decap) instead |
| Adding workflow states beyond draft/published | Keep workflow in PR process, not runtime DB |
| Implementing user management/RBAC | Use existing auth (git hosting, SSO); don't build custom |
| Runtime becoming source of truth | Enforce sync-back; make canonical authoritative |
| Spending >1 week on runtime features | Re-evaluate; consider adopting a CMS if needs are genuine |

### Boundary enforcement

HCP SHOULD provide CLI commands to verify runtime/canonical alignment:

- `harmony-content runtime:check` — Compare runtime DB against canonical, report drift
- `harmony-content runtime:sync` — Generate PRs for runtime changes
- `harmony-content runtime:reset` — Reset runtime to match canonical

---

## Summary

The runtime content layer is an **optional extension** that becomes relevant when:

1. Content must update without deployment
2. Personalization or A/B testing is required
3. High-frequency updates exceed deploy cadence
4. Real-time collaboration or subscriptions are needed

**Key principles:**

- **Canonical remains source of truth** — Runtime extends, not replaces
- **Choose storage based on access patterns** — SQLite for reads, server DB for writes
- **Tier appropriately** — Start at Tier 0, escalate only when thresholds are crossed
- **Sync back to git** — Preserve auditability and versioning
- **Avoid CMS creep** — Runtime is an escape hatch, not a product
