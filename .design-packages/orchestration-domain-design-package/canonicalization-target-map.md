# Canonicalization Target Map

## Purpose

This document maps the implementation-ready orchestration surfaces defined by
this package to the live Harmony artifacts required to promote them into
canonical authority surfaces under `.harmony/orchestration/`.

## Promotion Rule

A package-defined surface is not live canonical until it has:

- runtime discovery artifacts
- at least one practices document
- any required governance policy or addendum
- a validation hook

## Target Map

| Surface | Runtime Targets | Practices Targets | Governance Targets | Validation Targets |
|---|---|---|---|---|
| `campaigns` | `runtime/campaigns/README.md`, `runtime/campaigns/manifest.yml`, `runtime/campaigns/registry.yml` | `practices/campaign-lifecycle-standards.md` | optional addendum in `governance/README.md` | `runtime/campaigns/_ops/scripts/validate-campaigns.sh` |
| `automations` | `runtime/automations/README.md`, `runtime/automations/manifest.yml`, `runtime/automations/registry.yml` | `practices/automation-authoring-standards.md`, `practices/automation-operations.md` | `governance/automation-policy.md` | `runtime/automations/_ops/scripts/validate-automations.sh` |
| `watchers` | `runtime/watchers/README.md`, `runtime/watchers/manifest.yml`, `runtime/watchers/registry.yml`, `runtime/watchers/<watcher-id>/watcher.yml`, `runtime/watchers/<watcher-id>/sources.yml`, `runtime/watchers/<watcher-id>/rules.yml`, `runtime/watchers/<watcher-id>/emits.yml`, `runtime/watchers/<watcher-id>/state/` | `practices/watcher-authoring-standards.md`, `practices/watcher-operations.md` | `governance/watcher-signal-policy.md` | `runtime/watchers/_ops/scripts/validate-watchers.sh` |
| `queue` | `runtime/queue/README.md`, `runtime/queue/registry.yml`, `runtime/queue/schema.yml`, `runtime/queue/pending/`, `runtime/queue/claimed/`, `runtime/queue/retry/`, `runtime/queue/dead-letter/`, `runtime/queue/receipts/` | `practices/queue-operations-standards.md` | `governance/queue-safety-policy.md` | `runtime/queue/_ops/scripts/validate-queue.sh` |
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
  - reaffirm the discovery order and mark `README.md` as subordinate guidance,
    not the canonical execution contract
- `runtime/workflows/registry.yml`
  - keep commands, access, and dependency summaries as routing projections only;
    do not make registry projections canonical for inputs, artifacts, or
    execution controls
- `runtime/workflows/_scaffold/template/workflow.yml`
  - add the orchestration-required top-level fields
    (`side_effect_class`, `execution_controls`, `coordination_key_strategy`,
    `executor_interface_version`) to the schema-backed definition contract
- `runtime/workflows/<group>/<workflow-id>/workflow.yml`
  - make `workflow.yml` the authoritative execution artifact for version,
    inputs, stage graph, artifacts, and execution controls
- `runtime/workflows/<group>/<workflow-id>/stages/`
  - keep stage assets executor-facing and subordinate to `workflow.yml`
- `practices/workflow-authoring-standards.md`
  - add requirements for schema-backed `workflow.yml` authority, stage-asset
    locality, run emission, decision linkage, and cancel-safe declarations
- `runtime/workflows/_ops/scripts/validate-workflows.sh`
  - validate `workflow.yml`, stage asset resolution, and non-authoritative
    registry/README drift checks
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

## Watcher Promotion Note

## Queue Promotion Note

When `queue` is promoted, live Harmony must preserve:

- the singular top-level surface path `runtime/queue/`
- queue-item definition authority in `contracts/queue-item-and-lease-contract.md`
  plus `contracts/schemas/queue-item-and-lease.schema.json`
- `registry.yml` and any local `schema.yml` as discovery/reference artifacts,
  not as the primary behavioral contract
- lane directories as mutable state and `receipts/` as append-only evidence
- the absence of `queue_id` or named-queue collection semantics in v1

When `watchers` are promoted, live Harmony must preserve:

- schema-backed authority for `watcher.yml`, `sources.yml`, `rules.yml`, and
  `emits.yml`
- watcher-runner-owned mutable state under `state/`
- emitted event lineage as an evidence layer distinct from watcher mutable
  state and distinct from registry projections
