---
name: contributor-guide
title: "Contributor Guide"
description: "Run /contributor-guide to generate documentation from project state."
---

# Step 5: Contributor Guide

## Input

- Validated input record (from step 1)
- All outputs from steps 2–4 (this skill reads project state)

## Purpose

Generate accurate contributor documentation by reading everything the
previous skills produced: module layout, justfile targets, contract files,
test structure, and CI config. This skill must run last because it
discovers and documents the actual project state.

## Actions

1. **Check skip list:**

   If `contributor-guide` is in the skip list, skip to step 6.

2. **Invoke:**

   ```text
   /contributor-guide {PROJECT_NAME} "{TEAM_NAME}" {TICKET_PREFIX}
   ```

   If team name or ticket prefix were not provided in the original
   arguments, use sensible defaults:

   - Team name: project name
   - Ticket prefix: optional (omit ticket segment when no ticket ID is used)

3. **Validate outputs:**

   - `AGENT.md` exists with Module Layout and Coding Conventions sections
   - `CONTRIBUTING.md` exists with Local Workflow section
   - `.github/PULL_REQUEST_TEMPLATE.md` exists
   - `.github/workflows/ci.yml` exists

4. **Spot-check accuracy:**

   - `AGENT.md` Module Layout lists the sub-packages that actually exist in `src/<package>/`
   - `CONTRIBUTING.md` Local Workflow references `just` targets that actually exist in `justfile`
   - CI workflow uses the correct Python version from `pyproject.toml`

## Idempotency

**Check:** Documentation files already exist.

- [ ] `AGENT.md` exists
- [ ] `CONTRIBUTING.md` exists
- [ ] `.github/workflows/ci.yml` exists

**If Already Complete:**

- The skill reads existing files and regenerates with updated state
- Safe to re-run (preserves custom sections)

**Marker:** `checkpoints/python-api-foundation/05-contributor-guide.complete`

## Error Messages

- Skill invocation failed: "CONTRIBUTOR_GUIDE_FAILED: /contributor-guide exited with errors: {details}"
- Accuracy check failed: "CONTRIBUTOR_GUIDE_STALE: {file} references {item} which does not exist in project"

## Output

- `AGENT.md` — AI agent orientation document
- `CONTRIBUTING.md` — human contributor guide
- `.github/PULL_REQUEST_TEMPLATE.md` — PR template
- `.github/workflows/ci.yml` — CI pipeline

## Proceed When

- [ ] `AGENT.md` exists with accurate module layout
- [ ] `CONTRIBUTING.md` exists with accurate workflow commands
- [ ] `.github/workflows/ci.yml` exists with correct Python version
