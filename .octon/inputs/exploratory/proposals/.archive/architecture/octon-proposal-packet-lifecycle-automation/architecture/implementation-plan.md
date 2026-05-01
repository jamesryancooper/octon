# Implementation Plan

- proposal: `octon-proposal-packet-lifecycle-automation`

## Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- rationale: the extension pack, activation, publication outputs, host
  projections, and validation fixtures must land coherently. A partially
  published lifecycle automation route would invite stale prompt execution and
  confused closeout behavior.

## Workstream 1 - Scaffold Extension Pack

Create `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/`
with:

- `pack.yml`
- `README.md`
- `context/`
- `prompts/`
- `skills/`
- `commands/`
- `validation/`

Use existing first-party packs as shape references, especially
`octon-concept-integration`, `octon-impact-map-and-validation-selector`, and
`octon-pack-scaffolder`.

Use the recommended scaffold in `architecture/target-architecture.md` unless a
better structure is justified by live repository conventions. If the
implementation deviates, record the rationale in the pack README or context
docs and preserve equivalent coverage for context docs, shared contracts,
bundle manifests, stages, companions, references, validation fixtures,
commands, skills, and publication outputs.

## Workstream 2 - Shared Contracts

Author shared prompt contracts for:

- repository grounding,
- proposal authority and non-authority boundaries,
- source context preservation,
- packet support artifact placement,
- generated custom prompt requirements,
- verification finding identity,
- correction prompt output,
- closeout GitHub/CI/review boundaries,
- evidence retention and registry regeneration.

Preferred shared contract filenames are:

- `repository-grounding.md`
- `proposal-contract.md`
- `proposal-authority-boundaries.md`
- `lifecycle-artifact-contract.md`
- `validation-and-evidence-contract.md`
- `github-closeout-boundary.md`

## Workstream 2A - Reusable Pattern Layer

Materialize the reusable patterns from `architecture/reusable-patterns.md`
inside the extension pack context tree. The implementation may choose one file:

```text
.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/context/patterns.md
```

or split files:

```text
.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/context/patterns/
```

Every route-specific bundle must reference the relevant patterns instead of
duplicating divergent lifecycle, evidence, support-artifact, authority, or
closeout rules.

The Proposal Program pattern must be materialized as a first-class pattern,
preferably:

```text
.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/context/patterns/proposal-program.md
```

or as a clearly labeled section in `context/patterns.md`.

## Workstream 3 - Route Prompt Bundles

Implement prompt bundles for the whole lifecycle:

- `create-proposal-packet`
- `explain-proposal-packet`
- `generate-implementation-prompt`
- `generate-verification-prompt`
- `generate-correction-prompt`
- `run-verification-and-correction-loop`
- `generate-closeout-prompt`
- `closeout-proposal-packet`
- `create-proposal-program`
- `generate-program-implementation-prompt`
- `generate-program-verification-prompt`
- `generate-program-correction-prompt`
- `run-program-verification-and-correction-loop`
- `generate-program-closeout-prompt`
- `closeout-proposal-program`

Each bundle must have a manifest, README, stages, at least one maintenance
companion, and validation scenarios.

The `create-proposal-packet` bundle should use the recommended stage and
companion shape:

```text
create-proposal-packet/
  manifest.yml
  README.md
  stages/
    01-normalize-source-context.md
    02-classify-proposal-scenario.md
    03-select-creation-route.md
    04-generate-or-create-packet.md
    05-validate-packet.md
  companions/
    01-generate-custom-creation-prompt.md
    02-align-bundle.md
  references/
```

If a different bundle shape is used, the implementation must preserve the same
behavioral stages and document why the alternate shape better matches Octon's
extension-pack conventions.

## Workstream 4 - Commands And Skills

Add a composite skill and leaf skills with matching command wrappers:

- `octon-proposal-packet-lifecycle`
- `octon-proposal-packet-lifecycle-create`
- `octon-proposal-packet-lifecycle-explain`
- `octon-proposal-packet-lifecycle-generate-implementation-prompt`
- `octon-proposal-packet-lifecycle-generate-verification-prompt`
- `octon-proposal-packet-lifecycle-generate-correction-prompt`
- `octon-proposal-packet-lifecycle-generate-closeout-prompt`
- `octon-proposal-packet-lifecycle-closeout`
- `octon-proposal-packet-lifecycle-create-program`
- `octon-proposal-packet-lifecycle-generate-program-implementation-prompt`
- `octon-proposal-packet-lifecycle-generate-program-verification-prompt`
- `octon-proposal-packet-lifecycle-generate-program-correction-prompt`
- `octon-proposal-packet-lifecycle-generate-program-closeout-prompt`
- `octon-proposal-packet-lifecycle-closeout-program`

The composite route should select the correct leaf route from source kind,
packet path, lifecycle action, and optional user constraints.

## Workstream 5 - Existing Surface Composition

Route to existing Octon surfaces wherever possible:

- proposal create workflows for pure scaffolding,
- concept-integration source-to-packet routes for source-driven packets,
- concept-integration packet-to-implementation for execution,
- impact-map-and-validation-selector for validation selection,
- validate-proposal workflow and proposal validators,
- promote/archive proposal workflows for lifecycle state changes,
- extension publication scripts for pack publication,
- host projection publication scripts for command and skill projection.

## Workstream 6 - Validation Fixtures

Add pack-local tests and scenarios for:

- audit-aligned packet creation,
- architecture evaluation packet creation,
- highest-leverage next-step packet creation,
- packet explanation,
- implementation prompt generation,
- verification prompt generation,
- correction prompt generation from findings,
- verification-and-correction convergence,
- closeout prompt generation,
- closeout behavior boundaries,
- stale packet refresh/supersession routing,
- proposal program parent/child sequencing,
- proposal program validation and closeout gates,
- proposal program rejection of nested child packet directories,
- proposal program aggregate prompts preserving child manifest authority,
- failure when prompts or generated artifacts try to become authority.

## Workstream 7 - Publication

Update `.octon/instance/extensions.yml`, publish effective extension state,
publish capability routing, publish host projections, and validate all generated
outputs.

## Workstream 8 - Packet Closeout

After implementation:

1. run proposal validators,
2. run extension and capability publication validators,
3. run host projection validators,
4. run pack-local tests,
5. verify generated outputs are coherent,
6. generate and run this packet's follow-up verification prompt,
7. correct findings,
8. promote/archive this proposal with retained evidence.
