# Step 4: Execute Changes

## Purpose

Make all planned changes systematically, tracking progress against the manifest. No ad-hoc changes—stick to the plan.

## Actions

1. Execute Phase 1 (Physical Changes):
   ```bash
   # Rename directories
   mv .octon/inputs/exploratory/ideation/scratchpad .octon/inputs/exploratory/ideation/scratchpadpad

   # Move files
   mv old/path/file.md new/path/file.md
   ```
   - Mark each item complete in TodoWrite immediately after
   - Verify the rename/move succeeded before proceeding

2. Execute Phase 2 (Config Files):
   - Open each config file
   - Replace old pattern with new pattern
   - Save and mark complete
   - For JSON files, ensure valid JSON after edit

3. Execute Phase 3 (Documentation & Code):
   - Work through files in manifest order
   - For each file:
     1. Read the file
     2. Replace ALL occurrences of ALL pattern variations
     3. Save the file
     4. Mark complete in TodoWrite
   - **Do not batch completions**—mark each file done immediately

4. Execute Phase 4 (Continuity Artifacts):
   - **CRITICAL: APPEND ONLY**
   - Do NOT modify existing content
   - Add new entry at the appropriate location:

   For `/.octon/state/continuity/repo/log.md`:
   ```markdown
   ## YYYY-MM-DD

   **Session focus:** Refactor `.scratch/` to `.scratchpad/`

   **Completed:**
   - Renamed `.octon/inputs/exploratory/ideation/scratchpad/` to `.octon/inputs/exploratory/ideation/scratchpad/`
   - Updated 47 references across 12 files
   - [list key files changed]

   **Next:**
   - [if applicable]

   **Blockers:**
   - None
   ```

   For `/.octon/instance/cognition/decisions/<NNN>-<slug>.md` (if applicable):
   ```markdown
   # ADR-XXX: [Topic]

   ## Context
   [Why the refactor required a durable decision]

   ## Decision
   [What was chosen]

   ## Consequences
   [Key tradeoffs and impact]
   ```

   Then update `/.octon/instance/cognition/decisions/index.yml` and run:
   ```bash
   bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh
   ```

## Rules During Execution

| Rule | Reason |
|------|--------|
| Mark items complete immediately | Prevents losing track mid-refactor |
| Don't add unplanned changes | Scope creep introduces errors |
| Read before editing | Ensures you see current state |
| One file at a time | Maintains focus and tracking |
| APPEND to continuity artifacts | Preserves historical accuracy |

## If You Discover Missing Items

If you find a reference not in the manifest:

1. **Stop** current execution
2. **Add** the new item to the manifest
3. **Continue** execution including the new item
4. **Note** the discovery for the verification step

## Output

- All manifest items marked complete
- Continuity artifacts updated (append-only)
- Any discovered items noted

## Idempotency

**Check:** Are changes partially or fully executed?
- [ ] Check TodoWrite for completion status
- [ ] Check if manifest items are marked done
- [ ] Verify files reflect expected changes

**If Partially Complete:**
- Resume from first incomplete manifest item
- Skip already-completed items

**If Fully Complete:**
- Verify all items marked done
- Skip to verification step

**Marker:** `checkpoints/refactor/<refactor-id>/04-execute.complete`

## Proceed When

- Every manifest item is marked complete
- No items left unchecked
- Continuity artifacts have new entries (not modified old ones)
