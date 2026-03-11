# Watcher Signal Policy

Canonical policy guidance for watcher-emitted signals.

## Scope

Applies to watcher definitions and emitted watcher events.

## Policy Rules

1. Watchers detect and emit; they do not launch workflows directly.
2. Emitted event types must be declared in watcher `emits.yml`.
3. Routing hints are recommendations only.
4. Emitted payloads must be sanitized.
5. Duplicate detections are expected and must be handled through `dedupe_key`
   and downstream policy, not through silent event mutation.

## Boundary

- Watcher state is runner-owned mutable state.
- Event lineage is the canonical watcher evidence layer.
