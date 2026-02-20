# Workflow Authoring Standards

These standards define how workflow authors keep orchestration runtime artifacts
consistent, safe, and maintainable.

## Scope

Applies to all workflows under `/.harmony/orchestration/runtime/workflows/`.

## Standards

1. **Use canonical workflow shape**
   - Directory workflow: `WORKFLOW.md` plus ordered step files.
   - Single-file workflow is allowed only for small procedures that do not
     require multi-file decomposition.
2. **Keep metadata contract-complete**
   - `WORKFLOW.md` must include `name` and `description`.
   - Multi-file workflows must include an ordered `steps` list whose `file`
     entries exist.
   - Step files must include `name` and `description` frontmatter.
3. **Require an explicit verification gate**
   - Every multi-file workflow must include a final verify step.
   - Workflow body must define completion criteria that are testable.
4. **Make each step idempotent**
   - Each step must document how to detect "already complete."
   - Re-running a step must not corrupt state or produce conflicting artifacts.
5. **Fail closed on ambiguous side effects**
   - If a step can create durable side effects, it must require explicit
     operator confirmation or a governing gate before execution.
   - No implicit fallback behavior is allowed for failed prerequisite checks.
6. **Keep boundary ownership correct**
   - Runtime execution logic belongs in `runtime/`.
   - Incident policy belongs in `governance/`.
   - Authoring discipline and runbook guidance belong in `practices/`.

## Author Checklist

- [ ] Workflow location and naming follow canonical conventions.
- [ ] `WORKFLOW.md` metadata is valid and complete.
- [ ] Every step has clear input, actions, output, and proceed conditions.
- [ ] Final verify step exists and enforces completion.
- [ ] Idempotency behavior is explicit for each step.
- [ ] Side-effectful steps are fail-closed and policy-gated.
