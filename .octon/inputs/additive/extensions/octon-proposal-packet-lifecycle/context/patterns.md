# Reusable Lifecycle Patterns

## Lifecycle State Machine

Routes move through explicit packet or program states and stop at `blocked`,
`needs-packet-revision`, `superseded`, or `explicitly-deferred` when the next
transition is unsafe.

## Route Dispatcher

The composite dispatcher selects a leaf bundle from source kind, proposal kind,
lifecycle action, packet path, current lifecycle state, and user constraints.
Explicit route ids win only when they are supported.

## Packet Support Artifact Placement

Source lineage belongs in packet `resources/**`. Generated operational prompts
belong in packet `support/**`. These artifacts are retained aids and must not
claim authority.

## Finding To Correction

Verification findings must include stable ids, severity, affected paths,
evidence, expected behavior, correction scope, acceptance criteria, and
deferral eligibility. Correction prompts target one finding or a justified
finding group.

## Convergence Loop

Verification and correction repeat until `clean`, `blocked`,
`needs-packet-revision`, `superseded`, or `explicitly-deferred`.

## Closeout Gate

Closeout verifies proposal promotion or archival, registry regeneration when
safe, intended staging, green required checks, resolved review conversations,
retained evidence, branch cleanup posture, and sync state before declaring
closeout-ready.

## Evidence Receipt

Every route records route inputs, selected route, source or packet path,
generated artifacts, commands, validation results, findings, correction status,
and final verdict in existing Octon evidence roots.

## Composition First

Prefer existing proposal workflows, validators, concept-integration routes,
impact mapping, drift triage, hygiene packetization, extension publication,
capability publication, and host projection publishing over duplicate logic.

## Authority Firewall

Prompts, generated support artifacts, proposal packets, generated registries,
GitHub, CI, labels, comments, chat, browser state, tool availability, and model
memory never become Octon authority, control truth, runtime policy, or
permission.

## Scenario Fixtures

Manual prompt classes are represented as fixtures and validation expectations,
not copied as canonical prompt text.

## Proposal Program

The full Proposal Program pattern lives in `context/patterns/proposal-program.md`.
