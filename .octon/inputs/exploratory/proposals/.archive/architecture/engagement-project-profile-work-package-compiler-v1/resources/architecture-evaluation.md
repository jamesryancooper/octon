# Architecture Evaluation

## Why this is the highest-leverage next step

Drop-in governed autonomy cannot start with a fully unattended mission runner. That would amplify current gaps: repo classification, project orientation, charter reconciliation, support posture, capability posture, context request, rollback planning, and Decision Request surfacing.

The highest-leverage move is therefore a compiler layer that prepares safe work before execution. This gives Octon a simple operator-facing lifecycle while preserving the existing governance machinery.

The retained conversation in `resources/octon-workflow-improvement-conversation.md`
arrives at the same conclusion after evaluating the broader drop-in governed
autonomy workflow: keep the low-level run, mission, support, evidence, and
authorization machinery, but add a higher-level Engagement / Project Profile /
Work Package compiler so operators do not have to drive the raw governance
sequence manually.

## Current constraint

Octon is currently run-first. The run lifecycle is strong, but there is no product-level path from “this repository exists” to “this run contract is ready, staged, blocked, or denied.” As a result, the operator must manually bridge adoption, orientation, planning, support, capability, context, rollback, and authorization readiness.

## Why these primitives are the right abstraction layer

- Engagement gives the human one assignment container without replacing missions or runs.
- Project Profile gives stable repo-local orientation facts without making generated summaries authoritative.
- Work Package compiles the run-readiness bundle without becoming execution authority.
- Decision Request hides low-level approval/exception/revocation complexity without creating a rival control plane.
- Evidence Profile makes safety scalable without weakening consequential evidence requirements.
- Preflight Evidence Lane resolves the bootstrap evidence/authorization tension under strict constraints.
- Tool/MCP Connector posture prepares future tool support while keeping v1 stage-only.

## How governance is preserved

The compiler never authorizes material execution. It produces candidate artifacts. Existing authorization and run lifecycle still decide whether material work can proceed.

The compiler must keep root roles distinct:

- `framework/**` and `instance/**` for authored authority;
- `state/control/**` for operational truth;
- `state/evidence/**` for proof;
- `state/continuity/**` for resumable context;
- `generated/**` for projections only;
- `inputs/**` for exploratory/non-authoritative material.

## How operator complexity is reduced

The operator sees `start`, `profile`, `plan`, `arm`, `decide`, and `status`. Internally, Octon still runs authority binding, classification, support reconciliation, capability posture, context-pack request, risk classification, rollback planning, and run-contract candidate generation.

## Why not build mission runner first

Mission runner work depends on the outputs of this compiler. Long-horizon autonomy must be backed by Project Profile, Objective Brief, Work Package, support posture, capability posture, evidence profile, and Decision Requests. Building mission continuation first would risk creating an infinite-agent loop without safe initial work shaping.

The same reasoning applies to Autonomy Window and effectful connector work.
They remain part of the target lifecycle, but this v1 packet only preserves
the hooks needed for later mission-runner and connector admission work.
