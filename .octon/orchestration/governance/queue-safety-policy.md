# Queue Safety Policy

Canonical safety policy for the shared orchestration queue.

## Scope

Applies to the queue surface under `/.octon/orchestration/runtime/queue/`.

## Policy Rules

1. Queue ingress is automation-only.
2. Queue lane transitions must be deterministic and serialized per queue item.
3. Claims require `claim_token` and `claim_deadline`.
4. Stale acknowledgement or release attempts are rejected and recorded.
5. Dead-letter is the terminal quarantine path for exhausted or non-retryable
   items.

## Boundary

- Queue state coordinates automation ingress only.
- Queue is not a mission planner, workflow definition surface, or policy
  authoring surface.
