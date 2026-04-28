# Conversation Alignment

## Source

`resources/octon-workflow-improvement-conversation.md` preserves the exploratory
conversation that led to this packet. It is source lineage only. It does not
create proposal lifecycle authority, runtime authority, policy authority,
support authority, approval authority, or generated/effective authority.

## Distilled Direction

The conversation converges on one target product direction:

- Octon should support drop-in governed autonomy as a product model.
- The current repository already has strong run-level governance, evidence,
  authorization, rollback, support-target, context-pack, mission, and generated
  handle machinery.
- The missing layer is the product-level compiler from repo adoption and
  orientation to first safe run-contract readiness.
- The raw internal governance sequence is too low-level to expose as the normal
  operator workflow.
- Octon should add higher-level primitives that compile existing lower-level
  constitutional and runtime machinery instead of replacing it.

## Packet Alignment Decisions

| Conversation concept | Packet decision | Alignment note |
|---|---|---|
| Engagement | Adopt in v1 | Product-level assignment container above missions and runs. |
| Project Profile | Adopt in v1 | Durable repo-local orientation facts, backed by retained evidence. |
| Objective Brief | Adopt as engagement candidate/control state | Shapes one Work Package without replacing workspace-charter authority. |
| Work Package | Adopt in v1 | Central compiler output from objective and profile to run readiness. |
| Autonomy Envelope | Merge in v1 | Kept as a Work Package section to avoid concept sprawl. |
| Decision Request | Adopt in v1 | Operator-facing wrapper over canonical approval, exception, revocation, risk, and clarification paths. |
| Evidence Profile | Adopt MVP-light in v1 | Minimum profiles: `orientation-only`, `stage-only`, and `repo-consequential`. |
| Preflight Evidence Lane | Adopt in v1 | Resolves the adoption/context evidence bootstrapping tension while forbidding material project effects. |
| Tool/MCP Connector posture | Adopt stage/block/deny policy in v1 | Models future connector operation posture without effectful MCP/API/browser execution. |
| Autonomy Window | Defer runtime implementation | Target lifecycle concept for mission runner work; v1 records mission-required prerequisites and blocks or stages when they are missing. |

## Final V1 Boundary

This packet intentionally narrows the conversation's broader target workflow to
the highest-leverage next implementation step:

> Engagement / Project Profile / Work Package Compiler v1.

The v1 compiler must produce an Engagement, Project Profile, per-engagement
Objective Brief candidate, Work Package, Decision Requests, Evidence Profile
selection, context-pack request, support/capability posture, rollback/validation
plan, and first run-contract candidate.

It must not implement broad effectful MCP execution, arbitrary API/browser
autonomy, deployment automation, credential provisioning, multi-repo autonomy,
autonomous support-target widening, autonomous governance amendments,
destructive external operations, or a fully unattended long-horizon mission
runner.

## Promotion Implication

Promotion must distill the conversation-derived decisions into durable
`framework/**`, `instance/**`, `state/control/**`, `state/evidence/**`, and
derived `generated/**` targets. No promoted target may depend on the raw
conversation file or this proposal path as a runtime or policy source.
