# Orchestration Governance

`governance/` contains orchestration-wide governance contracts.

## Contracts

- `approver-authority-registry.json` - Canonical approver authority registry for privileged orchestration actions.
- `automation-policy.md` - Canonical policy for unattended automation launch behavior.
- `queue-safety-policy.md` - Canonical safety policy for queue claim, ack, retry, and dead-letter handling.
- `watcher-signal-policy.md` - Canonical policy for watcher signal emission and routing-hint posture.
- `incidents.md` - Canonical incident governance contract for severity, authority, escalation, and closure.
- `production-incident-runbook.md` - Product-specific operational response guide for production rollback and investigation.
- `capability-map-v1.yml` - Workflow autonomy classification (`execution-role-ready`,
  `role-mediated`, `human-only`).
- `capability-map-v1.schema.json` - Validation schema for capability map
  updates.
- `workflow-system-audit-v1.yml` - Machine-readable contract for the workflow-system bounded audit.
- `workflow-system-audit-v1.schema.json` - Validation schema for workflow-system audit contract updates.

## Boundary

This surface is policy and governance only.
Executable workflows and mission state belong in `../runtime/`.

Autonomous workflow execution is permitted only when classification is
`execution-role-ready`. `role-mediated` and `human-only` modes require non-autonomous
routing.
