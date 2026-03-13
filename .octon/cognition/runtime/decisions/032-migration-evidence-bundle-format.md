# ADR 032: Migration Evidence Bundle Format

- Date: 2026-02-21
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes: Flat migration evidence filename pattern under `output/reports/migrations/`

## Context

Migration evidence was centralized under `output/reports/migrations/` in ADR 031,
but evidence still relied on a single-file format (`*-evidence.md`).

As migration checks became broader, command receipts, validator outcomes, and
artifact inventory details were mixed into one file, which reduced readability
and made machine discovery more brittle.

## Decision

Adopt a canonical migration evidence bundle format:

- Bundle directory location:
  - `/.octon/output/reports/migrations/<YYYY-MM-DD>-<slug>/`
- Required bundle files:
  - `bundle.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`

`bundle.yml` is the machine-readable bundle manifest and must declare:

- `id` matching the bundle directory name
- `kind: migration-evidence-bundle`
- canonical pointers to the required files above

Flat files of the form `/.octon/output/reports/migrations/*-evidence.md` are
removed and prohibited.

## Consequences

### Benefits

- Clear separation of narrative evidence, command receipts, validation receipts,
  and inventory metadata.
- Consistent, machine-checkable bundle structure across migrations.
- Better long-term discoverability and maintainability as migration volume grows.

### Risks

- Existing automation or links targeting flat files can break.
- Missing required bundle files could create partial evidence artifacts.

### Mitigations

- One-shot path and contract updates across docs, templates, and migration index.
- Harness structure validator enforces required bundle files and metadata.
- Legacy banlist explicitly blocks reintroduction of flat evidence filenames.
