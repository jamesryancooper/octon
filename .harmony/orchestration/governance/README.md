# Orchestration Governance

`governance/` contains orchestration-wide governance contracts.

## Contracts

- `incidents.md` - Canonical incident response governance and operating protocol.
- `capability-map-v1.yml` - Workflow autonomy classification (`agent-ready`,
  `agent-augmented`, `human-only`).
- `capability-map-v1.schema.json` - Validation schema for capability map
  updates.
- `workflow-system-audit-v1.yml` - Machine-readable contract for the workflow-system bounded audit.
- `workflow-system-audit-v1.schema.json` - Validation schema for workflow-system audit contract updates.

## Boundary

This surface is policy and governance only.
Executable workflows and mission state belong in `../runtime/`.

Autonomous workflow execution is permitted only when classification is
`agent-ready`. `agent-augmented` and `human-only` modes require non-autonomous
routing.
