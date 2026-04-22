# Source of Truth Map

## Proposal-local authority

| Surface | Role | Authority status |
|---|---|---|
| `proposal.yml` | Base proposal lifecycle authority | Proposal-local only |
| `architecture-proposal.yml` | Architecture subtype manifest | Proposal-local only |
| `navigation/source-of-truth-map.md` | Manual precedence and boundary map | Proposal-local navigation |
| `architecture/target-architecture.md` | Proposed target architecture | Proposal-local decision aid |
| `architecture/implementation-plan.md` | Proposed work plan | Proposal-local decision aid |
| `architecture/acceptance-criteria.md` | Proposed landing criteria | Proposal-local decision aid |

## Durable authority to be respected during promotion

| Durable surface | Current role |
|---|---|
| `/.octon/framework/constitution/CHARTER.md` | Supreme repo-local constitutional charter |
| `/.octon/framework/constitution/obligations/fail-closed.yml` | Deny/stage/escalate obligations and reason-code contract |
| `/.octon/framework/constitution/obligations/evidence.yml` | Retained evidence obligations |
| `/.octon/framework/constitution/precedence/normative.yml` | Normative authority order |
| `/.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Machine-readable structural registry |
| `/.octon/framework/cognition/_meta/architecture/specification.md` | Human-readable structural companion |
| `/.octon/octon.yml` | Root manifest, profiles, runtime-resolution anchors, generated commit defaults |
| `/.octon/instance/manifest.yml` | Repo-side overlay enablement |
| `/.octon/instance/ingress/manifest.yml` | Mandatory ingress reads and closeout pointer |
| `/.octon/instance/governance/support-targets.yml` | Bounded support universe and tuple inventory |
| `/.octon/instance/governance/capability-packs/**` | Repo-owned capability-pack governance intent |
| `/.octon/instance/orchestration/missions/**` | Mission continuity authority |

## Operational truth and evidence surfaces

| Surface | Role |
|---|---|
| `/.octon/state/control/execution/**` | Mutable run, approval, exception, revocation, mission, publication, and extension control truth |
| `/.octon/state/evidence/**` | Retained evidence, disclosure, receipts, validation evidence, proof bundles |
| `/.octon/state/continuity/**` | Handoff and resumption state |

## Generated and input boundaries

| Surface | Role | Boundary rule |
|---|---|---|
| `/.octon/generated/effective/**` | Runtime-facing compiled outputs | Valid only with current publication receipt and freshness lock |
| `/.octon/generated/cognition/**` | Operator read models | Non-authoritative; may not route runtime or policy |
| `/.octon/generated/proposals/registry.yml` | Proposal discovery projection | Discovery-only; never proposal lifecycle authority |
| `/.octon/inputs/additive/extensions/**` | Raw additive extension inputs | Non-authoritative until trust selection, activation, quarantine handling, and publication |
| `/.octon/inputs/exploratory/**` | Proposals and ideation | Non-authoritative; excluded from runtime and policy resolution |

## Boundary rule for this packet

This packet may recommend changes to durable authority, runtime, state, evidence, and generated
outputs. It may not become one of those surfaces. After promotion, every canonical target must be
self-sufficient and must not cite this proposal path as live authority.
