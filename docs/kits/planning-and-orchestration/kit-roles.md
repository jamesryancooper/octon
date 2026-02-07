# Kit Roles — PlanKit, AgentKit, FlowKit, and the LangGraph Runtime

This document is the **canonical reference** for how Harmony’s planning and orchestration stack fits together:

- **PlanKit** (planning)
- **AgentKit** (agents that run plans)
- **FlowKit** (flow orchestration)
- The shared **LangGraph runtime** under `agents/runner/runtime/**`

Use this guide together with:

- `docs/kits/planning-and-orchestration/README.md`
- `docs/kits/planning-and-orchestration/{speckit,plankit,agentkit,flowkit}/guide.md`
- `docs/architecture/{overview,monorepo-layout,repository-blueprint,agent-roles,knowledge-plane/knowledge-plane}.md`

When any earlier docs conflict with this page, **this page wins**.

---

## 1. High‑level roles

### 1.1 FlowKit (TypeScript kit)

- FlowKit is the **flow orchestration kit**.
- In TypeScript (`packages/kits/flowkit/src/**`), it defines:
  - `FlowConfig`, `FlowRunner`, `FlowRunResult` (generic flow contracts).
  - `createHttpFlowRunner` and a CLI that:
    - Reads `*.flow.json` configs.
    - Starts or connects to a runner service (`agents.runner.runtime.server` by default).
    - Sends a `/flows/run` HTTP request with prompt path, manifest path, and entrypoint.
- FlowKit itself is **runtime‑agnostic**:
  - It assumes *“there is some runner that can execute flows”*.
  - In this repo, that runner is implemented with LangGraph in Python under `agents/runner/runtime/**`.

### 1.2 LangGraph runtime (Python)

- Lives under `agents/runner/runtime/**`.
- Responsibilities:
  - Build concrete LangGraph graphs from workflow manifests (for example `assessment/graph.py`, `graph_factory.py`, `state.py`, etc.).
  - Provide a **runner service** (`server.py`) that exposes `/flows/run` and dispatches to specific flows (for example `"architecture_assessment"`).
  - Provide **Studio entrypoints** (for example `assessment/studio_entry.py`) that expose `graph` for `langgraph.json` and LangGraph Studio.
- Conceptually, this is **infrastructure**:
  - It is the concrete “FlowKit runtime” implementation, built on LangGraph.
  - It is **shared by all flows and agents**; there is only one runtime in this monorepo.

### 1.3 AgentKit

- AgentKit is the **agent kit**.
- Responsibilities:
  - **Run PlanKit plans** as durable, stateful agent graphs (with retries, resume, checkpoints, human‑in‑the‑loop).
  - Delegate runtime gates to PolicyKit/EvalKit/TestKit/ComplianceKit.
  - Produce artifacts and keep a durable state store (SQLite by default) via LangGraph checkpointers.
- AgentKit **inherits FlowKit’s LangGraph runtime**:
  - It does **not** own a separate runtime.
  - It uses the same FlowKit → LangGraph pipeline as any other FlowKit client.
  - It sits **above FlowKit**, wiring PlanKit plans to FlowKit flows and using LangGraph’s durability/checkpointing.

### 1.4 PlanKit

- PlanKit is the **planning kit**, wrapping BMAD as a Harmony‑native kit (`plankit`).
- Responsibilities:
  - Take validated specs and constraints (primarily SpecKit outputs) and produce BMAD‑style plans and stories.
  - Emit a canonical `plan.json` plus any ADR/checklist updates that downstream kits can consume.
  - Integrate with PolicyKit/ComplianceKit/ObservaKit so planning is governed, observable, and repeatable.
- PlanKit sits **between SpecKit and FlowKit/AgentKit**:
  - Upstream: consumes SpecKit artifacts and methodology constraints as primary inputs.
  - Downstream: its `plan.json` is what FlowKit turns into executable flows and what AgentKit uses to drive long‑running runs.

---

## 2. Flows vs agents vs runtimes

### 2.1 Flows (FlowKit + LangGraph)

In Harmony:

- A **flow** is a single, structured workflow:
  - Canonical prompt + YAML workflow manifest + LangGraph graph + HTTP handler.
  - Example: “Architecture Assessment Flow”.
- FlowKit provides the **contracts and runner client**:
  - `FlowConfig`, `FlowRunner`, `FlowRunResult`.
  - HTTP runner (`createHttpFlowRunner`) and CLI (`flowkit:run`).
- The LangGraph runtime under `agents/runner/runtime/**` provides the **concrete implementation**:
  - A `StateGraph` per flow.
  - Nodes that implement the steps from the manifest.
  - `/flows/run` handler that executes the graph given a `FlowConfig`.

**Key point:** FlowKit itself does not “own” LangGraph or Python; it simply **talks to the runtime** over HTTP.

### 2.2 Agents (AgentKit)

An **agent** is a higher‑level actor that:

- Consumes a plan from PlanKit (`plan.json`).
- Decides which flows to invoke when, with what parameters and context.
- Handles retries, resume, long‑term run identity, and human‑in‑the‑loop checkpoints.

AgentKit:

- Uses PlanKit’s `plan.json` as source of truth.
- Chooses FlowKit flows per plan step and calls FlowKit (which calls `/flows/run` on the runtime).
- Interprets results and updates durable agent state via LangGraph checkpointing.
- Delegates gates and evidence to PolicyKit, EvalKit, TestKit, ComplianceKit, ObservaKit, etc.

### 2.3 Runtimes (`agents/runner/runtime/**`)

The **LangGraph runtime** under `agents/runner/runtime/**`:

- Hosts *all* graphs used by FlowKit flows and AgentKit agents.
- Exposes **one** HTTP API (`/flows/run`) to any FlowKit client.
- Provides LangGraph Studio entrypoints via `langgraph.json` → `studio_entry.py`.

**Important invariants:**

- There is **one shared LangGraph runtime** in this monorepo.
- Agents do **not** spawn their own runtimes.
- New flows extend the shared runtime; new agents call into it via FlowKit.

---

## 3. Adding new flows

Right now we have one primary flow: `architecture_assessment`, implemented under `agents/runner/runtime/assessment/**`. Additional flows (for example `security_assessment`, `refactoring_advisor`) follow this pattern.

### Step 1 — Define flow assets (FlowKit‑level artifacts)

Under `packages/workflows/<flowId>/`, add:

- Flow config: `<flowId>.flow.json` — registers the flow with FlowKit tooling.
- Flow config: `config.flow.json` — registers the flow with FlowKit tooling.
- Canonical prompt: `00-overview.md` — describes the flow mission/process.
- Workflow manifest: `manifest.yaml` — graph structure; node ids, dependencies, prompt paths, meta, etc.
- Step prompts: `NN-<step>.md` — numbered step-specific prompts (like `.harmony` workflows).

Reusable action prompts can be placed under `packages/prompts/**`.

These are **FlowKit artifacts**; they are independent of the runtime implementation.

### Step 2 — Add Python graph implementation under `agents/runner/runtime`

Create a new package‑like subdirectory, mirroring `assessment`:

- `agents/runner/runtime/<flow_name>/`
  - `graph.py` (LangGraph `StateGraph` wiring).
  - `state.py` (Pydantic models for graph state).
  - Node implementations (for example `analysis.py`, `inventory.py`, etc.).
  - `graph_factory.py` (compile from manifest → `CompiledStateGraph`).
  - `studio_entry.py` (exports `graph` for LangGraph Studio).

This keeps each flow’s LangGraph graph, state, and nodes **together** under the shared runtime.

### Step 3 — Wire it into the HTTP runner (`server.py`)

In `agents/runner/runtime/server.py`, extend `FLOW_HANDLERS`:

- Add a handler function that:
  - Reads `canonicalPromptPath`, `workflowManifestPath`, `workflowEntrypoint`, `workspaceRoot`.
  - Compiles or loads the LangGraph graph for this flow.
  - Invokes the graph and returns a `FlowRunResponse`.
- Register a new `flowName` key (for example `"security_assessment"`).

This is the **API surface** the FlowKit HTTP runner uses (`/flows/run`).

### Step 4 — Register it for FlowKit CLI and LangGraph Studio

For FlowKit CLI:

- Add a `*.flow.json` config pointing to:
  - `canonicalPromptPath`, `workflowManifestPath`, `workflowEntrypoint`.
  - `runtime.url` and `runtime.autoStart.pythonCommand` (pointing to `agents/runner/runtime/.venv/bin/python` and module `agents.runner.runtime.server`).

For LangGraph Studio:

- Extend `langgraph.json` with another entry:
  - `"path": "agents.runner.runtime.<flow_name>.studio_entry:graph"`.
- This lets you inspect the new graph in Studio while FlowKit and AgentKit use the same runtime in normal operation.

**Net effect:** all LangGraph graphs (for flows) live under the **single shared runtime** in `agents/runner/runtime`, with one HTTP API (`/flows/run`) serving all named flows.

---

## 4. Adding new agents under `agents/`

To keep responsibilities clean:

### 4.1 Mental model — flows vs agents

- A **flow** (FlowKit + LangGraph) is a single, structured workflow:
  - Canonical prompt + YAML manifest + LangGraph graph + HTTP handler.
  - Example: “Architecture Assessment Flow”.
- An **agent** (AgentKit) is a higher‑level actor that:
  - Consumes a plan from PlanKit (`plan.json`).
  - Decides which flows to invoke when, with what parameters and context.
  - Handles retries, resume, long‑term run identity, and human‑in‑the‑loop checkpoints.

### 4.2 Where agents live physically

- Keep the **shared runtime** (LangGraph + HTTP server) in `agents/runner/runtime`.
- Agent logic is split as follows:
  - The **core agent logic** (state machines, plan execution, hooks, etc.) lives in AgentKit and related kits under `packages/kits` as configurations and orchestrators that always call FlowKit.
  - The **`agents/` directory** is reserved for small, **deployable agent or flow‑oriented services/processes** that embody particular agent behaviors in production (review, assess, triage, etc.), all of which **reuse** the same shared LangGraph runtime in `agents/runner/runtime`.

Services under `agents/<agent-name>/<agent-behavior-name>/` should remain **thin hosts** that:

- Read `plan.json` (PlanKit output) or similar artifacts.
- Use AgentKit APIs to drive the plan.
- Delegate all orchestration to AgentKit + FlowKit, which in turn call the shared runtime.

### 4.3 Examples

Examples of useful `agents/<agent-name>/<agent-behavior-name>/` hosts:

- `agents/architect/assessment/` — long‑running **Architecture Assessment Agent** that:
  - Consumes architecture specs via SpecKit/PlanKit.
  - Orchestrates `architecture_assessment` and related flows via FlowKit.
  - Produces structured findings and ADR suggestions for Architecture docs.
- `agents/planner/doc-refresh/` — **Documentation Refresh Agent** that:
  - Watches for stale specs/ADRs.
  - Uses PlanKit to generate a “doc refresh” plan and drives FlowKit flows to propose content updates.
- `agents/verifier/change-risk-review/` — **Change Risk Review Agent** that:
  - Consumes a PlanKit plan and CI signals (EvalKit/TestKit/PolicyKit).
  - Orchestrates flows that summarize risk, required gates, and recommended rollout steps before PatchKit/ReleaseKit run.

**Key principle:**

- **Do not clone the LangGraph runtime per agent.**
- Keep **one** runtime in `agents/runner/runtime` and have multiple agents (AgentKit instances/configs) call into it via FlowKit.

---

## 5. Responsibilities: FlowKit vs PlanKit vs AgentKit vs LangGraph runtime

This section is the canonical summary of responsibilities; other docs (AI‑Toolkit, architecture, methodology) should align with it.

### 5.1 FlowKit responsibilities

- Define the **flow contract** (config, run request, run result).
- Provide:
  - Type‑safe interfaces (`FlowConfig`, `FlowRunner`, `FlowRunResult`).
  - The HTTP runner client (`createHttpFlowRunner`).
  - A CLI that:
    - Loads `*.flow.json`.
    - Starts/stops the runner (`agents.runner.runtime.server`).
    - Calls `/flows/run` with correct payloads.
- Know how to:
  - Map a single “flow run” → HTTP call → runtime → result.

**FlowKit is _not_ responsible for:**

- PlanKit plans or agent‑level logic.
- Checkpointing semantics (it just sends a single run request).
- Human‑in‑the‑loop control.

### 5.2 LangGraph runtime responsibilities (`agents/runner/runtime/**`)

- Build and run **graphs** based on YAML manifests and prompts:
  - Use LangGraph `StateGraph` to wire nodes and edges.
  - Use Pydantic models for graph state (for example `AssessmentGraphState`).
- Serve flows over HTTP (`/flows/run`) to any FlowKit client.
- Provide Studio entrypoints via `langgraph.json` → `studio_entry.py`.

**The runtime is _not_ responsible for:**

- Deciding *which* flow to run given a PlanKit plan.
- Long‑lived agent orchestration across multiple flow runs.

### 5.3 AgentKit responsibilities

- Consume **plans**, not just prompts/manifests:
  - Input: `plan.json` produced by PlanKit, plus `run_id`/`resume` etc.
  - Output: durable state (checkpoints), artifacts, run records under `runs/**`, and a reproducible trace.
- Use FlowKit + the LangGraph runtime as its **execution engine**:
  - For each plan or plan step, construct a `FlowConfig` (or choose from a set of known configs).
  - Invoke FlowKit (which hits `/flows/run` on the runtime).
  - Interpret results and update the agent’s state/checkpoint.
  - Configure and rely on LangGraph checkpointing (for example, SQLite) so long‑running agent runs can pause/resume and survive restarts.
- Handle:
  - **Retries/resume** using LangGraph checkpointing (via the runtime).
  - **Human‑in‑the‑loop** pauses and edits (HITL checkpoints) based on PlanKit/PolicyKit guidance.
  - **No‑silent‑apply**: produce proposed diffs, tests, and notes only; delegate actual apply to PatchKit/ReleaseKit or humans.
  - **Determinism and safety**: integrate GuardKit, PolicyKit, EvalKit, ComplianceKit, and CacheKit for redaction, policy gates, evaluation, evidence packs, and idempotency on mutating operations.
  - **Observability**: emit ObservaKit spans and structured run records (for example `kit.agentkit.execute`, `run.id`, `stage=implement`, `plan.id`, `prompt_hash` where applicable).

### 5.4 PlanKit responsibilities

- Own the **planning** stage between SpecKit and FlowKit/AgentKit:
  - Input: validated specs and constraints (primarily SpecKit outputs and Methodology guidance).
  - Output: BMAD‑style plans and stories plus a canonical `plan.json` (and ADR/checklist updates) that downstream kits can consume.
- Wrap **BMAD** as a Harmony‑native kit (`plankit`) so that:
  - BMAD workflow/parameter churn is encapsulated behind a single, versioned kit boundary.
  - Callers rely on stable contracts under `packages/contracts/schemas/kits/plankit.inputs.v1.json`.
- Coordinate with **PolicyKit/ComplianceKit/ObservaKit** at plan time:
  - Ensure the right policy ruleset is selected and that risky plans can be gated or rejected before execution.
  - Emit required spans (for example `kit.plankit.plan`) and link plans to traces/run records for later evidence packs.
- Provide a **clean handoff** into execution:
  - Design plans so FlowKit can deterministically map steps → flows.
  - Make it easy for AgentKit to drive long‑running runs using `plan.json` as the source of truth.

---

## 6. End‑to‑end mental model

The end‑to‑end flow across kits and the runtime looks like this:

1. **PlanKit** turns validated specs and constraints into a BMAD‑style plan and canonical `plan.json`.
2. **AgentKit** decides *what needs to happen* (per PlanKit plan) and when to resume/pause, using `plan.json` as its source of truth.
3. **FlowKit** turns “run this flow with these paths and params” into structured HTTP calls derived from the plan (or canonical prompts where appropriate).
4. The **LangGraph runtime** actually runs the flow and manages graph‑level state and checkpointing.
5. **LangGraph Studio** connects to the runtime (via `langgraph.json` and `studio_entry.py`) so we can debug the same graphs AgentKit is invoking.

For **development of a new capability**:

1. (Spec/Plan) Use SpecKit + PlanKit to produce a validated spec, ADR, and `plan.json` for the capability.
2. Define prompts and workflow manifest — informed by the spec/plan — as **FlowKit artifacts**.
3. Implement LangGraph graph + nodes → **runtime code** under `agents/runner/runtime/<flow_name>/`.
4. Add a FlowKit `*.flow.json` config and extend `FLOW_HANDLERS` in `server.py`.
5. Optionally register the graph in `langgraph.json` for Studio.

For **running a flow directly (FlowKit)**:

1. Developer runs `pnpm flowkit:run path/to/flow.flow.json`.
2. FlowKit CLI:
   - Starts/contacts `agents.runner.runtime.server`.
   - Calls `/flows/run` with `flowName`, prompt path, manifest path, etc.
3. The runtime uses LangGraph to execute the graph and returns a result.

For **running a plan as an agent (AgentKit)**:

1. PlanKit produces a `plan.json` (PlanKit plan).
2. AgentKit:
   - Loads the plan.
   - Chooses which FlowKit flows to call (and in what order) given the plan.
   - For each step or sub‑flow:
     - Calls FlowKit (HTTP runner) → LangGraph runtime.
   - Uses LangGraph checkpointing to maintain resilient state across runs.
   - Pauses for human approval or edits when required; then resumes.
3. LangGraph Studio can be used at any time to inspect the underlying graphs that AgentKit is driving.

---

## 7. LangGraph Studio and `langgraph.json`

LangGraph Studio can attach directly to the shared LangGraph runtime so you can explore every node, edge, and state mutation. In this repo:

- `agents/runner/runtime/assessment/studio_entry.py` exports the compiled graph as `graph`.
- `langgraph.json` at the repo root registers the `architecture_assessment` graph (and any others you add) for the LangGraph CLI.

To launch Studio locally:

1. Install the CLI (one time per workstation):
   - `uv tool install "langgraph-cli[inmem]"`
2. Ensure the runtime dependencies are installed:
   - `cd agents/runner/runtime`
   - `uv sync`
3. From the repo root, run:
   - `LANGCHAIN_API_KEY=<optional-langsmith-key> langgraph dev --config langgraph.json`

By default, Studio uses environment variables (or defaults inside `studio_entry.py`) for:

- `FLOWKIT_STUDIO_WORKSPACE_ROOT` (workspace root, usually the repo root).
- `FLOWKIT_STUDIO_WORKFLOW_MANIFEST` (for example `packages/workflows/architecture_assessment/manifest.yaml`).
- `FLOWKIT_STUDIO_WORKFLOW_ENTRYPOINT` (usually the manifest’s first step).

Override these before running `langgraph dev` if you want Studio to load a different manifest, workspace root, or entrypoint.

Use Studio whenever you need to:

- Visualize graphs defined in workflow manifests.
- Inspect node inputs/outputs and shared state models (for example `AssessmentGraphState`).
- Replay or branch from checkpoints generated by the runtime.

Studio is a **debugging and visualization tool** that attaches to the same graphs that FlowKit and AgentKit use, not a separate runtime.

---

## 8. Summary and guidance

- **Keep** the LangGraph runtime in `agents/runner/runtime` as the **shared FlowKit runtime** for the monorepo.
- **Add new flows** by:
  - Creating a new flow directory under `packages/workflows/<flowId>/` with flow config, canonical prompt, and workflow manifest.
  - Implementing new LangGraph graphs under `agents/runner/runtime/<flow_name>/`.
  - Wiring handlers in `server.py` and registering the graph in `langgraph.json`.
- **Create new agents** by:
  - Implementing AgentKit configurations to consume plans and orchestrate flows.
  - Optionally adding thin hosts under `agents/<agent-name>/<agent-behavior-name>/` when you need dedicated agent processes.
  - Always reusing the single LangGraph runtime via FlowKit, rather than spawning per‑agent runtimes.
- **Secure and observe the runner and hosts** by:
  - Treating `/flows/run` as an internal control‑plane API: restrict access to trusted callers (for example, FlowKit, AgentKit hosts, CI) and validate any file paths or identifiers it receives.
  - Instrumenting the Python runtime and any `agents/<agent-name>/<agent-behavior-name>/` hosts with ObservaKit + OpenTelemetry so flow and agent runs emit consistent traces/logs/metrics.
  - Avoiding logging sensitive content or raw secrets; rely on GuardKit and redaction rules at kit and host boundaries.

This model keeps PlanKit, FlowKit, LangGraph, and AgentKit cleanly separated but tightly integrated, with `agents/runner/runtime` as the central, shared execution engine for all flows and agents in the monorepo and `agents/<agent-name>/<agent-behavior-name>/` reserved for thin, deployable agent or flow‑oriented hosts.
