# Step 4: Validation

Verify the migrated workspace is functional.

## Actions

1. **Run health check**
   - Execute `init.sh` if present
   - Or manually verify structure

2. **Test boot sequence**
   - Read `START.md` and follow boot sequence
   - Verify all referenced files exist and are readable

3. **Check token budgets**
   - Total harness: ~2,000 target, ~5,000 max
   - Single file: ~300 target, ~500 max
   - `START.md`: ~200 target, ~300 max

4. **Validate frontmatter**
   - Run `/validate-frontmatter @<workspace-path>`

## Output

| Section | Content |
|---------|---------|
| **Migration Summary** | Files moved, transformed, created |
| **Preserved Content** | Custom content retained with new locations |
| **Archived Content** | Deprecated content moved to `ideation/scratchpad/archive/` |
| **Validation Status** | Pass/fail with details |
| **Post-Migration Notes** | Any manual follow-up needed |

