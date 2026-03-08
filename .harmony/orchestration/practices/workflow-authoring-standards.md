# Workflow Authoring Standards

These standards define how workflow authors keep orchestration runtime artifacts
consistent, safe, and maintainable.

## Scope

Applies to all workflows under `/.harmony/orchestration/runtime/workflows/`.

## Standards

1. **Use canonical workflow naming and command contract**
   - Workflow identifier (`id`) must end with `-workflow`.
   - Audit workflow identifier must follow `audit-<objective>-workflow`.
   - Workflow directory path must be `<group>/<workflow-id>/`.
   - `WORKFLOW.md` frontmatter `name` must exactly match workflow `id`.
   - Workflow command must be exactly `/<workflow-id>` (no alias commands).
   - Triggers may use natural language, but must not include deprecated IDs or legacy command aliases.
2. **Use canonical workflow shape**
   - Directory workflow: `WORKFLOW.md` plus ordered step files.
   - Single-file workflow is allowed only for small procedures that do not
     require multi-file decomposition.
3. **Keep metadata contract-complete**
   - `WORKFLOW.md` must include `name` and `description`.
   - Multi-file workflows must include an ordered `steps` list whose `file`
     entries exist.
   - Step files must include `name` and `description` frontmatter.
   - Optional `execution_controls.cancel_safe` belongs in `runtime/workflows/registry.yml`, not in `WORKFLOW.md`.
4. **Require an explicit verification gate**
   - Every multi-file workflow must include a final verify step.
   - Workflow body must define completion criteria that are testable.
5. **Make each step idempotent**
   - Each step must document how to detect "already complete."
   - Re-running a step must not corrupt state or produce conflicting artifacts.
6. **Fail closed on ambiguous side effects**
   - If a step can create durable side effects, it must require explicit
     operator confirmation or a governing gate before execution.
   - No implicit fallback behavior is allowed for failed prerequisite checks.
7. **Keep boundary ownership correct**
   - Runtime execution logic belongs in `runtime/`.
   - Incident policy belongs in `governance/`.
   - Authoring discipline and runbook guidance belong in `practices/`.
8. **Declare cancellation safety conservatively**
   - Omitted `execution_controls.cancel_safe` is treated as `false`.
   - Set it to `true` only when partial cancellation cannot leave ambiguous side effects.

## Author Checklist

- [ ] Workflow location and naming follow canonical conventions.
- [ ] Workflow `id`, `WORKFLOW.md` `name`, runtime directory, and command are identical (`/<workflow-id>`).
- [ ] Audit workflows follow `audit-<objective>-workflow`.
- [ ] `WORKFLOW.md` metadata is valid and complete.
- [ ] Every step has clear input, actions, output, and proceed conditions.
- [ ] Final verify step exists and enforces completion.
- [ ] Idempotency behavior is explicit for each step.
- [ ] Side-effectful steps are fail-closed and policy-gated.
- [ ] `execution_controls.cancel_safe` is declared only when cancellation is safe and deterministic.
