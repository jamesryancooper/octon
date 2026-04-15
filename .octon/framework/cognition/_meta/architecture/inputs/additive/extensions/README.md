# Additive Extension Inputs

`inputs/additive/extensions/**` is the canonical raw-input surface for additive
extension packs.

## Placement Rules

- Raw packs live only under `inputs/additive/extensions/<pack-id>/`.
- Raw packs are non-authoritative source inputs only.
- Runtime and policy consumers must never read raw pack paths directly.
- Pack payloads remain additive and subordinate to `framework/**` and
  `instance/**`.

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

- `pack.yml` uses `octon-extension-pack-v3`.
- `compatibility.required_contracts` is required, even when empty.
- `provenance` is pack-authored and carries origin metadata, digests, and
  attestation references.
- Repo trust remains in `instance/extensions.yml`; it does not move into raw
  pack payloads.
