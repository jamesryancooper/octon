# Canonicalization Target Map

## Purpose

This document maps the implementation-ready proposal surfaces to the live
Harmony artifacts that would be required to promote them into canonical
authority surfaces under `.harmony/orchestration/`.

## Promotion Rule

A proposed surface is not canonical until it has:

- runtime discovery artifacts
- at least one practices document
- any required governance policy or addendum
- a validation hook

## Target Map

| Surface | Runtime Targets | Practices Targets | Governance Targets | Validation Targets |
|---|---|---|---|---|
| `campaigns` | `runtime/campaigns/README.md`, `runtime/campaigns/manifest.yml`, `runtime/campaigns/registry.yml` | `practices/campaign-lifecycle-standards.md` | optional addendum in `governance/README.md` | `runtime/campaigns/_ops/scripts/validate-campaigns.sh` |
| `automations` | `runtime/automations/README.md`, `runtime/automations/manifest.yml`, `runtime/automations/registry.yml` | `practices/automation-authoring-standards.md`, `practices/automation-operations.md` | `governance/automation-policy.md` | `runtime/automations/_ops/scripts/validate-automations.sh` |
| `watchers` | `runtime/watchers/README.md`, `runtime/watchers/manifest.yml`, `runtime/watchers/registry.yml` | `practices/watcher-authoring-standards.md`, `practices/watcher-operations.md` | `governance/watcher-signal-policy.md` | `runtime/watchers/_ops/scripts/validate-watchers.sh` |
| `queue` | `runtime/queue/README.md`, `runtime/queue/registry.yml`, `runtime/queue/schema.yml` | `practices/queue-operations-standards.md` | `governance/queue-safety-policy.md` | `runtime/queue/_ops/scripts/validate-queue.sh` |
| `runs` | `runtime/runs/README.md`, `runtime/runs/index.yml` | `practices/run-linkage-standards.md` | addendum to continuity evidence policy if needed | `runtime/runs/_ops/scripts/validate-runs.sh` |
| `incidents` | `runtime/incidents/README.md`, `runtime/incidents/manifest.yml`, `runtime/incidents/registry.yml` | `practices/incident-lifecycle-standards.md` | extend generic `governance/incidents.md`; keep product steps in `governance/production-incident-runbook.md` | `runtime/incidents/_ops/scripts/validate-incidents.sh` |

## Live Shared Continuity Authorities

The mature model depends on live cross-domain continuity authorities that are
not themselves orchestration runtime surfaces:

- `continuity/decisions/README.md`
  - orientation for continuity-owned decision evidence
- `continuity/decisions/<decision-id>/decision.json`
  - canonical store for routing and authority outcomes
- `continuity/decisions/retention.json`
  - retention and lifecycle handling for decision evidence
- `continuity/_meta/architecture/decisions-retention.md`
  - continuity architecture contract for decision evidence handling

## Existing Canonical Surfaces

The following already have live Harmony authority surfaces:

- `workflows`
- `missions`

`campaigns` remain optional and should only be promoted if mission coordination
pressure justifies the extra hierarchy.

Their mature-model promotion work is not to invent new top-level surface docs.
It is to add:

- explicit run/evidence linkage conventions
- explicit mission-to-run and mission-to-workflow linkage conventions
- lifecycle, routing, evidence, assurance, and operator guidance addenda from
  the new control documents in this package

## Workflow And Mission Integration Targets

If the mature model is promoted, the current Harmony surfaces should receive the
following addenda:

- `runtime/workflows/README.md`
  - add workflow execution context rules for `run_id`, `mission_id`,
    `automation_id`, `incident_id`, and `decision_id`
- `runtime/workflows/registry.yml`
  - add `execution_controls.cancel_safe: true|false` for machine-readable
    cancellation safety
- `practices/workflow-authoring-standards.md`
  - add requirements for run emission, decision linkage, and cancel-safe
    declarations
- `runtime/missions/README.md`
  - add mission linkage fields for `campaign_id`, `default_workflow_refs`, and
    `related_run_ids`
- `practices/mission-lifecycle-standards.md`
  - add mission/run/decision linkage expectations

## Canonicalization Sequence

1. Promote `runs`
2. Promote `automations`
3. Promote `incidents` runtime state, if desired
4. Promote `queue`
5. Promote `watchers`
6. Promote `campaigns` only if needed

This sequence keeps Harmony aligned to minimal sufficient complexity while still
allowing the mature model to land cleanly.
