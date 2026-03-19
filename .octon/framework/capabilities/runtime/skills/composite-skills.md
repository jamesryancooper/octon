# Composite Skills (Canonical)

Composite Skills are a **harness-only** concept for reusable capability
bundles in the skills subsystem.

A Composite Skill orchestrates multiple skills (and optionally service calls)
behind a single skill boundary, while preserving typed I/O contracts,
validation, and safety constraints.

## Scope

- Composite Skills live in:
  - `.octon/framework/capabilities/runtime/skills/**`
- Composite Skills are:
  - Skill-level composition artifacts with SKILL.md + registry metadata.
- Composite Skills are not:
  - Runtime roots.
  - Workflow replacements.
  - Team replacements.
  - External package-layer abstractions.

## Composition Boundaries

| Primitive | Owns | Typical Shape |
|---|---|---|
| Atomic Skill | One focused capability | Single transform/check/generation operation |
| Composite Skill | Reusable capability bundle | Orchestrates multiple skills under one skill contract |
| Workflow | Ordered execution procedure | Multi-step runbook across skills/services/checkpoints |
| Team | Multi-actor topology and handoff policy | Agent/assistant collaboration contract |

## Authoring Model

Composite Skills use existing capability vocabulary (no new subsystem schema):

- `skill_sets`:
  - required: `integrator`
  - recommended: `coordinator`
  - optional: `delegator`, `guardian`, `collaborator`
- `capabilities`:
  - commonly: `composable`, `contract-driven`, `parallel`,
    `task-coordinating`, `stateful`, `resumable`, `self-validating`

## Registry Contract

In `.octon/framework/capabilities/runtime/skills/registry.yml`, a Composite Skill SHOULD:

1. Declare a stable slash command (for example `/quality-composite`).
2. Declare explicit parameters and output artifacts.
3. Declare child skill/service steps in `composition.steps` with typed refs and bindings.
4. Expose deterministic output policy in `io.outputs[].determinism`.
5. Record execution artifacts in `/.octon/state/control/skills/checkpoints/<skill-id>/<run-id>/` and
   `/.octon/state/evidence/runs/skills/<skill-id>/<run-id>.md`.

## Execution Semantics

Composite Skills should execute child capabilities in this order:

1. Validate input contract and policy preconditions.
2. Resolve child-skill execution plan.
3. Dispatch child skills/services according to `composition.mode` and declared step order.
4. Merge child outputs into the Composite Skill output contract.
5. Run post-merge validation and safety checks.
6. Persist run state + logs + final deliverables.

## Relationship to Workflows

- Use a **Composite Skill** when the composition should be reusable as a
  single invocable capability with a stable command and contract.
- Use a **Workflow** when the primary requirement is a human-readable,
  multi-step procedure with staged checkpoints.
- Workflows may invoke Composite Skills.
- Composite Skills may call child skills that are also used in workflows.

## Relationship to Teams

- Teams choose who executes work and how handoffs occur.
- Composite Skills define what bundled capability is invoked.
- A Team may standardize on one or more Composite Skills for specific phases
  (for example, verification bundles before release).

## Governance Rules

- Keep Composite Skills bounded; avoid open-ended orchestration.
- Prefer explicit `composition` contracts and explicit output contracts.
- Fail closed when child skill preconditions are unmet.
- Do not bypass skill-level or service-level policy contracts.
