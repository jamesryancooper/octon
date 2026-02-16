# Planning

Decide *what* to do and *how* to run it.

## Native-First Portability Policy (Normative)

The Planning domain is stack-agnostic and OS-agnostic by default.
Core service behavior must run within Harmony harness constraints without requiring Python.

Policy rules:

1. `spec`, `plan`, `agent`, `playbook`, and `flow` are core Planning services and must have native harness execution paths.
2. External runtimes (including LangGraph) are optional adapter integrations.
3. Flow runtime default is native harness execution; adapter runtime usage is opt-in.
4. Core contracts must not embed provider- or runtime-specific terms.

This domain covers the path from **validated specs** to **executable flows and agents**:

- **Spec**: turn product/architecture intent into validated specs.
- **Plan**: turn specs into governed, BMAD-style plans and `plan.json`.
- **Agent**: run plans as durable, stateful agent graphs with HITL checkpoints.
- **Flow**: define and run flows over prompts/manifests via a shared runtime.
- **Playbook**: plan templates for common workflows (consumed by the Plan service).

For a detailed description of how these services, the native flow runtime, and optional external adapters fit together, see:

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
   - Runs natively inside Harmony by default.
   - May optionally call an external runtime adapter (for example LangGraph HTTP).
5. Optional external runtimes (for example LangGraph under `agents/runner/runtime/**`) can be attached via adapters:
   - Adapter integrations do not redefine core Planning contracts.
   - Adapter integrations remain optional and removable without breaking native mode.

This keeps **planning**, **agents**, **flows**, and the **runtime** cleanly separated but tightly integrated.
