---
title: Copy Templates
description: Copy workspace template structure to target directory.
---

# Step 5: Copy Template Structure

Copy the template directory structure to the target:

```text
.harmony/scaffolding/templates/harmony/    →    <target>/.harmony/
├── START.md                            ├── START.md
├── scope.md                            ├── scope.md
├── conventions.md                      ├── conventions.md
├── continuity/                         ├── continuity/
│   ├── log.md                          │   ├── log.md
│   └── tasks.json                      │   └── tasks.json
└── quality/                            └── quality/
    └── done.md                                 └── done.md
```

## Idempotency

**Check:** Are templates already copied?
- [ ] Directory `<target>/.harmony/` exists
- [ ] Core files present (START.md, scope.md, conventions.md)

**If Already Complete:**
- Verify file structure
- Skip to next step if complete

**Marker:** `checkpoints/create-workspace/<target>/05-copy.complete`
