# Workflow Projection Standards

These standards define how Harmony keeps workflow projections aligned to their
canonical backing pipelines.

## Scope

Applies to all workflow surfaces under
`/.harmony/orchestration/runtime/workflows/`.

## Standards

1. Workflows are projections, not the source of truth.
   - Do not author new canonical execution behavior directly in `WORKFLOW.md`
     or numbered step files.
2. Every workflow must have a backing pipeline.
   - Registry metadata must declare `projection.pipeline_id`,
     `projection.pipeline_path`, `projection.generated`, and
     `projection.projection_format`.
3. Generated projections must be deterministic.
   - Validators must be able to detect drift against the source pipeline.
4. Preserve identity stability.
   - Existing workflow ids and slash-facing names remain stable unless a human
     explicitly authorizes a rename.
5. Keep local wrapper assets bounded.
   - Workflow-local `prompts/`, `references/`, or `_ops/` are allowed only as
     wrapper-local aids around a canonical pipeline.
   - Those assets must be referenced relatively and must not depend on
     `/.design-packages/`.
6. Keep projections reviewable.
   - `WORKFLOW.md` should clearly state that it is generated from or backed by a
     canonical pipeline.
7. Manual workflow authoring is deprecated.
   - New authoring starts from the pipeline scaffold, not the workflow scaffold.

## Projection Checklist

- [ ] Workflow registry entry includes projection metadata.
- [ ] Backing pipeline exists and validates.
- [ ] The projection shape matches the declared format.
- [ ] Generated projections contain canonical-pipeline references.
- [ ] No live projection asset references temporary design-package content.
