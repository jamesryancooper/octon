---
title: Gather Input
description: Collect user context for workspace customization.
---

# Step 4: Gather Context from User

Ask these questions (skip if obvious from analysis):

| Question | Maps to |
|----------|---------|
| "What is this directory for?" (1-2 sentences) | `scope.md` description |
| "What types of work happen here?" | `scope.md` In Scope |
| "What should NOT be done here?" | `scope.md` Out of Scope |
| "What must be verified before work is complete?" | `checklists/complete.md` quality gates |
| "Any prerequisites to work here?" (deps, env vars) | `START.md` boot sequence |

## Idempotency

**Check:** Is user input already gathered?
- [ ] Checkpoint file exists: `checkpoints/create-workspace/<target>/04-input.complete`
- [ ] User responses cached

**If Already Complete:**
- Load cached responses
- Ask if user wants to modify
- Skip to next step if no changes

**Marker:** `checkpoints/create-workspace/<target>/04-input.complete`
