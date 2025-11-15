# FlowKit — LangGraph Flows for Harmony

- **Purpose:** Provide a standard way to implement long‑running, multi‑step AI workflows (flows) as explicit LangGraph graphs wired to Harmony prompts, kits, and documents.
- **Responsibilities:** model workflow state, orchestrate prompt/action execution, enforce ordering and stop conditions, surface telemetry, and coordinate hand‑offs to other kits (PlanKit, AgentKit, PromptKit, PolicyKit, ObservaKit, etc.).
- **Harmony alignment:** turns Harmony’s architecture/methodology guidance into executable flows; ensures workflows remain deterministic, inspectable, and easy to validate against the architecture and methodology docs.
- **Integrates with:** PlanKit (plans → flows), SpecKit (specs → flow inputs), AgentKit (task/tool execution), PromptKit (prompt assets), PolicyKit/GuardKit (gates), ObservaKit (traces/metrics/logs), TestKit/EvalKit (validation flows), Cursor custom commands (`run` tool) for local developer workflows.
- **I/O:** inputs: canonical prompts (`packages/prompts/**`), workflow manifests (`*.yaml`), Harmony docs (for context); outputs: structured run state, reports (for example, alignment reports), and orchestrated edits applied by downstream kits/agents.
- **Wins:** repeatable, auditable workflows that directly reflect Harmony docs and AI‑Toolkit kits, with clear state and minimal hidden magic.
- **Implementation choices (opinionated):**
  - Python + [LangGraph](https://docs.langchain.com/oss/python/langgraph/overview) for graph orchestration and state handling.
  - Typed state models (pydantic or dataclasses) per flow for clarity and validation.
  - YAML workflow manifests + prompt frontmatter as configuration, not code.
  - Cursor custom commands + `run` tool for low‑friction local execution.

---

## 1. Core Concepts

FlowKit sits in **Planning & Orchestration** alongside SpecKit and PlanKit. It focuses on the *execution* of multi‑step work once a plan or canonical prompt exists.

### 1.1 Flow

A **flow** is a named LangGraph graph that models a multi‑step workflow:

- Has a clear **entrypoint** and **stop conditions**.
- Operates over a shared **state object**.
- Calls Harmony prompts and AI‑Toolkit kits as needed.

Examples:

- `ArchitectureAssessmentFlow` — implements the architecture assessment pipeline (inventory → analyze → map → detect_issues → align → edit → validate → summarize → declare_no_update).
- `SpecToPlanFlow` — chains SpecKit + PlanKit + AgentKit to go from spec → plan → executable run.

### 1.2 Node (Action)

Each **node** represents a single actionable step in the flow:

- For architecture assessment, nodes map 1:1 to action prompts:
  - `inventory`, `analyze`, `map`, `detect_issues`, `align`, `edit`, `validate`, `summarize`, `declare_no_update`.
- A node:
  - Reads its action prompt (for example, `assessment/architecture/actions/inventory.md`).
  - Uses LangGraph + an LLM to execute the step.
  - Mutates the shared state (for example, fills `state.inventory` or appends to `state.issue_register`).

### 1.3 State

FlowKit uses a **typed state object** per flow. For the architecture assessment, this might include:

- `workspace_root` and paths (for example, `docs/harmony/architecture`).
- `inventory` (files, headings, terms, roles, invariants, links).
- `terminology_map` and `decision_map`.
- `issue_register`.
- `alignment_plan`.
- `edits_applied`.
- `validation_summary`.
- `alignment_report`.

The state flows through nodes; LangGraph takes care of passing and updating it.

### 1.4 Workflow Manifest

Each flow can be described by a **YAML manifest** (for example, `packages/prompts/assessment/architecture/workflows/architecture-assessment.yaml`) that defines:

- `suite` and `description`.
- `canonical_prompt_path` — points back to the canonical Markdown prompt.
- `steps`:
  - `id`, `name`.
  - `prompt_path` — which action prompt to load.
  - `meta.type`, `meta.mode`, `meta.action`, `meta.subject`, `meta.step_index`.
  - Optional `depends_on` for explicit dependencies.

FlowKit uses this manifest to build the LangGraph graph wiring.

### 1.5 Canonical Prompt

Each flow has a **canonical prompt** that acts as the human‑readable spec and entrypoint, for example:

- `packages/prompts/assessment/architecture/architecture-assessment.md`
  - Contains: role, mission, scope, objectives, process, focus areas, expected output, quality rubric, constraints, stop instruction.
  - Includes `meta.workflow.path` pointing to the YAML manifest and an `entrypoint`.

FlowKit does **not** re‑spec the workflow; it executes what the canonical prompt and manifest encode.

---

## 2. Architecture & Design Decisions

### 2.1 Placement in Harmony

- **Docs:** FlowKit lives under `docs/harmony/ai-toolkit/planning-and-orchestration/flowkit/guide.md`.
- **Purpose:** it is the orchestration layer that makes Harmony’s architecture/methodology/AI‑Toolkit guidance executable.
- **Dependencies:**
  - Harmony Architecture (`docs/harmony/architecture`) — defines the target system and constraints.
  - Harmony Methodology (`docs/harmony/methodology`) — defines how work should flow (Spec‑First, Agentic Agile/BMAD, etc.).
  - Harmony AI‑Toolkit (`docs/harmony/ai-toolkit`) — provides the kits FlowKit calls during execution.

### 2.2 FlowKit vs PlanKit vs AgentKit

- **PlanKit**: decides *what* should happen and produces BMAD‑style plans (`plan.json`).
- **FlowKit**: turns a plan or canonical prompt into a **LangGraph graph** and orchestrates the execution over time.
- **AgentKit**: executes individual steps (tools/actions) within a flow.

One typical pipeline:

1. SpecKit + Methodology produce/validate a spec.
2. PlanKit turns spec + constraints into a plan.
3. FlowKit instantiates a LangGraph flow from that plan (or a canonical prompt + YAML).
4. AgentKit executes tools/actions invoked from nodes in the flow.

### 2.3 Why LangGraph

FlowKit uses LangGraph because:

- **Graph‑native:** workflows are DAGs or small graphs, not just linear scripts.
- **Stateful:** each node updates a shared state object, making flows inspectable and debuggable.
- **LLM‑centric:** designed for LLM agents and tools, matching Harmony’s AI‑Toolkit focus.
- **Deterministic control:** you explicitly define nodes and edges; there is no “magic” orchestration.

### 2.4 Why YAML + Frontmatter

Instead of hard‑coding flows, FlowKit uses:

- **Markdown frontmatter** on canonical prompts:
  - `meta.type`, `meta.mode`, `meta.subject`, `meta.subtype`, `meta.workflow.path`.
- **YAML workflow manifests**:
  - Define steps, ordering, prompt paths, and meta tags.

Benefits:

- Developers can evolve workflows by editing Markdown/YAML, keeping behavior close to prompts.
- Tools (including Cursor and AI agents) can introspect flows without reading Python internals.

### 2.5 Determinism, Safety, and Alignment

FlowKit is designed to:

- Preserve Harmony’s emphasis on **determinism and safety**:
  - Minimal hidden state; everything lives in the flow state object.
  - Explicit stop conditions (for example, `declare_no_update`).
  - Strong constraints from Architecture/Methodology docs.
- Keep flows **aligned with AI‑Toolkit and architecture**:
  - Flows for architecture align with `docs/harmony/architecture` scope and constraints.
  - Flows for planning/orchestration respect Methodology/PlanKit guidance.

---

## 3. Implementation Outline

FlowKit’s implementation is intentionally minimal and composable.

### 3.1 Directory Layout (example)

In code (Python side), a typical layout might look like:

```text
flows/
  __init__.py
  architecture_assessment/
    state.py          # State model for ArchitectureAssessmentFlow
    graph.py          # LangGraph graph construction
    run.py            # Public entrypoint
  ...
```

On the prompts side, FlowKit expects:

- Canonical prompt:
  - `packages/prompts/assessment/architecture/architecture-assessment.md`
- Action prompts:
  - `packages/prompts/assessment/architecture/actions/*.md`
- Workflow manifest:
  - `packages/prompts/assessment/architecture/workflows/architecture-assessment.yaml`

### 3.2 Graph Construction (conceptual)

At a high level, graph construction for the architecture assessment flow:

1. Read the canonical prompt; get `meta.workflow.path`.
2. Load the YAML workflow manifest (steps, prompt paths, meta).
3. Create a state object with initial fields (paths, empty maps, empty issue register, etc.).
4. For each step:
   - Create a LangGraph node that:
     - Loads the action prompt Markdown.
     - Calls the model/tooling as defined by the FlowKit runtime.
     - Updates the state.
5. Wire nodes in order using `depends_on` / `meta.step_index`.
6. Set stop conditions (for example, after `declare_no_update`).

### 3.3 State Models

State models should:

- Be explicit and typed (pydantic or dataclasses).
- Mirror the concepts in the canonical prompt:
  - Inventory, terminology map, decision map, issue register, alignment plan, edits, validation summary, alignment report.
- Include metadata:
  - `run_id`, `flow_name`, `kit_name`, timestamps, etc., for ObservaKit.

---

## 4. Usage Patterns

### 4.1 Running Flows from the CLI

FlowKit should expose a small CLI (or Python module entrypoint), for example:

```bash
python -m flows.architecture_assessment.run \
  packages/prompts/assessment/architecture/architecture-assessment.md
```

The runner:

- Reads the canonical prompt and workflow manifest.
- Builds the LangGraph graph.
- Executes nodes in order, updating state.
- Emits a final alignment report and/or no‑update declaration.

### 4.2 Running Flows via Cursor Custom Commands

With Cursor’s custom commands and `run` tool:

- Define a `/run-architecture` command that:
  - Uses the `run` tool to call the FlowKit CLI (as above) inside the repo.
- Optionally define a generic `/run-flow` command that:
  - Parses the file link from chat (for example, `[architecture-assessment.md](packages/prompts/assessment/architecture/architecture-assessment.md)`).
  - Passes that path into the FlowKit CLI.

This keeps developer ergonomics high while leveraging FlowKit’s orchestration.

### 4.3 Defining New Flows

To add a new Harmony‑aligned flow:

1. **Write a canonical prompt**
   - Under `packages/prompts/**`, describing role, mission, scope, process, outputs, constraints, and stop instruction.
   - Include `meta.workflow.path` in frontmatter.
2. **Create action prompts**
   - Under a scoped `actions/` directory (for example, `assessment/<subject>/actions/*.md`).
   - One prompt per action/node; wire them with `meta.type`, `meta.mode`, `meta.action`, `meta.subject`, `meta.step_index`.
3. **Add a workflow manifest**
   - YAML under `workflows/` referencing each action prompt via `prompt_path`.
   - Include `canonical_prompt_path` and `steps` with `id`, `name`, `depends_on`, and `meta`.
4. **Implement the FlowKit graph**
   - Add a state model and graph builder around these prompts.
5. **Register a Cursor command (optional)**
   - Add a project‑local command that calls the FlowKit runner for your new flow.

---

## 5. When to Use FlowKit

Use FlowKit when:

- A workflow spans multiple steps/actions and needs shared state.
- You want an auditable, replayable history of agent work.
- The workflow encodes Harmony architecture/methodology guidance and must remain aligned with those docs.
- You need to coordinate multiple kits (PlanKit, AgentKit, PromptKit, PolicyKit, ObservaKit, etc.) in a single run.

If a task is:

- Single‑shot, stateless, or trivial → use a direct kit call (for example, AgentKit or PromptKit) without a flow.
- Multi‑step, cross‑kit, or long‑running → model it as a FlowKit flow.

FlowKit’s job is to make those flows explicit, reliable, and easy to run from both automation and local tools like Cursor.
