# Preflight Evidence Lane v1

Preflight Evidence Lane v1 is the narrow preauthorization lane used by the
Engagement / Project Profile / Work Package compiler to collect adoption,
orientation, profile-source, and context-request evidence before ordinary
material execution authorization is available.

The lane is not an execution authority. It may write retained evidence and
engagement control records required to decide whether a first run-contract
candidate can be prepared, but it may not mutate project code, invoke
effectful tools, publish generated/effective outputs, activate capability
packs, use credentials, widen support targets, or perform external side
effects.

## Allowed Records

- adoption classification evidence
- read-only repo inventory and omission records
- per-engagement Objective Brief candidate evidence
- Project Profile source-fact evidence
- Work Package compilation evidence
- context-pack request preparation evidence
- operator-visible diagnostics

## Forbidden Effects

- project code mutation
- arbitrary shell execution
- external API, browser, or MCP effectful invocation
- credential use
- destructive operations
- support-target widening
- governance amendment without approval
- generated/effective publication
- capability-pack activation

## Control And Evidence Placement

- control truth: `/.octon/state/control/engagements/<engagement-id>/**`
- preflight evidence: `/.octon/state/evidence/engagements/<engagement-id>/preflight/**`
- objective evidence: `/.octon/state/evidence/engagements/<engagement-id>/objective/**`
- orientation evidence: `/.octon/state/evidence/orientation/<orientation-id>/**`
- profile source evidence: `/.octon/state/evidence/project-profiles/<profile-id>/source-facts/**`
- run-contract readiness evidence: `/.octon/state/evidence/engagements/<engagement-id>/run-contract-readiness/**`

Generated read models may mirror the result for operators, but they remain
derived-only and must not be consumed as runtime, policy, support, or approval
authority.
