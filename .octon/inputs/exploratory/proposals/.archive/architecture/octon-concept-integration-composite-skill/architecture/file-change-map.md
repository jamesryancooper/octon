# File Change Map

| Target | Change type | Why it changes | Notes |
| --- | --- | --- | --- |
| `/.octon/inputs/additive/extensions/octon-concept-integration/pack.yml` | create | Declare the first-party bundled pack identity, compatibility, provenance, and content entrypoints | Must use `octon-extension-pack-v3` |
| `/.octon/inputs/additive/extensions/octon-concept-integration/README.md` | create | Describe the pack purpose and operator intent | Explanatory only |
| `/.octon/inputs/additive/extensions/octon-concept-integration/skills/manifest.fragment.yml` | create | Publish the extension skill discovery record | Should advertise `octon-concept-integration` as an invocable capability |
| `/.octon/inputs/additive/extensions/octon-concept-integration/skills/registry.fragment.yml` | create | Hold command, parameter, and composition metadata for the pack-local skill | Pack-local metadata; preserve composite-skill contract |
| `/.octon/inputs/additive/extensions/octon-concept-integration/skills/octon-concept-integration/SKILL.md` | create | Define the reusable composite-skill execution contract | Owns the bounded multi-phase pipeline |
| `/.octon/inputs/additive/extensions/octon-concept-integration/skills/octon-concept-integration/references/**` | create | Keep detailed phase, I/O, and prompt-selection guidance out of the core SKILL body | Progressive disclosure |
| `/.octon/inputs/additive/extensions/octon-concept-integration/commands/manifest.fragment.yml` | create | Publish the stable command entrypoint | Preferred v1 invocation surface |
| `/.octon/inputs/additive/extensions/octon-concept-integration/commands/octon-concept-integration.md` | create | Provide the thin command wrapper that routes into the composite skill | Keeps operator invocation simple |
| `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/octon-concept-integration-pipeline/**` | create | Internalize the prompt-set assets into the pack | Removes runtime dependence on any root-level prompt-set copy |
| former root prompt-set copy | delete | Remove the superseded root prompt-set copy after the pack-local prompt assets become the live source | Historical lineage survives through proposal artifacts and retained evidence |
| `/.octon/inputs/additive/extensions/octon-concept-integration/context/octon-concept-integration-overview.md` | create | Provide pack-local context and usage notes | Supporting input only |
| `/.octon/inputs/additive/extensions/octon-concept-integration/validation/README.md` | create | Point operators at pack/publication/proposal validators | Documentation support |
| `/.octon/instance/extensions.yml` | update | Seed the new bundled pack in repo-owned desired extension state | Prefer disabled-by-default initial state |
| `/.octon/instance/bootstrap/catalog.md` | update | Make the new optional capability discoverable to operators | Documentation only |

## Intentionally Not In Scope

| Surface | Why excluded |
| --- | --- |
| `/.octon/framework/orchestration/runtime/workflows/**` | The preferred primitive is a composite skill, not a new workflow |
| `/.octon/framework/capabilities/packs/**` | Extension packs are additive content bundles, not governed capability packs |
| `/.octon/framework/constitution/**` | No constitutional or support-target widening is required for this landing |
| `/.octon/generated/**` | Generated publication is downstream evidence and projection, not a promotion target |
| former root prompt-set copy | Superseded and removed after live references were cleared |
