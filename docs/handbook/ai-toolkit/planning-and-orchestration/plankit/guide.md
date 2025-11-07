# PlanKit — Planning & Behavior (BMAD)

- **Purpose:** Wrap BMAD METHOD Platform behaviors as Harmony plans, normalizing plan contracts and emitting BMAD‑compatible, governed plans.
- **Responsibilities:** mapping goals/specs to BMAD behaviors, instantiating steps/dependencies from playbooks, validating contracts and policy/budget gates, emitting BMAD‑compatible `plan.json`, delegating execution to AgentKit.
- **Harmony alignment:** advances interoperability via consistent plan contracts and governed handoffs; exposes policy/budget approval hooks for auditable, safe planning.
- **Integrates with:** SpecKit (goal/spec inputs), PlaybookKit (plan templates), PromptKit (LLM prompts), PolicyKit (plan gates), ScheduleKit (triggers), CostKit (budgets), ModelKit (model selection), AgentKit (execute runs).
- **I/O:** inputs: `docs/specs/**` (SpecKit), `playbooks/**` (PlaybookKit), `policy/*.yml` (PolicyKit); outputs: BMAD‑compatible `plan.json` (steps, deps, tools, success gates).
- **Wins:** Interoperable, reviewable BMAD plans that are deterministic and ready to run.
- **Implementation Choices (opinionated):**
  - BMAD METHOD Platform API: authoritative behavior schema; normalize and emit BMAD‑compatible plans.
  - pydantic v2: typed plan/step models with strict, fail‑fast validation.
  - graphlib.TopologicalSorter: stdlib DAG ordering and cycle detection.
- **Common Qs:**
  - *LLM-only?* No—rules first; LLM assists when templating or expanding steps.
  - *Human edits?* Yes—plans are plain JSON/YAML and revalidated.
  - *Reuse?* Author templates in PlaybookKit; PlanKit instantiates per run.
  - *Harmony default?* Seed from SpecKit; require PolicyKit gates before execution.

## Minimal Interfaces (copy/paste scaffolds)

### PlanKit (make a plan)

```json
{
  "goal": "Refresh API docs and open a PR",
  "constraints": {"budget_usd": 2.50, "max_runtime_min": 20},
  "policy": ["policy/paths.yml", "policy/stack.yml"],
  "steps": [
    {"id":"ingest","tool":"ingestkit.build","inputs":{"source":"."}},
    {"id":"index","tool":"indexkit.update","inputs":{"modes":["dense","keyword","graph"]}},
    {"id":"draft","tool":"dockit.improve","inputs":{"paths":["docs/api/**"]}},
    {"id":"verify","tool":"evalkit.check","inputs":{"targets":["docs_out/**"]}},
    {"id":"pr","tool":"patchkit.open_pr","inputs":{"title":"docs: refresh API"}}
  ],
  "success": ["verify.passed == true"]
}
```