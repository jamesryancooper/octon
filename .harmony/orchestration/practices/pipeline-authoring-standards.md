# Pipeline Authoring Standards

These standards govern canonical orchestration authoring under
`/.harmony/orchestration/runtime/pipelines/`.

## Scope

Applies to every canonical pipeline, scaffold, validator, and generator that
targets the pipeline runtime.

## Standards

1. `pipeline.yml` is authoritative.
   - Do not encode canonical execution semantics only in workflow prose.
2. Use the canonical layout.
   - Every pipeline lives at `<group>/<pipeline-id>/`.
   - Canonical stage assets live in `stages/`.
   - `schemas/`, `fixtures/`, and `_ops/` are optional and pipeline-local.
3. Keep the contract complete.
   - `pipeline.yml` must declare `name`, `description`, `version`,
     `entry_mode`, `execution_profile`, `inputs`, `stages`, `artifacts`,
     `done_gate`, `projection`, and `constraints`.
4. Keep stage contracts explicit.
   - Every stage must declare `id`, `asset`, `kind`, `produces`, `consumes`,
     and `mutation_scope`.
   - `mutation` stages require non-empty mutation scope.
5. Keep projections bounded.
   - Every pipeline that exposes a workflow surface must declare projection
     metadata linking to the workflow id and path.
6. Fail closed.
   - Done-gates must be explicit and testable.
   - Constraints must not rely on hidden operator inference.
7. Keep temporary material non-canonical.
   - `/.design-packages/` may inform implementation work, but it must never be
     a live dependency of canonical pipelines or validators.
8. Prefer deterministic validation.
   - If a generator or projection exists, validation must be able to detect
     drift without depending on live model execution.

## Author Checklist

- [ ] The pipeline lives under `runtime/pipelines/`.
- [ ] `pipeline.yml` contains the required contract fields.
- [ ] Every declared stage asset exists under the pipeline directory.
- [ ] Mutation stages declare explicit mutation scope.
- [ ] Projection metadata points at a valid workflow projection surface.
- [ ] Done-gates are explicit and fail closed.
- [ ] No canonical asset references `/.design-packages/`.
