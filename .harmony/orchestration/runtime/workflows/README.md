# Workflows

All workflows live in `.harmony/orchestration/runtime/workflows/`, organized by group.

Workflows are now generated projection/readability surfaces over the canonical
autonomous contracts in `/.harmony/orchestration/runtime/pipelines/`.

**Discovery:** Read `manifest.yml` for the projection index (Tier 1). After
matching, read `registry.yml` for extended metadata and the backing pipeline
link (Tier 2). Then load `WORKFLOW.md` when a workflow projection is activated.

## Execution Profiles

Workflow entries may declare `execution_profile` in `manifest.yml`:

- `core` (default): only harness-minimal runtime assumptions.
- `external-dependent`: may require external binaries or project-root I/O outside `.harmony/`.

This field is a workflow runtime dependency classification only.
It is not the governance migration profile.

Governance migration profile is tracked separately as `change_profile`:

- `atomic`
- `transitional`

## Execution Controls

Workflow entries in `registry.yml` may declare optional execution controls.

Current machine-readable control:

- `execution_controls.cancel_safe: true|false`

Use this only when cancellation is safe and deterministic for the workflow.
If omitted, Harmony treats `cancel_safe` as `false`.

This field exists for orchestration-time behavior such as automation
`replace` semantics. It is not a scheduling or lifecycle field.

Use `.harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh`
to validate projection integrity, manifest/registry parity, and pipeline drift.

The full workflow-system bounded audit is defined by:

- `.harmony/orchestration/governance/workflow-system-audit-v1.yml`
- `.harmony/orchestration/runtime/workflows/_ops/scripts/audit-workflow-system.sh`

## Composition Boundaries

Workflows are one part of the composition model:

- **Composite Skill** (`.harmony/capabilities/runtime/skills/composite-skills.md`):
  reusable skill bundle with a stable command and contract.
- **Pipeline** (`/.harmony/orchestration/runtime/pipelines/`):
  canonical autonomous execution contract.
- **Workflow** (this directory):
  generated projection/readability layer for humans and slash-facing compatibility.
- **Team** (`.harmony/agency/runtime/teams/`):
  actor topology and handoff policy.

Use pipelines when autonomous execution authority matters.
Use workflows when human-readable staged projection or slash-surface
compatibility is needed.
Use Composite Skills when reusable capability bundling is primary.
Teams may standardize which workflows and composite skills are used.

## Workflow Groups

- `meta/` — Harness management (create, evaluate, migrate, update) and meta-workflows (create, evaluate, update workflow/skill)
- `audit/` — Audit orchestration and release gates (audit-orchestration-workflow, audit-pre-release-workflow, audit-change-risk-workflow, audit-continuous-workflow, audit-post-incident-workflow, audit-release-readiness-workflow, audit-documentation-workflow, audit-design-package-workflow, audit-workflow-system-workflow)
- `refactor/` — Verified structural refactor orchestration (refactor)
- `foundations/` — Stack-specific project scaffolding (python-api, swift-macos-app)
- `missions/` — Mission lifecycle (create, complete)
- `projects/` — Project creation
- `ideation/` — Scratchpad content promotion
- `tasks/` — Guided operational playbooks (single-file workflows)

## Workflow System Audit

Use `audit-workflow-system-workflow` when workflow surfaces change materially and you need a bounded, repeatable audit of the workflow system itself.

- Human/full mode emits a runtime audit plan plus an authoritative bundle under `.harmony/output/reports/audits/`.
- CI/static mode runs through `validate-workflows.sh` and writes only temp artifacts under `.harmony/output/.tmp/workflow-system-audit/`.
