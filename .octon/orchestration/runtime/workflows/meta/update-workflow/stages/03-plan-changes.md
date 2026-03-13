---
title: Plan Changes
description: Create a manifest of changes to apply.
---

# Step 3: Plan Changes

## Input

- Gap list from Step 2
- User preferences (--gaps-only, specific items)

## Purpose

Create an ordered, safe change plan that can be executed systematically.

## Actions

1. **Filter gaps by scope:**
   ```text
   If --gaps-only:
     Include only gap remediation items (frontmatter, idempotency, versioning)
     Exclude content/structure changes

   If specific items requested:
     Filter to requested items only
   ```

2. **Order changes by safety:**
   ```text
   Order 1: Read-only/additive (lowest risk)
     - Add missing frontmatter fields
     - Add Version History section

   Order 2: Section additions
     - Add Idempotency sections to steps
     - Add parallel execution notes

   Order 3: Content modifications (higher risk)
     - Update existing sections
     - Fix broken links
   ```

3. **Plan version increment:**
   ```text
   Determine new version based on changes:
     - Gap fields only: patch bump (1.0.0 -> 1.0.1)
     - New sections: minor bump (1.0.0 -> 1.1.0)
     - Structure changes: major bump (1.0.0 -> 2.0.0)
   ```

4. **Generate change manifest:**
   ```json
   {
     "changes": [
       {
         "id": "change-001",
         "gap_id": "gap-001",
         "file": "00-overview.md",
         "action": "add_frontmatter_field",
         "field": "depends_on",
         "value": "[]",
         "order": 1
       }
     ]
   }
   ```

5. **Present plan to user:**
   ```markdown
   ## Proposed Changes

   **Version:** 1.0.0 -> 1.0.1

   ### Frontmatter Updates (4 changes)
   - Add `depends_on: []`
   - Add `checkpoints: {enabled: true, storage: "..."}`
   - Add `parallel_steps: []`
   - Update `version: "1.0.1"`

   ### Section Additions (8 changes)
   - Add ## Idempotency to 01-define-scope.md
   - Add ## Idempotency to 02-audit.md
   - ...
   - Add ## Version History to 00-overview.md

   **Total:** 12 changes
   **Risk:** Low (all additive)

   Proceed? [Y/n]
   ```

6. **Get user confirmation:**
   ```text
   If user confirms: Proceed to execution
   If user declines: Allow editing change list
   If user cancels: Exit workflow
   ```

## Idempotency

**Check:** Is change plan already created?
- [ ] `checkpoints/update-workflow/<workflow-id>/plan.json` exists
- [ ] Plan is for current gap list (hash match)

**If Already Complete:**
- Load cached plan
- Ask user to confirm or regenerate
- Skip to next step if confirmed

**Marker:** `checkpoints/update-workflow/<workflow-id>/03-plan.complete`

## Change Manifest Schema

```json
{
  "workflow_id": "refactor",
  "current_version": "1.0.0",
  "new_version": "1.0.1",
  "created_at": "2025-01-14T10:00:00Z",
  "confirmed_at": null,
  "changes": [
    {
      "id": "change-001",
      "gap_id": "gap-001",
      "file": "00-overview.md",
      "location": "frontmatter",
      "action": "add_field",
      "details": {
        "field": "depends_on",
        "value": []
      },
      "order": 1,
      "status": "pending"
    }
  ],
  "summary": {
    "total": 12,
    "by_file": {"00-overview.md": 5, "01-define-scope.md": 1, ...},
    "by_action": {"add_field": 4, "add_section": 8}
  }
}
```

## Change Actions

| Action | Description | Risk |
|--------|-------------|------|
| add_field | Add frontmatter field | Low |
| add_section | Add markdown section | Low |
| update_field | Modify frontmatter field | Medium |
| update_section | Modify markdown section | Medium |
| rename_file | Rename step file | High |
| reorder_steps | Change step numbering | High |

## Output

- Ordered change manifest
- Version increment determined
- User confirmation obtained
- Ready for execution

## Proceed When

- [ ] Change manifest generated
- [ ] Version increment determined
- [ ] User has confirmed the plan
