# ACP Operation Classes (taxonomy)

This document defines the **currently enforced operation classes** for ACP evaluation.

Wrappers and runtime gateways should emit `operation.class` using these values.
ACP policy rules match on `operation.class` (and optionally target metadata like
branch/path/env). If a class is not listed here, it is not part of the active
contract and should be treated as an extension candidate.

## Repo / Git

- `git.commit` — creating a commit on a non-protected branch
- `git.merge` — promoting a branch into another (including PR merge)
- `ci.workflow_edit` — changes under `.github/` or CI workflow controls

## Filesystem / Workspace

- `fs.write` — writing files (non-protected, reversible via git)
- `fs.soft_delete` — move-to-trash + manifest
  - `target.scope=local` -> ACP-1 (reversible local promotion)
  - `target.scope=broad` or missing scope -> ACP-3 (destructive-adjacent guardrails)
- `fs.hard_delete` — hard delete without retention (ACP-4 blocked)

## Runtime / Services

- `service.execute` — generic service-driven promotion path (policy fallback)
- `service.deploy` — promoting a build/deploy (ACP-2+)
- `execution.authorize` — shared execution-governance boundary for material runtime paths

## Database / State

- `db.migrate` — schema migration (ACP-2)
- `db.tombstone` — soft delete records (ACP-3)
- `db.hard_delete` — hard delete records (ACP-4 blocked)

## Resource Lifecycle

- `resource.detach` — detach but retain resource for recovery window
- `resource.finalize_destroy` — finalize destroy (ACP-4)

## Aliases (deprecated)

- `repo.modify_ci` — alias of `ci.workflow_edit`

## Target Metadata (optional)

Wrappers SHOULD include metadata so policy can bump ACP when targets are protected.

- `target.branch`: `main`, `production`, etc.
- `target.path`: file/glob path(s)
- `target.env`: `dev`, `staging`, `prod`
- `target.system`: `github`, `aws`, `k8s`, etc.
- `target.scope`: `local` or `broad` (used by `fs.soft_delete`)

## Extension Guidance

- Prefer extending taxonomy with a new namespace rather than reusing existing names.
  Example: `payments.db.migrate` instead of overloading `db.migrate`.
- Keep `operation.class` stable; add nuance via `operation.params` or `target.*`.
