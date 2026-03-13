# Engine Architecture Contract

This contract defines the bounded-surface architecture for `/.octon/engine/`.

## Contract

- `runtime/` holds executable authority.
- `governance/` holds normative contracts.
- `practices/` holds operating standards.
- `_ops/` and `_meta/` remain support namespaces only.

## Benefits

- Clear authority boundaries reduce ambiguity.
- Governance and operations are independently auditable.
- CI can enforce clean-break regressions on explicit surfaces.

## Risks

- Surface drift can reintroduce mixed ownership.
- Over-expansion can add unnecessary structure.

## Mitigations

- Enforce deprecated-path bans in migration CI.
- Keep contract updates in the same change set as behavioral changes.
- Apply bounded surfaces only where each surface is materially owned.
