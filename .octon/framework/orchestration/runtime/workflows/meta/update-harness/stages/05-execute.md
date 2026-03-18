# Step 5: Execute Changes

After user approval:

1. Create missing structure
2. Move/rename files as proposed
3. Update v2 root-manifest/profile content as needed
4. Route export requests to `/export-harness`
5. Update `continuity/log.md` with changes made

## Output format

Produce report with these sections:

1. **Current State** — Files and directories found
2. **Canonical Comparison** — What's present vs. what's expected
3. **Token Analysis** — Files with estimated tokens vs budget
4. **Proposed Changes** — Specific actions organized by type (create/move/rename/update/merge)
5. **Gaps Remaining** — Any issues that need human decision
