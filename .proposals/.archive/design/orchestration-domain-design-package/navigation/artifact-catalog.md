# Artifact Catalog

This file is the exhaustive discovery index for the artifacts in this temporary
design package. It keeps the current paths intact and groups files by role so
an AI agent can find the right material without guessing from the flat root
listing.

## Discovery Flow

1. Start with `README.md` for package scope, conclusions, and the recommended
   reading order.
2. Use this catalog when you need a complete file-level inventory.
3. Use subtree readmes when narrowing scope:
   - `contracts/README.md`
   - `implementation/README.md`
   - `history/adr/README.md`
4. Treat this package as implementation-scoped design material. Long-lived
   canonical authority belongs in `.harmony/` after promotion.

## Entry Points And Navigation

- `README.md`
- `navigation/artifact-catalog.md`
- `navigation/source-of-truth-map.md`
- `conformance/README.md`

## Core Normative Specification

- `normative/architecture/domain-model.md`
- `normative/architecture/runtime-architecture.md`
- `normative/execution/orchestration-execution-model.md`
- `normative/execution/dependency-resolution.md`
- `normative/execution/concurrency-control-model.md`
- `normative/governance/approval-and-override-contract.md`
- `normative/execution/automation-bindings-contract.md`
- `normative/execution/run-liveness-and-recovery-spec.md`
- `normative/governance/approver-authority-model.md`
- `normative/assurance/surface-artifact-schemas.md`
- `normative/execution/orchestration-lifecycle.md`
- `normative/governance/governance-and-policy.md`
- `normative/assurance/failure-model.md`
- `normative/assurance/observability.md`

## Control, Assurance, And Promotion Docs

- `normative/execution/lifecycle-and-state-machine-spec.md`
- `normative/governance/routing-authority-and-execution-control.md`
- `normative/governance/evidence-observability-and-retention-spec.md`
- `normative/assurance/assurance-and-acceptance-matrix.md`
- `normative/assurance/implementation-readiness.md`
- `navigation/source-of-truth-map.md`
- `normative/assurance/operator-and-authoring-runbook.md`
- `navigation/canonicalization-target-map.md`

## Conformance

- `conformance/README.md`
- `conformance/validate_scenarios.py`
- `conformance/scenarios/routing/`
- `conformance/scenarios/scheduling/`
- `conformance/scenarios/recovery/`

## Supporting Context, Examples, And Historical Inputs

- `history/adoption-roadmap.md`
- `history/alignment-with-harmony-goal.md`
- `reference/canonical-surface-taxonomy.md`
- `reference/end-to-end-flow.md`
- `reference/example-orchestration-charter.md`
- `reference/failure-modes-and-safety-analysis.md`
- `reference/layered-model.md`
- `history/mature-harmony-orchestration-model.md`
- `history/profile-selection-and-compliance.md`
- `reference/reference-examples.md`
- `reference/runtime-shape-and-directory-structure.md`
- `reference/surface-criticality-and-ranking.md`
- `history/surface-shape-architectural-review.md`

## Implementation Contracts

- `contracts/README.md`
- `contracts/versioning-and-compatibility-policy.md`
- `contracts/cross-surface-reference-contract.md`
- `contracts/decision-record-contract.md`
- `contracts/workflow-execution-contract.md`
- `contracts/mission-object-contract.md`
- `contracts/campaign-object-contract.md`
- `contracts/automation-execution-contract.md`
- `contracts/coordination-lock-contract.md`
- `contracts/watcher-definition-contract.md`
- `contracts/watcher-event-contract.md`
- `contracts/queue-item-and-lease-contract.md`
- `contracts/run-linkage-contract.md`
- `contracts/incident-object-contract.md`
- `contracts/discovery-and-authority-layer-contract.md`
- `contracts/mission-workflow-binding-contract.md`
- `contracts/campaign-mission-coordination-contract.md`

## Contract Schemas

- `contracts/schemas/approval-and-override.schema.json`
- `contracts/schemas/approver-authority-registry.schema.json`
- `contracts/schemas/automation-definition.schema.json`
- `contracts/schemas/automation-bindings.schema.json`
- `contracts/schemas/automation-execution.schema.json`
- `contracts/schemas/automation-policy.schema.json`
- `contracts/schemas/automation-trigger.schema.json`
- `contracts/schemas/campaign-object.schema.json`
- `contracts/schemas/coordination-lock.schema.json`
- `contracts/schemas/decision-record.schema.json`
- `contracts/schemas/incident-actions.schema.json`
- `contracts/schemas/incident-object.schema.json`
- `contracts/schemas/mission-object.schema.json`
- `contracts/schemas/queue-item-and-lease.schema.json`
- `contracts/schemas/run-linkage.schema.json`
- `contracts/schemas/watcher-definition.schema.json`
- `contracts/schemas/watcher-sources.schema.json`
- `contracts/schemas/watcher-event.schema.json`
- `contracts/schemas/watcher-rules.schema.json`
- `contracts/schemas/watcher-emits.schema.json`
- `contracts/schemas/workflow-execution.schema.json`

## Valid Proof Fixtures

- `contracts/fixtures/valid/approval-and-override.valid.json`
- `contracts/fixtures/valid/approver-authority-registry.valid.json`
- `contracts/fixtures/valid/automation-definition.valid.json`
- `contracts/fixtures/valid/automation-bindings.valid.json`
- `contracts/fixtures/valid/automation-execution.valid.json`
- `contracts/fixtures/valid/automation-policy.valid.json`
- `contracts/fixtures/valid/automation-trigger.valid.json`
- `contracts/fixtures/valid/campaign-object.valid.json`
- `contracts/fixtures/valid/coordination-lock.valid.json`
- `contracts/fixtures/valid/decision-record.valid.json`
- `contracts/fixtures/valid/incident-actions.valid.json`
- `contracts/fixtures/valid/incident-object.valid.json`
- `contracts/fixtures/valid/mission-object.valid.json`
- `contracts/fixtures/valid/queue-item-and-lease.valid.json`
- `contracts/fixtures/valid/run-linkage.valid.json`
- `contracts/fixtures/valid/watcher-definition.valid.json`
- `contracts/fixtures/valid/watcher-sources.valid.json`
- `contracts/fixtures/valid/watcher-event.valid.json`
- `contracts/fixtures/valid/watcher-rules.valid.json`
- `contracts/fixtures/valid/watcher-emits.valid.json`
- `contracts/fixtures/valid/workflow-execution.valid.json`

## Invalid Proof Fixtures

- `contracts/fixtures/invalid/approval-and-override.invalid.json`
- `contracts/fixtures/invalid/approver-authority-registry.invalid.json`
- `contracts/fixtures/invalid/automation-definition.invalid.json`
- `contracts/fixtures/invalid/automation-bindings.invalid.json`
- `contracts/fixtures/invalid/automation-execution.invalid.json`
- `contracts/fixtures/invalid/automation-policy.invalid.json`
- `contracts/fixtures/invalid/automation-trigger.invalid.json`
- `contracts/fixtures/invalid/campaign-object.invalid.json`
- `contracts/fixtures/invalid/coordination-lock.invalid.json`
- `contracts/fixtures/invalid/decision-record.invalid.json`
- `contracts/fixtures/invalid/incident-actions.invalid.json`
- `contracts/fixtures/invalid/incident-object.invalid.json`
- `contracts/fixtures/invalid/mission-object.invalid.json`
- `contracts/fixtures/invalid/queue-item-and-lease.invalid.json`
- `contracts/fixtures/invalid/run-linkage.invalid.json`
- `contracts/fixtures/invalid/watcher-definition.invalid.json`
- `contracts/fixtures/invalid/watcher-sources.invalid.json`
- `contracts/fixtures/invalid/watcher-event.invalid.json`
- `contracts/fixtures/invalid/watcher-rules.invalid.json`
- `contracts/fixtures/invalid/watcher-emits.invalid.json`
- `contracts/fixtures/invalid/workflow-execution.invalid.json`

## Implementation Blueprint

- `implementation/README.md`
- `implementation/01-system-purpose-and-production-architecture.md`
- `implementation/02-service-boundaries-and-data-model.md`
- `implementation/03-state-machines-and-algorithms.md`
- `implementation/04-runtime-enforcement-and-failure-handling.md`
- `implementation/05-first-slice-and-implementation-order.md`

## Surface Deep Dives

- `reference/surfaces/workflows.md`
- `reference/surfaces/missions.md`
- `reference/surfaces/automations.md`
- `reference/surfaces/watchers.md`
- `reference/surfaces/queue.md`
- `reference/surfaces/runs.md`
- `reference/surfaces/incidents.md`
- `reference/surfaces/campaigns.md`

## Architectural Decision Records

- `history/adr/README.md`
- `history/adr/0001-queue-is-automation-ingress-only.md`
- `history/adr/0002-runs-are-projection-and-linkage-layer.md`
- `history/adr/0003-campaigns-remain-optional.md`
- `history/adr/0004-governance-runtime-continuity-separation.md`
- `history/adr/0005-workflow-recurrence-stays-outside-workflows.md`
- `history/adr/0006-decision-records-are-first-class-continuity-evidence.md`
- `history/adr/0007-queue-claims-require-claimed-at-and-claim-token.md`
- `history/adr/0008-replace-is-cancel-safe-latest-wins.md`

## Fast Lookup Hints

- Need the intended reading path: `README.md`
- Need the full contract set: `contracts/README.md`
- Need machine-checkable object definitions: `contracts/schemas/`
- Need positive or negative proof examples: `contracts/fixtures/valid/` and
  `contracts/fixtures/invalid/`
- Need implementation sequencing: `implementation/README.md`
- Need per-surface intent: `reference/surfaces/`
- Need rationale behind major decisions: `history/adr/README.md`
