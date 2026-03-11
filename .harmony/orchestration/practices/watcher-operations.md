# Watcher Operations

Operational guidance for watchers under
`/.harmony/orchestration/runtime/watchers/`.

## Scope

Applies to watcher health, cursor management, suppression handling, and
emission safety.

## Operating Rules

1. A watcher in `paused` or `error` must not emit new events.
2. Update watcher health and cursor state only through runner-owned state
   artifacts.
3. Treat emitted events as at-least-once.
   - Duplicate handling belongs to `dedupe_key`, routing, and automation
     idempotency.
4. Keep emitted payloads sanitized.
   - Watchers may link to payload references, but must not emit secrets or
     unsafe raw content.
5. Prefer narrow routing hints.
   - A routing hint is a recommendation, not an authorization grant.

## Failure Posture

- Invalid watcher definitions should block startup or emission.
- Missing rule or emit declarations should fail closed.
- Repeated noisy detections should be handled through suppression windows, not
  by weakening event contracts.
