# Progress Log

## 2025-12-10

**Session focus:** Initial setup and refinement of .workspace structure

**Completed:**

- Created minimal `START.md` with boot sequence
- Created `scope.md` with boundaries for root workspace
- Created `conventions.md` with style rules
- Set up `progress/` directory with log.md and tasks.json
- Created `checklists/complete.md` with quality gates
- Moved verbose README to `.humans/README.md` (preserved for humans)
- Created `prompts/` with `evaluate-workspace.md`
- Established flat, agent-facing structure with dot-prefix ignore convention

**Next:**

- Create `workflows/`, `commands/`, `context/`, `templates/`, `examples/` directories
- Populate with initial content
- Test the harness with actual agent sessions

**Blockers:**

- None

## 2025-12-10 (session 2)

**Session focus:** Evaluate and refine .workspace structure

**Completed:**

- Ran `evaluate-workspace.md` prompt against `.workspace/`
- Removed redundant failure modes from `START.md` (duplicated in `complete.md`)
- Moved terminology definitions from `conventions.md` to `.humans/README.md`
- Corrected progress log to reflect actual state
- Created `context/` directory with:
  - `tools.md` — Tool inventory and selection guide
  - `compaction.md` — Long session strategy
- Created `commands/` directory with:
  - `recover.md` — Error recovery procedures
- Created `init.sh` — Bootstrap/health check script

**Next:**

- Test workspace scaffolding with `/create-workspace` command
- Add examples to `examples/` directory

**Blockers:**

- None

## 2026-01-13

**Session focus:** Extract shared components to `.harmony/` foundation

**Completed:**

- Created `.harmony/` directory with shared infrastructure
- Moved generic components: assistants, templates, workflows, commands, context, checklists, prompts, skills, examples
- Updated symlinks in `.claude/`, `.codex/`, `.cursor/` to point to `.harmony/skills/`
- Updated all 12 `.cursor/commands/*.md` files to reference `.harmony/`
- Updated `.cursor/rules/*.md` files with new paths and globs
- Implemented split registries: `.harmony/skills/registry.yml` (definitions) + `.workspace/skills/registry.yml` (mappings)
- Added inheritance section to `.workspace/START.md`
- Created stub READMEs in `.workspace/` for override points and discoverability
- Updated `docs/architecture/workspaces/README.md` with two-layer architecture
- Updated `CLAUDE.md` to reference both `.harmony/` and `.workspace/` skills
- Created `.workspace/decisions/` directory for full ADRs
- Documented decision as ADR-001 in `.workspace/decisions/001-harmony-shared-foundation.md`

**Next:**

- Test workspace creation with updated templates from `.harmony/`
- Verify skills invocation works with new symlink structure

**Blockers:**

- None

## 2026-01-13 (session 2)

**Session focus:** Consolidate human-led directories into single `.scratchpad/` zone

**Completed:**

- Removed `.humans/` directory concept (agent-first philosophy; access tracked in frontmatter if needed)
- Consolidated `.inbox/` and `.archive/` into `.scratchpad/` as subdirectories
- Updated all documentation in `docs/architecture/workspaces/`:
  - `README.md` — Updated structure diagrams
  - `dot-files.md` — Rewritten for single `.scratchpad/`
  - `scratchpad.md` — Updated with subdirectory structure
  - `context.md` — Fixed old references
  - `missions.md` — Clarified mission-specific archive
- Updated `.workspace/` files:
  - `START.md` — Updated structure and visibility rules
  - `context/glossary.md` — Consolidated terminology
  - `context/constraints.md` — Single human-led zone rule
  - `context/lessons.md` — Updated references
  - `context/decisions.md` — Added D003, D005, D008; superseded D006
  - `conventions.md` — Updated references
  - `catalog.md` — Updated archive reference
  - `missions/README.md` — Clarified mission archive path
  - `.scratchpad/README.md` — Updated for consolidated structure
- Updated `.harmony/` shared foundation:
  - Checklists (complete.md, session-exit.md)
  - All workspace workflows (evaluate, update, migrate)
  - Templates (conventions.md, done.md)
  - Removed obsolete `.humans/` directory from templates
- Created physical structure:
  - `.workspace/.scratchpad/inbox/` and `.workspace/.scratchpad/archive/`
  - Moved content from old directories
  - Removed empty old directories
- Created ADR-002: Consolidated .scratchpad/ Human-Led Zone

**Decisions made:**

- D003: Human-led zone — Single `.scratchpad/` directory (updated)
- D005: Human-led collaboration — `.scratchpad/` only (updated)
- D008: Consolidated human zones — Subdirectories within `.scratchpad/` (new)
- D006: Superseded by D008

**Next:**

- Test workspace creation with updated templates
- Verify documentation consistency across all files

**Blockers:**

- None

## 2026-01-13 (session 3)

**Session focus:** Rename `.scratch/` to `.scratchpad/` for explicitness

**Completed:**

- Renamed `.workspace/.scratch/` directory to `.workspace/.scratchpad/`
- Renamed `.workspace/workflows/scratch/` to `.workspace/workflows/scratchpad/`
- Renamed `.harmony/workflows/promote-from-scratch.md` to `promote-from-scratchpad.md`
- Renamed `docs/architecture/workspaces/scratch.md` to `scratchpad.md`
- Renamed ADR file to `002-consolidated-scratchpad-zone.md`
- Updated all references across ~50 files:
  - `.cursor/commands/` and `.cursor/rules/`
  - `.harmony/` checklists, workflows, templates, skills, prompts
  - `.workspace/` context, conventions, catalog, START.md
  - `docs/architecture/workspaces/`

**Decisions made:**

- D009: Human-led zone naming — `.scratchpad/` over `.scratch/` for explicitness

**Rationale:**

`.scratchpad/` is more explicit and self-documenting than `.scratch/`, making the purpose clearer for newcomers while maintaining the consolidated human-led zone architecture.

**Next:**

- Test workspace creation with updated templates
- Verify all symlinks and cross-references work correctly

**Blockers:**

- None

---

## 2025-12-10 (session 3)

**Session focus:** Create workspace scaffolding system

**Completed:**

- Created `workflows/create-workspace.md` — orchestration workflow
- Created `commands/scaffold.md` — atomic scaffolding reference
- Created templates in `templates/`:
  - `START.md`, `scope.md`, `conventions.md`
  - `complete.md`, `log.md`, `tasks.json`
- Created Cursor slash command `.cursor/commands/create-workspace.md`
- Created Cursor slash command `.cursor/commands/evaluate-workspace.md`
- Documented both commands in `.humans/README.md`
- Enhanced `/create-workspace` with context-aware customization:
  - Directory analysis (type detection, pattern recognition)
  - User context gathering (scope, boundaries, quality checks)
  - Smart template customization based on context
- Created examples in `examples/`:
  - `create-workspace-flow.md` — Complete walkthrough
  - `workspace-node-ts/` — Node/TypeScript project example
  - `workspace-docs/` — Documentation project example

**Next:**

- Test `/create-workspace` command on a real target directory

**Blockers:**

- None

---

## 2026-01-14

**Session focus:** Elevate projects to workspace level and introduce idea funnel

**Completed:**

- Elevated `projects/` from `.scratchpad/projects/` to `.workspace/projects/`
  - Created `README.md` with comprehensive documentation
  - Created `registry.md` for project tracking
  - Created `_template/` with project templates
  - Created `.workspace/workflows/projects/create-project.md`
- Introduced `.scratchpad/brainstorm/` as filter stage between ideas and projects
  - Created `README.md` with template for single-file explorations
  - Brainstorms use frontmatter status: `exploring | graduated | killed | parked`
- Established "The Funnel" — clear pipeline from ideas to permanent knowledge:
  - `.scratchpad/ideas/` → Quick captures (most die here)
  - `.scratchpad/brainstorm/` → Structured exploration (filter stage)
  - `projects/` → Committed research (produces artifacts)
  - `missions/` → Committed execution
  - `context/` → Permanent knowledge
- Updated all documentation across multiple directories:
  - `.workspace/` files: START.md, catalog.md, agent-autonomy-guard.globs, context/glossary.md
  - `.workspace/.scratchpad/` files: README.md, ideas/README.md, inbox/README.md
  - `.workspace/skills/registry.yml` — Updated input paths
  - `docs/architecture/workspaces/` — README.md, scratchpad.md, projects.md, dot-files.md, workflows.md, taxonomy.md, skills.md
  - `.harmony/` — prompts/research/*.md, skills/research-synthesizer/*.md, workflows, templates
  - `.cursor/commands/` — research.md, use-skill.md, synthesize-research.md
- Created ADR-003: Projects Elevation and Idea Funnel
- Updated `context/decisions.md` with D010, D011, D012; updated D003, D005, D008

**Decisions made:**

- D010: Projects location — Workspace level (`projects/`), not `.scratchpad/`
- D011: Brainstorm stage — Single-file exploration before projects
- D012: The Funnel — Pipeline from ideas to context
- Updated D003, D005, D008 to reflect new structure

**Rationale:**

Projects have significant structure (registry, templates, lifecycle) and frequently produce artifacts that feed `context/`, `missions/`, and other workspace areas. Keeping them in `.scratchpad/` created unnecessary promotion friction. The new structure allows direct artifact flow while maintaining human-led access control.

**Next:**

- Test project creation workflow with updated templates
- Verify funnel documentation is discoverable

**Blockers:**

- None
