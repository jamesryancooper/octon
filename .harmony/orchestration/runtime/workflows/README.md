# Workflows

All workflows live in `.harmony/orchestration/runtime/workflows/`, organized by group.

**Discovery:** Read `manifest.yml` for workflow index (Tier 1). After matching, read `registry.yml` for extended metadata (Tier 2). Then load `WORKFLOW.md` when a workflow is activated.

## Execution Profiles

Workflow entries may declare `execution_profile` in `manifest.yml`:

- `core` (default): only harness-minimal runtime assumptions.
- `external-dependent`: may require external binaries or project-root I/O outside `.harmony/`.

Use `.harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh` to validate profile boundaries and manifest path parity.

## Composition Boundaries

Workflows are one part of the composition model:

- **Composite Skill** (`.harmony/capabilities/runtime/skills/composite-skills.md`):
  reusable skill bundle with a stable command and contract.
- **Workflow** (this directory):
  ordered procedural execution with staged checkpoints.
- **Team** (`.harmony/agency/runtime/teams/`):
  actor topology and handoff policy.

Use workflows when execution order and checkpoint structure are primary.
Use Composite Skills when reusable capability bundling is primary.
Teams may standardize which workflows and composite skills are used.

## Workflow Groups

- `meta/` — Harness management (create, evaluate, migrate, update) and meta-workflows (create, evaluate, update workflow/skill)
- `audit/` — Audit orchestration and release gates (orchestrate-audit, pre-release-audit, change-risk-audit, continuous-audit, post-incident-audit, release-readiness-audit, documentation-audit)
- `refactor/` — Verified structural refactor orchestration (refactor)
- `foundations/` — Stack-specific project scaffolding (python-api, swift-macos-app)
- `missions/` — Mission lifecycle (create, complete)
- `projects/` — Project creation
- `ideation/` — Scratchpad content promotion
- `tasks/` — Guided operational playbooks (single-file workflows)
