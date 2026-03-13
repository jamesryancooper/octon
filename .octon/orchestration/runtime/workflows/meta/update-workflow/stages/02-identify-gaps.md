---
title: Identify Gaps
description: Compare workflow against requirements and identify needed changes.
---

# Step 2: Identify Gaps

## Input

- Audit results from Step 1
- Gap requirements from `.octon/cognition/runtime/context/workflow-gaps.md`
- Quality requirements from `.octon/cognition/runtime/context/workflow-quality.md`

## Purpose

Systematically identify all gaps between current state and requirements.

## Actions

1. **Check frontmatter gaps:**
   ```text
   Required fields:
   - [ ] title (string)
   - [ ] description (string, max 160 chars)
   - [ ] access (human | agent)
   - [ ] version (semantic format)
   - [ ] depends_on (array)
   - [ ] checkpoints ({enabled, storage})
   - [ ] parallel_steps (array)

   For each missing: Add to gap list
   ```

2. **Check idempotency gaps:**
   ```text
   For each step file:
     Has ## Idempotency section?
     - [ ] Check clause present
     - [ ] If Already Complete clause present
     - [ ] Marker path specified

   For each missing: Add to gap list
   ```

3. **Check version history gap:**
   ```text
   Does overview have ## Version History section?
   - Present with entries: OK
   - Missing: Add to gap list
   ```

4. **Check parallel opportunities:**
   ```text
   If parallel_steps is empty:
     Analyze step dependencies
     Identify potential parallel pairs
     If opportunities found: Add to gap list
   ```

5. **Check content gaps:**
   ```text
   - [ ] Prerequisites section has content
   - [ ] Failure conditions section has content
   - [ ] All step links resolve
   - [ ] No placeholder text remains
   ```

6. **Check harness integration gaps (if access: human):**
   ```text
   If access is "human":
     - [ ] Command file exists in .octon/capabilities/runtime/commands/ or .octon/capabilities/runtime/commands/
     - [ ] Symlink exists in .cursor/commands/ (if directory exists)
     - [ ] Symlink exists in .claude/commands/ (if directory exists)
     - [ ] Symlinks resolve correctly (not broken)

   For each missing: Add to gap list
   ```

7. **Categorize gaps:**
   ```text
   For each gap:
     - Severity: critical | major | minor
     - Effort: low | medium | high
     - Risk: low | medium | high
   ```

## Idempotency

**Check:** Is gap identification already complete?
- [ ] `checkpoints/update-workflow/<workflow-id>/gaps.json` exists

**If Already Complete:**
- Load cached gap list
- Ask user if they want to re-analyze
- Skip to next step if no re-analysis needed

**Marker:** `checkpoints/update-workflow/<workflow-id>/02-gaps.complete`

## Gap List Schema

```json
{
  "workflow_id": "refactor",
  "identified_at": "2025-01-14T10:00:00Z",
  "gaps": [
    {
      "id": "gap-001",
      "category": "frontmatter",
      "item": "depends_on field",
      "current": "missing",
      "required": "array (can be empty)",
      "severity": "minor",
      "effort": "low",
      "risk": "low",
      "fix": "Add depends_on: [] to frontmatter"
    },
    {
      "id": "gap-002",
      "category": "idempotency",
      "item": "01-define-scope.md Idempotency section",
      "current": "missing",
      "required": "## Idempotency with Check, If Already Complete, Marker",
      "severity": "minor",
      "effort": "medium",
      "risk": "low",
      "fix": "Add Idempotency section to step file"
    }
  ],
  "summary": {
    "total": 12,
    "by_severity": {"critical": 0, "major": 2, "minor": 10},
    "by_effort": {"low": 8, "medium": 4, "high": 0},
    "by_category": {"frontmatter": 4, "idempotency": 7, "versioning": 1}
  }
}
```

## Gap Categories

| Category | Examples |
|----------|----------|
| frontmatter | Missing version, depends_on, checkpoints, parallel_steps |
| idempotency | Steps missing ## Idempotency section |
| versioning | Missing version field, missing Version History |
| structure | Missing verify step, broken links |
| content | Missing prerequisites, vague error messages |
| harness | Missing command file, missing/broken symlinks in .cursor/ or .claude/ |

## Output

- Complete gap list with categories
- Severity/effort/risk assessment for each
- Summary statistics
- Ready for change planning

## Proceed When

- [ ] All gap categories checked (including harness integration)
- [ ] Each gap categorized and assessed
- [ ] Summary generated
