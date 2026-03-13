# ADR 047: Self-Contained Bootstrap And Ingress Adapters

- Date: 2026-03-06
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/AGENTS.md`
  - `/.octon/OBJECTIVE.md`
  - `/.octon/scaffolding/runtime/bootstrap/`
  - `/.octon/scaffolding/runtime/templates/octon/scaffolding/runtime/bootstrap/`
  - `/AGENTS.md`
  - `/CLAUDE.md`

## Context

Octon's bootstrap assets were split across reusable template surfaces and
live bootstrap entrypoints, which created avoidable drift. The human-authored
repo bootstrap governance also lived at repo root even though the harness is
meant to be self-contained under `/.octon/`.

At the same time, external tool discovery and CI still rely on repo-root
ingress files such as `AGENTS.md` and `CLAUDE.md`.

## Decision

Adopt a self-contained bootstrap model with generated ingress adapters.

Rules:

1. Canonical authored bootstrap governance lives under `/.octon/`.
2. Canonical repo-bootstrap assets live under
   `/.octon/scaffolding/runtime/bootstrap/`.
3. Reusable scaffolding templates remain under
   `/.octon/scaffolding/runtime/templates/`.
4. Repo-root `AGENTS.md` and `CLAUDE.md` are ingress adapters to
   `/.octon/AGENTS.md`, preferably symlinks and otherwise byte-identical
   fallback copies.
5. The human-readable objective brief lives only at `/.octon/OBJECTIVE.md`.
6. The base `octon` template carries a generated projection of the bootstrap
   bundle so adopted repositories remain self-contained after scaffold.

## Consequences

### Benefits

- Reduces drift between live bootstrap behavior and projected harness copies.
- Keeps authored bootstrap governance inside the harness boundary.
- Preserves tool and CI discovery through deterministic repo-root adapters.

### Costs

- Adds projection/parity validation work for bootstrap assets.
- Requires active docs and validators to distinguish canonical sources from
  generated ingress files.
