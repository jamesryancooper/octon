# Architecture Proposal: Mission Autonomy Runtime v2

## Decision

Adopt **Mission Autonomy Runtime v2** as the second implementation wave for Octon's drop-in governed autonomy lifecycle, assuming the v1 Engagement / Project Profile / Work Package compiler layer exists.

v2 implements a mission-scoped continuation runtime that consumes a v1 Work Package and produces bounded governed runs under an active Autonomy Window.

## Architectural rule

The Mission Runner is an orchestrator over existing governed execution. It may compile or refresh run-contract candidates, but it may not mutate the repo, invoke services, drive tools, or continue a mission outside the existing engine-owned authorization boundary.

## Target primitives

- Autonomy Window
- Mission Runner
- Mission Queue
- Action Slice operationalization
- Continuation Decision
- Mission Run Ledger
- Mission Evidence Profile
- Mission-Aware Decision Request
- Limited Connector Admission

## Direct architectural value

v1 makes Octon safe to start; v2 makes Octon safe to continue. v2 is the missing bridge from first-run readiness to bounded multi-run mission completion.
