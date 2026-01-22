# Step 3: Plan Changes

## Purpose

Transform the audit results into an actionable change manifest. Every change should be tracked before execution begins.

## Actions

1. Create a todo item for each file requiring changes:
   ```markdown
   ## Change Manifest

   ### Physical Changes (do first)
   - [ ] Rename directory `.scratch/` → `.scratchpad/`
   - [ ] Move file `old/location.md` → `new/location.md`

   ### Text Changes (by file)
   - [ ] `.workspace/START.md` (4 occurrences)
   - [ ] `.harmony/workflows/example.md` (1 occurrence)
   - [ ] `.cursor/commands/command.md` (1 occurrence)
   - [ ] `package.json` (1 occurrence)
   ```

2. Identify continuity artifacts that need **append-only** treatment:
   ```markdown
   ### Continuity Artifacts (append-only)
   - [ ] `progress/log.md` — Add new entry, do NOT modify existing
   - [ ] `decisions/*.md` — Add new decision, do NOT update old references
   ```

3. Order changes strategically:
   - **First:** Physical renames/moves (so paths exist for references)
   - **Second:** Config files (package.json, tsconfig, etc.)
   - **Third:** Documentation and code
   - **Last:** Continuity artifacts (append new entries)

4. Note any cascading effects:
   - Symlinks that may break
   - Import statements that need updating
   - Build scripts that reference old paths

5. Load the manifest into TodoWrite (or equivalent tracking):
   ```
   Use TodoWrite to create a checklist item for each file
   ```

## Output

A prioritized, trackable change manifest:

```markdown
## Refactor Change Manifest

**Refactor:** `.scratch/` → `.scratchpad/`
**Total files:** 12
**Total changes:** 47

### Phase 1: Physical Changes
- [ ] Rename `.workspace/.scratch/` → `.workspace/.scratchpad/`

### Phase 2: Config Files
- [ ] `package.json` (1 change)

### Phase 3: Documentation & Code
- [ ] `.workspace/START.md` (4 changes)
- [ ] `.harmony/workflows/promote-from-scratch.md` (rename + 3 changes)
- [ ] [... remaining files ...]

### Phase 4: Continuity Artifacts (APPEND ONLY)
- [ ] `progress/log.md` — Add refactor entry
- [ ] `context/decisions.md` — Add decision entry if applicable
```

## Idempotency

**Check:** Is change manifest already created?
- [ ] Change manifest document exists
- [ ] TodoWrite items populated
- [ ] All audit files represented

**If Already Complete:**
- Load existing manifest
- Verify it matches audit (no new files found)
- Skip to next step if manifest is current

**Marker:** `checkpoints/refactor/<refactor-id>/03-plan.complete`

## Proceed When

- Every file from audit is represented in the manifest
- Files are ordered by execution priority
- Continuity artifacts are clearly marked as append-only
- TodoWrite (or equivalent) is populated
