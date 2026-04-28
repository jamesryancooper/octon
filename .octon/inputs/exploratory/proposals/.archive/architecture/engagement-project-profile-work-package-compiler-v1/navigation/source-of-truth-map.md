# Source of Truth Map

## Proposal authority inside this packet

| Priority | Surface | Role |
|---:|---|---|
| 1 | `proposal.yml` | Proposal lifecycle authority. |
| 2 | `architecture-proposal.yml` | Architecture subtype manifest. |
| 3 | `navigation/source-of-truth-map.md` | Proposal-local precedence and boundary map. |
| 4 | `architecture/target-architecture.md` | Intended landing architecture. |
| 5 | `architecture/implementation-plan.md` | Workstream sequence. |
| 6 | `architecture/acceptance-criteria.md` | Promotion acceptance conditions. |
| 7 | `resources/**` | Supporting analysis and repository-grounded evaluation. |

## Source lineage inside this packet

| Surface | Role | Authority status |
|---|---|---|
| `resources/octon-workflow-improvement-conversation.md` | Raw exploratory conversation that produced the target workflow and packet ask. | Source lineage only; not lifecycle, runtime, policy, support, approval, or generated/effective authority. |
| `resources/conversation-alignment.md` | Packet-local distillation of the conversation into v1 primitive and scope decisions. | Supporting analysis subordinate to the manifests and architecture acceptance artifacts. |

## Durable authorities this packet must respect

| Durable surface | Role in this proposal |
|---|---|
| `/.octon/framework/constitution/**` | Supreme repo-local authority; defines fail-closed and evidence obligations. |
| `/.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Machine-readable topology and placement registry. |
| `/.octon/framework/cognition/_meta/architecture/specification.md` | Human-readable structural companion; explains class roots and placement invariants. |
| `/.octon/instance/ingress/manifest.yml` | Mandatory reads, optional orientation, continuity, closeout workflow references. |
| `/.octon/instance/bootstrap/START.md` | Boot sequence and standard preflight orientation. |
| `/.octon/instance/charter/{workspace.md,workspace.yml}` | Workspace objective authority. |
| `/.octon/instance/governance/support-targets.yml` | Bounded admitted support universe; default-deny support posture. |
| `/.octon/instance/governance/capability-packs/**` | Repo-local capability-pack admission posture. |
| `/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | Run lifecycle control state machine. |
| `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md` | Engine-owned authorization boundary. |
| `/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md` | Deterministic context evidence builder. |
| `/.octon/framework/engine/runtime/spec/engagement-work-package-compiler-v1.md` | Runtime contract for the prepare-only compiler boundary. |
| `/.octon/framework/engine/runtime/spec/evidence-store-v1.md` | Retained proof, replay, disclosure, and closeout evidence expectations. |
| `/.octon/framework/engine/runtime/spec/mission-charter-v2.schema.json` | Mission continuity authority shape. |
| `/.octon/framework/engine/runtime/spec/mission-control-lease-v1.schema.json` | Mission continuation lease shape. |
| `/.octon/framework/engine/runtime/spec/autonomy-budget-v1.schema.json` | Budget/fuel state shape for later mission runner work. |
| `/.octon/framework/engine/runtime/spec/circuit-breaker-v1.schema.json` | Circuit-breaker state shape for later mission runner work. |
| `/.octon/framework/engine/runtime/spec/runtime-resolution-v1.md` | Runtime route and effective-handle resolution discipline. |
| `/.octon/instance/governance/policies/engagement-work-package-compiler.yml` | Repo-local Work Package readiness gate policy. |
| `/.octon/instance/governance/connectors/{registry.yml,posture.yml}` | Machine-readable stage/block/deny connector posture. |
| `/.octon/instance/governance/engagements/path-families.yml` | Machine-readable compiler path-family placement. |

## Non-authoritative surfaces excluded from runtime control

- `inputs/**`, including this proposal, is non-authoritative exploratory lineage.
- `generated/**` is derived only and cannot mint authority.
- chat history, labels, comments, host UI, external dashboards, and generated summaries may aid operator understanding but cannot become control, policy, support, approval, or runtime authority.
- `resources/octon-workflow-improvement-conversation.md` is retained as proposal
  lineage and must not be consumed by promoted runtime, policy, support,
  approval, or generated/effective routes.

## Promotion boundary

Promotion targets must be durable `.octon/**` surfaces outside `inputs/exploratory/proposals/**`. Durable targets must not retain dependencies on this proposal path after implementation lands.
