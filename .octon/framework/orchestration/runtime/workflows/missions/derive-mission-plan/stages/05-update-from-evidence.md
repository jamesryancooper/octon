---
title: Update From Evidence
description: Update plan status only from retained runtime and validation evidence.
---

# Update From Evidence

Plan revisions after execution must cite retained evidence, not intention.

Accepted evidence refs include:

- Run Journal events and manifests;
- run lifecycle state;
- authorization receipts;
- effect-token receipts;
- evidence-store records;
- rollback posture;
- interventions;
- validation results; and
- closeout evidence.

## Boundary

Run control and retained run evidence remain canonical for execution truth.
Plan status may explain lineage and derived planning state, but it cannot repair
or replace run rollback truth, replay truth, or closeout evidence.

Stale or contradictory plan state must emit a `plan-drift-record-v1` record and
block further compile until the drift is resolved, staged, or escalated.
