# Plan: Retrieval Query Service (`.harmony/capabilities/services/retrieval/query`)

## Context

`retrieval/query` currently exists only as a design guide:

- `.harmony/capabilities/services/retrieval/query/guide.md`

It is not yet a first-class service in the services subsystem:

- no `SERVICE.md`
- no typed schemas, rules, fixtures, or contract invariants
- no registry entry in `.harmony/capabilities/services/manifest.yml` and `.harmony/capabilities/services/registry.yml`
- no command entrypoints for invoking Query through the command layer

This plan turns Query into a contract-rich composite service with a minimal
robust MVP first, then staged expansion to advanced retrieval routes.

---

## Architectural Boundary: Agent-Native, Adapter-External

Query is permanently agent-native. The service implements retrieval using
only the harness tool surface (`read`, `glob`, `grep`, `bash`, `jq`) and
the agent's own reasoning capabilities. There is no dependency on external
retrieval libraries, embedding models, vector databases, or ML inference
runtimes.

External retrieval backends (FAISS, pgvector, ColBERT, networkx, etc.) are
**never implemented inside this service**. If integration with external
backends is needed in the future, it follows the adapter-contract pattern
established by `interfaces/agent-platform`:

- Adapter contracts (metadata, mappings, compatibility, fixtures) live
  under `adapters/<id>/` within the service directory.
- Adapter contracts define the interface; actual implementation lives
  externally.
- The core service functions without any adapter loaded (native-first
  invariant).
- Provider-specific terms are confined to `adapters/` and never appear in
  core service files.

This boundary is permanent, not a staging decision.

---

## Scope and Risk Tier

- **Primary archetype:** Shell/CLI service (agent-interpreted semantic layer)
- **Risk tier:** **B** (cross-module contract + registry + validation + observability coordination)
- **In scope:**
  - Query service contract and implementation plan
  - service registration and governance wiring
  - deterministic retrieval/evidence output for baseline hybrid route
  - test/fixture/eval gates and rollout sequencing
- **Out of scope (permanent):**
  - implementing external retrieval libraries within the service
  - provider-specific hosted vector DB integrations as service internals
  - non-deterministic LTR pipelines without explicit Eval gating
- **Out of scope (initial rollout):**
  - advanced routes behind feature flags (Phase 4)
  - adapter contracts for external backends (future, post-MVP)

---

## Non-Negotiables

1. Query outputs must be grounded and citation-complete at chunk granularity.
2. Evidence packaging must be deterministic for identical inputs + index snapshot.
3. Service contract artifacts are source of truth; implementation follows contract.
4. Query must degrade predictably when index signals are missing.
5. Registration and validation must pass existing service subsystem checks.
6. The service must function without any adapter loaded (native-first invariant).
7. Provider-specific terms are adapter-confined; core files are provider-agnostic.

---

## Signal Architecture

Query retrieves, scores, fuses, and cites using three native signals:

### `keyword`

Deterministic lookup against a pre-built inverted index (`keyword.json`) or
direct grep over chunk text. Index artifacts are built at index time with
`bash`/`awk`/`jq`. At query time: term lookup via `jq` or pattern match via
`grep`. Zero dependencies.

### `semantic`

Agent reads top-N candidates (from keyword and/or graph signals) and scores
them for relevance to the query. The agent is the semantic scorer — not a
workaround but an architectural choice. Full contextual understanding of
both query and chunk content produces higher-quality relevance judgments
than frozen embeddings. Non-deterministic per model invocation, but stable
for identical agent + input + snapshot within a session.

### `graph`

Traverse pre-built link graph (`links.jsonl`) via `jq` filtering or bounded
shell traversal. One edge per line: `{source, target, relation, weight}`.
Deterministic for identical graph snapshot.

### Processing pipeline

```
Query request
  |
  v
[keyword signal] -----> jq/grep over keyword.json ----> ranked chunk IDs + scores
  |
  v
[graph signal] -------> jq over links.jsonl -----------> graph-expanded chunk IDs + scores
  |
  v
[fusion] -------------> RRF or weighted arithmetic ----> merged ranked list
  |
  v
[semantic signal] ----> agent reads top-N chunks ------> rescored ranked list
  |
  v
[citation assembly] --> chunk metadata join -----------> citations + evidence pack
  |
  v
Query response (JSON)
```

Keyword and graph are deterministic. Fusion is pure arithmetic,
deterministic. Semantic is agent-interpreted. Citation assembly is a
lookup join, deterministic. The only non-deterministic step is semantic
scoring, and its determinism boundary is explicitly declared in the
contract.

---

## Target Service Contract (MVP)

### Canonical Actions

1. `ask`:
   - Retrieve, fuse, rescore, and return answer + citations + evidence pack.
2. `retrieve`:
   - Return ranked candidates and score breakdown without answer synthesis.
3. `explain`:
   - Return routing/fusion decisions and per-signal contribution detail.

### Input Contract (MVP fields)

- `command`: `ask | retrieve | explain`
- `query`: string
- `index.snapshot`: explicit snapshot path or ID
- `strategy.use`: subset of `keyword | semantic | graph`
- `strategy.fuse`: `rrf | weighted`
- `strategy.top_k`: integer
- `filters`: optional metadata filters
- `evidence.max_excerpts`: integer cap
- `evidence.max_chars_per_excerpt`: integer cap

### Output Contract (MVP fields)

- `run`: `run_id`, `service_version`, `snapshot_id`
- `answer`: text (for `ask`)
- `candidates`: ranked array with `chunk_id`, `doc_id`, `score`, `signals`
- `citations`: array of `{ chunk_id, locator, confidence }`
- `evidence`: array of excerpt records with bounded text
- `diagnostics`: route/fusion/rescore timings and knobs
- `status`: `success | partial | error` with typed error payload

---

## Phase Plan and Exit Gates

## Phase 0: Contract Skeleton and Service Scaffolding

Deliverables:

1. `.harmony/capabilities/services/retrieval/query/SERVICE.md`
2. `.harmony/capabilities/services/retrieval/query/schema/input.schema.json`
3. `.harmony/capabilities/services/retrieval/query/schema/output.schema.json`
4. `.harmony/capabilities/services/retrieval/query/rules/rules.yml`
5. `.harmony/capabilities/services/retrieval/query/contracts/invariants.md`
6. `.harmony/capabilities/services/retrieval/query/contracts/errors.yml`
7. `.harmony/capabilities/services/retrieval/query/compatibility.yml`
8. `.harmony/capabilities/services/retrieval/query/fixtures/positive.json`
9. `.harmony/capabilities/services/retrieval/query/fixtures/negative.json`
10. `.harmony/capabilities/services/retrieval/query/fixtures/edge.json`
11. `.harmony/capabilities/services/retrieval/query/references/examples.md`
12. `.harmony/capabilities/services/retrieval/query/references/errors.md`
13. `.harmony/capabilities/services/retrieval/query/impl/generated.manifest.json` (stub: `"status": "pending"`)

The input schema must NOT include `adapters`, `rerankers`,
`retriever.engine`, or provider-specific configuration blocks. These are
out of scope permanently for the core contract; adapter contracts define
external integration surfaces separately.

Exit gate:

- Contract completeness meets rich-contract requirements (`schema`, `rules`, `fixtures`, `invariants`, `errors`, `compatibility`).
- Fixture inputs validate against input schema; fixture expected outputs validate against output schema.

## Phase 1: MVP Runtime (Keyword + Semantic + Graph Fusion)

Deliverables:

1. `.harmony/capabilities/services/retrieval/query/impl/query.sh` (shell entrypoint)
2. Signal scripts (`bash` + `jq`), called by `query.sh`:
   - `impl/signals/keyword.sh` — term lookup against `keyword.json` or grep over chunk text.
   - `impl/signals/graph.sh` — bounded traversal over `links.jsonl`.
   - `impl/signals/semantic.sh` — present top-N candidates to agent for relevance scoring.
   - `impl/fusion.sh` — RRF or weighted arithmetic over signal score arrays.
   - `impl/cite.sh` — chunk metadata join for citations and evidence excerpts.
3. Deterministic candidate retrieval from:
   - `indexes/<snapshot>/keyword.json`
   - `indexes/<snapshot>/links.jsonl`
   - `indexes/<snapshot>/chunks.jsonl` (chunk text + metadata, one record per line)
4. Fusion implementation:
   - default `rrf`
   - optional `weighted`
5. Chunk-level citation assembler and evidence excerpt packer.

No external dependencies. No Python. No embedding models. The semantic
signal is agent-interpreted; keyword, graph, fusion, and citation assembly
are pure `bash` + `jq`.

Behavioral requirements:

1. Missing required artifact for enabled signal returns typed error.
2. Missing optional signal yields `partial` with degradation note.
3. Identical inputs and snapshot produce stable candidate ordering for deterministic signals (keyword, graph, fusion, citation). Semantic signal stability depends on agent model determinism and is documented as a known boundary.

Exit gate:

- Fixture suite passes and manual golden-query checks confirm citation correctness.

## Phase 2: Service Registry and Command Wiring

Deliverables:

1. Add `query` service in `.harmony/capabilities/services/manifest.yml`.
2. Add `query` metadata in `.harmony/capabilities/services/registry.yml`.
   - Declare `integratesWith: [index]` (Query reads index artifacts).
3. Update `.harmony/capabilities/services/capabilities.yml`:
   - add `retrieval` to `service_categories`.
4. Add command docs:
   - `.harmony/capabilities/commands/query-ask.md`
   - `.harmony/capabilities/commands/query-retrieve.md`
   - `.harmony/capabilities/commands/query-explain.md`
5. Register commands in `.harmony/capabilities/commands/manifest.yml`.

Service metadata:

- `interface_type`: `shell`
- `category`: `retrieval`
- `status`: `draft` (promoted to `active` after Phase 3 gates pass)

Validation updates:

1. Extend `.harmony/capabilities/services/_ops/scripts/validate-services.sh` coverage implicitly via manifest onboarding.
2. Extend `.harmony/capabilities/services/_ops/scripts/validate-service-independence.sh` `services-core` scan list to include `retrieval/query`.

Exit gate:

- `validate-services.sh` passes with no errors.
- `validate-service-independence.sh --mode services-core` passes with no query-path violations. No allowlist exceptions required.

## Phase 3: Observability, Eval, and Quality Gates

Deliverables:

1. Required spans declared and emitted:
   - `service.query.ask`
   - `service.query.retrieve`
   - `service.query.explain`
2. Run record emission aligned with service conventions.
3. Baseline evaluation dataset for query quality.
4. Baseline report in:
   - `.harmony/output/reports/analysis/<date>-query-baseline.md`

Acceptance thresholds (initial):

1. Citation completeness: `100%` (every answer claim backed by citation entry).
2. Citation locator validity: `>= 99%` resolvable chunk locators.
3. Retrieval quality: baseline Recall@20 and MRR recorded.
4. Latency (local snapshot, baseline corpus): p95 target established and tracked.
   - The baseline report must document that the semantic signal is agent-bound: its latency scales with candidate count and model inference time, not with a precomputed operation. The primary latency knob is the candidate set size passed from keyword/graph to semantic scoring.

Exit gate:

- Baseline metrics and evidence report committed; no unknown failure modes in typed error taxonomy.

## Phase 4: Advanced Routes and Adapter Contracts (Feature-Flagged)

### Agent-native route expansion

Implement incrementally behind explicit strategy flags, using only the
native tool surface:

1. `route: hierarchical` — probe higher-level summary chunks, then descend to supporting leaf chunks. Requires hierarchical index artifacts.
2. `route: graph_global` — read community/cluster summaries to draft partial answers for global questions, fuse with local chunk retrieval. Requires graph-community index artifacts.
3. Optional memory clue pre-retrieval — agent drafts search clues before retrieval to steer keyword/graph signals.

Rollout rule:

- Each route ships only after A/B evaluation vs baseline with explicit gate pass criteria.

### Adapter contracts (external backends)

If integration with external retrieval backends is required, define adapter
contracts following the `interfaces/agent-platform` pattern:

```
adapters/
  registry.yml
  <backend-id>/
    adapter.yml          # Metadata and capability support matrix
    mapping.md           # Canonical-to-provider term mappings
    compatibility.yml    # Runtime/tool requirements for the external backend
    fixtures/
      capabilities.json  # Conformance fixture
```

Adapter contracts define the interface only. Implementation lives
externally. The core service continues to function without any adapter
loaded. Provider-specific terms appear only within `adapters/<backend-id>/`.

Exit gate:

- Route-specific eval report for each added native route with no citation-correctness regression.
- Adapter contracts (if any) pass structural validation and include conformance fixtures.

---

## Compatibility Profile

```yaml
version: "1.0.0"
compatibility:
  required_tools: [read, glob, grep, bash]
  optional_tools: [jq]
  minimum_behavior:
    deterministic_tier1: true
    fixture_calibration: true
    fail_closed_policy: false
  external_dependencies: none
```

---

## Guide.md Scope Boundary

The existing `guide.md` documents aspirational design including external
backends (FAISS, ColBERT, pgvector, networkx, SQLite FTS5, hnswlib,
Tantivy), ephemeral adapters, database adapters, and provider-specific
configuration.

Scope boundary:

- `guide.md` is a design reference, not a contract source.
- The MVP contract (SERVICE.md, schemas, rules, fixtures) derives from
  the agent-native signal architecture defined in this plan, not from
  guide.md's external-backend sections.
- External backend content in `guide.md` becomes source material for
  future adapter contracts under `adapters/`, if and when those are needed.
- `guide.md` should not be modified for MVP; it retains its value as design
  context. SERVICE.md is the authoritative contract.

---

## PR Cut Strategy

1. **PR-1 (contracts only):** Phase 0 scaffolding artifacts.
2. **PR-2 (runtime MVP):** Phase 1 implementation and fixture calibration.
3. **PR-3 (registration/wiring):** Phase 2 manifest/registry/commands/validators.
4. **PR-4 (quality baseline):** Phase 3 observability + eval baseline report.
5. **PR-5+ (expansion):** Phase 4 native routes and adapter contracts, one at a time.

This keeps each review slice small, reversible, and independently verifiable.

---

## Key Risks and Mitigations

1. **Risk:** Overbuilding advanced routes before baseline reliability.
   - **Mitigation:** MVP-first contract and route-level feature flags.
2. **Risk:** Citation drift from chunk/document mismatch.
   - **Mitigation:** enforce chunk-first citation schema and locator validation gate.
3. **Risk:** Manifest onboarding blocked by category constraints.
   - **Mitigation:** add `retrieval` to `service_categories` in same PR as service registration.
4. **Risk:** Validator blind spots for new retrieval paths.
   - **Mitigation:** extend `validate-service-independence.sh` scan targets.
5. **Risk:** Semantic signal latency dominates end-to-end response time.
   - **Mitigation:** `strategy.top_k` caps the candidate set before semantic scoring. Keyword and graph signals pre-filter aggressively. Phase 3 baseline documents the latency profile and establishes the tuning knob.
6. **Risk:** guide.md content treated as contract source, pulling in external dependencies.
   - **Mitigation:** SERVICE.md is authoritative. guide.md is design context only. Scope boundary documented in this plan and enforced by review.

---

## Immediate Next Execution Step

Start Phase 0 by scaffolding Query as a rich-contract service under:

- `.harmony/capabilities/services/retrieval/query/`

and keep initial status as `draft` in service metadata until Phase 2 wiring and Phase 3 baseline gates pass.
