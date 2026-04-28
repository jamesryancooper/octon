# Concept Coverage Matrix

| Concept | Decision | v1 implementation | Deferred work |
|---|---|---|---|
| Engagement | Adopt | Top-level assignment container under `state/control/engagements/**`. | Multi-engagement queueing and cross-repo orchestration. |
| Project Profile | Adopt | Durable repo facts in `instance/locality/project-profile.yml` only after retained source evidence exists. | Auto-learning promotion beyond explicit review. |
| Objective Brief | Adopt as candidate/control state | Per-engagement objective record under Engagement control; not workspace-charter authority. | Workspace-charter amendment workflow, if needed, remains separate. |
| Work Package | Adopt | Compiler output with plan/safety/run-readiness sections, including the merged Autonomy Envelope section. | Full Autonomy Window execution. |
| Decision Request | Adopt | Operator-facing wrapper over approvals/exceptions/revocations/risk acceptance. | Rich UI and quorum workflows. |
| Evidence Profile | Adopt MVP-light | `orientation-only`, `stage-only`, `repo-consequential`. | Full evidence profile taxonomy. |
| Preflight Evidence Lane | Adopt | Constrained evidence-only lane for adoption/orientation/context request prep. | Effectful preflight tools. |
| Tool/MCP Connector posture | Adopt stage/block/deny policy | Machine-readable connector posture; no effectful live execution. | Live MCP/API/browser operation after support proof. |
| Autonomy Envelope | Merge | Section inside Work Package. | None as separate primitive unless future complexity proves need. |
| Autonomy Window | Defer runtime implementation | Work Package flags mission-required prerequisites and records the target Autonomy Window hooks. | Mission runner phase. |
