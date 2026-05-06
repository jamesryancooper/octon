# Runtime Integration Plan

## Orchestrator Responsibilities

The single accountable orchestrator may:

- create a MissionPlan candidate
- select branches for decomposition
- run duplicate, dependency, staleness, and readiness checks
- compile ready leaves into action-slice candidates
- request context packs
- request authorization
- update plan state from retained evidence
- escalate conflicts, missing approvals, and drift

The orchestrator may not:

- use a plan as authority
- bypass run contracts
- bypass Context Pack Builder
- bypass `authorize_execution`
- treat generated plan views as control truth
- treat proposal packets or raw inputs as runtime dependencies
- declare consequential completion without evidence-store completeness

## Mission And Run Binding

The mission remains the continuity container. Consequential execution remains
bound to per-run contracts under:

```text
.octon/state/control/execution/runs/<run-id>/**
```

Planning artifacts may link to runs and action-slice candidates, but run
contracts and run journals remain canonical for execution.

## Context Pack Construction

Context packs may include:

- mission charter and mission digest
- MissionPlan control refs
- selected PlanNode refs
- DependencyEdge refs
- action-slice candidate
- run-contract draft
- risk and rollback refs
- support-target tuple refs
- required evidence refs
- approval refs

The pack must preserve source classes and must not classify proposal or
generated artifacts as authority.

## Authorization Boundary

Plan leaves produce authorization requests, never authorization grants. All
material effects still require `authorize_execution`, `GrantBundle`, typed
`AuthorizedEffect<T>`, `VerifiedEffect<T>`, receipts, and journal coverage.

## Support-Target Admission

Plan nodes may cite required support-target tuple refs and identify support
questions. They cannot admit capabilities, widen support targets, or convert a
stage-only tuple into a live support claim.

## Evidence Capture

Consequential planning transitions should retain evidence for plan creation,
decomposition, critic review, duplicate check, dependency check, readiness
check, compile, approval, drift, revision, and closeout.

Run evidence remains under `state/evidence/runs/**`. Planning evidence remains
under `state/evidence/control/execution/planning/**`.

## Replay And Rollback

Replay reconstructs execution from the Run Journal first. The plan may explain
why a run existed, but it cannot become replay authority. Rollback truth
remains in run control and run evidence; planning rollback updates only the
derived status and linked planning evidence.
