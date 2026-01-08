# Agent Layer Guide — Policies, Guardrails, Budgets, Evaluation

**Harmony-aligned.** Agents provide judgment; kits provide deterministic capabilities. The Agent layer is a thin, swappable policy that sequences kit calls, enforces budgets, and emits concise decision telemetry (no raw chain-of-thought).

---

## 1) Role & scope

- **What agents do:** use PlanKit plans and the Knowledge Plane to plan, choose tools (kits), trade off cost/time/quality, and summarize decisions.
- **What agents don’t do:** own long-lived state outside of AgentKit’s durable graphs, bypass contracts, or stream large payloads.
- **Where to use:** planning/research, retrieval routing, result triage—only where ROI is clear.

---

## 2) Architecture

```text
Spec/Plan → PlanKit (plan.json) → AgentKit(policy, budget)
  → [validate inputs] → choose FlowKit flow(s) → FlowKit HTTP → LangGraph runtime (/flows/run)
  → [validate outputs + gates] → next step
                         ↘ events/artifacts ↙
```

- **Agent shells:** wrap steps that need reasoning; everything else is direct kit calls/flows.
- **No hidden state:** persist context via artifacts and AgentKit checkpoints; include `run_id` in every call.

For canonical responsibilities and runtime boundaries, see also `docs/kits/planning-and-orchestration/kit-roles.md`.

---

## 3) Guardrails (the agent sandwich)

### 3.1 Pre-validators

- Schema validation of params against JSON Schema.
- Static safety checks (allowlist/denylist of operations & URIs).
- Budget check before execution (`seconds_max`, `calls_max`).

### 3.2 Post-validators

- Output schema validation; invariants (e.g., `docs_processed >= 0`).
- Sanity checks (e.g., result set size bounds; dedupe).
- Attach provenance (tool version, parameters) to artifacts.

### 3.3 Idempotency & retries

- Require `idempotency_key` on mutating kit calls.
- Retry only `Transient` errors with bounded jittered backoff.

---

## 4) Budgets & deadlines

- **Per-run budget:** `{seconds_max, calls_max, tokens_max?}` enforced by AgentKit.
- **Per-call deadline:** pass `deadline_ms` or `budget.seconds_max` to kits; kits must honor.
- **Circuit breaker:** abort run if burn-rate exceeds thresholds (e.g., >50% budget in <20% time).

**Budget example:**

```json
{"calls_max": 30, "seconds_max": 300, "spent": {"calls": 7, "seconds": 92}}
```

---

## 5) Decision telemetry (concise, observable)

Emit a compact record for every agentized step.

```json
{
  "run_id": "r_123",
  "goal": "refresh RAG index for docs_main",
  "capabilities_used": ["SearchKit.web", "IngestKit.load", "IndexKit.build"],
  "decision_summary": "2 crawls stale; re-ingest 18 docs; rebuild IVF-Flat",
  "actions": [
    {"call": "SearchKit.web", "args_ref": "runs/r_123/inputs/search.json"},
    {"call": "IngestKit.load", "args_ref": "..."},
    {"call": "IndexKit.build", "args_ref": "..."}
  ],
  "budget": {"calls_max": 30, "seconds_max": 300, "spent": {"calls": 7, "seconds": 92}},
  "trace_id": "..."
}
```

---

## 6) Evaluation (fit-for-purpose, not vibe checks)

### 6.1 Offline eval

- **Golden tasks:** curated inputs with expected outputs/metrics.
- **Metrics:** task success %, latency, cost, hallucination rate, retrieval precision/recall.
- **Repro:** pin model/tool versions, seeds, and corpora hashes.

### 6.2 Online checks

- **Canaries:** small % of traffic to new policy; compare SLOs & task success.
- **Shadow runs:** execute new policy in parallel; log-only.
- **Interventions:** require approval for destructive ops (PatchKit deploys, data writes).

### 6.3 Reporting

- EvalKit produces a report artifact; emit `eval.report.available` with URI.

---

## 7) Policies & composition

- **Strategy patterns:**

  - Planner → Executor → Reviewer (PER)
  - Router: choose one of N kit configurations (e.g., rerankers)
  - Retriever ensemble: run multiple retrievers; merge/deduplicate
- **Stop conditions:** max steps, no gain, time budget used.

---

## 8) Safety & ethics guardrails

- **Content safety gates** aligned with product policy (configurable per domain).
- **PII handling:** mask/redact before logging; restrict persistence.
- **Transparency:** user-facing summaries avoid chain-of-thought; provide sources and artifacts.

---

## 9) Playbooks

- **Agentize a step:** define success & budget → add pre/post validators → emit telemetry → A/B test → keep or revert.
- **Rollback:** feature flag the policy; instant revert path.
- **Incident handling:** raise severity if SLO burn-rate > threshold; freeze risky tools via denylist.

---

## 10) Interfaces

- **AgentKit API (sketch):** `run(goal, policy, budget, context_artifacts[]) → result_artifact_uri`
- **Policy plug-in:** `decide(state) → {actions[], stop?}` with deterministic validators around it.
