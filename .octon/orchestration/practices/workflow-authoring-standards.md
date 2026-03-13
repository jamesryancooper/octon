# Workflow Authoring Standards

These standards govern canonical orchestration authoring under
`/.octon/orchestration/runtime/workflows/`.

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
   - `/.proposals/design/` may inform work, but must never be a live dependency
     of canonical workflows, generated READMEs, or validators.
   - Exception: workflows whose explicit purpose is to scaffold, validate, or
     harden design proposals may target `/.proposals/design/` directly, but that
     allowance does not extend to unrelated runtime workflows.
8. Keep the workflow boundary honest.
   - Use a workflow when the unit needs explicit multi-stage orchestration,
     operator-visible sequencing, or coordination across multiple runtime
     surfaces.
   - Prefer a skill, command, or single narrower capability when the work is a
     thin wrapper around one focused action with no meaningful orchestration
     value.
9. Make side effects terminate in verification.
   - Workflows with `side_effect_class: mutating` or `destructive` must end in
     a terminal verification stage.
   - Read-only workflows may use a done gate without a dedicated verify stage
     when the flow remains structurally unambiguous.
10. Keep recovery and dependency shape explicit.
   - Side-effectful workflows must document failure conditions and rerun or
     recovery posture in their stage assets or generated operator guidance.
   - Workflow-to-workflow dependencies should be rare, acyclic, and justified
     by real orchestration boundaries rather than authoring convenience.
11. Keep compatibility helpers non-authoritative.
   - Legacy compatibility helpers, such as root-level `00-overview.md`, are
     exceptional companion artifacts and must not be taught as part of the
     canonical authoring layout.
   - Authoring surfaces and scaffolds must not reference `guide/` as a required
     workflow artifact.

## Checklist

- [ ] `workflow.yml` exists and validates.
- [ ] `workflow.yml` declares side-effect class, execution controls,
      coordination strategy, and executor interface version.
- [ ] `stages/` exists and matches the declared stage assets.
- [ ] `README.md` is generated and in sync with the canonical workflow contract.
- [ ] Workflow artifacts do not carry recurrence or scheduler semantics.
- [ ] No unit retains deprecated root `WORKFLOW.md`.
- [ ] No unit depends on `runtime/pipelines/`.
- [ ] Side-effectful workflows end in a terminal verification stage.
- [ ] Workflow authoring guidance keeps `workflow.yml`, `stages/`, and root
      `README.md` as the only canonical layout.
- [ ] Workflow boundaries are justified; thin wrappers are not promoted to
      workflows without orchestration value.
