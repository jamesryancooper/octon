# Workflow Authoring Standards

These standards govern canonical orchestration authoring under
`/.harmony/orchestration/runtime/workflows/`.

## Scope

Applies to every workflow unit, guide generator, validator, and meta workflow
that authors or evaluates workflows.

## Standards

1. `workflow.yml` is authoritative.
   - Do not encode canonical execution semantics only in `README.md`.
2. Use the canonical workflow unit layout.
   - `<group>/<id>/workflow.yml`
   - `<group>/<id>/stages/`
   - `<group>/<id>/README.md`
3. Keep the contract complete.
   - `workflow.yml` must declare `name`, `description`, `version`,
     `entry_mode`, `execution_profile`, `side_effect_class`,
     `execution_controls.cancel_safe`, `coordination_key_strategy`,
     `executor_interface_version`, `inputs`, `stages`, `artifacts`,
     `done_gate`, and `constraints`.
4. Keep stage contracts explicit.
   - Every stage must declare `id`, `asset`, `kind`, `produces`, `consumes`,
     and `mutation_scope`.
5. Keep recurrence out of workflows.
   - `workflow.yml` must not declare schedule cadence, event-trigger selection,
     timezone handling, or missed-run policy.
   - Recurrence and unattended launch behavior belong to `automations`.
6. Keep the README generated.
   - `README.md` is derived from `workflow.yml + stages/`.
   - README drift is a validation failure.
7. Keep temporary material non-canonical.
   - `/.design-packages/` may inform work, but must never be a live dependency
     of canonical workflows, generated READMEs, or validators.
   - Exception: workflows whose explicit purpose is to scaffold, validate, or
     harden design packages may target `/.design-packages/` directly, but that
     allowance does not extend to unrelated runtime workflows.

## Checklist

- [ ] `workflow.yml` exists and validates.
- [ ] `workflow.yml` declares side-effect class, execution controls,
      coordination strategy, and executor interface version.
- [ ] `stages/` exists and matches the declared stage assets.
- [ ] `README.md` is generated and in sync with the canonical workflow contract.
- [ ] Workflow artifacts do not carry recurrence or scheduler semantics.
- [ ] No unit retains deprecated root `WORKFLOW.md`.
- [ ] No unit depends on `runtime/pipelines/`.
