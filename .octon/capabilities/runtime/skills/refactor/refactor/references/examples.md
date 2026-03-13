# Examples Reference

Worked examples demonstrating the refactor skill.

## Example 1: Simple Directory Rename

**Goal:** Rename `.scratch/` to `.scratchpad/` across the codebase.

### Invocation

```
/refactor ".scratch/ → .scratchpad/"
```

### Phase 1: Define Scope

```markdown
## Refactor Scope

**Refactor ID:** 2026-01-20-rename-scratch-to-scratchpad
**Type:** Rename
**Old:** `.scratch/`
**New:** `.scratchpad/`

**Search variations:**
- [ ] `.scratch`
- [ ] `/.scratch`
- [ ] `.scratch/`
- [ ] `/.scratch/`
- [ ] `".scratch"`
- [ ] `'.scratch'`
- [ ] `.scratch/` in paths
- [ ] `scratch` (without dot, if applicable)

**File types:** md, yml, yaml, json, ts

**Physical changes:**
- [ ] Rename directory `.octon/ideation/scratchpad/` → `.octon/ideation/scratchpad/`

**Exclusions:** node_modules, .git, dist
```

### Phase 2: Audit

```markdown
## Audit Results

### Pattern: `.scratch`
- `.octon/START.md` (3 matches)
- `.octon/orchestration/runtime/workflows/promote-from-scratch.md` (5 matches)
- `.octon/cognition/_meta/architecture/overview.md` (2 matches)

### Pattern: `/.scratch/`
- `CLAUDE.md` (1 match)

### Pattern: `".scratch"`
- `package.json` (1 match)

## Files Requiring Changes

| File | Match Count | Patterns Found |
|------|-------------|----------------|
| `.octon/START.md` | 3 | `.scratch`, `/.scratch/` |
| `.octon/orchestration/runtime/workflows/promote-from-scratch.md` | 5 | `.scratch` |
| `.octon/cognition/_meta/architecture/overview.md` | 2 | `.scratch` |
| `CLAUDE.md` | 1 | `/.scratch/` |
| `package.json` | 1 | `".scratch"` |

**Total files:** 5
**Total matches:** 12

**Physical artifacts:**
- Directory: `.octon/ideation/scratchpad/`
```

### Phase 3: Plan

```markdown
## Refactor Change Manifest

**Refactor:** `.scratch/` → `.scratchpad/`
**Total files:** 5
**Total changes:** 12

### Phase 1: Physical Changes (do first)
- [ ] Rename `.octon/ideation/scratchpad/` → `.octon/ideation/scratchpad/`

### Phase 2: Config Files
- [ ] `package.json` (1 change)

### Phase 3: Documentation & Code
- [ ] `.octon/START.md` (3 changes)
- [ ] `.octon/orchestration/runtime/workflows/promote-from-scratch.md` (5 changes)
- [ ] `.octon/cognition/_meta/architecture/overview.md` (2 changes)
- [ ] `CLAUDE.md` (1 change)

### Phase 4: Continuity Artifacts (APPEND ONLY)
- [ ] `.octon/continuity/log.md` — Add entry documenting this refactor
```

### Phase 4: Execute

```markdown
## Execution Log

### Physical Changes
- [x] 14:32:01 Renamed `.octon/ideation/scratchpad/` → `.octon/ideation/scratchpad/`

### Config Files
- [x] 14:32:05 Updated `package.json` (1 replacement)

### Documentation & Code
- [x] 14:32:08 Updated `.octon/START.md` (3 replacements)
- [x] 14:32:12 Updated `.octon/orchestration/runtime/workflows/promote-from-scratch.md` (5 replacements)
- [x] 14:32:15 Updated `.octon/cognition/_meta/architecture/overview.md` (2 replacements)
- [x] 14:32:18 Updated `CLAUDE.md` (1 replacement)

### Continuity Artifacts
- [x] 14:32:22 Appended entry to `.octon/continuity/log.md`
```

### Phase 5: Verify

```markdown
## Verification Results

| Pattern | Result | Status |
|---------|--------|--------|
| `.scratch` | 0 matches | ✓ |
| `/.scratch` | 0 matches | ✓ |
| `.scratch/` | 0 matches | ✓ |
| `/.scratch/` | 0 matches | ✓ |
| `".scratch"` | 0 matches | ✓ |
| `'.scratch'` | 0 matches | ✓ |
| Physical dirs | 0 found | ✓ |
| Physical files | 0 found | ✓ |

**VERIFICATION:** PASSED ✓
```

### Phase 6: Document

```markdown
## Summary

**Refactor:** `.scratch/` → `.scratchpad/`
**Status:** Complete
**Duration:** 45 seconds

**Statistics:**
- Files changed: 6
- Total replacements: 12
- Physical renames: 1
- Verification: PASSED

**Suggested commit:**
```
refactor: rename `.scratch/` to `.scratchpad/`

- Updated 12 references across 6 files
- Renamed directory `.octon/ideation/scratchpad/` → `.octon/ideation/scratchpad/`
- Verification: all audit searches return zero results
```
```

---

## Example 2: Move File with Reference Updates

**Goal:** Move `src/helpers.ts` to `lib/utils/helpers.ts`.

### Invocation

```
/refactor "src/helpers.ts → lib/utils/helpers.ts"
```

### Key Differences from Example 1

**Search variations include:**
- `src/helpers.ts`
- `./src/helpers.ts`
- `from 'src/helpers'`
- `from "src/helpers"`
- `../helpers` (relative imports)
- `@/helpers` (alias imports)

**Physical changes:**
1. Create directory `lib/utils/` if needed
2. Move file `src/helpers.ts` → `lib/utils/helpers.ts`

**Import updates:**
```typescript
// Before
import { helper } from '../helpers';
import { helper } from 'src/helpers';

// After
import { helper } from '../../lib/utils/helpers';
import { helper } from 'lib/utils/helpers';
```

### Verification Considerations

- Check for broken imports in TypeScript/JavaScript
- Run `tsc --noEmit` to verify compilation
- Check for path alias updates in `tsconfig.json`

---

## Example 3: Dry-Run Preview

**Goal:** Preview a refactor without making changes.

### Invocation

```
/refactor "utils/ → lib/utils/" --dry_run
```

### Behavior

Phases 1-3 execute normally:
1. Define Scope — captures patterns
2. Audit — finds all references
3. Plan — creates change manifest

Phase 4-6 are SKIPPED.

### Output

```markdown
## Dry Run Complete

**Scope:** `utils/` → `lib/utils/`

**Audit Summary:**
- 45 files contain references
- 127 total matches
- 3 directories to rename

**Change Manifest:**
See _ops/state/runs/refactor/2026-01-20-move-utils/change-manifest.md

**Physical changes planned:**
- Rename `src/utils/` → `lib/utils/`
- Rename `tests/utils/` → `tests/lib/utils/`
- Update 45 import statements

**Next steps:**
- Review the change manifest at _ops/state/runs/refactor/2026-01-20-move-utils/
- If satisfied, run: `/refactor "utils/ → lib/utils/"` (without --dry_run)
```

### Use Cases for Dry-Run

1. **Large refactors** — Preview scope before committing
2. **Team coordination** — Share plan for review
3. **Risk assessment** — Identify affected files
4. **Estimation** — Understand scope of work

---

## Example 4: Verification Loop-Back

**Scenario:** Verification fails, requiring return to Phase 4.

### Initial Execution

Phases 1-4 complete normally. Phase 5 verification runs:

```markdown
## Verification Results (First Pass)

| Pattern | Result | Status |
|---------|--------|--------|
| `old-name` | 2 matches | ✗ FAILED |
| `/old-name` | 0 matches | ✓ |
| ... | ... | ... |

**VERIFICATION:** FAILED

**Remaining References:**
- `.octon/scaffolding/runtime/templates/example.md:15` — contains `old-name`
- `tests/fixtures/data.json:42` — contains `old-name`
```

### Loop-Back to Phase 4

```markdown
## Execution Log (Continuation)

### Discovered Items
- [x] 14:45:01 Updated `.octon/scaffolding/runtime/templates/example.md` (1 replacement)
- [x] 14:45:05 Updated `tests/fixtures/data.json` (1 replacement)

Note: These files were not in original audit. Added during verification loop.
```

### Second Verification

```markdown
## Verification Results (Second Pass)

| Pattern | Result | Status |
|---------|--------|--------|
| `old-name` | 0 matches | ✓ |
| `/old-name` | 0 matches | ✓ |
| ... | ... | ... |

**VERIFICATION:** PASSED ✓

Note: Required 1 loop-back iteration.
```

---

## Example 5: Resume Interrupted Refactor

**Scenario:** Session ended during Phase 4.

### Resume Invocation

```
/refactor ".scratch/ → .scratchpad/"
```

### Detection

Skill detects existing checkpoint:

```
Found existing refactor in progress:
  ID: 2026-01-20-rename-scratch-to-scratchpad
  Status: in_progress
  Phase: 4 (Execute)
  Progress: 7/13 items complete
  Last completed: .octon/START.md

Resume from Phase 4? [Y/n]
```

### User Confirms

```
Resuming refactor from Phase 4, item 8...
```

### Continuation

```markdown
## Execution Log (Resumed)

### Previously Completed (items 1-7)
- [x] Physical changes
- [x] package.json
- [x] .octon/START.md
- [x] ... (4 more files)

### Resumed Execution (items 8-13)
- [x] 15:20:01 Updated `.octon/cognition/_meta/architecture/overview.md`
- [x] 15:20:05 Updated `CLAUDE.md`
- [x] 15:20:08 Updated `.octon/orchestration/runtime/workflows/promote.md`
- [x] 15:20:11 Updated `tests/fixtures/config.yml`
- [x] 15:20:14 Updated `.octon/conventions.md`
- [x] 15:20:18 Appended to `.octon/continuity/log.md`

All items complete. Proceeding to Phase 5 (Verify)...
```

---

## Anti-Example: What NOT to Do

### Skipping Verification

**Wrong:**
```
# Do NOT do this
Phases 1-4 complete. Looks good, declaring complete!
```

**Why it's wrong:** Verification is MANDATORY. You may NOT skip it.

### Modifying Continuity Artifacts

**Wrong:**
```markdown
# In continuity/log.md

## 2026-01-15
- Working on .scratch/ directory  ← MODIFIED to say .scratchpad/
```

**Right:**
```markdown
# In continuity/log.md

## 2026-01-15
- Working on .scratch/ directory  ← LEFT UNCHANGED

## 2026-01-20
- Refactored .scratch/ to .scratchpad/  ← NEW ENTRY APPENDED
```

### Incomplete Pattern Search

**Wrong:**
```
Only searched for `.scratch` — found 5 files, updated them.
```

**Why it's wrong:** Must search ALL 8 variations. Other patterns like `/.scratch/` or `".scratch"` may exist.
