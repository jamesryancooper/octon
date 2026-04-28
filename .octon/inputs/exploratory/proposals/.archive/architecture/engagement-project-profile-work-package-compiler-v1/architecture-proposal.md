# Architecture Proposal

## Decision

Add **Engagement / Project Profile / Work Package Compiler v1** as the first product-level lifecycle layer for Octon's drop-in governed autonomy workflow.

## Target outcome

After v1, Octon can move from:

> A repository exists, with or without Octon.

To:

> A governed Engagement exists; the project has been profiled; the objective has been shaped; a Work Package has been compiled; required Decision Requests are known; support, capability, context, evidence, validation, rollback, and risk posture are resolved or staged; and a first run-contract candidate can be authorized, staged, denied, or blocked.

## Architecture move

This is a **new product-level surface**, not a replacement for the existing run lifecycle, authorization boundary, mission charter, context-pack builder, evidence store, support-target model, or generated/effective handle discipline.

The compiler must hide normal operator ceremony while preserving strict internal gates:

- Engagement provides the operator-facing assignment container.
- Project Profile captures durable repo-local orientation facts backed by evidence.
- Objective Brief is a per-engagement candidate/control record, not workspace-charter authority.
- Work Package compiles plan, safety, support, capability, validation, rollback, context, evidence, and run readiness.
- Decision Request unifies approval/escalation prompts without creating a rival control plane.
- Evidence Profile scales evidence depth without weakening consequential closeout.
- Preflight Evidence Lane resolves the adoption/context-pack bootstrapping tension without allowing repo mutation.
- Tool/MCP/API/browser Connector posture is machine-readable stage/block/deny policy in v1 and maps future connector operations to existing capability packs and material-effect classes without authorizing effectful use.

## Scope control

This proposal intentionally defers broad effectful MCP support, external API/browser autonomy, deployments, credential provisioning, multi-repo autonomy, autonomous support-target widening, autonomous governance amendments, fully unattended mission running, and destructive/irreversible external operations.
