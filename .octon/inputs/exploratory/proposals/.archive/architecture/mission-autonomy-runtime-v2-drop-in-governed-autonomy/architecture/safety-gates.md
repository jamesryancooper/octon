# Safety and Governance Gates

## Lease Gate

No autonomous continuation without an active, unexpired, scoped mission-control lease.

## Budget Gate

- `healthy`: continuation allowed if all other gates pass.
- `warning`: narrow, checkpoint, or emit Decision Request.
- `exhausted`: pause or escalate.

## Circuit-Breaker Gate

No continuation while a breaker is `tripped` or `latched`.

Trip reasons include repeated validation failure, repeated authorization denial, repeated run failure, support posture drift, connector posture drift, stale context, rollback posture loss, evidence emission failure, unexpected material side-effect attempt, budget exhaustion, and unresolved high-priority Decision Request.

## Context Freshness Gate

Each governed run must have a valid run-bound context pack. Mission continuation must also detect stale Project Profile, stale Work Package, stale support posture, stale capability posture, branch drift, queue drift, and prior-run assumption drift.

## Connector Drift Gate

No connector operation may execute when connector posture, operation schema, support posture, egress, credential class, capability mapping, evidence obligations, or rollback posture have drifted.

## Progress Gate

Stop or escalate if no Action Slice can be selected, the same slice fails repeatedly, validation cannot pass, the queue churns without reducing work, success criteria cannot be evaluated, the mission appears unreachable, or the agent expands scope merely to keep working.

## Closeout Gate

Mission closure requires all relevant runs terminal, run-level closeout complete, mission success/failure criteria satisfied or accepted, mission queue resolved, mission-level evidence complete, replay/disclosure status known, rollback/compensation disposition known, continuity updated, and no unresolved blocking Decision Requests.
