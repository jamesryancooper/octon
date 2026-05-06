# Governance And Approval Plan

## Agent-Owned Work

Within granted scope, an agent may:

- draft a MissionPlan candidate
- draft workstreams, dependencies, risks, assumptions, and decision points
- suggest branch decomposition
- run duplicate, dependency, staleness, and readiness checks
- compile low-risk ready leaves into action-slice candidates
- prepare run-contract drafts
- prepare approval requests
- update plan status from retained run evidence

## Human-Owned Work

Human governance must approve:

- mission creation or mission scope changes
- strategic goal changes
- risk ceiling changes
- protected-zone mutation
- support-target widening
- capability admission
- external effects
- destructive or irreversible actions
- high-risk workstream activation
- plan mutation that changes mission scope after execution begins
- completion declaration for consequential work

## Approval Thresholds

| Threshold | Rule |
| --- | --- |
| ACP-0 or ACP-1 | Agent may decompose and stage; material effects still require authorization. |
| ACP-2 | Agent may decompose; human approval is required before activation if scope, risk, or support changes. |
| ACP-3 | Human approval is required before compile-to-run. |
| ACP-4, destructive, or irreversible | Human approval is required before decomposition beyond risk and decision mapping. |

## Ownership Receipts

Plan creation and compile receipts should record:

- mission owner ref
- orchestrator ref
- approval refs when required
- support-target tuple refs
- risk ceiling
- action-class constraints
- evidence root refs
- rollback or compensation refs

Missing ownership or approval evidence routes to stage-only, escalation, or
deny according to the constitutional fail-closed rules.
