# Artifact Surface Architecture Overview

## Final architecture decision

**Name:** **Octon Artifact Surface (HAS)**
**One sentence:** A **flat-file-first artifact compiler** that validates, resolves, indexes, and transforms content files into a **queryable Octon Artifact Graph** and deterministic multi-destination outputs.

## Status

HAS is the canonical architecture surface for the **foundational Artifact Plane**.
Runtime overlay layers are optional extensions.

## Position Relative to the Foundational Planes

HAS implements the Artifact Plane in Octon's canonical model:

| Foundational Plane | Core Question | Primary Surface |
|-------|---------------|-----------|
| Execution Kernel | How is executable work dispatched? | `.octon/engine/runtime/` |
| Service | What typed runtime operations exist? | `.octon/capabilities/runtime/services/` |
| Ingress | How does human intent enter? | `.octon/capabilities/runtime/commands/` |
| Capability | What atomic execution units exist? | `.octon/capabilities/runtime/skills/` |
| Orchestration | How are missions sequenced? | `.octon/orchestration/runtime/workflows/` |
| Assurance | What must pass before completion? | `.octon/assurance/{runtime,practices}/` |
| Continuity | What is active and next? | `.octon/continuity/{log.md,tasks.json,entities.json,next.md}` |
| Knowledge | What durable context/decisions/evidence exist? | `.octon/cognition/runtime/{context,decisions,evidence,evaluations,projections,knowledge-plane}/` |
| **Artifact (HAS)** | What durable outputs/evidence are produced? | `.octon/output/` + this architecture surface |

See [Foundational Planes Integration](../../../../continuity/_meta/architecture/three-planes-integration.md) for cross-plane architecture.

---

## Core design principles

1. **Files are canonical**: source lives in git; outputs are generated.
2. **Structure is explicit**: schemas define contracts; validation is mandatory.
3. **References over duplication**: reuse is via explicit, resolvable IDs.
4. **Query runs on an index**: SQLite/JSON/graph outputs, not grep.
5. **Compiler not product**: minimal runtime; avoid CMS creep.
6. **Agent-first collaboration**: leases + small diffs + deterministic checks.
7. **Continuity is first-class**: Continuity artifacts share schemas/indexing with lifecycle rules.
8. **Runtime extends, not replaces**: when runtime is needed, it overlays canonical content without becoming the source of truth.

## What it IS vs what it is NOT

**HAS IS:**

- A **toolchain** (CLI + library) that compiles content into stable artifacts.
- A **schema registry** for content types (Zod) with migrations.
- A **build-time "content database"** (SQLite) that is regenerated deterministically.
- A **dependency graph** enabling impact analysis ("blast radius").
- A shared infrastructure for **public, internal, and agent continuity** content.

**HAS IS NOT:**

- A hosted CMS or a multi-user editorial product.
- A real-time collaborative editor.
- A workflow engine (draft/review/publish state machines beyond simple metadata).
- A runtime content mutation API with auth/RBAC (unless you explicitly cross boundaries).

## Hard boundaries

Octon explicitly will **not** build:

- WYSIWYG editor, page builder, or visual layout tool.
- Scheduling UI, release calendar, notification system.
- Custom auth/user management beyond git hosting.
- A custom query language server; use SQLite + helpers.
- Bidirectional sync between files and a live database (runtime writes sync back to git via controlled PR workflows—see [runtime-artifact-layer.md](./runtime-artifact-layer.md)).

## The Hybrid Model (Canonical + Runtime)

When boundary conditions are crossed (see [boundary-conditions.md](./boundary-conditions.md)), HAS supports a **hybrid model** where runtime content extends canonical content:

### Content layer hierarchy

| Layer | Storage | Mutability | Purpose |
|-------|---------|------------|---------|
| **Canonical** | `content/` + `.octon/continuity/` in git | Immutable at runtime; changed via PR | Source of truth |
| **Compiled** | `.octon/content/` (HAG) | Regenerated each build | Query layer |
| **Runtime Read** | SQLite at edge (Turso/D1/LiteFS) | Read-only replica | Fast global reads |
| **Runtime Write** | Server DB (Postgres/Supabase) | Mutable | Live overrides, personalization |

### How layers interact

1. **Canonical content** is compiled into the **Octon Artifact Graph (HAG)**
2. **HAG artifacts** (SQLite, JSON) are deployed to runtime infrastructure
3. **Runtime read layer** serves content from edge-replicated SQLite
4. **Runtime write layer** (when needed) overlays canonical with dynamic data
5. **Sync-back workflows** preserve runtime changes in git for auditability

### When to use each layer

| Need | Use Layer |
|------|-----------|
| Content versioning and audit | Canonical (git) |
| Fast global reads | Runtime Read (edge SQLite) |
| Content updates without deploy | Runtime Write (server DB) |
| Personalization / A/B testing | Runtime Write (server DB) |
| Real-time subscriptions | Runtime Write (server DB) |

See [runtime-artifact-layer.md](./runtime-artifact-layer.md) for complete runtime layer specification.

## Synthesis notes

### Consensus across all recommendation versions

- **Flat files stay canonical** (agent-friendly, git-native).
- A **build-time index** (Option B + build-time index / "polyglot persistence") is required to solve **grep ≠ query**.
- **References and a content graph** are required for reuse and impact analysis.
- **Multi-destination output requires an IR** so frameworks consume stable contracts instead of re-parsing markdown in different ways.
- The biggest risk is **CMS creep**, so boundaries must be explicit and revisited.

### Key divergences and final resolutions

- **MDX vs constrained markup**: earlier versions recommend Markdoc for safe transclusion; spec v0.1 uses MDX. Final: **Markdown-first with strict directives**; allow MDX only in explicitly human-owned areas (see "Prose formats"). This preserves agent safety while still supporting component-like blocks. (Rationale: avoid arbitrary JS execution in agent-written content while still enabling reuse.)
- **Surface as folders vs metadata**: final: **both**. Surface is *authoritative metadata*, while folders provide ergonomic defaults and visibility boundaries.
- **Locks.yaml vs per-bundle leasing**: final: **per-content-ID lease files** (no "conflict magnet" lock file), plus optional PR overlap detection.
- **SQLite schema minimal vs relational joins**: final: keep the minimal core tables but add **join tables and indexes** for tags/relations so queries are "real SQL," not string hacks.

### What was well-specified vs underspecified

**Well-specified in the sources:**

- Reference grammar and compile commands.
- Output artifact set (SQLite, JSON, graph) and lease concept.
- Guardrails against CMS creep ("compiler not product").

**Underspecified (resolved here with prescriptive choices):**

- Exact repo layout for three surfaces + Continuity integration.
- Full normalized SQL schema and query helpers.
- Lifecycle enforcement (append-only logs, immutable decisions).
- Multi-destination renderer contracts (IR schema, exporter formats).
- CI enforcement details (risk tiers, approvals, convivial/security lint gates).
