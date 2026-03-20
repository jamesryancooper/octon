# Step 6: Document and Close

## Purpose

Record the completed refactor in continuity artifacts and formally close the refactor workflow.

## Actions

1. Confirm verification passed:
   - Step 5 must show PASSED status
   - If not, return to Step 4

2. Update `/.octon/state/continuity/repo/log.md` (**APPEND ONLY**):
   ```markdown
   ## YYYY-MM-DD

   **Session focus:** Refactor `old-name` to `new-name`

   **Completed:**
   - Renamed [physical changes]
   - Updated N references across M files
   - Key files: [list 3-5 most significant]
   - Verification: PASSED (all searches returned zero)

   **Next:**
   - [follow-up items if any]

   **Blockers:**
   - None
   ```

3. If the refactor represents a durable decision, add or update an ADR in
   `/.octon/instance/cognition/decisions/` and refresh the generated summary:
   ```markdown
   # ADR-XXX: [Title]

   ## Context
   [Why the refactor was needed]

   ## Decision
   [What was changed]

   ## Consequences
   [Impact of the change]
   ```

4. Update `/.octon/instance/cognition/decisions/index.yml` if the ADR set
   changed, then run:
   ```bash
   bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh
   ```

5. Clear TodoWrite items related to this refactor

6. Declare completion:
   ```
   Refactor complete: `old-name` → `new-name`
   - Files changed: N
   - Verification: PASSED
   - Continuity artifacts: Updated (append-only)
   ```

## Continuity Artifact Rules (Final Reminder)

| Action | Allowed | Not Allowed |
|--------|---------|-------------|
| Add new log entry | ✓ | |
| Add new ADR or ADR addendum | ✓ | |
| Create new ADR | ✓ | |
| Modify existing log entries | | ✗ |
| Update old decision text | | ✗ |
| Change paths in historical ADRs | | ✗ |

**Why:** Historical records should reflect what was true at the time. Future readers should see the progression, not a sanitized history.

## Output

- Progress log updated with refactor summary
- ADR recorded and summary regenerated if applicable
- ADR created if significant
- TodoWrite cleared
- Explicit completion declaration

## Idempotency

**Check:** Is documentation already complete?
- [ ] Progress log has entry for this refactor
- [ ] TodoWrite items are cleared
- [ ] Completion was declared

**If Already Complete:**
- Verify documentation entries exist
- Skip if all documentation present

**Marker:** `checkpoints/refactor/<refactor-id>/06-document.complete`

## Refactor Complete When

- [ ] Verification (Step 5) passed
- [ ] Progress log has new entry (not modified old)
- [ ] ADR recorded and summary regenerated if applicable
- [ ] TodoWrite items cleared
- [ ] Completion declared with stats
