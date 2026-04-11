# Source-of-truth map

| Class                           | Canonical root                    | Meaning                                                                |
| ------------------------------- | --------------------------------- | ---------------------------------------------------------------------- |
| Durable core authority          | `framework/**`                    | Constitution, contracts, architecture, portable invariants             |
| Repo-specific durable authority | `instance/**`                     | Repo policy, repo contracts, ingress, repo runtime/config overlays     |
| Live mutable control truth      | `state/control/**`                | Mission/run/approval/exception/revocation/control records              |
| Retained evidence               | `state/evidence/**`               | Run evidence, disclosure bundles, validation receipts, replay pointers |
| Continuity                      | `state/continuity/**`             | Resumable handoff and continuity artifacts                             |
| Derived read models             | `generated/**`                    | Effective/cognition/proposals publications only                        |
| Exploratory packets             | `inputs/exploratory/proposals/**` | Proposal lineage only; never runtime/policy truth                      |

## Live repo anchors used in this packet

- `/.octon/framework/cognition/_meta/architecture/specification.md` — umbrella architecture contract
- `/.octon/framework/constitution/**` — constitutional kernel
- `/.octon/AGENTS.md` — projected ingress
- `/.octon/instance/ingress/AGENTS.md` — canonical internal ingress
- `/.octon/instance/manifest.yml` — enabled overlays
- `/.octon/framework/overlay-points/registry.yml` — legal overlay points
- `/.octon/state/control/execution/**` — mission/run/approval/exception/revocation control truth
- `/.octon/state/evidence/**` — retained proof and disclosure
- `/.octon/generated/**` — derived-only projections and publications

## Source-of-truth implications for this packet

1. No recommendation in this packet treats proposal-local artifacts as canonical truth.
2. Any promoted capability must place durable meaning in `framework/**` or `instance/**`.
3. Any promoted capability that changes approvals, mission control, or progression must materialize canonical mutable truth in `state/control/**`.
4. Any promoted capability that relies on proof must retain evidence in `state/evidence/**`.
5. Any generated summaries or distillation outputs remain non-authoritative unless and until separately promoted into authority surfaces.
