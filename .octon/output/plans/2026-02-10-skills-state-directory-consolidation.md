# Plan: Consolidate operational directories under `_ops/state/`

## Context

The skills directory at `.octon/capabilities/skills/` mixes operational directories (`configs/`, `resources/`, `runs/`, `logs/`) with skill group directories (`foundations/`, `meta/`, `platforms/`, etc.) at the same level. There is no visual or structural distinction between them. Moving the four operational directories under a `_ops/state/` parent creates a clear separation of mutable runtime data from skill definitions, improves top-level legibility, and simplifies gitignore/cleanup operations.

## Target structure

```
.octon/capabilities/skills/
├── _ops/state/                  # Mutable operational data
│   ├── configs/{skill-id}/
│   ├── resources/{skill-id}/
│   ├── runs/{skill-id}/{run-id}/
│   └── logs/{skill-id}/{run-id}.md
├── _scaffold/template/               # Scaffolding
├── foundations/              # Skill groups
├── meta/
├── platforms/
├── quality-gate/
├── synthesis/
├── manifest.yml
├── registry.yml
├── capabilities.yml
└── README.md
```

## Decisions

- **Historical output/report files** (`.octon/output/`): Leave as-is. These are frozen audit artifacts and updating them would misrepresent what was reported.
- **Archive files** (`.octon/capabilities/skills/archive/`): Leave as-is. Historical snapshots.
- **`.gitignore`**: Keep the existing broad `logs/` and `runs/` patterns — they already cover nested paths. No change needed.
- **Commit strategy**: Single atomic commit. The subsystem is small and all changes are tightly coupled.

## Implementation

### Step 1: Physical directory moves

```
mkdir .octon/capabilities/skills/_state
git mv .octon/capabilities/skills/configs   .octon/capabilities/skills/_ops/state/configs
git mv .octon/capabilities/skills/resources .octon/capabilities/skills/_ops/state/resources
git mv .octon/capabilities/skills/runs      .octon/capabilities/skills/_ops/state/runs
git mv .octon/capabilities/skills/logs      .octon/capabilities/skills/_ops/state/logs
```

### Step 2: Update `registry.yml`

**File:** `.octon/capabilities/skills/registry.yml`

- Update comment block (lines 40-46): prefix all four directory patterns with `_ops/state/`
- Global replace all I/O `path:` values:
  - `"logs/` → `"_ops/state/logs/` (~75 occurrences across every skill entry)
  - `"resources/` → `"_ops/state/resources/` (3 occurrences: synthesize-research, refine-prompt)
  - `"runs/` → `"_ops/state/runs/` (2 occurrences: refactor, create-skill)
  - `"configs/` → `"_ops/state/configs/` (1 occurrence: audit-migration)
- Update pipeline section (lines 1372-1378): prefix `resources/` paths with `_ops/state/`

### Step 3: Update validation and setup scripts

**File:** `.octon/capabilities/skills/scripts/validate-skills.sh`
- Line 466-467: Update comments `Write(runs/*)` → `Write(_ops/state/runs/*)`, `Write(logs/*)` → `Write(_ops/state/logs/*)`
- Line 485: `Write\(runs/\*\))` → `Write\(_ops/state/runs/\*\))`
- Line 486: `Write\(logs/\*\))` → `Write\(_ops/state/logs/\*\))`
- Line 555, 559: Update comment examples
- Line 2595: `infra_dirs` — replace `configs logs resources runs` with `_state`
- Lines 1538, 1550: Update scaffold template paths to `_ops/state/resources/` and `_ops/state/logs/`

**File:** `.octon/capabilities/skills/scripts/setup-harness-links.sh`
- Line 22: Replace `"logs"` with `"_state"` in `EXCLUDE_DIRS`

### Step 4: Update `allowed-tools` in all SKILL.md files

Global find-and-replace within `.octon/capabilities/skills/**/SKILL.md` (excluding `archive/` and `_scaffold/template/`):
- `Write(logs/*)` → `Write(_ops/state/logs/*)` (19 SKILL.md files)
- `Write(runs/*)` → `Write(_ops/state/runs/*)` (2 files: refactor, create-skill)

### Step 5: Update template files

**`.octon/capabilities/skills/_scaffold/template/SKILL.md`** — Lines 41, 48, 49, 87-93: update all `logs/`, `runs/`, `configs/`, `resources/` path references

**`.octon/capabilities/skills/_scaffold/template/references/`** — 7 reference files with path updates:
- `io-contract.md` (lines 39, 51, 68, 112)
- `checkpoints.md` (lines 14, 119-120, 137, 188, 241)
- `interaction.md` (lines 27, 40, 46, 167-169, 230)
- `safety.md` (lines 26-27, 65-66)
- `phases.md` (lines 19, 68)
- `validation.md` (line 66)
- `agents.md` (line 545)

### Step 6: Update individual skill reference files

Grep for `Write(logs/*)`, `Write(runs/*)`, and bare `logs/`/`runs/` path references in `**/references/*.md` across all non-archived skills. Update each occurrence with the `_ops/state/` prefix.

### Step 7: Update `CLAUDE.md`

- Line 13: `.octon/capabilities/skills/logs/` → `.octon/capabilities/skills/_ops/state/logs/`
- Line 32: `capabilities/skills/logs/` → `capabilities/skills/_ops/state/logs/`

### Step 8: Update skills README

**File:** `.octon/capabilities/skills/README.md`
- Line 130: invocation example with `resources/` → `_ops/state/resources/`
- Lines 144-160: directory structure diagram — nest `configs/`, `resources/`, `runs/`, `logs/` under `_ops/state/`
- Lines 196-197: architecture diagram references
- Line 226: execution flow text
- Line 381: `Write(logs/*)` → `Write(_ops/state/logs/*)`

### Step 9: Update architecture docs

All files under `docs/architecture/harness/skills/`:
- `design-conventions.md` (~60 references — directory diagrams, tables, code examples)
- `architecture.md` (~20 references — diagrams, tables)
- `execution.md` (~15 references — tables, flow diagrams)
- `discovery.md` (~6 references)
- `specification.md` (~6 references)
- `skill-format.md`, `creation.md`, `declaration.md`, `README.md`, `invocation.md` (1-2 each)

### Step 10: Update workflow and cognition files

- `.octon/orchestration/workflows/quality-gate/orchestrate-audit/06-report.md` (lines 88, 116)
- `.octon/orchestration/workflows/meta/create-skill(x)/03-initialize-skill.md` (lines 31, 41)
- `.octon/cognition/analyses/workflows-vs-skills-analysis.md` (lines 22-23, 71, 183, 479, 774)
- `.octon/cognition/context/primitives.md` (line 179)

### Step 11: Update cursor commands

- `.cursor/commands/use-skill.md` — log path references
- `.cursor/commands/synthesize-research.md` — resource and log path references

## Verification

1. Run `.octon/capabilities/skills/scripts/validate-skills.sh` — all skills should pass
2. Grep sweep for stale bare references (excluding archive/ and output/):
   ```
   grep -rn --include='*.md' --include='*.yml' --include='*.sh' \
     -E 'path: "(configs|resources|runs|logs)/' \
     .octon/capabilities/skills/ docs/architecture/harness/skills/ CLAUDE.md
   ```
3. Verify physical structure: `ls .octon/capabilities/skills/_ops/state/` shows 4 directories; old locations are gone
