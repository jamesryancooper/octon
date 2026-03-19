# Step 5: Execute Changes

After user approval:

1. Create missing structure
2. Move/rename files as proposed
3. Update root-manifest and repo-instance control-plane content as needed
4. Preserve repo-owned `instance/**` ingress, bootstrap, locality, context,
   decisions, missions, repo-native capabilities, and desired extension
   configuration unless an explicit migration contract says otherwise
5. Preserve and repair `instance/manifest.yml#enabled_overlay_points`,
   canonical `instance/ingress/**`, and the root adapter chain to
   `/.octon/AGENTS.md`
6. Remove or quarantine ad hoc overlay-like paths that fall outside the four
   ratified overlay roots
7. Preserve and repair Packet 6 locality authority under
   `instance/locality/**`, compiled locality outputs under
   `generated/effective/locality/**`, and locality quarantine state under
   `state/control/locality/**`
8. Route export requests to `/export-harness`
9. Update `state/continuity/repo/log.md` with changes made

## Output format

Produce report with these sections:

1. **Current State** — Files and directories found
2. **Canonical Comparison** — What's present vs. what's expected
3. **Token Analysis** — Files with estimated tokens vs budget
4. **Proposed Changes** — Specific actions organized by type (create/move/rename/update/merge)
5. **Gaps Remaining** — Any issues that need human decision
