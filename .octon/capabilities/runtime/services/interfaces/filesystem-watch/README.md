# Filesystem Watch Service

Native-first, OS-agnostic watcher hints for filesystem change detection.

## Purpose

- Provide polling-based change hints without requiring platform-specific file watcher APIs.
- Persist deterministic watcher cursor state in runtime state files.
- Persist a bounded sampled state map (not full-repo state) to avoid oversized runtime writes.
- Keep watch concerns separate from snapshot build and discovery query services.

## Operations

- `watch.poll` - scan a bounded filesystem scope, diff against previous cursor state, and emit changed paths.

## Notes

- This service is intentionally polling-based to preserve portability.
- It complements `filesystem-snapshot` and `filesystem-discovery`; it does not replace deterministic snapshots.
