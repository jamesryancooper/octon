# Multi-Graph Agentic Memory Architecture for Octon

**Generated:** 2026-01-14
**Status:** Architectural Example
**Scope:** Design documentation (not implementation)

---

## 1. Octon Architecture Overview

Octon uses a **two-layer inheritance model** for AI agent coordination:

```
┌─────────────────────────────────────────────────────────┐
│  .octon/  (Shared Foundation - Portable)              │
│  ├── capabilities/runtime/skills/       Shared skill definitions           │
│  ├── orchestration/runtime/workflows/   Workspace management workflows     │
│  ├── scaffolding/runtime/templates/     Workspace scaffolding              │
│  ├── agency/runtime/assistants/         Generic specialists (@reviewer)    │
│  └── cognition/runtime/context/         Shared tools, compaction guides    │
└──────────────────────┬──────────────────────────────────┘
                       │ inherits from
                       ▼
┌─────────────────────────────────────────────────────────┐
│  .octon/  (Project-Specific Harness)                  │
│  ├── cognition/runtime/context/  Decisions, constraints, glossary│
│  ├── continuity/     tasks.json, log.md, entities.json  │
│  ├── orchestration/runtime/missions/  Time-bounded sub-projects │
│  ├── graph/          ← Knowledge graph lives here       │
│  └── capabilities/runtime/skills/  Project-specific skill mappings│
└─────────────────────────────────────────────────────────┘
```

**Resolution rule:** Local workspace (`.octon/`) overrides shared foundation (`.octon/` root).

### Where Graphs Fit

Graphs follow the same inheritance pattern:

| Layer | Graph Role |
|-------|------------|
| `.octon/graph/` | Shared schema, types, rebuild skill |
| `.octon/graph/` | Root-level graph + subgraph registry |
| `apps/*/.octon/graph/` | Domain-specific graphs |

---

## 2. Multi-Graph Directory Structure

```
octon/
├── .octon/
│   └── graph/
│       ├── schema.json          # Shared node/edge JSON Schema
│       └── types.ts             # Shared TypeScript types
│
├── .octon/                    # Root workspace (graph portion)
│   └── graph/
│       ├── graph.json           # Root graph (decisions, repo-wide entities)
│       ├── manifest.json        # Source file hashes for staleness
│       └── subgraphs.json       # Registry of domain graphs
│
├── apps/
│   ├── api/
│   │   └── .octon/
│   │       ├── cognition/runtime/context/
│   │       │   └── decisions/
│   │       │       └── API-001.md   # ← Front matter declares node
│   │       └── graph/
│   │           ├── graph.json       # API-scoped graph
│   │           └── manifest.json
│   │
│   └── web/
│       └── .octon/
│           └── graph/
│               ├── graph.json       # Web-scoped graph
│               └── manifest.json
│
└── packages/
    └── kit-graph/                   # Graph infrastructure kit
        ├── src/
        │   ├── types.ts
        │   ├── graph.ts             # Query engine
        │   ├── rebuild.ts           # Build from front matter
        │   ├── federation.ts        # Cross-graph queries
        │   └── cli.ts
        └── package.json
```

---

## 3. Front Matter Schema

Source files declare graph nodes via YAML front matter:

```markdown
<!-- apps/api/.octon/cognition/runtime/decisions/001-octon-shared-foundation.md -->
---
# Graph Identity (required for graph inclusion)
graph:
  id: api:decision:API-001
  type: decision

# Relationships (edges)
references:
  - root:decision:D001        # Cross-graph ref to root workspace
  - api:task:T003             # Local ref within API workspace
depends_on: []
blocked_by: []

# Node Properties
title: REST over GraphQL
status: accepted
tags: [architecture, api]
created: 2026-01-10
---

# API-001: REST over GraphQL

We chose REST for the public API because...
```

### Node ID Convention

```
{workspace}:{type}:{id}

Examples:
  root:decision:D001      # Root workspace
  api:decision:API-001    # apps/api workspace
  web:component:Header    # apps/web workspace
  flowkit:skill:run       # packages/flowkit workspace
```

### Supported Relationship Fields

| Field | Direction | Meaning |
|-------|-----------|---------|
| `references` | outgoing | "This node mentions/uses that node" |
| `depends_on` | outgoing | "This node requires that node" |
| `blocked_by` | outgoing | "This node is blocked by that node" |
| `implements` | outgoing | "This node implements that node" |
| `contains` | outgoing | "This node contains that node" |

---

## 4. Graph JSON Structure

### Local Graph (`apps/api/.octon/graph/graph.json`)

```json
{
  "version": "1.0",
  "workspace": "api",
  "generated_at": "2026-01-14T10:30:00Z",
  "stats": {
    "nodes": 12,
    "edges": 23,
    "external_refs": 3
  },
  "nodes": {
    "api:decision:API-001": {
      "type": "decision",
      "props": {
        "title": "REST over GraphQL",
        "status": "accepted",
        "tags": ["architecture", "api"]
      },
      "meta": {
        "source": "cognition/runtime/decisions/001-octon-shared-foundation.md",
        "created": "2026-01-10",
        "modified": "2026-01-14"
      }
    },
    "api:task:T003": {
      "type": "task",
      "props": {
        "description": "Implement rate limiting",
        "status": "in_progress"
      },
      "meta": {
        "source": "continuity/tasks.json"
      }
    }
  },
  "edges": [
    { "from": "api:decision:API-001", "to": "root:decision:D001", "rel": "references" },
    { "from": "api:decision:API-001", "to": "api:task:T003", "rel": "references" }
  ],
  "external_refs": [
    "root:decision:D001"
  ]
}
```

### Root Graph with Subgraph Registry (`.octon/graph/graph.json`)

```json
{
  "version": "1.0",
  "workspace": "root",
  "generated_at": "2026-01-14T10:30:00Z",
  "stats": {
    "nodes": 8,
    "edges": 5,
    "subgraphs": 3
  },
  "nodes": {
    "root:decision:D001": {
      "type": "decision",
      "props": {
        "title": "State format: JSON over YAML",
        "status": "accepted"
      },
      "meta": {
        "source": "cognition/runtime/context/decisions.md"
      }
    }
  },
  "edges": [],
  "subgraphs": [
    { "workspace": "api", "path": "apps/api/.octon/graph/graph.json" },
    { "workspace": "web", "path": "apps/web/.octon/graph/graph.json" },
    { "workspace": "flowkit", "path": "packages/flowkit/.octon/graph/graph.json" }
  ]
}
```

### Manifest for Staleness Detection (`.octon/graph/manifest.json`)

```json
{
  "generated_at": "2026-01-14T10:30:00Z",
  "sources": {
    "cognition/runtime/context/decisions.md": {
      "hash": "a1b2c3d4e5f6",
      "mtime": "2026-01-14T09:00:00Z"
    },
    "continuity/tasks.json": {
      "hash": "b2c3d4e5f6a1",
      "mtime": "2026-01-14T10:15:00Z"
    }
  }
}
```

---

## 5. TypeScript Types

```typescript
// packages/kit-graph/src/types.ts

/** Namespaced node identifier: {workspace}:{type}:{id} */
export type NodeId = `${string}:${string}:${string}`;

/** Supported relationship types */
export type RelationType =
  | 'references'
  | 'depends_on'
  | 'blocked_by'
  | 'implements'
  | 'contains';

/** Graph node */
export interface Node {
  type: string;
  props: Record<string, unknown>;
  meta: {
    source: string;
    created?: string;
    modified?: string;
  };
}

/** Graph edge */
export interface Edge {
  from: NodeId;
  to: NodeId;
  rel: RelationType;
  props?: Record<string, unknown>;
}

/** Subgraph reference (for federated graphs) */
export interface SubgraphRef {
  workspace: string;
  path: string;
}

/** Local graph file structure */
export interface GraphFile {
  version: string;
  workspace: string;
  generated_at: string;
  stats: {
    nodes: number;
    edges: number;
    external_refs?: number;
    subgraphs?: number;
  };
  nodes: Record<NodeId, Node>;
  edges: Edge[];
  external_refs?: NodeId[];
  subgraphs?: SubgraphRef[];
}

/** Query options for traversal */
export interface TraverseOptions {
  maxDepth?: number;
  direction?: 'out' | 'in' | 'both';
  rel?: RelationType;
}

/** Pattern for querying nodes */
export interface QueryPattern {
  type?: string;
  workspace?: string;
  where?: Record<string, unknown>;
}
```

---

## 6. CLI Commands

```bash
# Rebuild single workspace graph from front matter
pnpm octon graph:rebuild .octon
pnpm octon graph:rebuild apps/api/.octon

# Rebuild all graphs in monorepo
pnpm octon graph:rebuild-all

# Check if graph is stale (fast, uses manifest hashes)
pnpm octon graph:status
pnpm octon graph:status apps/api/.octon

# Validate all cross-references resolve
pnpm octon graph:validate
# Output: ✓ 45 nodes, 78 edges, 0 dangling refs

# Query: find node by ID
pnpm octon graph:query --node root:decision:D001

# Query: find all nodes of type
pnpm octon graph:query --type decision

# Query: find what references a node
pnpm octon graph:query --to root:decision:D001 --rel references

# Query: find what a node depends on
pnpm octon graph:query --from api:task:T003 --rel depends_on

# Query: cross-graph traversal
pnpm octon graph:traverse api:decision:API-001 --depth 2

# Watch mode (rebuild on file change)
pnpm octon graph:watch
```

---

## 7. Kit Integration

### Package Structure

```
packages/kit-graph/
├── src/
│   ├── index.ts           # Public API exports
│   ├── types.ts           # Type definitions
│   ├── graph.ts           # Graph class (query engine)
│   ├── federation.ts      # FederatedGraph class
│   ├── rebuild.ts         # Build graph from front matter
│   ├── validate.ts        # Reference validation
│   ├── manifest.ts        # Staleness detection
│   └── cli.ts             # CLI entry point
├── package.json
└── tsconfig.json
```

### Package.json

```json
{
  "name": "@octon/kit-graph",
  "version": "0.0.1",
  "type": "module",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.js"
    }
  },
  "bin": {
    "kit-graph": "./dist/cli.js"
  },
  "scripts": {
    "build": "tsc -b",
    "test": "vitest run"
  },
  "dependencies": {
    "@octon/kit-base": "workspace:*",
    "gray-matter": "^4.0.3",
    "glob": "^10.3.10",
    "zod": "^3.22.4"
  }
}
```

### Integration with @octon/kits

```json
// packages/kits/package.json (add to exports)
{
  "exports": {
    "./kit-graph": {
      "types": "./kit-graph/dist/index.d.ts",
      "import": "./kit-graph/dist/index.js"
    }
  },
  "bin": {
    "kit-graph": "./kit-graph/dist/cli.js"
  }
}
```

---

## 8. Usage Examples

### Agent Boot Sequence Integration (Optional)

```typescript
// In agent initialization (optional enhancement to boot sequence)
import { Graph, isStale } from '@octon/kit-graph';

async function bootWithGraph(workspacePath: string) {
  const graphPath = path.join(workspacePath, 'graph/graph.json');

  if (await isStale(workspacePath)) {
    console.warn('Graph is stale. Run: pnpm octon graph:rebuild');
  }

  if (existsSync(graphPath)) {
    const graph = await Graph.load(graphPath);

    // Quick context: what decisions affect current work?
    const decisions = graph.query({ type: 'decision' });
    console.log(`Loaded graph: ${decisions.length} decisions tracked`);
  }
}
```

### Cross-Graph Query

```typescript
import { FederatedGraph } from '@octon/kit-graph';

const federated = await FederatedGraph.load('/path/to/octon');

// What depends on this core decision?
const dependents = federated.to('root:decision:D001', 'depends_on');
console.log(`${dependents.length} nodes depend on D001`);

// Impact analysis: if I change D001, what's affected?
const impacted = federated.traverse('root:decision:D001', {
  direction: 'in',
  maxDepth: 2
});
```

### Pre-Commit Hook

```bash
#!/bin/bash
# .husky/pre-commit

if pnpm octon graph:status --quiet; then
  echo "Graph is current"
else
  echo "Rebuilding stale graph..."
  pnpm octon graph:rebuild-all
  git add .octon/graph/ apps/*/.octon/graph/
fi
```

---

## 9. Summary

| Component | Location | Purpose |
|-----------|----------|---------|
| Shared schema | `.octon/graph/` | Types, JSON Schema |
| Root graph | `.octon/graph/` | Repo-wide nodes + subgraph index |
| Domain graphs | `apps/*/.octon/graph/` | Domain-specific nodes |
| Infrastructure | `packages/kit-graph/` | Query engine, CLI, rebuild |
| Source of truth | YAML front matter in `.md` files | Nodes declared inline |
| Derived cache | `graph.json` per workspace | Fast load, queryable |

**Key Principles:**
1. **Locality** — Graphs live where content lives
2. **Inheritance** — Follows root `.octon/` → domain `.octon/` pattern
3. **Derived, not authoritative** — Front matter is source; graph is cache
4. **Federated** — Each workspace owns its graph; root indexes all
5. **Optional** — Enhances workspace pattern without replacing it

---

*This is an architectural example. Implementation would follow standard kit development workflow.*
