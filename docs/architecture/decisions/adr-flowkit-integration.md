---
title: ADR — FlowKit Integration Model
description: Decision record for FlowKit's layered integration across Cursor, workspace, package, and runtime.
status: implemented
date: 2025-12-20
---

# ADR: FlowKit Integration Model

## Status

**Implemented** — The layered integration model is now in place with all required assets.

## Context

FlowKit appears in multiple "layers" of the repository:

- **Cursor commands** (`.cursor/commands/run-flow.md`) — IDE entrypoint
- **Workspace harness** (`.harmony/orchestration/workflows/flowkit/run-flow/`) — Procedural workflow
- **Package implementation** (`packages/kits/flowkit/`) — TypeScript kit + CLI
- **Runtime implementation** (`agents/runner/runtime/`) — Python LangGraph graphs

This raised questions about ownership, potential drift, and the correct integration model.

## Decision

We chose **Option 1: Layered Integration** — keep all four layers with clear ownership boundaries.

### Why This Option

| Criteria | Score | Justification |
|----------|:-----:|---------------|
| Architecture fit | 5 | Matches Harmony's workspace vs package vs runtime boundaries |
| Single source of truth | 4 | CLI is canonical; workspace workflow references it |
| Velocity | 5 | All entrypoints available; auto-start works |
| Trust | 5 | Full guardrails, idempotency, run records |
| Focus | 4 | Four layers to understand, but well-documented |
| Continuity | 5 | Run records, traces, artifacts present |
| Insight | 5 | Learning loops supported via run records |

**Total: 33/35** — Highest among evaluated options.

### Alternatives Considered

1. **Packages-only** (31/35) — Loses procedural guidance layer
2. **Workspace-centric** (23/35) — Violates code placement rules
3. **Template-distributed** (32/35) — Complementary enhancement, not replacement

## Consequences

### Positive

- Clear ownership: each layer has defined responsibilities
- No semantic overlap: workspace describes *procedure*, package defines *semantics*
- Single canonical implementation: all entrypoints converge on the CLI
- Contracts-first: `/flows/run` is now defined in `packages/contracts/openapi.yaml`

### Negative

- Four layers to understand (mitigated by documentation)
- Slight indirection (acceptable for separation of concerns)

## Implementation

The following artifacts were created or updated:

### Flow Assets (Phase 0)

Flow assets follow a standardized naming convention under `packages/workflows/<flowId>/`:

- `config.flow.json` — Registration config (FlowKit entrypoint/discovery)
- `manifest.yaml` — Workflow definition (step graph + flow-specific config)
- `00-overview.md` — Canonical prompt (flow-level spec)
- `NN-<step>.md` — Step-specific prompts (numbered like `.harmony` workflows)

Current flows:

- `packages/workflows/architecture_assessment/`
  - `config.flow.json`, `manifest.yaml`, `00-overview.md`, `01-inventory.md`, ... `09-declare-no-update.md`
- `packages/workflows/docs_glossary/`
  - `config.flow.json`, `manifest.yaml`, `00-overview.md`, `01-collect-terms.md`, `02-summarize-glossary.md`

### Drift Prevention (Phase 1)

- Updated `.harmony/orchestration/workflows/flowkit/run-flow/02-parse-config.md` to reference package schema
- Added clarification note to `.harmony/catalog.md`

### Studio UX (Phase 2)

- Standardized env vars to `FLOWKIT_STUDIO_*` in `agents/runner/runtime/glossary/studio_entry.py`

### Contracts (Phase 3)

- Added `/flows/run` and `/healthz` to `packages/contracts/openapi.yaml`
- Added `FlowRunRequest` and `FlowRunResponse` schemas

### Documentation

- Added responsibility matrix to `docs/kits/planning-and-orchestration/flowkit/guide.md`

## Definition of Done

- [x] `/run-flow` can execute a real flow with `@<some>.flow.json`
- [x] Runtime responds to `/healthz` and `/flows/run`
- [x] Studio env vars are consistent across flows
- [x] Contracts-first definition exists for `/flows/run`
- [x] Docs/examples match real file locations

## Related

- [FlowKit Guide](../../kits/planning-and-orchestration/flowkit/guide.md)
- [Workspace Scope](.harmony/scope.md)
- [Contracts OpenAPI](packages/contracts/openapi.yaml)

