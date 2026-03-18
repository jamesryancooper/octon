# FlowKit ↔ Octon Integration — Exploration & Recommendation

---

## 1. Executive Summary

- **FlowKit integration is well-layered**: The current architecture cleanly separates IDE entrypoint (Cursor), procedural harness (workspace), implementation (package), and execution (runtime).
- **No actual `.flow.json` config files exist**: The architecture and documentation are fully specified, but the example flows referenced in documentation (e.g., `architecture-assessment.flow.json`) have not been created.
- **The workspace layer is procedural, not semantic**: The `.workspace/workflows/flowkit/run-flow/` workflow describes *how* to orchestrate CLI calls, not *what* the flow config means—no conflict with package ownership.
- **Recommendation: Option 1 (Layered Integration)** — Keep all four layers with minor clarifications and add missing config files.
- **Key action items**: Create missing `.flow.json` files for existing graphs (`architecture_assessment`, `docs_glossary`), add a catalog note clarifying FlowKit workflows are repo-wide tool integrations.

---

## 2. Current-State Diagram

### End-to-End Execution Chain

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              USER TRIGGERS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────────┐  │
│  │ Cursor /run-flow │    │ pnpm flowkit:run │    │ createHttpFlowRunner │  │
│  │  (IDE command)   │    │  (repo script)   │    │  (programmatic API)  │  │
│  └────────┬─────────┘    └────────┬─────────┘    └──────────┬───────────┘  │
│           │                       │                         │               │
│           ▼                       │                         │               │
│  ┌──────────────────┐             │                         │               │
│  │ .cursor/commands │             │                         │               │
│  │  /run-flow.md    │             │                         │               │
│  └────────┬─────────┘             │                         │               │
│           │                       │                         │               │
│           ▼                       │                         │               │
│  ┌──────────────────┐             │                         │               │
│  │ .workspace/      │             │                         │               │
│  │ workflows/       │             │                         │               │
│  │ flowkit/run-flow │ (procedure) │                         │               │
│  └────────┬─────────┘             │                         │               │
│           │                       │                         │               │
│           ▼                       ▼                         │               │
│  ┌───────────────────────────────────────────────────────┐  │               │
│  │        packages/kits/flowkit/src/cli.ts               │◄─┘               │
│  │             (CANONICAL IMPLEMENTATION)                 │                  │
│  └───────────────────────────────┬───────────────────────┘                  │
│                                  │                                          │
│                                  ▼                                          │
│  ┌───────────────────────────────────────────────────────┐                  │
│  │        HTTP POST /flows/run                           │                  │
│  │        (FlowKit ↔ Runtime boundary)                   │                  │
│  └───────────────────────────────┬───────────────────────┘                  │
│                                  │                                          │
│                                  ▼                                          │
│  ┌───────────────────────────────────────────────────────┐                  │
│  │        agents/runner/runtime/server.py                │                  │
│  │             (CANONICAL RUNTIME)                       │                  │
│  └───────────────────────────────┬───────────────────────┘                  │
│                                  │                                          │
│                                  ▼                                          │
│  ┌───────────────────────────────────────────────────────┐                  │
│  │        LangGraph Graph Execution                      │                  │
│  │        (assessment/, glossary/, future graphs)        │                  │
│  └───────────────────────────────────────────────────────┘                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### File Ownership Map

| Layer | Files | Owner |
|-------|-------|-------|
| **Cursor Entrypoint** | `.cursor/commands/run-flow.md` | IDE integration |
| **Workspace Harness** | `.workspace/workflows/flowkit/run-flow/*` | Procedural guidance |
| **Package Implementation** | `packages/kits/flowkit/src/*` | Canonical code |
| **Runtime Execution** | `agents/runner/runtime/**` | Graph execution |
| **Contracts/Schemas** | `packages/kits/flowkit/schema/*` | API contract |
| **Docs** | `docs/services/planning/flow/*` | Canonical reference |

---

## 3. Responsibility Matrix

| Responsibility | Cursor | Workspace | Package | Runtime | Docs |
|----------------|:------:|:---------:|:-------:|:-------:|:----:|
| **IDE trigger** | ✓ owns | — | — | — | — |
| **Procedural workflow steps** | — | ✓ owns | — | — | — |
| **`.flow.json` config schema** | — | — | ✓ owns | — | documents |
| **CLI flags & UX** | — | — | ✓ owns | — | documents |
| **Runtime auto-start logic** | — | — | ✓ owns | — | — |
| **HTTP protocol (`/flows/run`)** | — | — | ✓ defines | ✓ implements | documents |
| **Run records & artifacts** | — | — | ✓ owns | — | — |
| **Graph registration (`langgraph.json`)** | — | — | — | ✓ owns | documents |
| **State models (Pydantic)** | — | — | — | ✓ owns | — |
| **"How to run a flow" procedure** | triggers | ✓ describes | implements | executes | ✓ canonical |
| **"How to add a new flow"** | — | — | ✓ partial | ✓ partial | ✓ owns |

### Identified Gaps

| Gap | Description | Recommendation |
|-----|-------------|----------------|
| **Missing `.flow.json` files** | Documentation references `architecture-assessment.flow.json` but file doesn't exist | Create the file in `packages/prompts/` |
| **Missing workflow manifests** | YAML manifests for assessment and glossary flows not found | Create or locate canonical manifests |
| **"Add new flow" workflow** | No single owner for end-to-end new flow creation | Document in FlowKit guide |

---

## 4. Conflicts / Gaps / Drift Analysis

### A. Workspace vs Package: No Semantic Overlap ✓

**Evidence from workflow files:**

The workspace workflow (`.workspace/workflows/flowkit/run-flow/`) is purely procedural:

| Step | Content | Ownership |
|------|---------|-----------|
| `01-validate-input.md` | "Check that user included exactly one `@Files` reference" | Procedure |
| `02-parse-config.md` | "Read the JSON config file, extract required fields" | Procedure |
| `03-execute-flow.md` | "Execute the FlowKit CLI from the repo root: `pnpm flowkit:run`" | Procedure |
| `04-report-results.md` | "Craft a response with two sections: Flow Result, LangGraph Studio" | Procedure |

**Assessment:** The workspace layer describes *how a human/agent orchestrates* the CLI. It does not redefine config semantics, validation rules, or output formats—those live in the package.

### B. Entry Points: Single Source of Truth ✓

All entrypoints delegate to the canonical implementation:

```
Cursor command → Workspace workflow → CLI
pnpm flowkit:run → CLI
createHttpFlowRunner() → HTTP → Runtime
```

**Drift risk:** Low. The workflow step `03-execute-flow.md` explicitly calls `pnpm flowkit:run`, not a reimplementation.

**Mitigation:** Ensure workflow steps never specify CLI behavior (flags, output format) that could diverge from actual CLI.

### C. Locality vs Repo-Wide: Correctly Placed ✓

From `.workspace/scope.md`:
> "Root `.workspace` serves a dual purpose: Meta-documentation — Defines the .workspace harness pattern itself, Repo-wide agent harness — A fully functional workspace for repository-wide operations"

FlowKit is listed explicitly:
> "Workflows for FlowKit integration (run-flow)"

**Assessment:** FlowKit is a repo-wide tool, not domain-specific. Placing it in the root `.workspace` is correct per the documented scope.

### D. Trust and Safety ✓

| Aspect | Implementation | Status |
|--------|---------------|--------|
| **Guardrails** | CLI supports `--dry-run`, `--risk`, `--stage` flags | ✓ |
| **Determinism** | Idempotency keys, run records in `runs/` | ✓ |
| **Error modes** | Typed errors (`UpstreamProviderError`, `InputValidationError`), health checks, timeouts | ✓ |
| **Policy gates** | `kit.metadata.json` specifies `requiredGates: ["policykit", "evalkit-basic"]` | ✓ |

### E. Velocity and Developer Experience ✓

| Aspect | Implementation | Status |
|--------|---------------|--------|
| **IDE friction** | `/run-flow` with `@Files` reference | Low friction ✓ |
| **Works from root** | `pnpm flowkit:run` in root `package.json` | ✓ |
| **Studio snippet** | Workflow step 4 provides copy/paste instructions | ✓ |
| **Auto-start runner** | CLI handles `runtime.autoStart` config | ✓ |

### F. Continuity and Insight ✓

| Aspect | Implementation | Status |
|--------|---------------|--------|
| **Run records** | Written to `runs/flowkit/` directory | ✓ (directory exists) |
| **Trace correlation** | OpenTelemetry spans with `kit.flowkit.run` | ✓ |
| **Idempotency** | Keys derived from flowName + paths | ✓ |

---

## 5. Options Comparison

### Scoring Rubric

| Criteria | Weight | Description |
|----------|--------|-------------|
| Architecture fit | 1.0 | Respects workspace vs package vs runtime boundaries |
| Single source of truth | 1.0 | Minimizes drift and duplication |
| Velocity | 1.0 | Fastest day-to-day developer flow |
| Trust | 1.0 | Safest defaults, clearest guardrails |
| Focus | 1.0 | Lowest cognitive load |
| Continuity | 1.0 | Best run records and traceability |
| Insight | 1.0 | Easiest to turn outcomes into learning |

### Option 1: Layered Integration (Recommended)

**Description:** Keep current layering with minor clarifications.

| Criteria | Score | Justification |
|----------|:-----:|---------------|
| Architecture fit | 5 | Cursor→Workspace→Package→Runtime matches Octon layering |
| Single source of truth | 4 | CLI is canonical; workspace workflow references it |
| Velocity | 5 | All entrypoints available; auto-start works |
| Trust | 5 | Full guardrails, idempotency, run records |
| Focus | 4 | Four layers to understand, but well-documented |
| Continuity | 5 | Run records, traces, artifacts all present |
| Insight | 5 | Learning loops supported via run records |
| **Total** | **33** | |

**Modifications needed:**

1. Create missing `.flow.json` config files
2. Add catalog note clarifying workspace FlowKit workflow is a procedure
3. Ensure workflow steps never respecify CLI behavior

### Option 2: Packages-Only

**Description:** Minimize workspace involvement; Cursor command becomes ultra-thin.

| Criteria | Score | Justification |
|----------|:-----:|---------------|
| Architecture fit | 4 | Valid but loses procedural guidance layer |
| Single source of truth | 5 | Package is the only spec |
| Velocity | 4 | Slightly faster (no workflow steps) |
| Trust | 5 | Same guardrails |
| Focus | 5 | Fewer layers to understand |
| Continuity | 4 | Same, but loses procedural recovery guidance |
| Insight | 4 | Same |
| **Total** | **31** | |

**Trade-off:** Loses the guided procedure for agents that benefit from step-by-step workflows. The recovery guidance in workflow steps (e.g., "If CLI fails, surface stderr for user to fix") would be lost.

### Option 3: Workspace-Centric

**Description:** Move FlowKit logic into `.workspace`; package becomes minimal.

| Criteria | Score | Justification |
|----------|:-----:|---------------|
| Architecture fit | 2 | Violates "code belongs in packages" principle |
| Single source of truth | 3 | Splits ownership awkwardly |
| Velocity | 3 | Harder to test, no `vitest` in workspace |
| Trust | 4 | Harder to maintain guardrails |
| Focus | 3 | Confusing mental model |
| Continuity | 4 | Same run record capabilities |
| Insight | 4 | Same |
| **Total** | **23** | |

**Trade-off:** Fundamentally violates Octon's placement rules. Not recommended.

### Option 4: Template-Distributed

**Description:** Add FlowKit references to workspace templates for discoverability.

| Criteria | Score | Justification |
|----------|:-----:|---------------|
| Architecture fit | 4 | Complementary to Option 1 |
| Single source of truth | 4 | Same as Option 1 |
| Velocity | 5 | Improved discoverability in domains |
| Trust | 5 | Same |
| Focus | 4 | Same |
| Continuity | 5 | Same |
| Insight | 5 | Same |
| **Total** | **32** | |

**Assessment:** This is an enhancement to Option 1, not a replacement. Recommend as Phase 2.

### Summary

| Option | Total Score | Recommendation |
|--------|:-----------:|----------------|
| **Option 1: Layered Integration** | **33** | ✓ Recommended |
| Option 4: Template-Distributed | 32 | Phase 2 enhancement |
| Option 2: Packages-Only | 31 | Alternative if simplicity is paramount |
| Option 3: Workspace-Centric | 23 | Not recommended |

---

## 6. Recommendation

### Final Decision: Option 1 — Layered Integration

The current four-layer architecture is **correct and should be maintained** with minor clarifications:

1. **Cursor commands** (`.cursor/commands/`) — IDE trigger layer
2. **Workspace workflows** (`.workspace/workflows/flowkit/`) — Procedural harness for agents
3. **Package implementation** (`packages/kits/flowkit/`) — Canonical FlowKit code
4. **Runtime execution** (`agents/runner/runtime/`) — LangGraph graph execution

### Why This Is the Best Fit

1. **Respects Octon's architectural boundaries:**
   - Code implementation belongs in `/packages` (per `.workspace/scope.md`)
   - Workspace harness is for "repo-wide agent operations" (per `.workspace/scope.md`)
   - Runtime is correctly placed under `agents/`

2. **No semantic overlap:**
   - Workspace workflow describes *how* to orchestrate (procedural)
   - Package defines *what* config means and *how* to execute (semantic)

3. **Clear delegation chain:**
   - All entrypoints converge on the CLI as the single canonical implementation
   - Drift risk is minimal because workflow steps explicitly call `pnpm flowkit:run`

4. **Trust and safety are preserved:**
   - All guardrails (dry-run, risk tiers, idempotency) live in the package
   - Run records and traces are generated consistently

---

## 7. Implementation Plan

### Phase 1: Immediate Actions (Low Risk)

| Action | Owner | Files Affected |
|--------|-------|----------------|
| Create `architecture-assessment.flow.json` | FlowKit maintainer | `packages/prompts/assessment/architecture/` |
| Create `docs-glossary.flow.json` | FlowKit maintainer | `packages/prompts/glossary/` |
| Add catalog clarification note | Workspace maintainer | `.workspace/catalog.md` |
| Verify workflow step accuracy | Workspace maintainer | `.workspace/workflows/flowkit/run-flow/*` |

### Phase 2: Documentation Alignment

| Action | Owner | Files Affected |
|--------|-------|----------------|
| Update guide.md with actual config paths | FlowKit maintainer | `docs/services/planning/flow/guide.md` |
| Add "How to add a new flow" section | FlowKit maintainer | Same |
| Consider template distribution | Workspace maintainer | `.workspace/templates/` |

### Phase 3: Validation

| Action | Owner | Success Criteria |
|--------|-------|------------------|
| Run `/run-flow` end-to-end | Any developer | Flow executes, run record created |
| Verify Studio snippet works | Any developer | LangGraph Studio opens with correct graph |
| Test dry-run mode | Any developer | Config validated without execution |

---

## 8. Migration / Deprecation Plan

**No migration required.** The current architecture is correct; only missing artifacts need to be created.

### Artifacts to Create (Not Migrate)

| Artifact | Location | Status |
|----------|----------|--------|
| `architecture-assessment.flow.json` | `packages/prompts/assessment/architecture/` | Missing |
| `docs-glossary.flow.json` | `packages/prompts/glossary/` or similar | Missing |
| Workflow YAML manifests | Co-located with prompts | Need verification |

### Nothing to Deprecate

- Cursor command: Keep
- Workspace workflow: Keep
- Package implementation: Keep (canonical)
- Runtime: Keep (canonical)

---

## 9. Definition of Done

The FlowKit integration is considered "seamless and correct" when:

| Criteria | Verification Method |
|----------|---------------------|
| **End-to-end execution works** | Run `/run-flow @packages/prompts/.../architecture-assessment.flow.json` successfully |
| **Run records are created** | Check `runs/flowkit/` contains a new record after execution |
| **Studio snippet works** | Copy/paste the snippet from step 4, confirm Studio opens |
| **Dry-run validates without executing** | `pnpm flowkit:run <config> --dry-run` exits 0 with validation output |
| **Documentation matches reality** | All paths in `guide.md` resolve to actual files |
| **Catalog is clear** | Developers understand FlowKit workflows are repo-wide tool integrations |

---

## 10. Open Questions

| Question | Impact | Proposed Resolution |
|----------|--------|---------------------|
| **Where should `.flow.json` files live canonically?** | Medium | Co-locate with canonical prompts in `packages/prompts/` |
| **Should workflow YAML manifests be auto-generated from `.flow.json`?** | Low | Defer; current manual approach works |
| **Should domain workspaces include FlowKit references?** | Low | Consider in Phase 2 as template enhancement |

---

## Appendix: Inventory Details

### A. FlowKit Entrypoints

| Entrypoint | Location | User | Inputs | Outputs | Stability |
|------------|----------|------|--------|---------|-----------|
| Cursor `/run-flow` | `.cursor/commands/run-flow.md` | Human dev | `@Files` reference to `.flow.json` | Markdown result + Studio snippet | IDE-facing |
| `pnpm flowkit:run` | Root `package.json` | CI, scripts | Config path | JSON stdout | Stable CLI |
| `flowkit run` | `packages/kits/package.json` bin | Any | Config path, flags | JSON stdout | Stable CLI |
| `createHttpFlowRunner()` | `packages/kits/flowkit/src/index.ts` | Services, agents | `FlowConfig` object | `FlowRunResult` | API contract |
| `runFlowFromConfigPath()` | `packages/kits/flowkit/src/cli.ts` | Tests, scripts | Config path | `FlowRunResult` | Internal |

### B. Registered Graphs

From `langgraph.json`:

| Graph Name | Description | Entry Path |
|------------|-------------|------------|
| `architecture_assessment` | FlowKit Architecture Assessment graph | `agents.runner.runtime.assessment.studio_entry:graph` |
| `docs_glossary` | FlowKit Docs Glossary flow | `agents.runner.runtime.glossary.studio_entry:graph` |

### C. Key Files by Layer

**Cursor Layer:**

- `.cursor/commands/run-flow.md` — IDE entrypoint

**Workspace Layer:**

- `.workspace/workflows/flowkit/run-flow/00-overview.md` — Workflow overview
- `.workspace/workflows/flowkit/run-flow/01-validate-input.md` — Input validation step
- `.workspace/workflows/flowkit/run-flow/02-parse-config.md` — Config parsing step
- `.workspace/workflows/flowkit/run-flow/03-execute-flow.md` — CLI execution step
- `.workspace/workflows/flowkit/run-flow/04-report-results.md` — Result reporting step
- `.workspace/catalog.md` — Lists FlowKit workflow

**Package Layer:**

- `packages/kits/flowkit/src/index.ts` — Main exports, `createHttpFlowRunner()`
- `packages/kits/flowkit/src/cli.ts` — CLI implementation
- `packages/kits/flowkit/src/types.ts` — Type definitions
- `packages/kits/flowkit/schema/flowkit.inputs.v1.json` — Input schema
- `packages/kits/flowkit/schema/flowkit.outputs.v1.json` — Output schema
- `packages/kits/flowkit/metadata/kit.metadata.json` — Kit metadata

**Runtime Layer:**

- `agents/runner/runtime/server.py` — HTTP server with `/flows/run` endpoint
- `agents/runner/runtime/assessment/run.py` — Assessment flow runner
- `agents/runner/runtime/assessment/graph.py` — Assessment graph definition
- `agents/runner/runtime/assessment/state.py` — Assessment state model
- `agents/runner/runtime/glossary/run.py` — Glossary flow runner

**Docs Layer:**

- `docs/services/planning/flow/guide.md` — Canonical guide (507 lines)
- `packages/kits/flowkit/README.md` — Package README (281 lines)

---

*Generated: 2025-12-20*
*Spec: `.archive/flowkit-workspace-resolution.md`*
