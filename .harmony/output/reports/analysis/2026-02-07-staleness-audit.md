# Post-Migration Staleness Audit Report

**Date:** 2026-02-07
**Scope:** Full codebase scan (257 target files across 12 agent groups)
**Migration:** Two-tier (`.harmony/` + `.workspace/`) → Single capabilities-based `.harmony/`

---

## Executive Summary

**Total stale references found: 29 actionable issues across 13 active files** (all CRITICAL/HIGH now fixed)
**Archive/scratchpad issues: ~80+ references (low priority, documented below)**

The migration was largely successful. Active production files (manifests, skill definitions, START.md, CLAUDE.md) are clean. Stale references concentrated in:
1. A few operational files with incorrect paths (CRITICAL — **FIXED**)
2. Workflow reference files with wrong directory names (HIGH — **FIXED**)
3. Scratchpad/inbox documents with old `.workspace/` references (MEDIUM)
4. Terminology confusion in docs about "two-tier architecture" (LOW)

**Supplemental audit (12 agents total):** 257 files scanned across all agent groups. Supplemental agents confirmed 200+ additional files are clean, including all scaffolding templates (critical — templates generate new workspaces).

---

## CRITICAL — Active Operational Files (ALL FIXED)

These files are used by agents during execution. Incorrect paths cause workflow failures.

### 1. `.harmony/catalog.md` — Broken relative paths (6 instances) — FIXED

Lines 70-72 and 106-108 use `../.harmony/` prefix, which is incorrect for links resolved from within `.harmony/`. Lines 68-69 in the same file correctly use `./` prefix.

| Line | Current | Should Be |
|------|---------|-----------|
| 70 | `[create-workflow.md](../.harmony/capabilities/commands/create-workflow.md)` | `[create-workflow.md](./capabilities/commands/create-workflow.md)` |
| 71 | `[evaluate-workflow.md](../.harmony/capabilities/commands/evaluate-workflow.md)` | `[evaluate-workflow.md](./capabilities/commands/evaluate-workflow.md)` |
| 72 | `[update-workflow.md](../.harmony/capabilities/commands/update-workflow.md)` | `[update-workflow.md](./capabilities/commands/update-workflow.md)` |
| 106 | `[create-workflow](../.harmony/orchestration/workflows/workflows/create-workflow/00-overview.md)` | `[create-workflow](./orchestration/workflows/workflows/create-workflow/00-overview.md)` |
| 107 | `[evaluate-workflow](../.harmony/orchestration/workflows/workflows/evaluate-workflow/00-overview.md)` | `[evaluate-workflow](./orchestration/workflows/workflows/evaluate-workflow/00-overview.md)` |
| 108 | `[update-workflow](../.harmony/orchestration/workflows/workflows/update-workflow/00-overview.md)` | `[update-workflow](./orchestration/workflows/workflows/update-workflow/00-overview.md)` |

### 2. `.harmony/cognition/context/primitives.md` — Stale `.harmony/missions/` paths (3 instances) — FIXED

| Line | Current | Should Be |
|------|---------|-----------|
| 113 | `.harmony/missions/<mission-id>/mission.yml` | `.harmony/orchestration/missions/<mission-id>/mission.yml` |
| 568 | `.harmony/missions/registry.yml` | `.harmony/orchestration/missions/registry.yml` |
| 568 | `.harmony/missions/_template/` | `.harmony/orchestration/missions/_template/` |

### 3. `.harmony/orchestration/workflows/skills(x)/create-skill/05-update-catalog.md` — Old filename convention (2 instances) — FIXED

| Line | Current | Should Be |
|------|---------|-----------|
| 24 | `[<skill-id>](./skills/<skill-id>/skill.md)` | `[<skill-id>](./skills/<skill-id>/SKILL.md)` |
| 32 | `Link to \`skill.md\` is correct` | `Link to \`SKILL.md\` is correct` |

### 4. `.harmony/orchestration/workflows/workspace/create-workspace/07-verify.md` — Old directory name — FIXED

| Line | Current | Should Be |
|------|---------|-----------|
| 19 | `- [ ] progress/ directory initialized` | `- [ ] continuity/ directory initialized` |

---

## HIGH — Active Files With Confusing/Duplicate References (ALL FIXED)

### 5. `.cursor/commands/use-skill.md` — Duplicate registry references (4 instances) — FIXED

The file lists the same registry path twice as if "shared" and "project-specific" are separate.

| Line | Current | Should Be |
|------|---------|-----------|
| 5 | `See .../registry.yml for shared skills and .../registry.yml for project-specific skills.` | `See .../registry.yml for skill definitions and mappings.` |
| 28 | `Read .../registry.yml for shared skill definitions` | Combine steps 1-2 into single step |
| 29 | `Read .../registry.yml for project-specific mappings` | (Remove duplicate) |
| 62-63 | `Shared Registry:` / `Local Registry:` both pointing to same path | Consolidate to single reference |

### 6. `.harmony/cognition/analyses/workflows-vs-skills-analysis.md` — Stale `.harmony/missions/` (4 instances) — FIXED

This is an analysis document (not operational) but is referenced from other active files.

| Line | Current | Should Be |
|------|---------|-----------|
| 604 | `Location: .harmony/missions/` | `Location: .harmony/orchestration/missions/` |
| 820 | `Missions ... .harmony/missions/` | `.harmony/orchestration/missions/` |
| 874 | `.harmony/missions/_template/` | `.harmony/orchestration/missions/_template/` |
| 642 | `# .harmony/missions/auth-migration/mission.yml` | `.harmony/orchestration/missions/auth-migration/mission.yml` |

### 7. `.harmony/orchestration/workflows/workflows/create-workflow/00-overview.md` — Wrong directory names (1 instance) — FIXED

| Line | Current | Should Be |
|------|---------|-----------|
| 95 | `.harmony/orchestration/workflows/refactor/`, `.../skills/create-skill/` | `.harmony/orchestration/workflows/refactor(x)/`, `.../skills(x)/create-skill/` |

### 8. `.harmony/orchestration/workflows/projects/create-project.md` — Broken relative paths (3 instances) — FIXED

| Line | Current | Should Be |
|------|---------|-----------|
| 99 | `[Projects](../../../docs/architecture/workspaces/projects.md)` | `[Projects](../../../../docs/architecture/workspaces/projects.md)` |
| 100 | `[Registry](../../projects/registry.md)` | `[Registry](../../../ideation/projects/registry.md)` |
| 101 | `[Brainstorm](../../ideation/scratchpad/brainstorm/README.md)` | `[Brainstorm](../../../ideation/scratchpad/brainstorm/README.md)` |

### 9. `.harmony/agency/agents/software-architect/audit-agent.md` — Broken markdown link (1 instance) — FIXED

| Line | Current | Should Be |
|------|---------|-----------|
| 3 | `[agent.md](.harmony/agency/agents/software-architect/agent.md)` | `[agent.md](./agent.md)` |

---

## MEDIUM — Scratchpad/Inbox Files (ALL FIXED)

These files are in the ideation zone. Not read by agents during execution, but misleading for humans.

### 10. `.harmony/ideation/scratchpad/inbox/README.md` — 8 stale `.workspace/` references — FIXED

| Line | Current | Should Be |
|------|---------|-----------|
| 28 | `.workspace/projects/` | `.harmony/ideation/projects/` |
| 29 | `.workspace/context/decisions.md` | `.harmony/cognition/context/decisions.md` |
| 30 | `Parent directory (outside .workspace/)` | `Parent directory (outside .harmony/)` |
| 95 | `.workspace/context/decisions.md` | `.harmony/cognition/context/decisions.md` |
| 114 | `.workspace/.scratchpad/README.md` | `.harmony/ideation/scratchpad/README.md` |
| 115 | `.workspace/.scratchpad/brainstorm/README.md` | `.harmony/ideation/scratchpad/brainstorm/README.md` |
| 116 | `.workspace/projects/README.md` | `.harmony/ideation/projects/README.md` |
| 117 | `.workspace/START.md` | `.harmony/START.md` |

### 11. `.harmony/ideation/scratchpad/README.md` — Diagram showing old structure — FIXED

| Line | Current | Should Be |
|------|---------|-----------|
| 33 | `.scratchpad/ ... .workspace/` | `.scratchpad/ ... .harmony/` |

### 12. `.harmony/capabilities/skills/refactor/references/phases.md` — Example uses old paths (4 instances) — FIXED

Lines 246, 304, 335, 525 updated from `.workspace/.scratch/` to `.harmony/ideation/.scratch/` (source paths in refactoring example).

---

## LOW — Terminology/Clarity Issues in Documentation (ALL FIXED)

### 13. `docs/architecture/workspaces/skills/` — "Two-tier architecture" terminology — FIXED

Files updated: `specification.md` (lines 124, 132-147), `README.md` (lines 3, 8, 118-133).

**Fix applied:** Renamed "Two-Tier Architecture" to "Progressive Disclosure" (manifest → registry → SKILL.md → references/). Updated the implementation table from confusing Shared/Workspace tiers pointing to the same location to a clear 4-tier progressive disclosure model. Deduplicated the Key Locations table in README.md.

---

## LOW — Migration Workflow Files (Intentional)

### `.harmony/orchestration/workflows/workspace/migrate-workspace/` (3 instances)

Lines in `00-overview.md` (15, 25, 26) and `01-backup-assessment.md` (3) reference `.workspace` — but this workflow is specifically for migrating old workspaces, so these are intentional. Could be clarified with "legacy" prefix.

---

## OUT OF SCOPE — Archive + History

The following directories contain ~80+ `.workspace/` references but are historical/archived and do not affect operations:

- `.history/` — Conversation logs (not part of workspace)
- `.harmony/ideation/scratchpad/archive/` — Archived analysis documents
- `.harmony/capabilities/skills/archive/v1-archetype-model/` — Archived skill template model
- `.harmony/cognition/decisions/` — ADRs documenting the migration (intentional historical references)

These are left as-is. ADRs in particular should preserve original path references as historical record.

---

## Non-Issues Verified Clean (Full 12-Agent Coverage)

The following file categories were audited across all 12 agent groups and found fully up-to-date:

| Agent | Scope | Result |
|-------|-------|--------|
| 1, 2, 4 | Root, Quality, Cognition, Cursor | Clean (START.md, scope.md, conventions.md, CLAUDE.md, quality/*, cognition/context/*, .cursor/rules/*) |
| 3 | Agency | Clean (agents, assistants, subagents, teams) — 1 minor link fix applied |
| 5 | Capabilities, Registries, Scripts | Clean (manifest.yml, registry.yml, capabilities.yml, all SKILL.md files, commands, init.sh) |
| 6 | Skills References | 14/17 clean; 3 minor clarity issues in error docs (functional) |
| 7 | Workspace Workflows | All 18 files clean (create/evaluate/update-workspace) |
| 8 | Domain Workflows | All 21 files clean (refactor(x), skills(x), flowkit, missions) |
| 9 | Meta-Workflows + Template | 25/28 clean; 3 fixed (create-workflow, create-project, audit-agent) |
| 10 | Scaffolding, Continuity, Ideation | Clean (templates, prompts, examples, continuity, projects) |
| 11 | Template Files (52 files) | **All clean** — templates will NOT propagate stale paths |
| 12 | docs/architecture/ | Clean except "two-tier" terminology (LOW) |
| — | Source code | Clean (`workspaceRoot` is code variable, `uv workspace` is Python tooling) |

---

## Summary by Priority

| Priority | Count | Status |
|----------|-------|--------|
| CRITICAL | 16 | **ALL FIXED** (catalog.md, primitives.md, 05-update-catalog.md, 07-verify.md, create-workflow.md, create-project.md, audit-agent.md) |
| HIGH | 9 | **ALL FIXED** (use-skill.md, workflows-vs-skills-analysis.md) |
| MEDIUM | 13 | **ALL FIXED** (scratchpad/inbox/README.md, scratchpad/README.md, refactor/references/phases.md) |
| LOW | ~6 | **ALL FIXED** (specification.md, skills/README.md — "two-tier" → "progressive disclosure") |
| ARCHIVE | ~80+ | Leave as-is — historical record |
