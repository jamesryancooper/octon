---
title: Interaction Reference
description: Human review checkpoints for spec-to-implementation.
---

# Interaction Reference

## Review Checkpoint

The plan must be presented for human review before finalization.

## What to Present

1. `Profile Selection Receipt` summary:
   - selected `change_profile`
   - derived `release_state`
   - hard-gate facts and rationale
2. `Implementation Plan` summary:
   - milestones
   - highest-risk tasks
   - dependency ordering
3. `Impact Map (code, tests, docs, contracts)` coverage.
4. `Compliance Receipt` status.
5. `Exceptions/Escalations` list.

## Review Outcomes

| Outcome | Next Step |
| --- | --- |
| Approved | Finalize and write artifacts |
| Revisions requested | Return to relevant phase and regenerate |
| Escalation required | Stop and route exception/escalation request |

## Must Escalate (Do Not Auto-Resolve)

- profile tie-break ambiguity where both profiles appear required.
- Pre-1.0 transitional request without complete exception note.
- Semver source mismatch between `version.txt` and release manifest.
