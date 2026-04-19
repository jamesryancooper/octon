---
title: Execution Role Hard Cutover
status: accepted
date: 2026-04-19
---

# 093 Execution Role Hard Cutover

## Decision

Hard-cut Octon from the legacy agency ontology to the execution-role subsystem.

The canonical durable noun is `execution role`. The only operator-facing role
kinds are:

- `orchestrator`
- `specialist`
- `verifier`
- `composition profile`

## Consequences

- `framework/execution-roles/**` becomes the sole canonical role subsystem.
- `framework/agency/**` and `instance/agency/runtime/**` are retired from the
  live authority path.
- `execution_role_ref` replaces `actor_ref` in active runtime contracts.
- `role-mediated` replaces `agent-augmented` in active workflow mode surfaces.
- Browser/API remain stage-only until runtime services, leases, replay, and
  proof satisfy the live-support gate.
