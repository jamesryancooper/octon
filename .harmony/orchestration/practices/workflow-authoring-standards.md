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
     `entry_mode`, `execution_profile`, `inputs`, `stages`, `artifacts`,
     `done_gate`, and `constraints`.
4. Keep stage contracts explicit.
   - Every stage must declare `id`, `asset`, `kind`, `produces`, `consumes`,
     and `mutation_scope`.
5. Keep the README generated.
   - `README.md` is derived from `workflow.yml + stages/`.
   - README drift is a validation failure.
6. Keep temporary material non-canonical.
   - `/.design-packages/` may inform work, but must never be a live dependency
     of canonical workflows, generated READMEs, or validators.
   - Exception: workflows whose explicit purpose is to scaffold, validate, or
     harden design packages may target `/.design-packages/` directly, but that
     allowance does not extend to unrelated runtime workflows.

## Checklist

- [ ] `workflow.yml` exists and validates.
- [ ] `stages/` exists and matches the declared stage assets.
- [ ] `README.md` is generated and in sync with the canonical workflow contract.
- [ ] No unit retains deprecated root `WORKFLOW.md`.
- [ ] No unit depends on `runtime/pipelines/`.
