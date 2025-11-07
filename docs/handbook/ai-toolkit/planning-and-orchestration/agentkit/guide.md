# AgentKit

- **Purpose:** Runs BMAD plans as durable, stateful agent graphs with human checkpoints; adds resilient, AI-powered execution aligned to Harmony.
- **Responsibilities:** executing plan steps with retries/resume, checkpointing run state/memory, enabling human-in-the-loop pauses/edits, enforcing runtime gates by delegating to Policy/Eval/Test/Compliance kits, emitting step artifacts for downstream kits.
- **Harmony alignment:** Advances Resilience and Interoperability via durable checkpoints and BMAD plan/run contracts; exposes Governance hooks for gated steps and human approvals.
- **Integrates with:** PlanKit (plans), ToolKit (actions), GuardKit (sandbox/gates), PolicyKit/EvalKit/TestKit/ComplianceKit (runtime gates), ScheduleKit (triggers), PatchKit/ReleaseKit/NotifyKit (PRs/releases/handoffs), CostKit (budgets), CacheKit (memo).
- **I/O:** inputs: `plan.json` (PlanKit), `run_id`/`resume`; outputs: `checkpoints/state.sqlite` (durable state), `artifacts/**` (step outputs).
- **Wins:** Runs survive failures and restarts; humans can pause/steer; artifacts remain reproducible and easy to debug.
- **Implementation Choices (opinionated):**
  - LangGraph: long-running, stateful agent graphs with built-in checkpointers and human interrupts.
  - SQLite (stdlib `sqlite3`): default LangGraph checkpointer for durable local state (swap to external DB in prod if needed).
  - pydantic v2: typed run state models for safe edits, validation, and serialization.
- **Common Qs:**
  - *Resume a run?* Provide `run_id` or `resume: true`; AgentKit restores from the last checkpoint.
  - *Insert a review step?* Pause at a node, edit state, then resume; approvals/alerts go through NotifyKit.
  - *Long-term memory?* AgentKit keeps working memory; delegate corpora/indexes to CacheKit/IndexKit/QueryKit.

---

## Minimal Interfaces (copy/paste scaffolds)

### AgentKit (run a plan)

```json
{"plan_path": "plan.json", "resume": false, "memoize": true}
```
