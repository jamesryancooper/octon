# Architecture Map

This map is a derived navigation aid for the target-state architecture. Source
authority remains in `framework/**`, `instance/**`, `state/control/**`, and
`state/evidence/**`.

## Canonical Layers

| Layer | Canonical surface | Role |
| --- | --- | --- |
| Constitutional kernel | `/.octon/framework/constitution/**` | Supreme repo-local control authority |
| Structural architecture | `/.octon/framework/cognition/_meta/architecture/{contract-registry.yml,specification.md}` | Topology, publication, doc-role, and placement truth |
| Governance and support | `/.octon/instance/governance/**` | Repo-owned policy, support-target, retirement, and disclosure authority |
| Execution truth | `/.octon/state/control/execution/**` | Mutable run, approval, exception, revocation, and mission control truth |
| Retained proof | `/.octon/state/evidence/**` | Retained execution, disclosure, validation, and support proof evidence |
| Derived maps | `/.octon/generated/cognition/projections/materialized/**` | Navigation-only read models |

## Target-State Navigation

- Authorization boundary contracts: `framework/engine/runtime/spec/**`
- Runtime kernels and authority engine: `framework/engine/runtime/crates/**`
- Packet-named closure evidence: `state/evidence/validation/architecture-target-state-transition/**`
- Tuple proof bundles: `state/evidence/validation/support-targets/**`
- Transitional retirement inventory: `instance/governance/retirement-register.yml`
