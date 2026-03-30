---
title: Agency Governance
description: Cross-agent governance shims and overlays for the agency subsystem.
---

# Agency Governance

`governance/` contains supporting delegation and memory overlays beneath the
singular constitutional kernel. `CONSTITUTION.md` is retained only as a
historical shim and is no longer part of the required execution path.

## Contracts

- `DELEGATION.md` — Delegation authority, handoff protocol, and escalation rules.
- `MEMORY.md` — Memory classes, retention boundaries, and privacy controls.
- `CONSTITUTION.md` — Historical constitutional shim retained for lineage only.

## Precedence

Agency kernel path is:

`framework/constitution/**` -> `instance/ingress/AGENTS.md` -> `runtime/agents/orchestrator/AGENT.md`

Supporting overlays may be consulted when needed:

`DELEGATION.md` -> `MEMORY.md`
