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
