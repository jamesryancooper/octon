---
title: Interaction Reference
description: Human review checkpoints for spec-to-implementation.
---

# Interaction Reference

## Review Checkpoint

The plan must be presented to a human before being considered final.

### What to Present

1. **Executive summary** — 2-3 sentences on scope and approach
2. **Key decisions** — Architectural choices that affect the plan
3. **Assumptions** — Listed with `[ASSUMPTION]` tags
4. **Open questions** — Items that need human input
5. **Risk highlights** — Top 3 risks with proposed mitigations

### Review Outcomes

| Outcome | Next Step |
|---------|-----------|
| Approved | Plan is final; write to output |
| Revisions requested | Return to appropriate phase with feedback |
| Questions answered | Incorporate answers, regenerate affected sections |
| Scope change | Re-parse spec with new constraints |

### When NOT to Proceed Without Review

- Spec has more than 3 ambiguities
- Plan exceeds 20 tasks
- Architectural decisions have >2 valid approaches
- Risk register contains HIGH-impact items
