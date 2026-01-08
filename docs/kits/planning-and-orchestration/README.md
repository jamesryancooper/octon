# Planning & Orchestration

Decide *what* to do and *how* to run it.

This slice of the AI‑Toolkit covers the path from **validated specs** to **executable flows and agents**:

- **SpecKit**: turn product/architecture intent into validated specs.
- **PlanKit**: turn specs into governed, BMAD‑style plans and `plan.json`.
- **AgentKit**: run plans as durable, stateful agent graphs with HITL checkpoints.
- **FlowKit**: define and run flows over prompts/manifests via a shared runtime.

For a detailed description of how these kits and the shared LangGraph runtime fit together, see:

- `./kit-roles.md` — canonical roles of PlanKit, AgentKit, FlowKit, and the LangGraph runtime.

## Kits

- [SpecKit](./speckit/guide.md)
- [PlanKit](./plankit/guide.md)
- [AgentKit](./agentkit/guide.md)
- [FlowKit](./flowkit/guide.md)

### End‑to‑end pipeline (Spec → Plan → Flows & Agents → Runtime)

At a high level:

1. **SpecKit** validates specs and constraints for a capability.
2. **PlanKit** consumes those specs and emits:
   - A canonical `plan.json` describing BMAD‑style steps and dependencies.
   - ADR/checklist updates for governance.
3. **AgentKit** loads `plan.json` and:
   - Decides which FlowKit flow(s) to run for each step.
   - Manages retries/resume, long‑term run identity, and HITL checkpoints.
4. **FlowKit**:
   - Defines `FlowConfig`/`FlowRunner`/`FlowRunResult`.
   - Calls the shared LangGraph runtime’s `/flows/run` endpoint for each configured flow.
5. The **LangGraph runtime** under `agents/runner/runtime/**`:
   - Builds and executes LangGraph graphs for each flow based on prompts and workflow manifests.
   - Exposes Studio entrypoints via `langgraph.json` so you can debug the same graphs AgentKit and FlowKit use.

This keeps **planning**, **agents**, **flows**, and the **runtime** cleanly separated but tightly integrated.
