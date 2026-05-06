# Source Of Truth Map

## Durable Authorities

| Surface | Role in this packet | Boundary |
| --- | --- | --- |
| `.octon/framework/constitution/**` | Constitutional non-negotiables for authority, evidence, fail-closed behavior, and ownership | The plan layer cannot override or reinterpret the kernel. |
| `.octon/instance/charter/{workspace.md,workspace.yml}` | Workspace objective authority and active release/profile posture | Planning work must stay within the workspace objective and pre-1.0 atomic profile. |
| `.octon/instance/orchestration/missions/**` | Mission authority and continuity container | A plan can bind to a mission; it cannot create or widen mission authority. |
| `.octon/framework/engine/runtime/spec/action-slice-v1.schema.json` | Existing executable leaf candidate shape | Plan leaves compile to action-slice candidates instead of inventing atomic actions. |
| `.octon/state/control/execution/runs/<run-id>/run-contract.yml` | Atomic per-run execution contract | A plan cannot replace run-contract binding. |
| `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md` | Context evidence assembly before authorization | Planning refs may enter context packs only with source-class preservation. |
| `.octon/framework/engine/runtime/spec/execution-authorization-v1.md` | Engine-owned material side-effect gate | A plan leaf cannot authorize execution. |
| `.octon/framework/engine/runtime/spec/evidence-store-v1.md` | Retained proof roots and evidence/control separation | Planning evidence must remain separate from run evidence. |
| `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` and `run-journal-v1.md` | Run lifecycle and replay truth | Plans may explain why a run exists but cannot become the run journal. |
| `.octon/instance/governance/support-targets.yml` | Bounded admitted support universe | Planning cannot widen support claims or admit capabilities. |

## Proposal-Local Authorities

| Surface | Proposal role | Promotion boundary |
| --- | --- | --- |
| `proposal.yml` | Base lifecycle manifest for this temporary packet | Lifecycle authority only inside the proposal workspace. |
| `architecture-proposal.yml` | Architecture subtype manifest | Subtype authority only inside the proposal workspace. |
| `navigation/source-of-truth-map.md` | Manual precedence and boundary map | Must not be cited by promoted runtime targets as authority. |
| `architecture/*.md` | Candidate target-state, implementation, and validation guidance | Promotion must translate accepted content into durable targets. |
| `resources/bounded-planning-layer-source-analysis.md` | Preserved operator-provided source analysis and rationale | Lineage only; must not be cited by promoted runtime targets as runtime, policy, control, or evidence authority. |
| `support/executable-implementation-prompt.md` | Generated operational implementation guidance | Implementation support only; it does not replace proposal manifests, promoted authority, or post-implementation gate receipts. |
| `support/*.md` | Creation, readiness, and post-implementation gate receipts | Receipts guide packet lifecycle; they do not authorize runtime behavior. |

## Derived Projections

| Surface | Role | Boundary |
| --- | --- | --- |
| `.octon/generated/proposals/registry.yml` | Discovery projection for manifest-governed proposals | Discovery only; never lifecycle authority over manifests. |
| `.octon/generated/cognition/projections/materialized/planning/**` | Candidate future operator read model | Derived only; forbidden as authority, control truth, or evidence substitute. |
| `.octon/generated/effective/**` | Runtime-facing derived handles | The planning layer should not publish runtime-effective handles in phase 1. |

## Retained Evidence Surfaces

| Evidence class | Proposed root | Role |
| --- | --- | --- |
| Plan mutation evidence | `.octon/state/evidence/control/execution/planning/<plan-id>/**` | Plan creation, revision, readiness, compile, drift, and closeout receipts. |
| Run execution evidence | `.octon/state/evidence/runs/<run-id>/**` | Canonical run evidence remains separate and primary for execution proof. |
| Validation evidence | `.octon/state/evidence/validation/**` | Validator transcripts and promotion evidence for durable implementation. |

## Boundary Rules

- Proposal-local files remain non-authoritative.
- Generated planning views remain operator read models only.
- Mutable planning state belongs under mission-local `state/control/**` paths
  only after durable schemas and validators are promoted.
- Planning doctrine and schemas belong under `framework/**`.
- Instance enablement belongs under `instance/**`.
- Material execution still requires run-contract binding, context packing,
  `authorize_execution`, typed authorized effects, retained run evidence, and
  journal coverage.
