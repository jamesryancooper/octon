# Repository Reconnaissance Receipt

## Profile Selection

- release_state: `pre-1.0`
- change_profile: `atomic`
- rationale: the workspace charter and constitutional charter declare
  pre-1.0 atomic mode, and this packet is a proposal-first architecture
  change rather than a transitional live runtime migration.

## Searches Run

- `rg -n "implementation-readiness|implementation.*readiness|implementation-grade" .octon/framework .octon/inputs .octon/state .codex`
- `find .octon/inputs/exploratory/proposals/architecture -maxdepth 3 -type f`
- `rg -n "mission plan|planning layer|PlanNode|hierarchical planning|action-slice" .octon/framework .octon/instance .octon/inputs/exploratory/proposals -g '!generated/**'`

## Existing Surfaces Found

- Mission authority and mission-local control exist.
- Action slices already provide the governable executable leaf primitive.
- Run contracts, Run Journal, run lifecycle, context packing, authorization,
  evidence store, rollback, and support-target governance already exist.
- Proposal standards and architecture subtype validators already exist.
- Archived mission-scoped reversible autonomy proposals provide lineage for
  action-slice and mission-control placement.
- No active durable `MissionPlan` or `PlanNode` schema was found.

## Reused Surfaces

- `octon-mission-v2` mission authority remains the planning input.
- `action-slice-v1` remains the executable leaf candidate.
- Run contracts remain the atomic consequential execution authority.
- Context Pack Builder remains the context evidence mechanism.
- `authorize_execution` remains the engine-owned side-effect gate.
- Evidence Store and Run Journal remain execution proof and replay truth.
- Generated proposal registry remains discovery-only.

## Rejected Surfaces

- Generic task-board semantics are rejected because Octon is a governed runtime,
  not a project-management subsystem.
- A new `AtomicAction` schema is rejected because `action-slice-v1` already
  carries the needed governance fields.
- Generated plan views as authority are rejected by the class-root model.
- Proposal-local planning material after promotion is rejected by proposal
  non-canonical rules.

## New Surfaces Proposed

The packet proposes a narrow planning family because no existing surface
records mission-to-action-slice decomposition as mutable control state with
retained revision, compile, and drift evidence.
