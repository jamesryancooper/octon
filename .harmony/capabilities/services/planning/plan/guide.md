# Plan — Planning & Behavior (BMAD)

- **Purpose:** Wrap BMAD METHOD Platform behaviors as Harmony plans, normalizing plan contracts and emitting BMAD‑compatible, governed plans.
- **Responsibilities:** mapping goals/specs to BMAD behaviors, instantiating steps/dependencies from playbooks, validating contracts and policy/budget gates, emitting BMAD‑compatible `plan.json`, and handing that plan off to execution services (Flow and Agent).
- **Harmony alignment:** advances interoperability via consistent plan contracts and governed handoffs; exposes policy/budget approval hooks for auditable, safe planning.
- **Integrates with:** Spec (goal/spec inputs), Playbook (plan templates), Prompt (LLM prompts), Policy (plan gates), Schedule (triggers), Cost (budgets), Model (model selection), Flow/Agent (execution of plans and flows).
- **I/O:** inputs: `docs/specs/**` (Spec), `playbooks/**` (Playbook), `policy/*.yml` (Policy); outputs: BMAD‑compatible `plan.json` (steps, deps, tools, success gates) and ADR/checklist updates that downstream services can consume.
- **Wins:** Interoperable, reviewable BMAD plans that are deterministic and ready to run, but **Plan itself never runs flows or agents**—it stays planning‑only.
- **Execution model:** Plan sits **between** Spec and Flow/Agent. It:
  - Consumes validated specs and constraints from Spec and methodology docs.
  - Produces a canonical `plan.json` that:
    - Flow can map deterministically to flows and `FlowConfig` objects.
    - Agent can use as its source of truth for long‑running, plan‑driven agents.
  - Does **not** own or call the LangGraph runtime directly; that is Flow's responsibility.
- **Implementation Choices (opinionated):**
  - BMAD METHOD Platform API: authoritative behavior schema; normalize and emit BMAD‑compatible plans.
  - pydantic v2: typed plan/step models with strict, fail‑fast validation.
  - graphlib.TopologicalSorter: stdlib DAG ordering and cycle detection.
- **Common Qs:**
  - *LLM‑only?* No—rules first; LLM assists when templating or expanding steps.
  - *Human edits?* Yes—plans are plain JSON/YAML and revalidated.
  - *Reuse?* Author templates in Playbook; Plan instantiates per run.
  - *Harmony default?* Seed from Spec; require Policy gates before execution.

## Minimal Interfaces (copy/paste scaffolds)

### Plan (make a plan)

```json
{
  "goal": "Refresh API docs and open a PR",
  "constraints": { "budget_usd": 2.5, "max_runtime_min": 20 },
  "policy": ["policy/paths.yml", "policy/stack.yml"],
  "steps": [
    { "id": "ingest", "tool": "ingestkit.build", "inputs": { "source": "." } },
    {
      "id": "index",
      "tool": "indexkit.update",
      "inputs": { "modes": ["dense", "keyword", "graph"] }
    },
    {
      "id": "draft",
      "tool": "dockit.improve",
      "inputs": { "paths": ["docs/api/**"] }
    },
    {
      "id": "verify",
      "tool": "evalkit.check",
      "inputs": { "targets": ["docs_out/**"] }
    },
    {
      "id": "pr",
      "tool": "patchkit.open_pr",
      "inputs": { "title": "docs: refresh API" }
    }
  ],
  "success": ["verify.passed == true"]
}
```

Downstream usage:

- Flow and Agent treat `plan.json` as a **plan contract**, not an imperative script.
- Flow may map steps to concrete flows (`FlowConfig`) where a flow is the right abstraction.
- Agent uses the same `plan.json` to drive long‑running, plan‑driven agents that:
  - Decide which Flow flows to run for which steps.
  - Handle retries/resume and HITL checkpoints.

For a complete picture of how Plan, Flow, Agent, and the shared LangGraph runtime fit together, see `.harmony/capabilities/services/planning/service-roles.md`.
