# Planning

Decide *what* to do.

## Native-First Portability Policy (Normative)

The Planning domain is stack-agnostic and OS-agnostic by default.
Core service behavior must run within Harmony harness constraints without requiring Python.

Policy rules:

1. `spec`, `plan`, and `playbook` are core Planning services and must have native harness execution paths.
2. Planning outputs (especially `plan.json`) are portable inputs for downstream execution services.
3. Core Planning contracts must not embed provider- or runtime-specific terms.
4. Python is never a required runtime dependency in Planning core paths.

This domain covers the path from **validated specs** to a governed **canonical plan**:

- **Spec**: turn product/architecture intent into validated specs.
- **Playbook**: plan templates for common workflows (consumed by the Plan service).
- **Plan**: turn specs and playbooks into governed BMAD-style plans and `plan.json`.

Execution responsibilities are defined in:

- `../execution/README.md`
- `../execution/service-roles.md`

## Services

- [Spec](./spec/guide.md)
- [Plan](./plan/guide.md)
- [Playbook](./playbook/guide.md)
- [Critic](./critic/guide.md)
- [Replan](./replan/guide.md)
- [Scheduler](./scheduler/guide.md)
- [Capability Bind](./capability-bind/guide.md)
- [Contingency](./contingency/guide.md)

### End-to-end pipeline (Spec → Plan → Execution)

At a high level:

1. **Spec** validates specs and constraints for a capability.
2. **Playbook** expands reusable planning templates into plan-ready structures.
3. **Plan** consumes validated specs/playbooks and emits:
   - A canonical `plan.json` describing BMAD-style steps and dependencies.
   - ADR/checklist updates for governance.
4. **Execution domain services** consume `plan.json`:
   - **Agent** orchestrates plan execution, retries/resume, and ACP gates.
   - **Flow** executes flow manifests through native runtime by default, with optional adapter forwarding.

This keeps **planning** (intent and sequencing) cleanly separated from **execution** (runtime and durable run control).
