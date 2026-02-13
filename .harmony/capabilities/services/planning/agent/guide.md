# Agent

- **Purpose:** Runs Plan plans as durable, stateful agent graphs with human checkpoints; adds resilient, AI‑powered execution aligned to Harmony.
- **Responsibilities:** executing plan steps with retries/resume, checkpointing run state/memory, enabling human‑in‑the‑loop pauses/edits, enforcing runtime gates by delegating to Policy/Eval/Test/Compliance services, emitting step artifacts for downstream services.
- **Harmony alignment:** Advances resilience and interoperability via durable checkpoints and Plan plan/run contracts; exposes governance hooks for gated steps and human approvals.
- **Integrates with:** Plan (plans), Flow (flows), Tool (actions), Guard (sandbox/gates), Policy/Eval/Test/Compliance (runtime gates), Schedule (triggers), Patch/Release/Notify (PRs/releases/handoffs), Cost (budgets), Cache (memo).
- **I/O:** inputs: `plan.json` (Plan), `run_id`/`resume`; outputs: `checkpoints/state.sqlite` (durable state), `artifacts/**` (step outputs), run records under `runs/**`.
- **Wins:** Runs survive failures and restarts; humans can pause/steer; artifacts remain reproducible and easy to debug.
- **Runtime model:** Agent is built **on top of Flow** and uses the same shared LangGraph runtime under `agents/runner/runtime/**`. It does *not* own or spin up its own runtime; instead it calls Flow, which calls `/flows/run` on the shared runtime.
- **Implementation choices (opinionated in this repo):**
  - LangGraph: long‑running, stateful agent graphs with built‑in checkpointers and human interrupts.
  - SQLite (stdlib `sqlite3`): default LangGraph checkpointer for durable local state (swap to external DB in prod if needed).
  - pydantic v2: typed run state models for safe edits, validation, and serialization.
- **Common Qs:**
  - *Resume a run?* Provide `run_id` or `resume: true`; Agent restores from the last checkpoint.
  - *Insert a review step?* Pause at a node, edit state, then resume; approvals/alerts go through Notify.
  - *Long‑term memory?* Agent keeps working memory; delegate corpora/indexes to Cache/Index/Query.

---

## Minimal Interfaces (copy/paste scaffolds)

### Agent (run a plan)

```json
{"plan_path": "plan.json", "resume": false, "memoize": true}
```

In practice:

- Plan produces a `plan.json` with BMAD‑style steps and acceptance criteria.
- Agent:
  - Loads `plan.json`.
  - Decides which Flow flow(s) to run for each step (and with what config).
  - Calls Flow's HTTP runner for each requested flow, using the shared runtime.
  - Uses LangGraph checkpointing to persist and resume agent state across runs.
  - Emits run records and Observe spans (`kit.agentkit.execute`, etc.) with links back to `plan.json` and flow executions.

For a full conceptual overview of how Plan, Agent, Flow, and the shared runtime fit together, see `.harmony/capabilities/services/planning/service-roles.md`.

## LangGraph Studio visibility

Agent inherits Flow's LangGraph runtime, so you can inspect any assessment or plan‑execution graph inside LangGraph Studio:

1. Follow the Flow instructions in `.harmony/capabilities/services/planning/flow/guide.md#44-visualizing-runs-in-langgraph-studio` to install the CLI and run `langgraph dev --config langgraph.json`.
2. Select the `architecture_assessment` (or other) graph registered in `langgraph.json` to open the config‑driven flow that Agent executes when it runs Plan‑generated plans via Flow.
3. Use the Studio UI to watch checkpoints, state transitions, and node outputs before sending actions to downstream services.

Studio gives human approvers and runtime developers a shared debugger for every Agent graph without changing the Flow CLI workflows or the shared runtime.
