# Step 6: Document and Close

## Purpose

Record the completed refactor in continuity artifacts and formally close the refactor workflow.

## Actions

1. Confirm verification passed:
   - Step 5 must show PASSED status
   - If not, return to Step 4

2. Update `progress/log.md` (**APPEND ONLY**):
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

3. If the refactor represents a decision, update `context/decisions.md` (**APPEND ONLY**):
   ```markdown
   | D0XX | [Topic] naming | `new-name` over `old-name` | [rationale] | YYYY-MM-DD |
   ```

4. If creating an ADR, add to `decisions/` (**NEW FILE**, not modifying existing):
   ```markdown
   # ADR-XXX: [Title]

   ## Status
   Accepted

   ## Context
   [Why the refactor was needed]

   ## Decision
   [What was changed]

   ## Consequences
   [Impact of the change]
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
| Add new decision | ✓ | |
| Create new ADR | ✓ | |
| Modify existing log entries | | ✗ |
| Update old decision text | | ✗ |
| Change paths in historical ADRs | | ✗ |

**Why:** Historical records should reflect what was true at the time. Future readers should see the progression, not a sanitized history.

## Output

- Progress log updated with refactor summary
- Decision recorded if applicable
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
- [ ] Decision recorded if applicable (append-only)
- [ ] TodoWrite items cleared
- [ ] Completion declared with stats
