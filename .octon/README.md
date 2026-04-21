# `.octon`: Super-Root

`.octon/` is Octon's single authoritative super-root. The machine-readable
topology and authority registry lives at
`/.octon/framework/cognition/_meta/architecture/contract-registry.yml`.

This README is the concise, registry-backed orientation surface. It summarizes
the class-root model, the canonical registries, and the bootstrap entrypoints
without restating the full path topology.

## Class Roots

| Root | Role |
| --- | --- |
| `framework/` | Portable authored Octon core, contracts, runtime, validators, and helper assets |
| `instance/` | Repo-specific durable authored authority |
| `state/` | Mutable control truth, retained evidence, and active continuity |
| `generated/` | Rebuildable effective outputs and read models |
| `inputs/` | Non-authoritative additive and exploratory inputs |

Only `framework/**` and `instance/**` are authored authority. `generated/**`
never mints authority, and `inputs/**` never becomes a direct runtime or policy
dependency.

## Canonical Registries

| Surface | Role |
| --- | --- |
| `/.octon/octon.yml` | Super-root manifest, profiles, runtime resolution inputs, generated commit defaults |
| `/.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Machine-readable topology, authority, publication, and doc-target registry |
| `/.octon/framework/constitution/contracts/registry.yml` | Constitutional family and integration registry |
| `/.octon/framework/overlay-points/registry.yml` | Legal overlay-point declaration |
| `/.octon/instance/manifest.yml` | Repo-side overlay enablement |
| `/.octon/instance/ingress/manifest.yml` | Mandatory ingress read order and closeout gate |
| `/.octon/instance/cognition/decisions/index.yml` | Append-only ADR discovery |

## Steady-State Model

- Constitutional authority lives under `framework/constitution/**`.
- The kernel anchor remains `/.octon/framework/constitution/CHARTER.md`.
- Repo-owned objective, governance, locality, ingress, bootstrap, decisions,
  and mission authority live under `instance/**`.
- Mutable execution and publication truth lives under `state/control/**`.
- Retained evidence, disclosure, and validation receipts live under
  `state/evidence/**`.
- Handoff and resumption state lives under `state/continuity/**`.
- Runtime-facing effective outputs live under `generated/effective/**` and
  require publication receipts plus freshness artifacts.
- Operator summaries and materialized read models live under
  `generated/cognition/**` and remain non-authoritative.
- Proposal discovery lives under `generated/proposals/registry.yml` and remains
  discovery-only.

## Bootstrap Entry Points

Start from these surfaces:

1. repo-root `AGENTS.md` or `CLAUDE.md`
2. `/.octon/AGENTS.md`
3. `/.octon/instance/ingress/AGENTS.md`
4. `/.octon/instance/bootstrap/START.md`
5. `/.octon/instance/charter/{workspace.md,workspace.yml}`

Use `/.octon/instance/bootstrap/START.md` for the steady-state boot sequence
and `/.octon/framework/cognition/_meta/architecture/specification.md` for the
human-readable structural contract.

## Portability

Portability is profile-driven through `/.octon/octon.yml`:

- `bootstrap_core`
- `repo_snapshot`
- `pack_bundle`
- `full_fidelity`

The profiles are authoritative in the root manifest. This README does not
duplicate their include or exclude matrices.

## History

Historical cutovers, wave lineage, and proposal provenance live in ADRs and
retained evidence, not in this overview. Use
`/.octon/instance/cognition/decisions/index.yml` to discover durable decision
records and `inputs/exploratory/proposals/**` only as archived lineage.
