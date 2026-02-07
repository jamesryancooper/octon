# Step 5: Verify Completion

## Purpose

**MANDATORY GATE:** Re-run ALL audit searches to confirm zero remaining references. A refactor is NOT complete until this step passes.

## Actions

1. Re-run EVERY search from the audit step:
   ```bash
   # Must return empty for each
   rg "old-name" --type md --type yaml --type json
   rg "/old-name" --type md --type yaml --type json
   rg "old-name/" --type md --type yaml --type json
   rg "/old-name/" --type md --type yaml --type json
   rg '"old-name"' --type md --type yaml --type json
   rg "'old-name'" --type md --type yaml --type json
   ```

2. Check for remaining physical artifacts:
   ```bash
   # Must return empty
   find . -type d -name "*old-name*" 2>/dev/null | grep -v node_modules | grep -v .git
   find . -type f -name "*old-name*" 2>/dev/null | grep -v node_modules | grep -v .git
   ```

3. Document verification results:
   ```markdown
   ## Verification Results

   | Pattern | Result | Status |
   |---------|--------|--------|
   | `old-name` | 0 matches | ✓ |
   | `/old-name` | 0 matches | ✓ |
   | `old-name/` | 0 matches | ✓ |
   | `/old-name/` | 0 matches | ✓ |
   | `"old-name"` | 0 matches | ✓ |
   | `'old-name'` | 0 matches | ✓ |
   | Physical dirs | 0 found | ✓ |
   | Physical files | 0 found | ✓ |

   **VERIFICATION:** PASSED ✓
   ```

## If Verification FAILS

If ANY search returns results:

1. **Do NOT declare refactor complete**
2. **Document** the remaining references:
   ```markdown
   ## Remaining References Found

   - `.harmony/cognition/context/old-file.md:15` — contains `old-name`
   - `docs/guide.md:42` — contains `/old-name/`
   ```
3. **Return to Step 4** (Execute) to address remaining items
4. **Re-run Step 5** (Verify) again
5. **Repeat** until verification passes

## Verification Must Pass

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   REFACTOR IS NOT COMPLETE UNTIL ALL SEARCHES          │
│   RETURN ZERO RESULTS                                   │
│                                                         │
│   Do not skip this step.                               │
│   Do not declare completion if it fails.               │
│   Do not rationalize remaining references.             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Acceptable Exceptions

The ONLY acceptable remaining references are:

1. **Continuity artifacts** that intentionally preserve old names (historical record)
2. **External documentation** explaining the migration
3. **Comments** explicitly noting the old name for historical context

These must be explicitly listed and justified:

```markdown
## Intentional Exceptions

| File | Reason |
|------|--------|
| `continuity/log.md:45` | Historical entry from 2025-01-13 |
| `decisions/001-*.md:23` | ADR documents the original name |
```

## Output

Either:
- **PASSED:** All searches return zero (proceed to Step 6)
- **FAILED:** Remaining references documented (return to Step 4)

## Proceed When

- ALL search variations return zero results
- OR all remaining references are documented as intentional exceptions
