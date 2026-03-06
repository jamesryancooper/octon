# Scaffolding

Reusable scaffolding assets for harness creation and operating flows.

## Surfaces

| Subdirectory | Surface | Purpose | Index |
|--------------|---------|---------|-------|
| `_meta/architecture/` | Reference metadata | Scaffolding subsystem specification docs | `_meta/architecture/README.md` |
| `runtime/` | Runtime artifacts | Executable scripts and reusable templates consumed by workflows and commands | `runtime/README.md` |
| `governance/` | Governing contracts | Reusable policy and design patterns that constrain scaffolding outputs | `governance/README.md` |
| `practices/` | Operating standards | Prompt templates and reference examples used in day-to-day operation | `practices/README.md` |

## Convention Authority

- Domain-local naming, authoring, and operating conventions belong in `practices/`.
- `_meta/architecture/` is reference architecture, not the canonical conventions surface.
- Cross-domain baseline conventions come from `/.harmony/conventions.md`.

## Interaction Model

**Referenced.** Discover template and prompt assets by task, then route through canonical runtime/governance/practices surfaces.

## Available Templates

Template bundles live under `runtime/templates/`:

| Template | Inherits | Purpose |
|----------|----------|---------|
| `AGENTS.md` | — | Project-level agent bootstrap template rendered by `/init` |
| `BOOT.md` | — | Optional recurring startup checklist template (`/init --with-boot-files`) |
| `BOOTSTRAP.md` | — | Optional one-time bootstrap checklist template (`/init --with-boot-files`) |
| `objectives/` | — | Common objective packs rendered by `/init` into `OBJECTIVE.md` and `intent.contract.yml` |
| `harmony/` | — | Base harness template |
| `harmony-docs/` | `harmony/` | Documentation area harness |
| `harmony-node-ts/` | `harmony/` | Node.js / TypeScript harness |
| `migrations/` | — | Clean-break migration plan and release-notes templates |
