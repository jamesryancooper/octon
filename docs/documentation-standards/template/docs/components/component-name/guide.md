# {{component-name}} — Developer Guide

## Quick Snapshot

- Modes/variants: <e.g., basic | hybrid | enterprise>
- Capabilities/signals: <e.g., dense | keyword | graph>
- Inputs: <normalized records, events, API payloads>
- Outputs: <responses, artifacts, events>
  - Artifacts: `<files with schema_version>`
  - Optional publish/serve: <DB/adapter options>

## What It Does

- <Primary functions and responsibilities in 3–6 bullets>

## Wins

- <Key benefits: recall, portability, speed, auditability, etc.>

## Opinionated Implementation Choices

- Frameworks/libs (examples): LangChain, LangGraph, AI‑SDK — why chosen, limitations, and when not to use
- Retrieval/index choices: GraphRAG patterns, FAISS/pgvector, Supabase — rationale and trade‑offs
- Algorithms: e.g., retrieval strategies, deduplication, chunking, scoring/ranking, link-graph traversal; explain which are used and why; mention any custom or nonstandard algorithms and give reasons
- Formats/engines: JSON/JSONL artifacts, FAISS index type (Flat/IVF/HNSW), BM25, networkx
- Models/rerankers: embedding model, cross‑encoder reranker — version and reasoning for selection
- Alternatives considered: summarize options evaluated with key trade‑offs
- Security/licensing notes: ASVS/SSDF impacts, license compatibility, and security posture
- ADR: link to decision record(s) for org‑wide or consequential choices

## Core Responsibilities

<What it owns/guarantees; what it explicitly does not do>

## Ecosystem Integrations

- Upstream: `<kits or sources>`
- Downstream: `<kits or consumers>`

## Operating Modes / Usage Recipes

- When to use each mode and trade‑offs
- Example configs per mode

Recommended sub-structure per mode (replicate as needed):

### mode: {{mode-name}} — short summary

- What it does
- I/O
- Wins
- Opinionated choices
- Contracts/special notes: <e.g., stable IDs, chunk-first contract>

## Signals/Capabilities (optional)

- <Signal/capability name>
  - Purpose
  - Artifacts (if any)
  - Config
  - Validation
  - Retrieval/runtime notes

## I/O & Contracts

- API endpoints: OpenAPI at `packages/contracts/openapi.yaml`
- Schemas: JSON Schema at `packages/contracts/schemas/feature-name.schema.json`
- Inputs/Outputs summary: <key fields, stable IDs/provenance if applicable>

## Artifacts & Layout (if applicable)

Describe artifact formats and include a brief tree with versions.

```plaintext
<artifact-root>/
  artifact.ext
  meta.json            # includes schema_version, build info
  snapshot/
    manifest.json      # checksums/ids
```

## Versioning & Compatibility

- Schema versioning: follow semantic versioning for artifact schemas (`schema_version`).
- Breaking changes: bump major; document migration or down‑conversion notes if feasible.
- Backward compatibility: state which older readers/parsers remain compatible.

## Configuration & Tuning

Minimal config

```yaml
enabled: true
mode: standard
limits:
  maxItems: 1000
```

Advanced knobs

```json
{
  "feature": { "knob": 10, "strategy": { "use": ["a","b"] } },
  "snapshot": true
}
```

## Sizing & Capacity (optional)

- Typical sizes and growth factors (corpus size, dim/features, artifact footprints)
- Memory/CPU guidance for common scales; note model/index parameters that affect footprint
- Performance tips: knobs to balance recall/latency/cost

## Adapters (optional)

- In-memory/off-disk adapters and when to use them
- Backend options and runtime knobs (e.g., ANN params)

## Publishing / Serving (optional)

- Adapters/backends: <e.g., PostgreSQL + pgvector/FTS, Redis, S3>
- Minimal DDL or table layout (if relevant)
- Security: DSNs via env/secret store

## Validation & Health

- Drift/parity checks: <schema_version, counts, dims>
- Health probes: </health, self‑check>

## Observability (optional)

- Logs/metrics/traces to emit (e.g., build/source hash, model/version, key knobs)
- Dashboards and alerts; integration points with ObservaKit/EvalKit
- Redaction/privacy notes for logs and payloads

## Harmony Alignment

- Spec‑first, contract‑driven; OpenAPI/JSON‑Schema enforced in CI
- Auditability & transparency via reproducible artifacts/snapshots
- Security & reliability: ASVS/SSDF controls, error‑budget policy
- Modular flow: tiny PRs, previews, flags
- See `.harmony/cognition/methodology/README.md`

## Why Teams Choose {{component-name}}

- <Unified API, stable artifacts, deterministic builds, interoperability, etc.>

## Minimal Interfaces (copy/paste)

```json
{ "mode": "standard", "output": { "dir": "out/" }, "snapshot": true }
```

## Contracts & Schemas

- Reference and extend schemas for artifacts as needed. Keep `schema_version` and include examples.

## Feature Roadmap: High‑Impact Add‑Ons (Harmony‑aligned)

<Phasing template (customize)>

- Now (0–2 weeks)
  - Feature: `<add-on name>`
  - Outcome: `<measurable win>`

- Next (2–6 weeks)
  - Feature: `<add-on name>`
  - Outcome: `<measurable win>`

- Later (6+ weeks)
  - Feature: `<add-on name>`
  - Outcome: `<measurable win>`

## Troubleshooting

- Symptom → Fix
- 400 Bad Request → Check schema conformance
- Timeouts → Verify upstream latency budgets

## Common Questions

- <FAQ 1>
- <FAQ 2>
