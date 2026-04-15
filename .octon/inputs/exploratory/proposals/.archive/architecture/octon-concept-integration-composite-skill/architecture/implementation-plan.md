# Implementation Plan

## Change Profile

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- implementation posture: additive pack introduction with no support-target
  widening and no new runtime root

## Workstream 1: Define the pack shell

Create the new bundled pack root:

- `pack.yml`
- `README.md`
- `skills/`
- `commands/`
- `prompts/`
- `context/`
- `validation/`

Decisions:

- `origin_class`: `first_party_bundled`
- trust hint: `allow`
- initial desired state in `instance/extensions.yml`: disabled by default

## Workstream 2: Internalize the prompt assets

Copy or normalize the current concept-integration prompt set into:

`/.octon/inputs/additive/extensions/octon-concept-integration/prompts/octon-concept-integration-pipeline/`

Rules:

- preserve the existing 4-stage pipeline contract
- keep the alignment audit as a companion/preflight artifact, not a fifth stage
- keep the executable-prompt generator as a companion artifact, not the main
  implementation stage

## Workstream 3: Implement the composite skill

Create the composite skill contract with:

- `skills/manifest.fragment.yml`
- `skills/registry.fragment.yml`
- `skills/octon-concept-integration/SKILL.md`
- pack-local references documenting phases, inputs, outputs, and guardrails

The skill should define:

1. source intake
2. prompt-alignment preflight rule
3. extraction
4. verification
5. selected-concept resolution
6. proposal packet generation
7. executable implementation prompt generation
8. packet validation and evidence retention

## Workstream 4: Add the command wrapper

Create the thin command surface:

- `commands/manifest.fragment.yml`
- `commands/octon-concept-integration.md`

Responsibilities:

- operator-facing invocation
- argument normalization
- explicit delegation into the composite skill
- no duplicate pipeline logic

## Workstream 5: Wire desired-state integration

Update:

- `/.octon/instance/extensions.yml`
- `/.octon/instance/bootstrap/catalog.md`

Goals:

- make the optional pack discoverable
- keep activation repo-owned
- avoid silently enabling new optional capability surfaces by default

## Workstream 6: Validate publication and runtime discovery

Run and capture evidence for:

- extension-pack validation
- extension publication
- capability routing publication
- host projection publication and validation

Correct any routing, collision, or quarantine issues before functional testing.

## Workstream 7: Prove end-to-end packet generation

Run the landed capability against a bounded sample source and confirm:

- packet directory creation in the standard architecture proposal path
- generation of required proposal files
- packet validator success
- executable implementation prompt generation as support material

## Deferred Follow-On Work

These items are intentionally outside the required landing unless validation
shows they are strictly necessary:

- extending the effective extension publication model to expose extension skill
  registry metadata as a first-class runtime-facing surface
- adding a workflow wrapper around the skill for pause/resume review gates
- archiving or deleting the root `.prompts/` source set after pack migration is
  complete
