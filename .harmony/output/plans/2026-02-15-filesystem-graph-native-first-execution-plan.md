# Plan: Filesystem + Knowledge Graph Native-First Execution

## Context

Harmony already has native service contracts, deterministic retrieval artifacts, and optional adapter boundaries. This plan adds a production-oriented `filesystem-graph` interface that gives agents stronger progressive discovery, graph traversal, and provenance-backed file resolution while preserving native-first governance.

This is an execution plan, not just design intent. Every phase below has concrete deliverables and an exit gate.

---

## Non-Negotiables

1. Files remain source-of-truth. The knowledge graph is derived.
2. Native mode works with zero external platform dependencies.
3. Core contracts remain provider-agnostic.
4. Critical policy failures are fail-closed.
5. Material side effects remain governed by:

- `.harmony/cognition/principles/no-silent-apply.md`
- `.harmony/cognition/principles/hitl-checkpoints.md`
- `.harmony/cognition/principles/deny-by-default.md`

---

## Objectives

1. Add a first-class internal API for filesystem + graph operations.
2. Add deterministic snapshot build and traversal artifacts.
3. Add progressive discovery operations for agent workflows.
4. Register runtime metadata and validation gates.
5. Keep backend pluggable: snapshot-first, accelerator optional.

---

## Target Structure

```text
.harmony/capabilities/services/interfaces/filesystem-graph/
  README.md
  SERVICE.md
  contract.md
  schema/
    input.schema.json
    output.schema.json
    node.schema.json
    edge.schema.json
    snapshot-manifest.schema.json
  rules/
    rules.yml
  contracts/
    invariants.md
    errors.yml
  fixtures/
    valid-fs-read.json
    valid-kg-neighbors.json
    valid-snapshot-build.json
  compatibility.yml
  impl/
    filesystem-graph.sh
    snapshot-build.sh
    snapshot-diff.sh
    generated.manifest.json

.harmony/cognition/context/
  filesystem-graph-interop.md

.harmony/capabilities/commands/
  filesystem-graph.md
  snapshot-build.md
  snapshot-diff.md
  discover-start.md
  discover-expand.md
  discover-explain.md
  discover-resolve.md
```

---

## Versioning

1. `filesystem_graph_contract_version`
- Location: `.harmony/cognition/context/filesystem-graph-interop.md`
- Scope: semantics, invariants, ownership boundaries

2. `filesystem_graph_schema_version`
- Location: `.harmony/capabilities/services/interfaces/filesystem-graph/schema/*.json`
- Scope: machine-readable op contracts and artifact schemas

3. `filesystem_graph_service_version`
- Location: `.harmony/capabilities/services/interfaces/filesystem-graph/SERVICE.md`
- Scope: service implementation contract and compatibility

---

## Phase 0: Contract + Governance Baseline

Deliverables:

1. Add context contract:
- `.harmony/cognition/context/filesystem-graph-interop.md`

2. Add context index entry:
- `.harmony/cognition/context/index.yml`

3. Add ADR:
- `.harmony/cognition/decisions/013-filesystem-graph-native-first.md`

4. Add plan execution report scaffold:
- `.harmony/output/reports/2026-02-15-filesystem-graph-phase0-baseline.md`

Exit gate:

- Contract and ADR exist with native-first, fail-closed, provenance, and source-of-truth rules.

---

## Phase 1: Service Contract Scaffold + Registration

Deliverables:

1. Add service artifacts:
- `.harmony/capabilities/services/interfaces/filesystem-graph/README.md`
- `.harmony/capabilities/services/interfaces/filesystem-graph/SERVICE.md`
- `.harmony/capabilities/services/interfaces/filesystem-graph/contract.md`
- `.harmony/capabilities/services/interfaces/filesystem-graph/rules/rules.yml`
- `.harmony/capabilities/services/interfaces/filesystem-graph/contracts/invariants.md`
- `.harmony/capabilities/services/interfaces/filesystem-graph/contracts/errors.yml`
- `.harmony/capabilities/services/interfaces/filesystem-graph/compatibility.yml`
- `.harmony/capabilities/services/interfaces/filesystem-graph/fixtures/*`

2. Add schemas:
- `schema/input.schema.json`
- `schema/output.schema.json`
- `schema/node.schema.json`
- `schema/edge.schema.json`
- `schema/snapshot-manifest.schema.json`

3. Register service metadata:
- `.harmony/capabilities/services/manifest.yml`
- `.harmony/capabilities/services/registry.yml`

Exit gate:

- Contract scaffold is complete and registered in service discovery manifests.

---

## Phase 2: Snapshot Builder + Deterministic Artifacts

Deliverables:

1. Add scripts:
- `.harmony/capabilities/services/interfaces/filesystem-graph/impl/snapshot-build.sh`
- `.harmony/capabilities/services/interfaces/filesystem-graph/impl/snapshot-diff.sh`

2. Add runtime state conventions:
- `.harmony/runtime/_ops/state/snapshots/<snapshot-id>/`
- `files.jsonl`, `nodes.jsonl`, `edges.jsonl`, `manifest.json`
- active snapshot pointer under state

3. Add generation manifest:
- `.harmony/capabilities/services/interfaces/filesystem-graph/impl/generated.manifest.json`

Exit gate:

- Same input tree produces stable snapshot IDs and deterministic artifact shape.

---

## Phase 3: Progressive Discovery Operations

Deliverables:

1. Add core op dispatcher:
- `.harmony/capabilities/services/interfaces/filesystem-graph/impl/filesystem-graph.sh`

2. Add operation families:
- Filesystem: `fs.list`, `fs.read`, `fs.stat`, `fs.search`
- Graph: `kg.get-node`, `kg.neighbors`, `kg.traverse`, `kg.resolve-to-file`
- Snapshot: `snapshot.build`, `snapshot.diff`, `snapshot.get-current`
- Discovery: `discover.start`, `discover.expand`, `discover.explain`, `discover.resolve`

3. Add command wrappers + manifest registration:
- `.harmony/capabilities/commands/filesystem-graph.md`
- `.harmony/capabilities/commands/snapshot-build.md`
- `.harmony/capabilities/commands/snapshot-diff.md`
- `.harmony/capabilities/commands/discover-start.md`
- `.harmony/capabilities/commands/discover-expand.md`
- `.harmony/capabilities/commands/discover-explain.md`
- `.harmony/capabilities/commands/discover-resolve.md`
- `.harmony/capabilities/commands/manifest.yml`

Exit gate:

- End-to-end command path works for build → discover.start → discover.expand → discover.resolve on fixture data.

---

## Phase 4: Runtime Registration + Optional Accelerator Contract Hook

Deliverables:

1. Register runtime service metadata:
- `.harmony/capabilities/services/manifest.runtime.yml`
- `.harmony/capabilities/services/registry.runtime.yml`

2. Add accelerator-neutral config (snapshot-first default, embedded optional):
- service config and docs describe optional accelerator mode
- no contract changes required when accelerator is off

3. Add phase report:
- `.harmony/output/reports/2026-02-15-filesystem-graph-phase4-runtime.md`

Exit gate:

- Runtime registry includes filesystem-graph service and still supports native snapshot-first execution by default.

---

## Phase 5: Validation + Completion Evidence

Deliverables:

1. Add validator:
- `.harmony/capabilities/services/_ops/scripts/validate-filesystem-graph.sh`

2. Add or update quality references:
- `.harmony/quality/complete.md`
- `.harmony/quality/session-exit.md`

3. Add final completion report:
- `.harmony/output/reports/2026-02-15-filesystem-graph-completion.md`

Exit gate:

- Validation script passes for contracts, schema existence, command registration, and snapshot artifact expectations.

---

## Execution Notes

1. Delivery style: contract-first, shell implementation first, deterministic behavior prioritized.
2. Backend strategy: snapshot artifacts as primary; accelerator backends are optional and pluggable.
3. Future path: Rust/WASM implementation can replace shell internals without contract changes.

