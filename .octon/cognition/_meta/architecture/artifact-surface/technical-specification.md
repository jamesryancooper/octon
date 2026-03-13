# Artifact Surface Technical Specification

> **Normative language:** MUST / SHOULD / MAY are used as RFC-style requirements.

## Terminology

- **Document**: any addressable content unit with `(type, id, locale)` identity.
- **Envelope**: required metadata header for a document (risk, surface, provenance, etc.).
- **Block**: a typed content fragment (hero, pricing, prose, cta…) used in compositions and exports.
- **Reference**: a stable pointer to a document: `ref:<type>:<id>[@locale]`.
- **IR**: Intermediate Representation—destination-neutral JSON form compiled from documents.
- **HAG**: Octon Artifact Graph—compiled indexes + dependency graph.
- **Canonical Content**: content stored in `content/` as the authoritative source of truth—git-tracked, schema-validated.
- **Continuity Artifacts**: state stored in `.octon/continuity/` with continuity lifecycle rules (append-first log + structured mutable state).
- **Runtime Artifacts**: dynamic data that overlays canonical content at request time (see [runtime-artifact-layer.md](./runtime-artifact-layer.md) for complete specification).

---

## Repository Layout

HAS MUST treat the following as **artifact roots**:

- `content/` — canonical content (public/internal/agent).
- `.octon/continuity/` — continuity artifacts (internal/agent-facing), validated and indexed.
- `assets/` — static assets and asset manifests.

### 5.2.1 Directory tree

```text
content/
  _meta/
    surfaces.yaml
    locales.yaml
    taxonomy.yaml
    governance.yaml
  _schemas/
    README.md
    index.ts
    document.ts
    entity/
      product.schema.ts
      pricing.schema.ts
      ...
    prose/
      doc.schema.ts
      adr.schema.ts
      decision.schema.ts
      ...
    composition/
      page.schema.ts
      email.schema.ts
      ...
    continuity/
      task.schema.ts
      entity.schema.ts
      next.schema.ts
      run-receipt.schema.ts
      ...
  public/
    entities/
      product/
        widget-pro.yaml
      pricing/
        widget-pro.yaml
      legal/
        standard-disclaimer.yaml
    prose/
      docs/
        getting-started.md
      blog/
        2025-12-octon-artifact-surface.md
      snippets/
        billing-terms.md
    compositions/
      page/
        widget-pro.page.yaml
      email/
        widget-pro-launch.email.yaml
  internal/
    prose/
      adrs/
        ADR-0042-use-sqlite-index.md
      runbooks/
        incident-content-publish.md
    compositions/
      page/
        internal-onboarding.page.yaml
  agent/
    prompts/
      blog-writer.prompt.md
      content-migration.prompt.md
    packs/
      onboarding.pack.yaml
      release-context.pack.yaml

.octon/continuity/
  log.md
  tasks.json
  entities.json
  next.md
  runs/
    retention.json

assets/
  manifest.yaml
  images/
  videos/

.octon/
  content/
    content.sqlite
    content.json
    graph.json
    search/
  leases/            # local/harness coordination (gitignored by default)
  cache/
  reports/
    validation.json
    convivial.json
    governance.json
```

The baseline artifact-surface repo layout and generated output directory align with the spec's canonical structure and `.octon/content` artifacts.

### Naming conventions

- **Type directories** MUST be singular domains (`product`, `pricing`, `page`, `email`, `adr`).
- **IDs** MUST be lowercase kebab-case unless a type mandates otherwise (e.g., ADR numbers).
- **File name** MUST equal document ID for single-file docs:

  - `content/public/entities/product/widget-pro.yaml` ⇒ `type=product`, `id=widget-pro`
- **Locales**:

  - Default locale file uses base name.
  - Non-default locale uses suffix: `widget-pro.de.yaml` or frontmatter `locale: de` (choose one convention and enforce; see §5.4.5).

---

## Content Modeling

### Content type taxonomy

HAS MUST support these primary categories (conceptual; implementation is via schemas):

1. **Entities** (structured state): products, pricing, features, legal clauses, taxonomy terms.
2. **Prose** (narrative): docs, blog posts, ADRs/decisions, runbooks, handoffs.
3. **Compositions** (assemblies): pages, emails, agent packs, app screens; built from blocks referencing entities/prose.
4. **Continuity artifacts (Continuity)**: backlog, plan, risks, progress events, handoffs, decisions. These share the artifact surface but have lifecycle rules (append-only, session-scoped).

### The envelope (required metadata)

Every document MUST be representable as an envelope + body/blocks.

**Envelope fields (minimum):**

- `type` (string)
- `id` (string)
- `locale` (string; default from repo config)
- `surface` (`public` | `internal` | `agent`)
- `status` (`draft` | `published` | `archived`)
- `risk_tier` (`low` | `medium` | `high` | `critical`)
- `agent_editable` (boolean)
- `requires_approval` (array of reviewers/teams)
- `provenance` (author/reviewer/agent-run IDs)
- `tags` (string[])

**Governance defaults** MAY be inherited from nearest `_meta.yaml` / directory governance definition (see §5.7).

### Entity documents

**Format:** YAML (preferred) or JSON. Spec v0.1: "Entities are YAML/JSON files, validated against Zod schemas."

Example:

```yaml
# content/public/entities/product/widget-pro.yaml
$schema: octon://schemas/product@1
type: product
id: widget-pro
locale: en
surface: public
status: published

title: "Widget Pro"
summary: "Fast sync for teams"
risk_tier: medium
agent_editable: true
requires_approval: []

tags: [product, sync]

pricing:
  ref: pricing:widget-pro

features:
  - ref: feature:fast-sync
  - ref: feature:offline-mode

provenance:
  author: agent:promptkit-run-abc123
  reviewed_by: human:james
  trace_id: otel-trace-xyz
```

### Prose documents

**Format:** Markdown (`.md`) with YAML frontmatter. MDX MAY be allowed only in `content/**/prose/components/` and MUST be `risk_tier: medium` or lower unless explicitly approved.

Prose files MUST include frontmatter:

```markdown
---
$schema: octon://schemas/doc@1
type: doc
id: getting-started
surface: public
status: published
title: "Getting Started"
risk_tier: low
agent_editable: true
tags: [docs, onboarding]
---

# Getting Started

Welcome to Octon…

:::octon-include ref="ref:snippet:billing-terms"
:::
```

**Restricted transclusion:** if includes are supported, they MUST be implemented as a compiler transform with strict boundaries (e.g., only include `snippet` type), consistent with the spec's transclusion policy.

### Compositions and blocks

Compositions MUST be YAML/JSON and describe **typed blocks** that reference entities/prose.

Example:

```yaml
# content/public/compositions/page/widget-pro.page.yaml
$schema: octon://schemas/page@1
type: page
id: widget-pro
locale: en
surface: public
status: published

route: "/products/widget-pro"
layout: "product"

risk_tier: medium
agent_editable: true
requires_approval: []

blocks:
  - kind: hero
    heading: "Widget Pro"
    subheading: "Fast sync for teams"
  - kind: pricing
    pricing: ref:pricing:widget-pro
  - kind: prose
    prose: ref:doc:widget-pro-body
```

The "envelope + blocks" approach is the explicit resolution of v2/v3 convergence: **use envelope-first for high reuse** and typed block structures.

### Continuity Plane Integration

> **Note**: `/.octon/continuity/` is the canonical storage location for the **Continuity Plane**. See [Continuity Plane](../../../../continuity/_meta/architecture/continuity-plane.md) for full specification.

HAS MUST treat `/.octon/continuity/` as a **first-class artifact root**, even though it is owned by the Continuity Plane. The Artifact Surface build pipeline validates and indexes Continuity artifacts alongside canonical content.

**Artifacts indexed from Continuity Plane:**

| Artifact | Path | Schema Required |
|----------|------|-----------------|
| Activity log | `.octon/continuity/log.md` | Yes (append-first markdown contract) |
| Active tasks | `.octon/continuity/tasks.json` | Yes (canonical schema) |
| Entity ledger | `.octon/continuity/entities.json` | Yes (canonical schema) |
| Next actions | `.octon/continuity/next.md` | Yes (coherence contract with tasks) |
| Run receipts/evidence | `.octon/continuity/runs/**` | Yes (retention-class contract) |

**Format guidance**: YAML/JSON for state, Markdown for narrative, logs append-only.

**Special lifecycle rules (enforced by Continuity Plane):**

| Artifact | Lifecycle | Rule |
|----------|-----------|------|
| **log.md** | Append-first | Add entries; avoid destructive rewrites except factual corrections |
| **tasks.json** | Mutable | Keep status/ownership/blockers/acceptance criteria coherent |
| **entities.json** | Mutable | Preserve stable IDs and ownership linkage to tasks |
| **next.md** | Mutable | Keep concise and aligned with active unblocked task IDs |
| **runs/** | Append-oriented evidence | Govern by `runs/retention.json`; do not replace active task state |

HAS MUST enforce these lifecycle rules in CI by verifying append-first behavior, schema conformance, and retention-class policy checks.

### ADR Ownership Clarification

ADRs may appear in two locations with different purposes:

| Location | Plane | Purpose | Lifecycle |
|----------|-------|---------|-----------|
| `content/internal/prose/adrs/` | Artifact Surface | Published ADR documentation for internal reference | Mutable (artifact-surface rules) |
| `.octon/cognition/runtime/decisions/` | Knowledge Plane | **Source of truth** for durable decision records | Immutable-by-record (supersede via new ADR) |

The **Knowledge Plane owns durable decisions** (rationale, context, alternatives). Artifact Surface may publish ADR documentation for internal reference. Continuity links active work to decision IDs for execution traceability.

See [Foundational Planes Integration](../../../../continuity/_meta/architecture/three-planes-integration.md) for complete boundary definitions.

---

## Schema System

### Schema technology

HAS MUST use **Zod** for schema validation and TypeScript typing.

### Schema module contract

Schema modules MUST live in `content/_schemas/**` and export:

```ts
// content/_schemas/entity/product.schema.ts
import { z } from "zod";
import type { SchemaModule } from "../document";

export const version = 1;

export const schema = z.object({
  $schema: z.string().optional(),
  type: z.literal("product"),
  id: z.string(),
  locale: z.string().default("en"),
  surface: z.enum(["public", "internal", "agent"]),
  status: z.enum(["draft", "published", "archived"]).default("draft"),
  title: z.string(),
  summary: z.string().optional(),
  tags: z.array(z.string()).default([]),

  risk_tier: z.enum(["low", "medium", "high", "critical"]).default("low"),
  agent_editable: z.boolean().default(true),
  requires_approval: z.array(z.string()).default([]),

  pricing: z.object({ ref: z.string() }),
  features: z.array(z.object({ ref: z.string() })).default([]),

  provenance: z
    .object({
      author: z.string(),
      reviewed_by: z.string().optional(),
      trace_id: z.string().optional(),
    })
    .optional(),
});

export const module: SchemaModule = {
  type: "product",
  version,
  schema,
  migrations: [
    // v0 -> v1, etc.
  ],
};
```

This aligns with the spec's schema registry concept (TypeScript modules exporting schema and migrations).

### Schema versioning

- Every schema MUST have an integer `version`.
- Every document MUST declare a `$schema` URI:

  - `octon://schemas/<type>@<version>`
- HAS MUST fail validation if:

  - `$schema` is missing, unknown, or version mismatch (unless configured for soft-accept during migration windows).

### Migrations

HAS MUST provide:

- `octon-content migrate --from <v> --to <v>` to update files in place (with a dry-run option).
- Schema modules MUST define migrations as pure functions `old -> new`.

**Migration policy:**

- Migrations MUST be deterministic and idempotent.
- Migrations MUST preserve semantic meaning; if not possible, tool MUST emit a "needs human review" report.

### Localization

HAS MUST support locale variants:

- `ref:<type>:<id>@<locale>` is canonical reference syntax.
- Default locale is defined in `content/_meta/locales.yaml`.
- Documents SHOULD be stored either:

  - as separate locale files (`widget-pro.de.yaml`), or
  - as a directory per locale (`de/widget-pro.yaml`)

Pick one and enforce; default recommendation: **file-suffix per locale** for small repos.

---

## Reference Syntax and Resolution

### Reference grammar

HAS MUST implement:

- Canonical form: `ref:<type>:<id>[@<locale>]`
- Examples:

  - `ref:product:widget-pro`
  - `ref:pricing:widget-pro@de`

### Where references may appear

References MAY appear in:

- YAML/JSON entity fields (as strings or `{ ref: "..." }` objects)
- Composition block fields
- Prose directives/shortcodes (restricted; see §5.3.4)

### Resolution rules

During compilation:

1. Unqualified locale refs (`ref:product:widget-pro`) resolve to:

   - target in same locale if exists, else default locale.
2. A ref MUST resolve to exactly one document; otherwise compilation fails.
3. The compiler MUST emit:

   - `refs` table rows (source → target)
   - `graph.json` adjacency lists (impact analysis)

### No implicit string linking

HAS MUST NOT treat "mentions" (string occurrences) as references. Only explicit refs are dependency edges (this is how we avoid Knut's "markdown has strings, not entities" trap).

---

## Build Pipeline

### Pipeline stages

HAS compiler stages MUST be:

1. **Discover**: find documents in artifact roots; apply ignore rules.
2. **Parse**: YAML/JSON/frontmatter + Markdown to AST.
3. **Validate**: schema validation + lifecycle validation + governance metadata merge.
4. **Resolve**: resolve refs; build dependency graph.
5. **Normalize**: produce IR documents with typed blocks and resolved links.
6. **Index**: write SQLite + JSON + FTS + graph outputs.
7. **Transform/Export**: produce destination artifacts (HTML/email/agent packs/search).

This matches and extends the spec's described compiler pipeline and commands.

### CLI commands and contracts

HAS MUST provide a CLI `octon-content` (or `octon content`) with:

- `validate`

  - Validates schemas, refs, lifecycle rules, governance rules.
  - Exit code `0` on success; `1` on errors; `2` on config errors.
- `build`

  - Runs full pipeline; writes artifacts under `.octon/content`.
- `query <sql>` (dev mode)

  - Runs SQL against `.octon/content/content.sqlite`.
- `where <dsl>` (optional)

  - A small convenience DSL compiled to SQL (see §5.8.3).
- `refs <ref>`

  - Prints inbound/outbound references + impacted compositions.
- `export <destination>`

  - Runs only render/export stages for one destination.
- `migrate`

  - Applies schema migrations.

Spec v0.1 already defines `validate`, `build`, `query`, and `where` and output behavior.

### Incremental builds (required)

To stay within Octon's "absorbed complexity," HAS SHOULD support incremental builds by default:

- Maintain `.octon/cache/manifest.json` mapping `source_path → content_hash → outputs`.
- On build:

  - Re-parse/validate only changed docs and affected dependents (via graph).
  - Rebuild indexes incrementally if possible; otherwise rebuild SQLite in <30s for typical Octon repos.

---

## Governance and Validation Gates

### Risk tiers

HAS MUST support risk tiers consistent with v1's governance table:

- **Low**: blog posts, changelogs
- **Medium**: product pages, feature pages
- **High**: pricing, positioning, competitive claims
- **Critical**: legal/compliance language; agents forbidden

### Directory governance via `_meta.yaml`

Any directory MAY include `_meta.yaml` defining defaults:

```yaml
# content/public/entities/legal/_meta.yaml
risk_tier: critical
requires_approval: [legal-team, compliance]
agent_editable: false
review_cadence: quarterly
owner: legal@company.com
```

This pattern is explicitly defined in v1.

### Content Decision Records (CDRs)

For `risk_tier >= high`, HAS SHOULD require a **CDR** (Content Decision Record) or an ADR link, as in v1.

Minimum rule:

- Any PR touching `high` or `critical` content MUST reference a CDR/ADR id in PR description or in a change manifest.

### Agent guardrails

HAS MUST support metadata-based constraints:

- If `agent_editable: false`, automated agents MUST NOT modify the doc.
- If `risk_tier: critical`, agents MUST NOT propose direct edits; they may draft a patch in a separate file or propose changes for human copy/paste.

v2 and v1 both specify `agent_editable` and risk-tier gates.

### CI gates

At minimum, CI MUST run:

- `octon-content validate` (schemas + refs + lifecycles)
- Governance check (risk tier approvals / CODEOWNERS)
- Link integrity (internal links + ref validity)
- Security scan (XSS vectors, secrets/PII heuristics)
- Convivial lint (see §6) for `high` and shared content

A representative workflow exists in v1.

---

## Query Layer

### Overview

HAS MUST provide **build-time indexing** into SQLite as the primary query layer, plus JSON exports for framework builds. This directly resolves "grep ≠ query" concerns.

### SQLite schema (normative)

HAS MUST write `.octon/content/content.sqlite` with:

**Core tables (compatible with spec v0.1 minimal set):**

- `entities(type, id, locale, surface, risk_tier, json)`
- `prose(id, locale, surface, kind, title, md, ast_json, excerpt)`
- `compositions(type, id, locale, surface, route, json)`
- `refs(src_type, src_id, src_locale, dst_type, dst_id, dst_locale, kind, path)`
- `assets(path, hash, mime, meta_json)`

**Additional normalization tables (required in v1.0):**

- `documents(doc_key PRIMARY KEY, type, id, locale, surface, status, title, risk_tier, agent_editable, source_path, updated_at)`

  - where `doc_key = type || ":" || id || "@" || locale`
- `document_tags(doc_key, tag)` with index on `(tag)`
- `document_blocks(doc_key, block_index, kind, json)` (for typed block queries)
- `continuity_events(session_id, ts, actor, action, json)` (from NDJSON parsing)

**FTS (recommended):**

- `prose_fts` FTS5 over `(doc_key, title, body)`.

This addresses the v2+v3 requirement to avoid "LIKE everywhere" and instead use join tables and indexes.

### Query helpers and optional DSL

HAS SHOULD ship:

- A TypeScript library `@octon/content` that:

  - reads `content.sqlite` or `content.json`
  - provides typed getters: `getEntity`, `getProse`, `getPageByRoute`
  - provides query helpers with safe parameterization

Optional convenience DSL (`where`) MAY support simple filters:

```txt
# Example DSL
type=page surface=public tag=docs sort=updated_at desc limit=10
```

Compiled to SQL.

### Example queries

**1) Find all pages impacted by a pricing change**:

```sql
SELECT src_type, src_id, src_locale
FROM refs
WHERE dst_type = 'pricing' AND dst_id = 'widget-pro';
```

**2) Find all "enterprise" content not translated to German**:

```sql
SELECT d.type, d.id
FROM documents d
JOIN document_tags t ON t.doc_key = d.doc_key
WHERE t.tag = 'enterprise'
  AND d.locale = 'en'
  AND NOT EXISTS (
    SELECT 1 FROM documents d2
    WHERE d2.type = d.type AND d2.id = d.id AND d2.locale = 'de'
  );
```

**3) Find all decisions related to auth (Knowledge Plane query)**:
(Durable decision records are owned by the Knowledge Plane)

```sql
SELECT d.decision_id, d.title, d.summary
FROM knowledge_decisions d
WHERE d.kind IN ('adr', 'decision')
  AND (d.title LIKE '%auth%' OR d.summary LIKE '%auth%');
```

**4) Find Knowledge Plane modules affected by a decision**:
(Cross-plane join; see [Foundational Planes Integration](../../../../continuity/_meta/architecture/three-planes-integration.md))

```sql
SELECT cpr.dst_id as module_path, d.title as decision_title
FROM cross_plane_refs cpr
JOIN knowledge_decisions d ON d.decision_id = cpr.src_id
WHERE cpr.src_plane = 'knowledge'
  AND cpr.dst_plane = 'knowledge'
  AND cpr.edge_type = 'AFFECTS'
  AND d.title LIKE '%auth%';
```

---

## Collaboration Model

### Collaboration assumptions

- Octon defaults to **git PR workflows** (small diffs, frequent merges).
- Real-time collaboration is not assumed; instead mitigate semantic conflicts using granularity and coordination (Knut highlights why prose conflicts are semantic and why teams end up using lock files and "don't touch it" workarounds).

### Agent coordination roles (Continuity + Knowledge aligned)

HAS SHOULD assume four roles aligned with the [Continuity Plane](../../../../continuity/_meta/architecture/continuity-plane.md) and [Knowledge Plane](../../../runtime/knowledge/knowledge.md):

| Role | Artifact Surface Responsibilities | Continuity Responsibilities | Knowledge Responsibilities |
|------|-------------------------------|---------------------------|----------------------------|
| **Orchestrator** | Assigns write sets, manages leases | Creates sessions and updates active task state | Links planned work to durable decision/context artifacts |
| **Implementer** | Edits artifact files within assigned write set | Records progress in continuity state | References relevant specs/contracts/decisions |
| **Archivist** | Updates published internal documentation | Maintains coherent handoff-ready continuity artifacts | Maintains durable decision/evidence indexes |
| **Verifier** | Runs validation and confirms acceptance criteria | Records verification status transitions | Records evidence links for traceability queries |

Continuity artifacts and templates exist under `.octon/continuity/` and MUST be validated alongside Artifact Surface artifacts. See [Continuity Plane](../../../../continuity/_meta/architecture/continuity-plane.md) for session lifecycle and handoff protocols.

### Leasing (advisory locks)

HAS MUST implement lease files (spec v0.1):

- Location: `.octon/leases/<type>.<id>.json`
- Fields: `content_id`, `holder`, `mode`, `expires_at`

Lease semantics:

- `exclusive` lease: only one holder may write.
- `shared-read` lease: multiple readers allowed, no writers.

**Lease workflow:**

- Agents MUST acquire a lease before editing a document.
- Leases MUST be short-lived (default TTL 15–30 minutes) and renewable.
- Lease files SHOULD be gitignored and used for coordination in a shared harness/workspace.

### Preventing collisions on hot files

HAS MUST reduce conflict probability structurally:

1. **Bundle high-risk hotspots** into dedicated documents (pricing entities, legal clauses) referenced everywhere—so edits concentrate in one file and are governed.
2. **Keep continuity logging append-first** (`.octon/continuity/log.md`) and store per-session run evidence under `.octon/continuity/runs/` when needed.
3. **Avoid a single shared locks.yaml**; if you must lock, lock per bundle/document (v2+v3 warns about conflict magnets).
4. For `high/critical` paths, CI SHOULD fail if multiple open PRs modify overlapping "hot sets" (optional GitHub API check).

### CI/CD integration and gates

- `octon-content validate` MUST run in PR CI.
- Governance MUST enforce risk-tier approvals via CODEOWNERS and/or required reviewers (v2 suggests CODEOWNERS patterns).
- PR automation SHOULD:

  - summarize content diffs
  - list impacted routes/emails/packs (from graph)
  - surface risk tier and required approvals (v1 roadmap calls out this automation).

---

## Multi-Destination Publishing

### Intermediate Representation (IR)

HAS MUST compile documents into IR JSON objects that are:

- destination-neutral
- fully resolved (refs expressed as explicit links + embedded summaries)
- stable across frameworks

v3 gives the canonical rationale and a representative IR shape.

**IR Document (normative minimum):**

```json
{
  "doc_key": "page:widget-pro@en",
  "type": "page",
  "id": "widget-pro",
  "locale": "en",
  "surface": "public",
  "status": "published",
  "route": "/products/widget-pro",
  "risk_tier": "medium",
  "title": "Widget Pro",
  "blocks": [
    { "kind": "hero", "heading": "Widget Pro", "subheading": "Fast sync for teams" },
    { "kind": "pricing", "pricing_ref": "ref:pricing:widget-pro" },
    { "kind": "prose", "prose_ref": "ref:doc:widget-pro-body", "format": "mdast", "ast": { } }
  ],
  "links": ["pricing:widget-pro@en", "doc:widget-pro-body@en"],
  "provenance": { "author": "agent:...", "reviewed_by": "human:..." }
}
```

### Destination renderers

HAS MUST support these renderer interfaces:

- **Web renderer**: IR → HTML/React/Vue templates (framework-specific adapter, not source coupling)
- **App renderer**: IR → JSON payloads for mobile (block mapping)
- **Email renderer**: IR → MJML/HTML + text fallback
- **Agent context exporter**: IR + indexes → "context packs" (chunked markdown + citations + entity bundles)

Destination renderers MUST consume IR, not raw markdown files, to keep frameworks agnostic.

### Consumer access patterns

HAS MUST support **at least** these consumption modes:

1. **Static import** (SSG/SSR build time): import `.octon/content/content.json`
2. **SQLite query** (server-side build or API): query `.octon/content/content.sqlite`
3. **Thin read-only API (optional)**: reads SQLite and serves stable endpoints (recommended for mobile)
4. **Runtime overlay (optional)**: merge canonical content with runtime overrides at request time (see [runtime-artifact-layer.md](./runtime-artifact-layer.md))

v3 gives a Next.js import example and a minimalist Hono API reading SQLite.

When boundary conditions are crossed (see [boundary-conditions.md](./boundary-conditions.md)), additional runtime layers can be added:

- **Tier 1 (Edge Read)**: SQLite replicated to edge (Turso/D1/LiteFS) for global low-latency reads
- **Tier 2 (Central Read)**: Server DB read replicas for complex queries and aggregations
- **Tier 3 (Write)**: Server DB for live updates, personalization, and content changes without deployment

See [runtime-artifact-layer.md](./runtime-artifact-layer.md) for complete runtime artifact layer specification.

### Agent context packs

HAS MUST output agent packs under:

- `.octon/content/agent-packs/<pack-id>/`

  - `pack.md` (assembled narrative context with citations)
  - `entities.json` (subset of entity docs)
  - `graph.json` (optional slice)
  - `queries.sql` (optional saved queries)

Pack assembly SHOULD be driven by composition definitions in `content/agent/packs/*.pack.yaml`.
