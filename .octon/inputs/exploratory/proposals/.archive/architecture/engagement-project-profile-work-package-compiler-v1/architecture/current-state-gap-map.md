# Current-State Gap Map

## Existing support in the live repository

| Area | Current repository support | v1 gap |
|---|---|---|
| Super-root and authority model | `.octon/` is the single super-root; `framework/**` and `instance/**` are authored authority; `state/**` splits control/evidence/continuity; `generated/**` is derived; `inputs/**` is non-authoritative. | No product-level Engagement container that compiles adoption/orientation/planning into run readiness. |
| Bootstrap / ingress | `instance/bootstrap/START.md` defines ingress, authority binding, preflight, continuity, and run start path. `instance/ingress/manifest.yml` defines mandatory reads and continuity refs. | No `octon start/profile/plan/arm` flow that materializes a safe adoption-to-run-contract lifecycle. |
| Workspace objective | Workspace charter pair exists; workspace Objective Brief remains the workspace-charter narrative. | The compiler needs only a per-engagement Objective Brief candidate/control record plus charter reconciliation status; it must not rewrite workspace authority. |
| Run lifecycle | Run lifecycle v1 has canonical run roots, states, context-pack requirement, token readiness, and closeout gates. | No first run-contract candidate generator from repo adoption/orientation/planning. |
| Execution authorization | Engine-owned `authorize_execution(request) -> GrantBundle`; typed `AuthorizedEffect` verification required before material effects. | Preflight lane needs explicit safe evidence-write exception with strict no-effect boundaries. |
| Context pack | Builder deterministically produces retained context evidence before authorization. | Work Package needs to prepare context-pack request and bind it to first run candidate without treating Project Profile as runtime authority. |
| Support targets | Support universe is bounded; default-deny and admitted packs constrain live claims. | Work Package must produce support posture and stage/deny non-admitted connectors rather than pretending support is live. |
| Capability packs | Repo/git/shell/telemetry exist as admitted live pack families; API/browser are not v1 live. Connector posture now has machine-readable stage/block/deny policy surfaces. | Connector posture must stay non-admitting and cannot imply live MCP/API/browser support. |
| Evidence / replay / disclosure | Evidence store and run lifecycle require retained evidence, replay/disclosure readiness, rollback posture, and closeout completeness. | Evidence Profile needs to scale required evidence for orientation-only/stage-only/repo-consequential phases. |
| Mission/lease/budget/breaker | Mission charter, mission-control lease, autonomy budget, and circuit-breaker schemas exist. | v1 must not implement mission runner, but Work Package should flag when mission mode is required and block or stage accordingly. |
| CLI | Current CLI is run-first and now also exposes Engagement compiler preparation commands: `start`, `profile`, `plan`, `arm --prepare-only`, `decide`, and `status`. | These commands remain prepare/control surfaces; material execution still enters through `run start --contract`. |

## Core implementation gap

Octon has strong run-level governance but lacks a product-level compiler that prepares the first safe governed run from a newly encountered repo. This proposal fills that gap without expanding live autonomy claims.

## What this proposal does not claim

- It does not make MCP/API/browser effectful autonomy live.
- It does not make missions run unattended.
- It does not broaden support targets.
- It does not let generated projections or proposal-local files become authority.
- It does not bypass execution authorization.
