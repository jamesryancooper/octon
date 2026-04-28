# v1 Dependency and Compatibility Shims

## Required v1 baseline

Mission Autonomy Runtime v2 assumes v1 provides Engagement, Project Profile, Work Package, Decision Request, Evidence Profile, Preflight Evidence Lane, stage-only Tool/MCP Connector Posture, and first governed run-contract candidate generation.

## Live repository observation after implementation

The live repository now contains the v1 Engagement, Project Profile, Work
Package, Decision Request, Evidence Profile, Preflight Evidence Lane, connector
posture, and first run-contract candidate surfaces. The v2 implementation
consumes the validation Engagement at
`/.octon/state/control/engagements/engagement-compiler-v1-validation/**` and
does not reimplement v1.

## Compatibility shims used

None for the promoted v2 validation path. The v2 runtime fails closed when any
required v1 surface is missing.

## Allowed fail-closed shims

If v2 implementation starts before v1 is fully landed, only these shims are allowed:

1. Read-only compatibility adapter mapping an existing run contract and mission charter into a temporary Work Package view for tests.
2. Prepare-only Engagement stub that cannot authorize execution.
3. Decision Request wrapper over existing approval/exception/revocation roots.
4. Connector posture stub that always returns stage-only or denied.

## Forbidden shims

- Hidden Engagement authority from chat.
- Generated summary as Work Package.
- Mission summary as Work Package authority.
- Run contract as full replacement for v1 Work Package.
- Support-target widening to make v2 pass.
