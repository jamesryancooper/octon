# Watcher Authoring Standards

These standards govern canonical orchestration authoring under
`/.harmony/orchestration/runtime/watchers/`.

## Scope

Applies to watcher definitions, scaffolds, validators, and authoring workflows.

## Standards

1. Keep definition family authority explicit.
   - `watcher.yml` owns identity, lifecycle, runner mode, and cursor posture.
   - `sources.yml` owns monitored-source declarations.
   - `rules.yml` owns detection rules.
   - `emits.yml` owns allowed emitted event types and routing-hint permissions.
2. Keep watchers as detectors only.
   - Watchers may emit events and suggest routing hints.
   - Watchers may not launch workflows directly.
3. Keep mutable state in `state/`.
   - `cursor.json`, `health.json`, and `suppressions.json` are runner-owned
     state only.
   - Event lineage is separate from watcher mutable state.
4. Keep event contracts explicit.
   - Every rule `event_type` must resolve to an emitted-event declaration.
   - Routing hints may appear only when allowed by `emits.yml`.

## Checklist

- [ ] `watcher.yml`, `sources.yml`, `rules.yml`, and `emits.yml` exist.
- [ ] Every rule references declared `source_id` values.
- [ ] Every rule `event_type` is declared in `emits.yml`.
- [ ] Watchers do not launch workflows directly.
- [ ] `state/` remains subordinate mutable state.
