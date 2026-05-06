# Current-State Gap Map

## Existing Strengths

| Existing surface | Current role | Planning relevance |
| --- | --- | --- |
| `.octon/framework/constitution/**` | Constitutional kernel | Already requires explicit scope, authority routing, evidence, fail-closed behavior, and one accountable orchestrator. |
| `.octon/instance/orchestration/missions/**` | Mission authority | Provides the durable mission object and continuity boundary for long-horizon or overlapping work. |
| `.octon/state/control/execution/missions/<mission-id>/**` | Mission-local control state | Already carries mission control artifacts such as action slices and runtime directives. |
| `action-slice-v1.schema.json` | Governable execution-unit primitive | Provides the executable leaf shape the planning layer should compile to. |
| `state/control/execution/runs/<run-id>/run-contract.yml` | Per-run execution authority | Remains the atomic consequential execution contract. |
| `context-pack-builder-v1.md` | Deterministic context evidence | Can include selected planning refs while preserving source classes. |
| `execution-authorization-v1.md` | Engine-owned execution gate | Prevents planning artifacts from authorizing material effects. |
| `evidence-store-v1.md` | Retained proof model | Separates control, retained evidence, generated projections, and proposal inputs. |
| `run-lifecycle-v1.md` and `run-journal-v1.md` | Lifecycle and replay truth | Keep execution reconstruction journal-first. |
| `support-targets.yml` | Bounded admitted support universe | Prevents planning from widening support claims or admitting new capabilities. |

## Gap

Octon has mission authority, mission-local control, action slices, run
contracts, context packing, authorization, retained evidence, replay, rollback,
and generated views. It does not have a canonical planning artifact that
records how a mission is decomposed into validated work-package candidates
before action slices and run contracts are drafted.

The gap is narrow:

- no canonical `MissionPlan` container
- no typed `PlanNode` schema
- no separate dependency-edge contract for non-tree dependencies
- no plan revision, compile, or drift receipt family
- no validator-enforced stop rules for hierarchical decomposition
- no workflow that compiles ready leaves into action-slice candidates

## Wrong Solutions To Avoid

- adding a project-management subsystem
- treating generated plan views as current truth
- routing execution directly from plan leaves
- replacing action slices with free-text atomic actions
- using proposal-local planning docs after promotion
- storing durable doctrine in `state/**`, `generated/**`, or `inputs/**`

## Target Gap Closure

Add only the minimum preparation layer needed to make mission-to-run
decomposition explicit, bounded, auditable, and evidence-backed. All runtime
authority and material execution remain with the existing mission, run,
context, authorization, evidence, rollback, and support-target systems.
