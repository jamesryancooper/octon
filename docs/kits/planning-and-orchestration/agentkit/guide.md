# AgentKit

- **Purpose:** Runs PlanKit plans as durable, stateful agent graphs with human checkpoints; adds resilient, AI‑powered execution aligned to Harmony.
- **Responsibilities:** executing plan steps with retries/resume, checkpointing run state/memory, enabling human‑in‑the‑loop pauses/edits, enforcing runtime gates by delegating to Policy/Eval/Test/Compliance kits, emitting step artifacts for downstream kits.
- **Harmony alignment:** Advances resilience and interoperability via durable checkpoints and PlanKit plan/run contracts; exposes governance hooks for gated steps and human approvals.
- **Integrates with:** PlanKit (plans), FlowKit (flows), ToolKit (actions), GuardKit (sandbox/gates), PolicyKit/EvalKit/TestKit/ComplianceKit (runtime gates), ScheduleKit (triggers), PatchKit/ReleaseKit/NotifyKit (PRs/releases/handoffs), CostKit (budgets), CacheKit (memo).
- **I/O:** inputs: `plan.json` (PlanKit), `run_id`/`resume`; outputs: `checkpoints/state.sqlite` (durable state), `artifacts/**` (step outputs), run records under `runs/**`.
- **Wins:** Runs survive failures and restarts; humans can pause/steer; artifacts remain reproducible and easy to debug.
- **Runtime model:** AgentKit is built **on top of FlowKit** and uses the same shared LangGraph runtime under `agents/runner/runtime/**`. It does *not* own or spin up its own runtime; instead it calls FlowKit, which calls `/flows/run` on the shared runtime.
- **Implementation choices (opinionated in this repo):**
  - LangGraph: long‑running, stateful agent graphs with built‑in checkpointers and human interrupts.
  - SQLite (stdlib `sqlite3`): default LangGraph checkpointer for durable local state (swap to external DB in prod if needed).
  - pydantic v2: typed run state models for safe edits, validation, and serialization.
- **Common Qs:**
  - *Resume a run?* Provide `run_id` or `resume: true`; AgentKit restores from the last checkpoint.
  - *Insert a review step?* Pause at a node, edit state, then resume; approvals/alerts go through NotifyKit.
  - *Long‑term memory?* AgentKit keeps working memory; delegate corpora/indexes to CacheKit/IndexKit/QueryKit.

---

## Minimal Interfaces (copy/paste scaffolds)

### AgentKit (run a plan)

```json
{"plan_path": "plan.json", "resume": false, "memoize": true}
```

In practice:

- PlanKit produces a `plan.json` with BMAD‑style steps and acceptance criteria.
- AgentKit:
  - Loads `plan.json`.
  - Decides which FlowKit flow(s) to run for each step (and with what config).
  - Calls FlowKit’s HTTP runner for each requested flow, using the shared runtime.
  - Uses LangGraph checkpointing to persist and resume agent state across runs.
  - Emits run records and ObservaKit spans (`kit.agentkit.execute`, etc.) with links back to `plan.json` and flow executions.

For a full conceptual overview of how PlanKit, AgentKit, FlowKit, and the shared runtime fit together, see `docs/kits/planning-and-orchestration/kit-roles.md`.

## LangGraph Studio visibility

AgentKit inherits FlowKit’s LangGraph runtime, so you can inspect any assessment or plan‑execution graph inside LangGraph Studio:

1. Follow the FlowKit instructions in `docs/kits/planning-and-orchestration/flowkit/guide.md#44-visualizing-runs-in-langgraph-studio` to install the CLI and run `langgraph dev --config langgraph.json`.
2. Select the `architecture_assessment` (or other) graph registered in `langgraph.json` to open the config‑driven flow that AgentKit executes when it runs PlanKit‑generated plans via FlowKit.
3. Use the Studio UI to watch checkpoints, state transitions, and node outputs before sending actions to downstream kits.

Studio gives human approvers and runtime developers a shared debugger for every AgentKit graph without changing the FlowKit CLI workflows or the shared runtime.
