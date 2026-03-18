---
name: contributor-guide
title: "Contributor Guide"
description: "Run /contributor-guide last, reading all outputs."
---

# Step 6: Contributor Guide

## Input

- All outputs from steps 2–5
- Validated input record (from step 1)

## Purpose

Generate accurate project documentation by reading the actual outputs
of all previous skills. This must run last to ensure documentation
reflects the true state of the project.

## Actions

1. **Check skip list:**

   If `contributor-guide` is in the skip list, skip to step 7.

2. **Invoke the skill:**

   ```text
   /contributor-guide {PROJECT_NAME} --author "{AUTHOR}" --license MIT
   ```

3. **Validate outputs:**

   After the skill completes, confirm these exist:

   - `CLAUDE.md` with accurate module layout and build commands
   - `CONTRIBUTING.md` with development setup and PR process
   - `Docs/architecture/overview.md` with system diagram
   - `.github/PULL_REQUEST_TEMPLATE.md`
   - `.gitignore` with Swift-appropriate patterns

4. **Cross-validate documentation:**

   - Verify `CLAUDE.md` module layout matches actual `Sources/` structure
   - Verify `CONTRIBUTING.md` build commands match `Package.swift` targets
   - Verify architecture overview mentions all implemented components

## Idempotency

**Check:** Documentation already exists and is accurate.

- [ ] `CLAUDE.md` exists with module layout matching `Sources/`
- [ ] `CONTRIBUTING.md` exists with valid build commands
- [ ] `Docs/architecture/overview.md` exists

**If Already Complete:**

- Skip to step 7
- Re-run if previous skills added new modules

**Marker:** `checkpoints/swift-macos-app-foundation/06-contributor-guide.complete`

## Error Messages

- Skill failed: "CONTRIBUTOR_GUIDE_FAILED: /contributor-guide exited with errors: {details}"
- Stale docs: "DOCS_STALE: CLAUDE.md module layout does not match Sources/ — re-run /contributor-guide"

## Output

- `CLAUDE.md` — AI agent orientation
- `CONTRIBUTING.md` — developer onboarding
- `Docs/architecture/overview.md` — architecture reference
- `.github/PULL_REQUEST_TEMPLATE.md` — PR template
- `.gitignore` — standard ignores

## Proceed When

- [ ] `CLAUDE.md` exists with accurate module layout
- [ ] `CONTRIBUTING.md` exists with accurate workflow
- [ ] Architecture overview exists
