# Additive Extension Inputs

`inputs/additive/extensions/**` is the canonical raw-input surface for
normalized additive extension packs.

## Placement Rules

- Normalized raw extension packs live only under
  `inputs/additive/extensions/<pack-id>/`.
- Raw packs are non-authoritative source inputs only.
- Runtime and policy consumers must never read raw pack paths directly.
- Pack payloads remain additive and subordinate to `framework/**` and
  `instance/**`.
- Downloaded, unreviewed, or route-undecided intake units live under
  `inputs/additive/.incoming/<intake-id>/`, not under this normalized extension
  pack root.

## Canonical Pack Layout

```text
inputs/additive/extensions/<pack-id>/
  pack.yml
  README.md
  skills/
  commands/
  templates/
  prompts/
  context/
  validation/
```

## Ownership

The canonical extension ownership model is defined in:

- `/.octon/framework/engine/governance/extensions/README.md`

Local implication for this surface:

- artifacts authored under `inputs/additive/extensions/<pack-id>/` are raw
  extension-owned additive inputs unless the canonical ownership model says
  otherwise.

## Schema Contracts

- `schemas/extension-pack.schema.json`

## Packet Contract

- `pack.yml` uses `octon-extension-pack-v5`.
- `capability_profiles` is required and declares the composable surfaces the
  pack provides. It must include `validation-surface`; other profiles are
  additive and artifact-backed.
- `compatibility.required_contracts` is required, even when empty.
- `compatibility.profile_path` is required and must point to
  `validation/compatibility.yml`.
- `provenance` is pack-authored and carries origin metadata, digests, and
  attestation references.
- Repo trust remains in `instance/extensions.yml`; it does not move into raw
  pack payloads.

## Capability Profiles

Capability profiles are not mutually exclusive extension types. They keep one
extension-pack substrate while making each surface explicit:

- `validation-surface`: required for every pack; requires `validation/` and
  `validation/compatibility.yml`.
- `command-surface`: requires `commands/manifest.fragment.yml` and referenced
  command files.
- `skill-surface`: requires `skills/manifest.fragment.yml`,
  `skills/registry.fragment.yml`, and referenced skill roots.
- `prompt-bundle`: requires at least one manifest-based prompt bundle under
  `prompts/**/manifest.yml`.
- `routing-contract`: requires `context/routing.contract.yml` and may only
  reference command, skill, or prompt capabilities declared by profiles.
- `lifecycle-contract`: requires `context/lifecycle.contract.yml`; extension
  lifecycle routes require `routing-contract`.
- `template-surface`: requires `templates/catalog.fragment.yml` and referenced
  template paths.

## Split-Layer Naming Contract

Extension naming keeps runtime authority, host projection identity, authored
execution content, and operator display separate:

- Runtime route IDs are local lifecycle/orchestration contract identifiers.
  They identify route-dispatch behavior inside the owning pack and do not need
  a host namespace.
- Slash command IDs are host projection identities. They must be namespaced by
  the pack or an explicitly documented operator family, such as
  `octon-proposal-*` for the `octon-proposal-lifecycle` pack.
- Skill registry `commands` entries are also slash-command projection
  references. When a pack declares a command surface, they must point at command
  IDs declared in that pack's command manifest. When a pack exposes skills
  without a command surface, they are direct skill invocation commands and must
  equal `/<skill-id>`.
- Skill IDs are capability identities. They must be namespaced by the owning
  pack ID and must not depend on matching a route ID or slash command ID
  exactly.
- Prompt set IDs identify authored execution content. They must use the pack
  namespace, either as `<pack-id>-<route-id>` when one bundle implements one
  route or as `<pack-id>-<content-purpose>` when the bundle has a narrower or
  content-specific purpose.
- Dropdown and display titles are concise operator read models only. They do
  not authorize execution, replace route IDs, or define command, skill, prompt,
  lifecycle, or receipt authority.

All command, skill, prompt-set, and routing binding IDs use lowercase kebab
case without consecutive hyphens. Extension projection IDs should stay at or
below 64 characters for host compatibility; existing longer first-party IDs are
accepted under staged enforcement until a deliberate rename migration.
