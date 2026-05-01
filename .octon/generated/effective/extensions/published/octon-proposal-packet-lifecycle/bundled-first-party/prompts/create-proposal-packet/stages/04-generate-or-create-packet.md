# Generate Or Create Packet

Materialize the proposal packet at the canonical active path:

```text
.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/
```

The packet must include `proposal.yml`, exactly one subtype manifest,
`README.md`, navigation docs, subtype-required working docs, source resources,
support artifacts when generated, validation plan, acceptance criteria, and a
clear exit expectation.

For architecture packets, include the artifact floor from the shared lifecycle
artifact contract unless the selected scope makes an item irrelevant and the
omission is recorded. Preserve complete audit, evaluation, or target-thesis
material under `resources/**`; add a traceability map from each source finding,
gap, score limiter, or selected-step blocker to the remediation artifact,
implementation action, acceptance criterion, validation command, and closure
condition that addresses it.

For audit-aligned packets, require zero unresolved source findings as the
target closure condition unless the packet explicitly records a rejected,
superseded, or deferred finding with owner and rationale. For
architecture-evaluation packets, translate score targets into concrete changes
across only the materially affected architecture dimensions. For
highest-leverage-next-step packets, inspect the live repo before selecting the
step, choose one bounded prerequisite or implementation target, and reject
scope expansion into later packets unless the selected step cannot be correct
without it.

When the source asks for a clean-break or big-bang migration, model it as an
atomic proposal implementation plan with explicit preconditions, cutover steps,
rollback posture, post-migration validation, and closure certification. Do not
create intermediate live states, generated/input authority, connector/tool
authority, external-dashboard authority, or any rival control plane.
