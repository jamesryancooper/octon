# Service Roles — Plan, Agent, Flow, Native Runtime, and Optional Adapters

This document is the **canonical reference** for how Octon's planning and orchestration stack fits together:

- **Plan** (planning)
- **Agent** (agents that run plans)
- **Flow** (flow orchestration)
- The native **Octon flow runtime** under `.octon/capabilities/runtime/services/execution/flow/**`
- Optional external runtime adapters (for example LangGraph HTTP)

Use this guide together with:

- `.octon/capabilities/runtime/services/planning/README.md`
- `.octon/capabilities/runtime/services/planning/{spec,plan,playbook}/guide.md`
- `.octon/capabilities/runtime/services/execution/{agent,flow}/guide.md`
- `.octon/cognition/_meta/architecture/{overview,monorepo-layout,repository-blueprint,agent-roles}.md`
- `.octon/cognition/runtime/knowledge/knowledge.md`

When any earlier docs conflict with this page, **this page wins**.

## 0. Normative Update (2026-02-16)

The following rules are normative and supersede legacy runtime assumptions:

1. Core Planning+Execution services (`spec`, `plan`, `playbook`, `agent`, `flow`) must run without Python as a required dependency.
2. Flow defaults to native harness execution.
3. External runtimes (including LangGraph) are adapter integrations and remain optional.
4. Provider/runtime-specific terms are restricted to adapter paths.
5. Any references below to Python as a default runtime are historical unless explicitly marked as adapter-only guidance.

---

## 1. High-level roles

### 1.1 Flow (Harness Runtime Service)

- Flow is the **flow orchestration service**.
- In the harness runtime (`.octon/capabilities/runtime/services/execution/flow/**` + runtime clients), it defines:
  - `FlowConfig`, `FlowRunner`, `FlowRunResult` (generic flow contracts).
  - A native runtime execution path with deterministic contracts.
- Flow is **runtime-agnostic**:
  - Native runtime is required and default.
  - External runtimes are optional adapter integrations.

### 1.2 External LangGraph Runtime Adapter (Optional)

- Adapter implementation can live under `agents/runner/runtime/**`.
- Responsibilities:
  - Build concrete LangGraph graphs from workflow manifests (for example `assessment/graph.py`, `graph_factory.py`, `state.py`, etc.).
  - Optionally provide an adapter runner service (`server.py`) that exposes `/flows/run` and dispatches to specific flows (for example `"architecture_assessment"`).
  - Provide **Studio entrypoints** (for example `assessment/studio_entry.py`) that expose `graph` for `langgraph.json` and LangGraph Studio.
- Conceptually, this is **external adapter infrastructure** and not core runtime ownership.

### 1.3 Agent

- Agent is the **agent service**.
- Responsibilities:
  - **Run Plan plans** as durable, stateful agent graphs (with retries, resume, checkpoints, and ACP gates).
  - Delegate runtime gates to Policy/Eval/Test/Compliance.
  - Produce artifacts and keep a durable state store (SQLite by default) via LangGraph checkpointers.
- Agent uses Flow's execution interfaces:
  - It does **not** own a separate runtime.
  - It sits **above Flow**, wiring Plan plans to Flow flows through native runtime or optional adapters.

### 1.4 Plan

- Plan is the **planning service**, wrapping BMAD as a Octon-native service (`plan`).
- Responsibilities:
  - Take validated specs and constraints (primarily Spec outputs) and produce BMAD-style plans and stories.
  - Emit a canonical `plan.json` plus any ADR/checklist updates that downstream services can consume.
  - Integrate with Policy/Compliance/Observe so planning is governed, observable, and repeatable.
- Plan sits **between Spec and Flow/Agent**:
  - Upstream: consumes Spec artifacts and methodology constraints as primary inputs.
  - Downstream: its `plan.json` is what Flow turns into executable flows and what Agent uses to drive long-running runs.

---

## 2. Flows vs agents vs runtimes

### 2.1 Flows (Flow + Runtime Adapters)

In Octon:

- A **flow** is a single, structured workflow:
  - Canonical prompt + YAML workflow manifest + execution graph + handler.
  - Example: "Architecture Assessment Flow".
- Flow provides the **contracts and runner client**:
  - `FlowConfig`, `FlowRunner`, `FlowRunResult`.
  - HTTP runner (`createHttpFlowRunner`) and CLI (`service:run` pattern).
- The native runtime under `.octon/capabilities/runtime/services/execution/flow/**` provides the default concrete implementation.
- Optional adapters (for example LangGraph HTTP) can provide external execution backends.

**Key point:** Flow does not require LangGraph or Python to operate.

### 2.2 Agents (Agent)

An **agent** is a higher-level actor that:

- Consumes a plan from Plan (`plan.json`).
- Decides which flows to invoke when, with what parameters and context.
- Handles retries, resume, long-term run identity, and ACP gates.

Agent:

- Uses Plan's `plan.json` as source of truth.
- Chooses Flow flows per plan step and calls Flow.
- Interprets results and updates durable agent state via LangGraph checkpointing.
- Delegates gates and evidence to Policy, Eval, Test, Compliance, Observe, etc.

### 2.3 Runtimes

The native runtime under `.octon/capabilities/runtime/services/execution/flow/**`:

- Is required for core execution behavior.
- Runs under harness constraints with no Python requirement.
- Owns canonical contract behavior for flow execution.

Optional external runtime adapters (for example `agents/runner/runtime/**`):

- Are explicitly configured via adapter contracts.
- Can expose `/flows/run` and Studio entrypoints where needed.
- Must not redefine canonical Flow semantics.

**Important invariants:**

- Native runtime support is mandatory.
- External runtime adapters are optional.
- Agents do not spawn per-agent runtimes.

---

## 3. Adding new flows

Right now we have one primary flow: `architecture_assessment`.

This section includes both paths:

1. Native runtime implementation path (default, required).
2. Optional LangGraph adapter path (opt-in).

### Step 1 — Define flow assets (Flow-level artifacts)

Under `packages/workflows/<flowId>/`, add:

- Flow config: `<flowId>.flow.json` — registers the flow with Flow tooling.
- Flow config: `config.flow.json` — registers the flow with Flow tooling.
- Canonical prompt: `00-overview.md` — describes the flow mission/process.
- Workflow manifest: `manifest.yaml` — graph structure; node ids, dependencies, prompt paths, meta, etc.
- Step prompts: `NN-<step>.md` — numbered step-specific prompts (like `.octon` workflows).

Reusable action prompts can be placed under `packages/prompts/**`.

These are **Flow artifacts**; they are independent of the runtime implementation.

### Step 2a — Add native flow runtime implementation (required)

Implement flow execution under `.octon/capabilities/runtime/services/execution/flow/**` with native contracts and deterministic behavior.

### Step 2b — Add optional LangGraph adapter implementation under `agents/runner/runtime`

Create a new package-like subdirectory, mirroring `assessment`:

- `agents/runner/runtime/<flow_name>/`
  - `graph.py` (LangGraph `StateGraph` wiring).
  - `state.py` (Pydantic models for graph state).
  - Node implementations (for example `analysis.py`, `inventory.py`, etc.).
  - `graph_factory.py` (compile from manifest → `CompiledStateGraph`).
  - `studio_entry.py` (exports `graph` for LangGraph Studio).

This keeps each flow's LangGraph graph, state, and nodes **together** under the shared runtime.

### Step 3 — Wire optional adapter runtime into HTTP runner (`server.py`)

In `agents/runner/runtime/server.py`, extend `FLOW_HANDLERS`:

- Add a handler function that:
  - Reads `canonicalPromptPath`, `workflowManifestPath`, `workflowEntrypoint`, `workspaceRoot`.
  - Compiles or loads the LangGraph graph for this flow.
  - Invokes the graph and returns a `FlowRunResponse`.
- Register a new `flowName` key (for example `"security_assessment"`).

This is the **API surface** the Flow HTTP runner uses (`/flows/run`).

### Step 4 — Register optional adapter for Flow and LangGraph Studio

For Flow CLI:

- Add a `*.flow.json` config pointing to:
  - `canonicalPromptPath`, `workflowManifestPath`, `workflowEntrypoint`.
  - optional external adapter `runtime.url` and adapter metadata.
  - avoid Python-specific defaults in core configs.

For LangGraph Studio:

- Extend `langgraph.json` with another entry:
  - `"path": "agents.runner.runtime.<flow_name>.studio_entry:graph"`.
- This lets you inspect the new graph in Studio while Flow and Agent use the same runtime in normal operation.

**Net effect:** native flow runtime remains default and mandatory; optional LangGraph runtime can be added via adapter contracts where needed.

---

## 4. Adding new agents under `agents/`

To keep responsibilities clean:

### 4.1 Mental model — flows vs agents

- A **flow** (Flow + runtime adapter) is a single, structured workflow:
  - Canonical prompt + YAML manifest + execution graph + handler.
  - Example: "Architecture Assessment Flow".
- An **agent** (Agent) is a higher-level actor that:
  - Consumes a plan from Plan (`plan.json`).
  - Decides which flows to invoke when, with what parameters and context.
  - Handles retries, resume, long-term run identity, and ACP gates.

### 4.2 Where agents live physically

- Keep native runtime behavior in Execution Flow service contracts.
- Agent logic is split as follows:
  - The **core agent logic** (state machines, plan execution, hooks, etc.) lives in the Agent service and related harness service contracts/orchestrators that always call Flow.
  - The **`agents/` directory** is reserved for small, **deployable agent or flow-oriented services/processes** that embody particular agent behaviors in production (review, assess, triage, etc.). These can integrate optional external adapters when needed.

Services under `agents/<agent-name>/<agent-behavior-name>/` should remain **thin hosts** that:

- Read `plan.json` (Plan output) or similar artifacts.
- Use Agent APIs to drive the plan.
- Delegate all orchestration to Agent + Flow, which in turn call the shared runtime.

### 4.3 Examples

Examples of useful `agents/<agent-name>/<agent-behavior-name>/` hosts:

- `agents/architect/assessment/` — long-running **Architecture Assessment Agent** that:
  - Consumes architecture specs via Spec/Plan.
  - Orchestrates `architecture_assessment` and related flows via Flow.
  - Produces structured findings and ADR suggestions for Architecture docs.
- `agents/planner/doc-refresh/` — **Documentation Refresh Agent** that:
  - Watches for stale specs/ADRs.
  - Uses Plan to generate a "doc refresh" plan and drives Flow flows to propose content updates.
- `agents/verifier/change-risk-review/` — **Change Risk Review Agent** that:
  - Consumes a Plan plan and CI signals (Eval/Test/Policy).
  - Orchestrates flows that summarize risk, required gates, and recommended rollout steps before Patch/Release run.

**Key principle:**

- **Do not clone the LangGraph runtime per agent.**
- Keep **one** runtime in `agents/runner/runtime` and have multiple agents (Agent instances/configs) call into it via Flow.

---

## 5. Responsibilities: Flow vs Plan vs Agent vs LangGraph runtime

This section is the canonical summary of responsibilities; other docs (AI Services, architecture, methodology) should align with it.

### 5.1 Flow responsibilities

- Define the **flow contract** (config, run request, run result).
- Provide:
  - Type-safe interfaces (`FlowConfig`, `FlowRunner`, `FlowRunResult`).
  - The HTTP runner client (`createHttpFlowRunner`).
  - A CLI that:
    - Loads `*.flow.json`.
    - Selects the configured adapter runtime endpoint and issues a typed run request.
    - Calls `/flows/run` with correct payloads.
- Know how to:
  - Map a single "flow run" → HTTP call → runtime → result.

**Flow is _not_ responsible for:**

- Plan plans or agent-level logic.
- Checkpointing semantics (it just sends a single run request).
- ACP control.

### 5.2 LangGraph runtime responsibilities (`agents/runner/runtime/**`)

- Build and run **graphs** based on YAML manifests and prompts:
  - Use LangGraph `StateGraph` to wire nodes and edges.
  - Use Pydantic models for graph state (for example `AssessmentGraphState`).
- Serve flows over HTTP (`/flows/run`) to any Flow client.
- Provide Studio entrypoints via `langgraph.json` → `studio_entry.py`.

**The runtime is _not_ responsible for:**

- Deciding *which* flow to run given a Plan plan.
- Long-lived agent orchestration across multiple flow runs.

### 5.3 Agent responsibilities

- Consume **plans**, not just prompts/manifests:
  - Input: `plan.json` produced by Plan, plus `run_id`/`resume` etc.
  - Output: durable state (checkpoints), artifacts, run records under `runs/**`, and a reproducible trace.
- Use Flow + the LangGraph runtime as its **execution engine**:
  - For each plan or plan step, construct a `FlowConfig` (or choose from a set of known configs).
  - Invoke Flow (which hits `/flows/run` on the runtime).
  - Interpret results and update the agent's state/checkpoint.
  - Configure and rely on LangGraph checkpointing (for example, SQLite) so long-running agent runs can pause/resume and survive restarts.
- Handle:
  - **Retries/resume** using LangGraph checkpointing (via the runtime).
  - **ACP gate** pauses and escalations based on Plan/Policy guidance.
  - **No-silent-apply**: produce proposed diffs, tests, and notes only; delegate actual apply to Patch/Release or humans.
  - **Determinism and safety**: integrate Guard, Policy, Eval, Compliance, and Cache for redaction, policy gates, evaluation, evidence packs, and idempotency on mutating operations.
  - **Observability**: emit Observe spans and structured run records (for example `service.agent.execute`, `run.id`, `stage=implement`, `plan.id`, `prompt_hash` where applicable).

### 5.4 Plan responsibilities

- Own the **planning** stage between Spec and Flow/Agent:
  - Input: validated specs and constraints (primarily Spec outputs and Methodology guidance).
  - Output: BMAD-style plans and stories plus a canonical `plan.json` (and ADR/checklist updates) that downstream services can consume.
- Wrap **BMAD** as a Octon-native service (`plan`) so that:
  - BMAD workflow/parameter churn is encapsulated behind a single, versioned service boundary.
  - Callers rely on stable contracts under `.octon/capabilities/runtime/services/planning/plan/schema/input.schema.json`.
- Coordinate with **Policy/Compliance/Observe** at plan time:
  - Ensure the right policy ruleset is selected and that risky plans can be gated or rejected before execution.
  - Emit required spans (for example `service.plan.plan`) and link plans to traces/run records for later evidence packs.
- Provide a **clean handoff** into execution:
  - Design plans so Flow can deterministically map steps → flows.
  - Make it easy for Agent to drive long-running runs using `plan.json` as the source of truth.

---

## 6. End-to-end mental model

The end-to-end flow across services and the runtime looks like this:

1. **Plan** turns validated specs and constraints into a BMAD-style plan and canonical `plan.json`.
2. **Agent** decides *what needs to happen* (per Plan plan) and when to resume/pause, using `plan.json` as its source of truth.
3. **Flow** turns "run this flow with these paths and params" into structured HTTP calls derived from the plan (or canonical prompts where appropriate).
4. The **LangGraph runtime** actually runs the flow and manages graph-level state and checkpointing.
5. **LangGraph Studio** connects to the runtime (via `langgraph.json` and `studio_entry.py`) so we can debug the same graphs Agent is invoking.

For **development of a new capability**:

1. (Spec/Plan) Use Spec + Plan to produce a validated spec, ADR, and `plan.json` for the capability.
2. Define prompts and workflow manifest — informed by the spec/plan — as **Flow artifacts**.
3. Implement LangGraph graph + nodes → **runtime code** under `agents/runner/runtime/<flow_name>/`.
4. Add a Flow `*.flow.json` config and extend `FLOW_HANDLERS` in `server.py`.
5. Optionally register the graph in `langgraph.json` for Studio.

For **running a flow directly (Flow)**:

1. Developer runs a Flow service command.
2. Flow CLI:
   - Uses native runtime by default.
   - Optionally contacts an external adapter runtime.
   - Calls `/flows/run` with `flowName`, prompt path, manifest path, etc.
3. The selected runtime executes the graph and returns a result.

For **running a plan as an agent (Agent)**:

1. Plan produces a `plan.json` (Plan plan).
2. Agent:
   - Loads the plan.
   - Chooses which Flow flows to call (and in what order) given the plan.
   - For each step or sub-flow:
     - Calls Flow execution interface.
   - Uses configured checkpointing to maintain resilient state across runs.
   - Pauses for ACP stage-only remediation or edits when required; then resumes.
3. LangGraph Studio can be used at any time to inspect the underlying graphs that Agent is driving.

---

## 7. LangGraph Studio and `langgraph.json`

LangGraph Studio is an optional adapter debugging surface. It is not required for core native execution.

LangGraph Studio can attach directly to the optional LangGraph adapter runtime so you can explore nodes, edges, and state mutation. In this repo:

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
- `FLOWKIT_STUDIO_WORKFLOW_ENTRYPOINT` (usually the manifest's first step).

Override these before running `langgraph dev` if you want Studio to load a different manifest, workspace root, or entrypoint.

Use Studio whenever you need to:

- Visualize graphs defined in workflow manifests.
- Inspect node inputs/outputs and shared state models (for example `AssessmentGraphState`).
- Replay or branch from checkpoints generated by the runtime.

Studio is a **debugging and visualization tool** that attaches to the same graphs that Flow and Agent use, not a separate runtime.

---

## 8. Summary and guidance

- **Keep** native flow runtime in `.octon/capabilities/runtime/services/execution/flow/**` as the default core runtime.
- **Add new flows** by:
  - Creating a new flow directory under `packages/workflows/<flowId>/` with flow config, canonical prompt, and workflow manifest.
  - Implementing native flow behavior under Execution flow runtime contracts.
  - Optionally implementing external adapters (for example LangGraph) under adapter boundaries.
- **Create new agents** by:
  - Implementing Agent configurations to consume plans and orchestrate flows.
  - Optionally adding thin hosts under `agents/<agent-name>/<agent-behavior-name>/` when you need dedicated agent processes.
  - Always reusing Flow interfaces, not spawning per-agent runtimes.
- **Secure and observe the runner and hosts** by:
  - Treating `/flows/run` as an internal control-plane API: restrict access to trusted callers (for example, Flow, Agent hosts, CI) and validate any file paths or identifiers it receives.
  - Instrumenting native runtime and optional adapter runtimes with Observe + OpenTelemetry so flow and agent runs emit consistent traces/logs/metrics.
  - Avoiding logging sensitive content or raw secrets; rely on Guard and redaction rules at service and host boundaries.

This model keeps Plan, Flow, optional adapters, and Agent cleanly separated but tightly integrated, with native runtime as the portable baseline and external runtimes as optional interoperability layers.
