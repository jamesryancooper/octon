# Acceptance Criteria

- A generated effective extension skill registry surface exists or the existing
  effective catalog carries validated structured skill metadata equivalent to a
  registry view.
- `publish-extension-state.sh` emits that metadata from extension
  `skills/registry.fragment.yml`.
- `validate-extension-publication-state.sh` verifies the metadata and fails
  closed on drift.
- `publish-capability-routing.sh` can rely on generated extension metadata for
  extension skill registry facts instead of rediscovering raw pack registry
  content.
