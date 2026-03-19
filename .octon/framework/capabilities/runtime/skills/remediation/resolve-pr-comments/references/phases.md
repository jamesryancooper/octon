---
behavior:
  phases:
    - name: "Fetch"
      steps:
        - "Extract PR number from parameter (number or full URL)"
        - "Run `gh pr view <number> --json number,title,headRefName,baseRefName` to get PR metadata"
        - "Run `gh api repos/{owner}/{repo}/pulls/{number}/comments` to get review comments"
        - "Run `gh api repos/{owner}/{repo}/pulls/{number}/reviews` to get review-level comments"
        - "Filter to unresolved comments only (exclude resolved threads)"
        - "If reviewer parameter set, filter to that reviewer's comments only"
        - "Record total: 'Fetched N unresolved comments from M reviewers'"
    - name: "Classify"
      steps:
        - "For each comment, determine type: BUG, DESIGN, STYLE, NIT, QUESTION, OUT_OF_SCOPE"
        - "Group comments by affected file"
        - "Within each file, sort by line number"
        - "Identify comment clusters (multiple comments on same function/block)"
        - "Flag conflicting comments from different reviewers"
        - "Record classification summary table"
    - name: "Plan"
      steps:
        - "For each comment group, determine resolution strategy"
        - "Order resolutions by type: structural → logic → design → style → docs → questions"
        - "Identify dependencies between resolutions (fix A before fix B)"
        - "Flag resolutions that require human decision (DESIGN type with tradeoffs)"
        - "Record plan summary with estimated changes per file"
    - name: "Resolve"
      steps:
        - "For each resolution in planned order:"
        - "  Read the affected file and surrounding context"
        - "  Apply the fix using Edit tool"
        - "  Record what was changed and why (linking to comment)"
        - "For QUESTION type: draft response text (no code change)"
        - "For OUT_OF_SCOPE type: draft acknowledgment with follow-up recommendation"
        - "For DESIGN type with tradeoffs: present options, do not apply without approval"
    - name: "Verify"
      steps:
        - "Re-read each modified file to confirm the change is correct"
        - "Check that no resolution introduced a conflict with another resolution"
        - "Verify the fix addresses the reviewer's specific concern (not just related code)"
        - "If tests exist for modified code, note which tests should be run"
        - "Record verification status for each resolution: APPLIED, DEFERRED, NEEDS_DISCUSSION"
    - name: "Report"
      steps:
        - "Generate resolution report with per-comment status"
        - "Include: comment text, classification, resolution, file:line, verification status"
        - "Group DEFERRED and NEEDS_DISCUSSION items at the top"
        - "Include summary statistics (resolved, deferred, questions answered)"
        - "Write report to /.octon/state/evidence/validation/analysis/"
        - "Write execution log with metadata"
        - "Update log index"
  goals:
    - "Every unresolved comment is addressed (resolved, deferred with reason, or answered)"
    - "Resolutions are applied in safe dependency order"
    - "No silent drops — every comment appears in the report"
    - "Design decisions are presented, not made unilaterally"
    - "Conflicting reviewer comments are flagged explicitly"
---

# Behavior Reference

Detailed phase-by-phase behavior for the resolve-pr-comments skill.

## Phase 1: Fetch

Retrieve all unresolved review comments from the pull request.

### Fetch Steps

1. **Parse PR identifier:**

   Accept either a PR number or a full URL:

   ```text
   # Number only (uses current repo context)
   /resolve-pr-comments pr="123"

   # Full URL
   /resolve-pr-comments pr="https://github.com/owner/repo/pull/123"
   ```

2. **Get PR metadata:**

   ```bash
   gh pr view 123 --json number,title,headRefName,baseRefName,reviewRequests
   ```

3. **Get review comments:**

   ```bash
   gh api repos/{owner}/{repo}/pulls/123/comments --paginate
   ```

   For each comment, extract:
   - `id`, `body`, `path`, `line`, `side`
   - `user.login` (reviewer)
   - `in_reply_to_id` (thread tracking)
   - `created_at`

4. **Get review-level comments:**

   ```bash
   gh api repos/{owner}/{repo}/pulls/123/reviews --paginate
   ```

   Extract top-level review comments (not attached to specific lines).

5. **Filter comments:**
   - Exclude resolved threads
   - If `reviewer` parameter set, keep only that reviewer's comments
   - Deduplicate (same comment can appear in multiple API responses)

### Fetch Result

Comment collection with metadata, ready for classification.

---

## Phase 2: Classify

Group and categorize comments for efficient resolution.

### Classification Rules

| Signal in Comment | Classification |
|-------------------|---------------|
| "bug", "incorrect", "wrong", "breaks", "crash" | BUG |
| "consider", "alternative", "architecture", "pattern" | DESIGN |
| "naming", "format", "convention", "style", "consistent" | STYLE |
| "nit", "optional", "minor", "suggestion" | NIT |
| "why", "what does", "could you explain", "?" at end | QUESTION |
| "separate PR", "follow-up", "out of scope" | OUT_OF_SCOPE |

When ambiguous, prefer the higher-severity classification (BUG > DESIGN > STYLE > NIT).

### Grouping

Comments are grouped by file path, then sorted by line number within each file. Comments on the same function or code block are clustered for coordinated resolution.

---

## Phase 3: Plan

Determine resolution strategy and order.

### Resolution Planning

For each comment, determine:

1. **What change is needed** — Specific edit, response, or deferral
2. **Where** — File path and line range
3. **Dependencies** — Does this fix depend on another fix?
4. **Risk** — Could this fix break something else?

### Ordering

Resolutions are ordered to minimize conflicts:

1. Structural changes (file-level)
2. Logic fixes (function-level)
3. Design changes (pattern-level)
4. Style/formatting (line-level)
5. Documentation (comment-level)
6. Questions (no code change)

---

## Phase 4: Resolve

Apply fixes in the planned order.

### Resolution Protocol

For each resolution:

1. Read the current state of the affected file
2. Apply the edit that addresses the reviewer's comment
3. Record the change with a reference to the comment ID
4. If the fix affects other comments in the same file, update the plan

### Special Cases

- **DESIGN comments:** Present options with tradeoffs. Do not apply without approval.
- **QUESTION comments:** Draft a response. Do not leave unanswered.
- **OUT_OF_SCOPE comments:** Acknowledge and suggest follow-up.
- **Conflicting comments:** Flag both, present the conflict, defer to the author.

---

## Phase 5: Verify

Confirm each resolution is correct and complete.

### Verification Checks

For each applied fix:

- [ ] The modified code is syntactically valid
- [ ] The fix addresses the reviewer's specific concern
- [ ] The fix doesn't conflict with other resolutions in the same run
- [ ] No unintended side effects on surrounding code

### Verification Statuses

| Status | Meaning |
|--------|---------|
| APPLIED | Fix applied and verified |
| DEFERRED | Requires human decision or out of scope |
| NEEDS_DISCUSSION | Conflicting comments or significant tradeoff |
| ANSWERED | Question responded to (no code change) |

---

## Phase 6: Report

Generate the resolution report.

### Report Structure

```markdown
# PR Comment Resolution Report

**PR:** #123 — Feature Title
**Date:** YYYY-MM-DD
**Comments processed:** N
**Resolved:** X | **Deferred:** Y | **Answered:** Z

## Items Needing Discussion

[DEFERRED and NEEDS_DISCUSSION items first]

## Resolutions by File

### path/to/file.ts

| Line | Reviewer | Type | Status | Resolution |
|------|----------|------|--------|-----------|
| 42 | @reviewer | BUG | APPLIED | Fixed null check |
| 78 | @reviewer | STYLE | APPLIED | Renamed variable |

## Questions Answered

[Draft responses for QUESTION type comments]

## Summary

| Type | Count | Resolved | Deferred |
|------|-------|----------|----------|
| BUG | N | N | 0 |
| DESIGN | N | N | N |
| STYLE | N | N | 0 |
| NIT | N | N | 0 |
| QUESTION | N | N | 0 |
| OUT_OF_SCOPE | N | 0 | N |
```
