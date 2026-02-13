# Planning

Decide *what* to do and *how* to run it.

This domain covers the path from **validated specs** to **executable flows and agents**:

- **Spec**: turn product/architecture intent into validated specs.
- **Plan**: turn specs into governed, BMAD-style plans and `plan.json`.
- **Agent**: run plans as durable, stateful agent graphs with HITL checkpoints.
- **Flow**: define and run flows over prompts/manifests via a shared runtime.
- **Playbook**: plan templates for common workflows (consumed by the Plan service).

For a detailed description of how these services and the shared LangGraph runtime fit together, see:

- `./service-roles.md` — canonical roles of Plan, Agent, Flow, and the LangGraph runtime.

## Services

- [Spec](./spec/guide.md)
- [Plan](./plan/guide.md)
- [Agent](./agent/guide.md)
- [Flow](./flow/guide.md)
- [Playbook](./playbook/guide.md)

### End-to-end pipeline (Spec → Plan → Flows & Agents → Runtime)

At a high level:

1. **Spec** validates specs and constraints for a capability.
2. **Plan** consumes those specs and emits:
   - A canonical `plan.json` describing BMAD-style steps and dependencies.
   - ADR/checklist updates for governance.
3. **Agent** loads `plan.json` and:
   - Decides which Flow flow(s) to run for each step.
   - Manages retries/resume, long-term run identity, and HITL checkpoints.
4. **Flow**:
   - Defines `FlowConfig`/`FlowRunner`/`FlowRunResult`.
   - Calls the shared LangGraph runtime's `/flows/run` endpoint for each configured flow.
5. The **LangGraph runtime** under `agents/runner/runtime/**`:
   - Builds and executes LangGraph graphs for each flow based on prompts and workflow manifests.
   - Exposes Studio entrypoints via `langgraph.json` so you can debug the same graphs Agent and Flow use.

This keeps **planning**, **agents**, **flows**, and the **runtime** cleanly separated but tightly integrated.
