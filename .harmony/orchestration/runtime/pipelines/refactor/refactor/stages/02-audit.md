# Step 2: Audit All References

## Purpose

Exhaustively search for ALL references to the old pattern before making any changes. This creates a complete inventory of what needs to change.

## Actions

1. For EACH search variation from step 1, run a search:
   ```bash
   # Example using ripgrep
   rg -l "old-name" --type md --type yaml --type json
   rg -l "/old-name" --type md --type yaml --type json
   rg -l "old-name/" --type md --type yaml --type json
   # ... repeat for all variations
   ```

2. Record results in a structured format:
   ```markdown
   ## Audit Results

   ### Pattern: `old-name`
   - `.harmony/START.md` (3 matches)
   - `.harmony/orchestration/runtime/workflows/example.md` (1 match)
   - `.harmony/cognition/_meta/architecture/overview.md` (2 matches)

   ### Pattern: `/old-name/`
   - `.cursor/commands/command.md` (1 match)

   ### Pattern: `"old-name"`
   - `package.json` (1 match)
   ```

3. Check for physical files/directories that need renaming:
   ```bash
   # Find directories with the old name
   find . -type d -name "*old-name*" 2>/dev/null

   # Find files with the old name
   find . -type f -name "*old-name*" 2>/dev/null
   ```

4. Consolidate into a single file list (deduplicated):
   ```markdown
   ## Files Requiring Changes

   | File | Match Count | Patterns Found |
   |------|-------------|----------------|
   | `.harmony/START.md` | 4 | `old-name`, `/old-name/` |
   | `.harmony/orchestration/runtime/workflows/example.md` | 1 | `old-name` |
   | `package.json` | 1 | `"old-name"` |

   **Total files:** 3
   **Total matches:** 6
   ```

5. Flag any unexpected locations:
   - Files you didn't expect to contain the pattern
   - Generated files that might regenerate the old pattern
   - External dependencies or configs

## Common Mistakes to Avoid

- **Searching only one variation:** Always search ALL variations
- **Missing file types:** Include config files, scripts, dotfiles
- **Ignoring case:** Consider case-insensitive search if pattern could vary
- **Stopping at first results:** Run ALL searches even if early ones find matches

## Output

A complete audit manifest listing:

- Every file containing any variation of the old pattern
- Match counts per file
- Which specific patterns matched
- Physical files/directories to rename

## Idempotency

**Check:** Is audit already complete for this refactor?
- [ ] Audit results document exists
- [ ] All search variations have recorded results
- [ ] Files list is consolidated

**If Already Complete:**
- Load existing audit results
- Ask user if re-audit needed
- Skip to next step if no re-audit

**Marker:** `checkpoints/refactor/<refactor-id>/02-audit.complete`

## Proceed When

- ALL search variations have been run
- Results are consolidated and deduplicated
- Unexpected locations are noted and understood
