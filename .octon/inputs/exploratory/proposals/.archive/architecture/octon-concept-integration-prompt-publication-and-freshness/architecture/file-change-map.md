# File Change Map

| Target | Change type | Why it changes | Notes |
| --- | --- | --- | --- |
| `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/octon-concept-integration-pipeline/manifest.yml` | create | Define the authored prompt-set contract and invalidation policy | Authoritative additive input for the pack |
| `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/octon-concept-integration-pipeline/README.md` | update | Align README guidance to the manifest-governed prompt publication model | Explanatory only |
| `/.octon/inputs/additive/extensions/octon-concept-integration/skills/octon-concept-integration/SKILL.md` | update | Bind runtime behavior to effective prompt bundle consumption and fail-closed auto-alignment | Reusable execution contract |
| `/.octon/inputs/additive/extensions/octon-concept-integration/skills/registry.fragment.yml` | update | Expose alignment policy semantics and any new parameter or provenance expectations | Pack-local metadata |
| `/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh` | update | Publish effective prompt bundle metadata and prompt asset projections | Generated publication path |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh` | update | Fail closed on prompt bundle drift, missing receipts, or invalid alignment state | Validation gate |
| `/.octon/framework/cognition/_meta/architecture/generated/effective/extensions/README.md` | update | Document the new prompt publication surface and rules | Architecture reference |
| `/.octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/*` | create or update | Define schema contracts for prompt bundle effective outputs when needed | Generated-effective contract surface |
| `/.octon/framework/capabilities/runtime/services/modeling/prompt/**` | update if required | Reuse the native prompt service for deterministic prompt bundle compilation and hashing | Prefer reuse over custom compiler logic |
| `/.octon/state/evidence/validation/extensions/prompt-alignment/**` | create | Retain prompt-set alignment receipts and drift evidence | Retained evidence, not authority |
| `/.octon/state/evidence/runs/skills/octon-concept-integration/**` | update | Record prompt bundle provenance for each run | Retained run evidence |

## Intentionally Not In Scope

| Surface | Why excluded |
| --- | --- |
| `/.octon/framework/capabilities/packs/**` | No new governed capability-pack family is required |
| `/.octon/framework/constitution/**` | No constitutional rewrite or support-target widening is required |
| `/.octon/framework/orchestration/runtime/workflows/**` | This is a prompt publication and skill-gating hardening path, not a workflow migration |
| raw prompt source outside the pack | Superseded; prompt publication should originate from the pack-local prompt set only |
