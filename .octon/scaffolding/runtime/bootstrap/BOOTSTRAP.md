# BOOTSTRAP.md

## Purpose

One-time bootstrap checklist after dropping `.octon/` into a repository.

## Steps

1. Run `.octon/scaffolding/runtime/_ops/scripts/init-project.sh` (or `/init`) to generate project-level bootstrap files and the repo objective contract.
   - Use `--list-objectives` to inspect common use cases or `--objective <id>` for scripted bootstrap.
   - Optional interop bootstrap: add `--with-agent-platform-adapters` (and optionally `--agent-platform-adapters <csv>`).
2. Verify `.octon/agency/manifest.yml` has the correct `default_agent` for this repository.
3. Customize `.octon/AGENTS.md`, `.octon/OBJECTIVE.md`, `.octon/scope.md`, and `.octon/conventions.md` for repo-specific objectives, boundaries, and standards.
4. Review `.octon/START.md` and `.octon/catalog.md` for boot flow, commands, and workflows.
5. Run `.octon/init.sh` from `.octon/` to validate harness integrity.

## Completion

Delete this file once onboarding is complete, or keep it as a reusable checklist for future repo bootstrap events.
