# Canonicalization Target Map

## Purpose

This document maps the implementation-ready orchestration surfaces defined by
this package to the live Octon artifacts required to promote them into
canonical authority surfaces under `.octon/orchestration/`.

This document is planning-only in the current remediation. It does not claim
that live authority reconciliation is complete.

## Promotion Rule

A package-defined surface is not live canonical until it has:

- runtime discovery artifacts
- at least one practices document
- any required governance policy or addendum
- a validation hook

## Target Map

| Surface | Runtime Targets | Practices Targets | Governance Targets | Validation Targets |
|---|---|---|---|---|
| `campaigns` | `runtime/campaigns/README.md`, `runtime/campaigns/manifest.yml`, `runtime/campaigns/registry.yml`, `runtime/campaigns/<campaign-id>/campaign.yml`, `runtime/campaigns/<campaign-id>/log.md` | `practices/campaign-lifecycle-standards.md` | optional addendum in `governance/README.md` | `runtime/campaigns/_ops/scripts/validate-campaigns.sh` |
| `automations` | `runtime/automations/README.md`, `runtime/automations/manifest.yml`, `runtime/automations/registry.yml` | `practices/automation-authoring-standards.md`, `practices/automation-operations.md` | `governance/automation-policy.md` | `runtime/automations/_ops/scripts/validate-automations.sh` |
| `watchers` | `runtime/watchers/README.md`, `runtime/watchers/manifest.yml`, `runtime/watchers/registry.yml`, `runtime/watchers/<watcher-id>/watcher.yml`, `runtime/watchers/<watcher-id>/sources.yml`, `runtime/watchers/<watcher-id>/rules.yml`, `runtime/watchers/<watcher-id>/emits.yml`, `runtime/watchers/<watcher-id>/state/` | `practices/watcher-authoring-standards.md`, `practices/watcher-operations.md` | `governance/watcher-signal-policy.md` | `runtime/watchers/_ops/scripts/validate-watchers.sh` |
| `queue` | `runtime/queue/README.md`, `runtime/queue/registry.yml`, `runtime/queue/schema.yml`, `runtime/queue/pending/`, `runtime/queue/claimed/`, `runtime/queue/retry/`, `runtime/queue/dead-letter/`, `runtime/queue/receipts/` | `practices/queue-operations-standards.md` | `governance/queue-safety-policy.md` | `runtime/queue/_ops/scripts/validate-queue.sh` |
| `runs` | `runtime/runs/README.md`, `runtime/runs/index.yml`, `runtime/runs/by-surface/workflows/`, `runtime/runs/by-surface/missions/`, `runtime/runs/by-surface/automations/`, `runtime/runs/by-surface/incidents/`, `runtime/runs/<run-id>.yml` | `practices/run-linkage-standards.md` | addendum to continuity evidence policy if needed | `runtime/runs/_ops/scripts/validate-runs.sh` |
| `incidents` | `runtime/incidents/README.md`, `runtime/incidents/index.yml`, `runtime/incidents/<incident-id>/incident.yml`, `runtime/incidents/<incident-id>/actions.yml`, `runtime/incidents/<incident-id>/timeline.md`, `runtime/incidents/<incident-id>/closure.md` | `practices/incident-lifecycle-standards.md` | extend generic `governance/incidents.md`; keep product steps in `governance/production-incident-runbook.md` | `runtime/incidents/_ops/scripts/validate-incidents.sh` |

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

The following already have live Octon authority surfaces:

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

If the mature model is promoted, the current Octon surfaces should receive the
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
  - define mission authority order as `registry.yml -> mission.yml ->
    mission.md`; keep tasks/log/context subordinate to the canonical mission
    object
- `runtime/missions/registry.yml`
  - keep discovery and lifecycle projections lightweight; do not make registry
    entries canonical for mission ownership, success criteria, or linkage
- `runtime/missions/_scaffold/template/mission.yml`
  - add the schema-backed mission object with lifecycle, ownership, success
    criteria, and linkage fields
- `runtime/missions/<mission-id>/mission.yml`
  - make `mission.yml` the authoritative mission artifact for identity,
    lifecycle, and cross-surface linkage
- `runtime/missions/<mission-id>/mission.md`
  - keep goal, scope, and operator narrative subordinate to `mission.yml`
- `practices/mission-lifecycle-standards.md`
  - add `mission.yml` authority, mission/run/decision linkage expectations, and
    archive semantics
- `runtime/missions/_ops/scripts/validate-missions.sh`
  - validate `mission.yml`, registry projection drift, and archive-state
    semantics

## Automation Promotion Targets

If `automations` are promoted, the live Octon surface should receive the
following artifacts and constraints:

- `runtime/automations/README.md`
  - define authority order as `manifest.yml -> registry.yml -> automation.yml +
    trigger.yml + bindings.yml + policy.yml -> state/`; keep README
    explanatory only
- `runtime/automations/manifest.yml`
  - discovery identity, summary, and canonical path projection only
- `runtime/automations/registry.yml`
  - lightweight routing metadata, dependency projections, and state pointers;
    do not make registry fields canonical for trigger or policy semantics
- `runtime/automations/_scaffold/template/automation.yml`
  - canonical automation identity, workflow target, owner, and lifecycle state
- `runtime/automations/_scaffold/template/trigger.yml`
  - canonical schedule/event selection contract
- `runtime/automations/_scaffold/template/bindings.yml`
  - canonical defaults and event-binding contract, including the empty-object
    case
- `runtime/automations/_scaffold/template/policy.yml`
  - canonical concurrency, idempotency, retry, and incident-escalation policy
- `runtime/automations/<automation-id>/`
  - preserve the split definition layer rather than collapsing authority into
    registry metadata or prose
- `practices/automation-authoring-standards.md`
  - require file-level schema-backed authority and forbid trigger selection in
    bindings or policy
- `practices/automation-operations.md`
  - define pause/resume, replay, retry, and state/evidence operating guidance
- `governance/automation-policy.md`
  - define how automation launch authority composes with workflow governance,
    approvals, incident thresholds, and objective scope
- `runtime/automations/_ops/scripts/validate-automations.sh`
  - validate `automation.yml`, `trigger.yml`, `bindings.yml`, and `policy.yml`
    first, then drift-check registry and state projections

## Canonicalization Sequence

1. Promote `runs`
2. Promote `automations`
3. Promote `incidents` runtime state, if desired
4. Promote `queue`
5. Promote `watchers`
6. Promote `campaigns` only if needed

This sequence keeps Octon aligned to minimal sufficient complexity while still
allowing the mature model to land cleanly.

## Runs Promotion Note

When `runs` is promoted, live Octon must preserve:

- `runtime/runs/README.md` as operator orientation only
- `runtime/runs/index.yml` as the global discovery and lookup projection
- `runtime/runs/<run-id>.yml` as the canonical orchestration-facing run
  object/state record
- `runtime/runs/by-surface/` as non-authoritative reverse-lookup projections
- `continuity/runs/<run-id>/` as the durable evidence authority

## Campaign Promotion Note

When `campaigns` are promoted, live Octon must preserve:

- `runtime/campaigns/README.md` as operator orientation only
- `runtime/campaigns/manifest.yml` as lightweight surface discovery
- `runtime/campaigns/registry.yml` as campaign lookup projection only
- `runtime/campaigns/<campaign-id>/campaign.yml` as the canonical campaign
  object/state record
- `runtime/campaigns/<campaign-id>/log.md` as subordinate coordination notes
  and waiver/evidence context
- campaign optionality and the rule that campaigns do not become execution
  containers or a second mission system

## Queue Promotion Note

When `queue` is promoted, live Octon must preserve:

- the singular top-level surface path `runtime/queue/`
- queue-item definition authority in `contracts/queue-item-and-lease-contract.md`
  plus `contracts/schemas/queue-item-and-lease.schema.json`
- `registry.yml` and any local `schema.yml` as discovery/reference artifacts,
  not as the primary behavioral contract
- lane directories as mutable state and `receipts/` as append-only evidence
- the absence of `queue_id` or named-queue collection semantics in v1

## Watcher Promotion Note

When `watchers` are promoted, live Octon must preserve:

- schema-backed authority for `watcher.yml`, `sources.yml`, `rules.yml`, and
  `emits.yml`
- watcher-runner-owned mutable state under `state/`
- emitted event lineage as an evidence layer distinct from watcher mutable
  state and distinct from registry projections

## Incident Promotion Note

When `incidents` are promoted, live Octon must preserve:

- `governance/incidents.md` as the governance authority for severity, closure
  authority, and escalation rules
- `runtime/incidents/README.md` as operator orientation only
- `runtime/incidents/index.yml` as the global incident lookup projection
- `runtime/incidents/<incident-id>/incident.yml` as the canonical incident
  object/state record
- `runtime/incidents/<incident-id>/actions.yml` as subordinate schema-backed
  coordination data when executable response actions exist
- `runtime/incidents/<incident-id>/timeline.md` and `closure.md` as
  operator-visible evidence that must not outrank `incident.yml` or linked run
  and decision evidence
