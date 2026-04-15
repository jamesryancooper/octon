# Target Architecture

## Goal

Promote the current concept-integration prompt set into a reusable Octon
capability by packaging it as a first-party bundled extension pack whose core
execution unit is a composite skill and whose operator-visible entrypoint is a
thin published command wrapper.

The landing must preserve Octon's existing class-root, publication, and
non-authority rules:

- raw reusable assets live under `inputs/additive/extensions/**`
- repo-owned activation remains in `instance/extensions.yml`
- runtime-facing extension consumption remains generated under
  `generated/effective/extensions/**`
- capability discovery and host projection remain generated under
  `generated/effective/capabilities/**`
- proposal packets produced by the capability remain temporary and
  non-canonical under `inputs/exploratory/proposals/**`

## Proposed Durable Surface

Add a first-party bundled extension pack at:

`/.octon/inputs/additive/extensions/octon-concept-integration/`

With this pack-local layout:

```text
pack.yml
README.md
skills/
  manifest.fragment.yml
  registry.fragment.yml
  octon-concept-integration/
    SKILL.md
    references/
commands/
  manifest.fragment.yml
  octon-concept-integration.md
prompts/
  octon-concept-integration-pipeline/
    README.md
    prompt-set-current-state-alignment-and-conflict-audit.md
    octon-implementable-concept-extraction.md
    octon-extracted-concepts-verification.md
    selected-concepts-integration-and-proposal-packet.md
    proposal-packet-executable-implementation-prompt-generator.md
    proposal-packet-implementation-and-closeout.md
context/
  octon-concept-integration-overview.md
validation/
  README.md
```

## Core Capability Shape

### 1. Composite skill as the reusable execution contract

The pack owns a composite skill named `octon-concept-integration`.

That skill is responsible for the full bounded pipeline:

1. Normalize source input and user constraints.
2. Run the prompt-set alignment companion as preflight when required.
3. Run concept extraction against the source.
4. Run verification against the live repository.
5. Resolve the in-scope concept set.
6. Generate a manifest-governed architecture proposal packet under
   `/.octon/inputs/exploratory/proposals/architecture/<proposal_id>/`.
7. Generate a packet-specific executable implementation prompt from the packet.
8. Validate the produced proposal packet and record retained run evidence.

The skill is the stable reusable orchestration contract.
It owns phase sequencing, expected outputs, and evidence locations.

### 2. Thin command wrapper as the published invocation surface

The pack also publishes a command wrapper named
`/octon-concept-integration`.

The command wrapper is intentionally narrow:

- gather or normalize operator arguments
- direct execution into the composite skill
- keep host-visible invocation simple and stable

This wrapper is the preferred v1 operator entrypoint because existing
extension publication clearly publishes commands and skill directories through
`routing_exports`, while the current runtime-facing extension publication model
does not appear to carry full extension skill registry metadata as a first-class
effective surface.

### 3. Pack-local prompt assets

The capability must internalize the current root prompt-set assets into the
pack's `prompts/` bucket.

The reusable pack must not depend on any superseded root-level prompt-set copy
at runtime, because that would break `pack_bundle` portability and leave the
capability non-self-contained outside this repository checkout shape.

The former root prompt-set copy is only historical migration lineage.
The durable reusable capability must read its prompt assets from the pack, and
the superseded root copy may be removed once live references are cleared.

## Preflight Audit Rule

`prompt-set-current-state-alignment-and-conflict-audit.md` remains a companion,
not a numbered pipeline stage.

In the durable capability it becomes a preflight gate with this rule:

- run automatically when the pack-local prompt assets or repo authority anchors
  have drifted since the last validated capability revision
- otherwise skip and proceed with the last aligned prompt revision

That keeps the stage count stable while still preventing stale prompt logic
from driving extraction or packetization.

## Output Model

The capability produces three primary output classes:

1. retained run evidence under `/.octon/state/evidence/runs/skills/**`
2. optional checkpoints under `/.octon/state/control/skills/checkpoints/**`
3. proposal artifacts under
   `/.octon/inputs/exploratory/proposals/architecture/<proposal_id>/`

The proposal packet remains the durable output of the capability run.
The executable implementation prompt is an attached proposal support artifact,
not a substitute for the packet.

## Non-Negotiables

- No new runtime or policy dependency on raw prompt assets outside the pack.
- No proposal packet treated as canonical authority.
- No generated effective surface treated as authored truth.
- No new capability-pack family or support-target widening.
- No requirement to add a new orchestration subsystem or `runtime/pipelines/`
  surface.
- No dependency on root `.prompts/**` for `pack_bundle` portability.

## Preferred Landing

The preferred landing is:

- new first-party bundled extension pack
- seeded off by default in `instance/extensions.yml`
- composite skill as reusable core
- thin command wrapper as v1 invocation gateway
- pack-local prompts and context docs
- proposal-packet-first outputs
- validation through existing extension publication and proposal validators

## Explicitly Avoided Alternatives

### Repo-native skill only

Rejected as the primary landing because it would remain repo-owned and would
not be modularly portable as a pack-level capability.

### Workflow-first implementation

Rejected as the primary landing because the capability is meant to be a stable,
reusable, contract-driven invocation surface rather than a human-visible staged
procedure first.

### Direct runtime dependence on root `.prompts/`

Rejected because it would make the extension pack non-self-contained and break
the portability model Octon already assigns to additive packs.
