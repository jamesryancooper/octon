# Mission Autonomy Runtime v2 for Full Drop-In Governed Autonomy

## Purpose

This packet defines the v2 architecture proposal for:

> **Autonomy Window + Mission Runner + Multi-Run Continuation + Mission Queue + Continuation Decisions + Mission-Level Evidence + Mission-Aware Decision Requests + Limited Connector Admission Hooks**

The guiding principle is:

> **v1 makes Octon safe to start. v2 makes Octon safe to continue.**

## Baseline and implementation status

This v2 packet assumes and now consumes the v1 surfaces introduced by
`engagement-project-profile-work-package-compiler-v1`:

- `Engagement`
- `Project Profile`
- `Work Package`
- `Decision Request`
- `Evidence Profile`
- `Preflight Evidence Lane`
- stage-only `Tool/MCP Connector Posture`
- first governed run-contract candidate generation

Implementation promotion has added the v2 mission continuation layer to durable
runtime, governance, control, evidence, continuity, and validation surfaces. No
v1 compatibility shim was needed for the live validation path because the v1
Engagement and Work Package surfaces exist under
`/.octon/state/control/engagements/engagement-compiler-v1-validation/**`.

## Non-authority notice

This proposal lives under `/.octon/inputs/exploratory/proposals/**` and is non-canonical lineage. It is not runtime authority, policy authority, support authority, evidence, or a control plane. Durable implementation has been promoted to the targets named in `proposal.yml`.

## Read order

1. `navigation/source-of-truth-map.md`
2. `resources/repository-baseline-audit.md`
3. `resources/v1-dependency-and-compatibility-shims.md`
4. `resources/architecture-evaluation.md`
5. `resources/primitive-decision-record.md`
6. `architecture/current-state-gap-map.md`
7. `architecture/target-architecture.md`
8. `architecture/mission-runner-sequence.md`
9. `architecture/runtime-cli-shape.md`
10. `architecture/safety-gates.md`
11. `architecture/implementation-plan.md`
12. `architecture/validation-plan.md`
13. `architecture/acceptance-criteria.md`
14. `architecture/cutover-checklist.md`
15. `architecture/rollback-plan.md`
16. `architecture/promotion-readiness-checklist.md`

## Executive target

Move Octon from:

> A governed Engagement exists, the project has been profiled, the objective has been shaped, a Work Package has been compiled, and a first governed run-contract candidate can be authorized or blocked.

To:

> Octon can continue working across a bounded mission, one governed run at a time, under an active Autonomy Window, mission-control lease, budget, circuit breakers, support posture, capability posture, context freshness, rollback posture, evidence requirements, and Decision Request gates until mission closure.

## Non-negotiables

- Missions do not replace run contracts.
- Mission Queue does not replace run lifecycle.
- Mission Run Ledger does not replace per-run journals.
- Continuation Decisions do not replace execution authorization.
- Autonomy Window does not override support targets, policy, capability admission, or material-effect authorization.
- Generated summaries, host UI, comments, labels, dashboards, chat, and `inputs/**` do not become authority.
