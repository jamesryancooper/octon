---
title: Compile Leaves
description: Compile ready PlanNodes to governed candidates and requests without executing them.
---

# Compile Leaves

Ready leaves may compile only to:

- `action-slice-v1` candidates;
- run-contract drafts;
- context-pack requests;
- authorization requests;
- rollback or compensation refs; and
- evidence requirements.

Each compiled leaf must retain a `plan-compile-receipt-v1` record with mission
digest, source plan digest, node id, candidate refs, evidence requirements,
rollback or compensation refs, validation result, and compiler version.

## Fail Closed

- Block compile when the mission digest is stale.
- Block compile when a node attempts direct execution.
- Block compile when a run contract, Context Pack Builder, or
  `authorize_execution` boundary would be bypassed.
- Block compile when required approvals, evidence, support refs, or rollback
  refs are missing.
- Block compile when a node would widen mission scope, support targets,
  capability admission, risk ceiling, or allowed action classes.
