# Source Artifact

## Primary source of truth

This packet treats the live Octon repository as the primary source of truth. The most important repo-grounding surfaces used for this packet are:

- `/.octon/framework/cognition/_meta/architecture/specification.md`
- `/.octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-request-v3.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- `/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-receipt-v3.schema.json`
- `/.octon/framework/engine/runtime/spec/runtime-event-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/authorized-effect-token-v1.md`
- `/.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md`
- `/.octon/framework/engine/runtime/README.md`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/framework/overlay-points/registry.yml`
- `/.octon/instance/manifest.yml`
- `/.octon/instance/ingress/manifest.yml`
- `/.octon/instance/charter/workspace.md`
- `/.octon/instance/charter/workspace.yml`
- proposal workspace rules under `/.octon/inputs/exploratory/proposals/**`

## External research used to sharpen implementation shape

These are supporting design references, not authoritative Octon sources:

- OpenAI, **Harness Engineering** — rationale for progressive disclosure and avoiding giant static context.
- Anthropic, **Effective Context Engineering for AI Agents** — framing context as all tokens made available to the model and the need for disciplined context assembly.
- Anthropic, **Advanced Tool Use** — evidence that large tool schemas consume context and should be loaded progressively.
- AGENTS.md effectiveness study — evidence that broad static context files can reduce task success and raise cost.

## Repository-first rule

Where repo reality and external advice differ, this packet follows the repo’s constitutional authority, support-target posture, and class-root discipline.
