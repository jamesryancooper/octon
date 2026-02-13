# Workflows

All workflows live in `.harmony/orchestration/workflows/`, organized by group.

**Discovery:** Read `manifest.yml` for workflow index (Tier 1). After matching, read `registry.yml` for extended metadata (Tier 2). Then load `WORKFLOW.md` when a workflow is activated.

## Workflow Groups

- `meta/` — Harness management (create, evaluate, migrate, update) and meta-workflows (create, evaluate, update workflow/skill)
- `quality-gate/` — Codebase integrity (refactor, orchestrate-audit)
- `foundations/` — Stack-specific project scaffolding (python-api, swift-macos-app)
- `missions/` — Mission lifecycle (create, complete)
- `flowkit/` — FlowKit LangGraph integration
- `projects/` — Project creation
- `ideation/` — Scratchpad content promotion
- `tasks/` — Guided operational playbooks (single-file workflows)
