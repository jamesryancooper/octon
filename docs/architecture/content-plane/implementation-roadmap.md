# Content Plane Implementation Roadmap

The roadmap is optimized for a solo developer/tiny team building the minimum viable compiler and iterating.

## Phase 0: Conventions and foundation (days)

**Deliverables**:

- Decide repo layout (create directories + starter README).
- Create `content/_meta/` files: `locales.yaml`, `surfaces.yaml`, `taxonomy.yaml`.
- Add `.continuity/` folder with starter templates per Continuity minimum.
- Define initial content type list (product, pricing, page, doc, adr/decision, continuity backlog).

## Phase 1: Core compiler (1–2 weeks)

**Deliverables**:

- File discovery (fast-glob honoring gitignore).
- YAML/JSON parsing + Markdown frontmatter parsing.
- Zod schema registry + `harmony-content validate`.
- Basic reference parsing + resolution (build a refs list).
- Generate `.harmony/content/content.json` (unified docs array).
- First CI workflow running validate.

## Phase 2: Query layer and indexing (1–2 weeks)

**Deliverables**:

- Generate SQLite index `.harmony/content/content.sqlite`.
- Implement `refs` table and `graph.json`.
- Add FTS5 for prose search.
- Implement `harmony-content query` and a small set of canned queries (`impacted-by`, `missing-seo`, `untranslated`).
- Add a "content health report" JSON artifact.

## Phase 3: Normalization and reuse (1 week)

**Deliverables**:

- Implement "envelope + blocks" schemas for compositions.
- Add block normalization into `document_blocks`.
- Add `document_tags` join table.
- Implement restricted `harmony-include` directive for snippets only.
- Add "amplification" detection (ref count threshold) to reports.

## Phase 4: Agent coordination (1 week)

**Deliverables**:

- Implement lease system in `.harmony/leases` per spec.
- Implement "write set" detection (files changed → doc keys).
- Add optional CI overlap check for hot sets (configurable).
- Add lifecycle checks for `.continuity/events/*.ndjson` append-only behavior.

## Phase 5: Multi-destination exports (1 week)

**Deliverables**:

- Implement IR generation for pages/emails/agent packs.
- Build at least two renderers:

  - Web: IR → HTML (minimal template)
  - Agent: IR → context pack markdown + citations + entity bundle
- Build Pagefind search index export (optional but recommended).

## Phase 6: Runtime Read Layer (as needed)

**Deliverables (only if boundary conditions demand—see [boundary-conditions.md](./boundary-conditions.md))**:

- **Tier 1 edge read**: Deploy SQLite to edge (Turso/Cloudflare D1/LiteFS).
- Thin read-only API reading SQLite (Hono/Express).
- CDN configuration for JSON artifact caching.
- Mobile/offline sync support via SQLite replication.

## Phase 7: Runtime Write Layer (as needed)

**Deliverables (only if boundary conditions demand—see [runtime-content-layer.md](./runtime-content-layer.md and [boundary-conditions.md](./boundary-conditions.md))**:

- **Tier 2/3 server DB**: Set up Postgres/Supabase/PlanetScale.
- Schema migration to sync HCG schema to server DB.
- Runtime override tables (personalization, A/B variants, live updates).
- Merge logic for canonical + runtime content at request time.
- Sync-back workflow:
  - Scheduled job to detect runtime changes.
  - PR generation for changed content.
  - Validation that runtime changes conform to schemas.
- `harmony-content runtime:check` CLI command (drift detection).
- `harmony-content runtime:sync` CLI command (PR generation).
- Real-time subscription support (if needed).

## Phase 8: Editor UI & Advanced Features (as needed)

**Deliverables (only if boundary conditions demand)**:

- Optional git-backed editor UI (Keystatic/Decap) for SMEs.
- Embeddings/hybrid search (Orama) if semantic search becomes required.
- Advanced personalization engine (if A/B testing scales significantly).
