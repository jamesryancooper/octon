# BOOTSTRAP.md

## Purpose

One-time bootstrap checklist after dropping `.harmony/` into a repository.

## Steps

1. Run `.harmony/scaffolding/_ops/scripts/init-project.sh` (or `/init`) to generate project-level bootstrap files.
   - Optional interop bootstrap: add `--with-agent-platform-adapters` (and optionally `--agent-platform-adapters <csv>`).
2. Verify `.harmony/agency/manifest.yml` has the correct `default_agent` for this repository.
3. Customize `.harmony/scope.md` and `.harmony/conventions.md` for repo-specific boundaries and standards.
4. Review `.harmony/START.md` and `.harmony/catalog.md` for boot flow, commands, and workflows.
5. Run `.harmony/init.sh` from `.harmony/` to validate harness integrity.

## Completion

Delete this file once onboarding is complete, or keep it as a reusable checklist for future repo bootstrap events.
