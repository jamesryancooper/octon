# State Continuity

`state/continuity/**` stores active resumable work state for the live
repository.

## Canonical Continuity Surfaces

| Path | Purpose |
| --- | --- |
| `state/continuity/repo/**` | Repo-wide and cross-scope active work state |
| `state/continuity/scopes/<scope-id>/**` | Stable single-scope active work state |
| `state/continuity/engagements/<engagement-id>/**` | Engagement compiler resumability and handoff state derived from engagement control and retained preparation evidence |
| `state/continuity/runs/<run-id>/**` | Run resumability, handoff, and operator continuity state derived from canonical run control and evidence roots |

Detailed work state has one primary home. Cross-scope work belongs in repo
continuity. Stable single-scope work belongs in the matching scope continuity
surface.

Continuity consumes canonical run evidence and lifecycle state. It does not
replace `state/control/execution/runs/**` or `state/evidence/runs/**` as the
execution-time source of truth.

Engagement continuity consumes engagement control and preparation evidence. It
does not replace `state/control/engagements/**` or any retained evidence root
as readiness authority.
