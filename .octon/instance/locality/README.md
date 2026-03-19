# Locality

`/.octon/instance/locality/` is the canonical repo-instance home for
root-owned locality authority.

## Purpose

- keep locality under `instance/**` as durable authored authority
- define one scope registry and one per-scope manifest contract
- separate authored locality inputs from compiled effective locality outputs
  and mutable quarantine state

## Layout

```text
.octon/instance/locality/
  README.md
  manifest.yml
  registry.yml
  scopes/
    <scope-id>/
      scope.yml
```

## Boundary Rules

- `manifest.yml`, `registry.yml`, and `scopes/<scope-id>/scope.yml` are the
  only authored locality authority surfaces.
- canonical `scope.yml` schema contract:
  `/.octon/framework/cognition/_meta/architecture/instance/locality/schemas/scope.schema.json`
- v1 permits exactly one `root_path` per `scope_id`.
- v1 permits zero or one active scope for any target path.
- Generated effective locality outputs belong under
  `/.octon/generated/effective/locality/**`.
- Mutable locality quarantine state belongs under
  `/.octon/state/control/locality/**`.
- Descendant-local `.octon/` roots, hierarchical scope inheritance,
  ancestor-chain composition, and multi-root scopes are invalid in v1.
