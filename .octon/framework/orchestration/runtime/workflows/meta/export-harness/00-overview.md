# Export Harness Overview

This overview exists as the short operator-facing introduction to the
`export-harness` workflow.

For the canonical workflow contract and generated operator guide, use:

- `workflow.yml`
- `README.md`

## Purpose

Materialize `repo_snapshot` or `pack_bundle` exports from the v2 root-manifest
profile contract and fail closed when enabled-pack closure cannot be resolved.

## Entry Command

```text
/export-harness
```

## Stage Order

1. `stages/01-validate-request.md`
2. `stages/02-resolve-profile.md`
3. `stages/03-materialize-export.md`
4. `stages/04-verify-export.md`
