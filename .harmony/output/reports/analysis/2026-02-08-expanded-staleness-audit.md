# Expanded Post-Migration Staleness Audit Report

**Date:** 2026-02-08
**Scope:** Expanded sweep — 250+ additional files across 6 agent groups (beyond the 257-file initial audit)
**Builds on:** [2026-02-07-staleness-audit.md](./2026-02-07-staleness-audit.md) (initial 12-agent sweep)

---

## Executive Summary

**Total new files audited: ~250 across 6 focused agents**
**Total new actionable findings: 53 across 25+ files**

The `.workspace` → `.harmony/` migration and bare flat-structure → capability-organized renaming are **fully clean** across the entire repository. Zero remnants remain in any active file.

However, the expanded audit uncovered **three additional classes of staleness** not covered by the initial sweep:

1. **Broken `docs/` cross-references** (23 findings) — `docs/handbooks/`, `docs/handbook/`, `docs/ai/`, `docs/human/` paths that don't resolve
2. **Cursor command broken paths** (10 findings) — stale directory names, nonexistent output/log directories
3. **Skill `behaviors.md` → `phases.md` rename gap** (4 findings) — all 4 active skills reference `references/behaviors.md` which was renamed to `references/phases.md`

---

## Agent A — docs/ non-architecture (146 files)

**Directories audited:** `docs/services/`, `docs/methodology/`, `docs/engines/`, `docs/pillars/`, `docs/principles/`, `docs/documentation-standards/`, `docs/development/`, `docs/specs/`, `docs/TASKS/`, `docs/purpose/`, `docs/runtimes/`, `docs/practices/`

**Result:** 132 files clean, 14 files with findings (23 total)

### Migration-specific categories: ALL CLEAN
- `.workspace` references: 0
- Bare flat-structure directory names: 0
- Two-root architecture descriptions: 0
- Old terminology: 0

### Broken path references: 23 findings in 4 stale patterns

#### Pattern 1: `docs/handbooks/` (directory does not exist) — 9 occurrences in 4 files

| File | Lines | Current Path | Should Be |
|------|-------|-------------|-----------|
| `docs/methodology/architecture-and-repo-structure.md` | 10, 14, 27, 119 | `docs/handbooks/harmony/architecture/**` | `docs/architecture/` |
| `docs/methodology/.harmony/.index/methodology-review.md` | 12, 16 | `docs/handbooks/harmony/methodology/README.md` | `docs/methodology/README.md` |
| `docs/runtimes/.harmony/.index/*-assessment.md` | 12,33,50,69,246,353,367 | `docs/handbooks/harmony/architecture/**` | `docs/architecture/` |
| `docs/runtimes/.harmony/.index/*-runtime-model.md` | 12, 24 | `docs/handbooks/harmony/architecture/**` | `docs/architecture/` |

#### Pattern 2: `docs/handbook/` (no "s", directory does not exist) — 6 occurrences in 3 files

| File | Lines | Current Path | Should Be |
|------|-------|-------------|-----------|
| `docs/documentation-standards/README.md` | 176 | `docs/handbook/documentation-standards/template` | `docs/documentation-standards/template` |
| `docs/documentation-standards/README.md` | 214, 232 | `docs/handbook/ai-toolkit/...` | `docs/services/...` |
| `docs/documentation-standards/template/README.md` | 3, 24 | `docs/handbook/.../README.md` | `docs/.../README.md` |
| `docs/documentation-standards/template/docs/.../guide.md` | 142 | `docs/handbook/methodology/README.md` | `docs/methodology/README.md` |

#### Pattern 3: `docs/ai/` (directory exists but is empty) — 5 occurrences in 5 files

| File | Lines | Current Path | Should Be |
|------|-------|-------------|-----------|
| `docs/methodology/methodology-as-code.md` | 268 | `docs/ai/methodology/` | `docs/methodology/` |
| `docs/methodology/ci-cd-quality-gates.md` | 319 | `docs/ai/kits/...` | `docs/services/...` |
| `docs/principles/roadmap.md` | 95 | `docs/ai/principles/` | `docs/principles/` |
| `docs/purpose/roadmap.md` | 46, 59 | `docs/ai/methodology/`, `docs/ai/purpose/` | `docs/methodology/`, `docs/purpose/` |
| `docs/TASKS/handle-security-issue.md` | 442 | `../ai/methodology/security-baseline.md` | `../methodology/security-baseline.md` |

#### Pattern 4: `docs/human/` (directory does not exist) — 3 occurrences in 3 files

| File | Lines | Current Path | Should Be |
|------|-------|-------------|-----------|
| `docs/methodology/ci-cd-quality-gates.md` | 317 | `../../human/RISK-TIERS.md` | `../../RISK-TIERS.md` |
| `docs/methodology/auto-tier-assignment.md` | 712 | `../../human/RISK-TIERS.md` | `../../RISK-TIERS.md` |
| `docs/methodology/templates/README.md` | 112 | `../../../human/RISK-TIERS.md` | `../../../RISK-TIERS.md` |

> **NOTE:** Additional `docs/ai/` and `docs/human/` references exist in root-level `docs/` files outside this agent's scope: `docs/GLOSSARY.md`, `docs/INCIDENTS.md`, `docs/DAILY-FLOW.md`, `docs/RISK-TIERS.md`, `docs/SHIPPING.md`, `docs/START-HERE.md`, `docs/principles.md`. These should be addressed in a follow-up.

---

## Agent B — docs/.harmony/ (14 files)

**Result:** Not a canonical Harmony workspace — it's a knowledge index. 2 stale path references, 1 empty file.

### Finding B1: Stale `.archive/architecture-agents` reference (2 instances)
- **File:** `docs/.harmony/.index/agent-system-design/archived-agent-design-docs-summary.md`
- **Lines:** 8, 114
- **Issue:** References `.archive/architecture-agents` which doesn't exist anywhere in the repo
- **Fix:** Update to note the original docs were consolidated into `.index/`

### Finding B2: Empty placeholder file
- **File:** `docs/.harmony/.index/agentic-system-implementation.md`
- **Issue:** 0 bytes. Either populate or remove.

### Structural note
`docs/.harmony/` does not follow the canonical capability-organized structure (no `agency/`, `capabilities/`, `cognition/`, etc.). It's a flat `.index/` knowledge store. Consider renaming to `docs/.research-index/` or restructuring if intended as a workspace.

---

## Agent C — Source code + CI (10 files + 20 grep searches)

**Result: 0 actionable findings**

All source code (`packages/harmony-cli/`, `packages/kits/costkit/`), scripts (`scripts/check-flowkit-paths.js`), CI/CD (`.github/workflows/skills-validate.yml`, `infra/ci/pr.yml`), and tool settings (`.claude/settings.local.json`) are clean.

- Zero `.workspace` references in any code
- All `.harmony/` paths use correct capability-organized structure
- Runtime data paths (`.harmony/state.json`, `.harmony/cost-data.json`) are correct

---

## Agent D — Continuity + Output + Config (13 files)

**Result:** 13 findings across 3 files. Root config files clean.

### Finding D1-D3: tasks.json bare flat-structure names (3 instances)
- **File:** `.harmony/continuity/tasks.json`
- **Line 19:** `context/` and `commands/` → `cognition/context/` and `capabilities/commands/`
- **Line 37:** `prompts/` → `scaffolding/prompts/`
- **Line 43:** `examples/` → `scaffolding/examples/`

### Finding D4: entities.json stale description
- **File:** `.harmony/continuity/entities.json`
- **Line 9:** `"notes": "Root workspace harness; structure finalized"` — should note "capability-organized structure"

### Finding D5-D13: log.md header section (first 50 lines) — 9 stale references
- **Lines 11, 35:** `.workspace` → `.harmony`
- **Lines 18, 44, 47:** bare `progress/`, `context/`, `commands/` → capability-organized
- **Line 19:** `checklists/` → `quality/`
- **Line 22:** "flat" architecture → "capability-organized"
- **Line 26:** 5 bare directory names in a single line

> **Note:** These are in the first two session entries of the append-only log. They are historically accurate (they describe what was done at the time) but use stale path names. Whether to update is a judgment call.

### Clean files
- `.harmony/continuity/next.md` — clean
- `.harmony/output/reports/` — clean (audit report uses correct paths)
- `AGENTS.md` / `CLAUDE.md` — all quick-reference paths verified against filesystem
- `langgraph.json`, `package.json`, `turbo.json`, `tsconfig.base.json` — clean

---

## Agent E — Cursor + Registry Validation (22 files)

**Result:** 4 symlinks valid. 10+ findings across cursor commands and registries.

### Symlinks: All 4 valid
All `.cursor/commands/` symlinks correctly resolve to `.harmony/capabilities/commands/`.

### Cursor Command Findings (7)

| # | File | Line(s) | Issue | Fix |
|---|------|---------|-------|-----|
| E1 | `.cursor/commands/create-skill.md` | 5, 27, 46 | `workflows/skills/create-skill/` → actual dir is `workflows/skills(x)/create-skill/` | Add `(x)` suffix |
| E2 | `.cursor/commands/create-skill.md` | 48 | `docs/architecture/workspaces/skills.md` → doesn't exist | → `docs/architecture/workspaces/skills/README.md` |
| E3 | `.cursor/commands/synthesize-research.md` | 34 | `.harmony/drafts/` → doesn't exist | → `.harmony/output/drafts/` |
| E4 | `.cursor/commands/synthesize-research.md` | 48 | `docs/architecture/workspaces/skills.md` → doesn't exist | → `docs/architecture/workspaces/skills/README.md` |
| E5 | `.cursor/commands/use-skill.md` | 32 | `.harmony/capabilities/skills/outputs/` → doesn't exist | → `.harmony/output/drafts/` |
| E6 | `.cursor/commands/use-skill.md` | 33 | `logs/runs/<timestamp>-<skill-id>.md` → wrong structure | → `logs/<skill-id>/<run-id>.md` |
| E7 | `.cursor/commands/use-skill.md` | 62 | `docs/architecture/workspaces/skills.md` → doesn't exist | → `docs/architecture/workspaces/skills/README.md` |

### Registry Findings (3+)

| # | File | Line(s) | Issue | Fix |
|---|------|---------|-------|-----|
| E8 | `registry.yml` | 75 | `resources/synthesize-research/` → actual dir is `resources/research-synthesizer/` | Rename on-disk dir |
| E9 | `registry.yml` | 93-94 | `logs/synthesize-research/` → actual dir is `logs/research-synthesizer/` | Rename on-disk dir |

> The `research-synthesizer` → `synthesize-research` rename was incomplete. The skill ID changed but the on-disk `resources/` and `logs/` subdirectories still use the old name.

---

## Agent F — Relationship Integrity Sweep (5 tasks)

### Task 1: START.md — 30+ paths checked, 1 finding

| # | Line | Path | Issue | Fix |
|---|------|------|-------|-----|
| F1 | 85 | `assistants/registry.yml` | Missing `agency/` prefix — resolves to nonexistent `.harmony/assistants/` | → `agency/assistants/registry.yml` |

### Task 2: catalog.md — 43 paths checked, 0 findings
All 43 link targets resolve correctly on disk.

### Task 3: Workflow step consistency — 11 workflows, 75+ step files, 1 finding

All 11 workflows have consistent step files matching their overviews. Mission workflows (create-mission, complete-mission) use inline steps by design.

| # | File | Line | Issue | Fix |
|---|------|------|-------|-----|
| F2 | `skills(x)/create-skill/00-overview.md` | 142 | `docs/architecture/workspaces/skills.md` → doesn't exist | → `docs/architecture/workspaces/skills/README.md` |

### Task 4: Skill SKILL.md ↔ references/ — 5 skills, 4 findings

**Systematic issue:** All 4 skills with `references/` directories link to `references/behaviors.md` which doesn't exist. The actual file is `references/phases.md`.

| # | Skill | SKILL.md Line | Issue |
|---|-------|--------------|-------|
| F3 | `create-skill` | 111 | `references/behaviors.md` → `references/phases.md` |
| F4 | `refactor` | 92 | `references/behaviors.md` → `references/phases.md` |
| F5 | `refine-prompt` | 88 | `references/behaviors.md` → `references/phases.md` |
| F6 | `synthesize-research` | 118 | `references/behaviors.md` → `references/phases.md` |

### Task 5: conventions.md — 2 findings

| # | Line | Path | Issue | Fix |
|---|------|------|-------|-----|
| F7 | 117 | `decisions/*.md` | Missing `cognition/` prefix | → `cognition/decisions/*.md` |
| F8 | 151 | `decisions/004-refactor-workflow.md` | Missing `cognition/` prefix | → `cognition/decisions/004-refactor-workflow.md` |

---

## Combined Summary

### By priority

| Priority | Count | Source |
|----------|-------|--------|
| **CRITICAL** | 1 | `docs/TASKS/handle-security-issue.md` broken security baseline link |
| **HIGH** | 25 | Cursor commands (7), docs cross-refs (11), registry (3), skills behaviors→phases (4) |
| **MEDIUM** | 15 | docs archived prompts (11), continuity files (4) |
| **LOW** | 12 | log.md header (9), entities.json (1), START.md (1), conventions.md (2 — in exclusion zone area) |
| **Total** | **53** | |

### By staleness pattern (new classes discovered)

| Pattern | Count | Initial audit caught? |
|---------|-------|-----------------------|
| `docs/handbooks/` or `docs/handbook/` broken refs | 15 | No — different migration |
| `docs/ai/` or `docs/human/` broken refs | 8 | No — different migration |
| `references/behaviors.md` → `references/phases.md` | 4 | No — rename not propagated to SKILL.md links |
| `research-synthesizer` → `synthesize-research` on-disk dirs | 2 | No — on-disk rename not completed |
| Cursor command stale paths | 7 | Partially (initial audit fixed `use-skill.md` duplicates) |
| `docs/architecture/workspaces/skills.md` → `skills/README.md` | 4 | No — file became directory |
| Continuity files with bare flat-structure names | 4 | No — not in original scope |

### Files confirmed clean (no issues)

| Scope | Files | Status |
|-------|-------|--------|
| Source code (`packages/`) | 10+ | All clean |
| CI/CD (`.github/`, `infra/`) | 3 | All clean |
| Root config | 5 | All clean |
| Template scaffolding (52 files) | 52 | All clean (prior audit) |
| `docs/services/` (58 files) | 58 | All clean |
| `docs/engines/` (15 files) | 15 | All clean |
| `docs/pillars/` (15 files) | 15 | All clean |
| `docs/development/` (4 files) | 4 | All clean |
| `docs/specs/` (5 files) | 5 | All clean |
| `docs/practices/` (1 file) | 1 | All clean |
| Registries/manifests (manifest.yml, capabilities.yml) | 2 | All clean |
| All 11 workflow step files | 75+ | All consistent |
| catalog.md index | 43 paths | All resolve |

---

## Recommended Fix Strategy

### Batch 1: `docs/` cross-reference cleanup (23 findings)
Four find-and-replace patterns across `docs/`:
1. `docs/handbooks/harmony/architecture/` → `docs/architecture/`
2. `docs/handbook/` → `docs/`
3. `docs/ai/` → `docs/` (when referring to docs subdirectories)
4. `docs/human/RISK-TIERS.md` → `docs/RISK-TIERS.md`

### Batch 2: Cursor command path fixes (7 findings)
- `create-skill.md`: `skills/` → `skills(x)/`, `skills.md` → `skills/README.md`
- `synthesize-research.md`: `.harmony/drafts/` → `.harmony/output/drafts/`, `skills.md` → `skills/README.md`
- `use-skill.md`: fix output/log paths, `skills.md` → `skills/README.md`

### Batch 3: Skill behaviors→phases rename (4 findings)
- All 4 SKILL.md files: `references/behaviors.md` → `references/phases.md`

### Batch 4: Registry + on-disk rename (2 findings)
- Rename `resources/research-synthesizer/` → `resources/synthesize-research/`
- Rename `logs/research-synthesizer/` → `logs/synthesize-research/`

### Batch 5: Operational file fixes (6 findings)
- START.md: `assistants/registry.yml` → `agency/assistants/registry.yml`
- conventions.md: `decisions/` → `cognition/decisions/` (2 instances)
- tasks.json: 3 bare flat-structure names
- entities.json: description update

### Batch 6: Low priority / judgment call (12 findings)
- log.md header: 9 stale references (historical vs current accuracy)
- docs/.harmony/: structural non-conformance + stale archive refs
