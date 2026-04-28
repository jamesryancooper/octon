# Instance Governance Policy Overlays

This directory is reserved for repo-specific governance policy overlays that
are valid only when covered by enabled framework overlay points.

## Engagement Compiler Policies

These policies narrow prepare-only Work Package readiness. They do not replace
run contracts, grant bundles, authorized-effect tokens, or existing runtime
authorization.

- `engagement-work-package-compiler.yml`: Work Package readiness gates for
  approvals, runtime authorization, support/capability reconciliation,
  connector posture, context-pack readiness, rollback, evidence profile
  selection, and Decision Request generation.
- `evidence-profiles.yml`: Risk-scaled evidence profile selection for
  orientation-only, stage-only, and repo-consequential compiler outputs.
- `preflight-evidence-lane.yml`: Narrow preauthorization lane for adoption and
  orientation evidence that forbids project-code mutation and external effects.

## Connector Admission Policies

Connector Admission Runtime v4 policies keep connector posture subordinate to
support targets, capability packs, run contracts, execution authorization, and
retained evidence.

- `connector-admission.yml`: operation-level admission modes, live-effect
  gates, drift policy, human-decision requirements, and deferred scope.
- `connector-credentials.yml`: credential classes and fail-closed handling.
- `connector-data-boundaries.yml`: egress, retention, redaction, disclosure,
  and data movement posture.
- `connector-evidence-profiles.yml`: risk-scaled connector evidence profiles.

These policies do not authorize connector execution. Material connector
operations remain bound to governed runs, context packs, authorization grants,
authorized-effect token verification, run journals, and connector receipts.

Related machine-readable posture and path-family declarations live outside this
policy directory:

- `.octon/instance/governance/connectors/{registry.yml,posture.yml}`
- `.octon/instance/governance/engagements/path-families.yml`
