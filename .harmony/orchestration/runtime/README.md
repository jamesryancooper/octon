# Orchestration Runtime

`runtime/` contains executable orchestration artifacts.

## Contents

| Path | Purpose | Discovery |
|------|---------|-----------|
| `workflows/` | Multi-step procedures and workflow contracts | `workflows/manifest.yml` |
| `missions/` | Time-bounded mission artifacts and lifecycle state | `missions/registry.yml` |
| `automations/` | Event and schedule-triggered launch policy | `automations/manifest.yml` |
| `watchers/` | Long-lived detectors that emit canonical watcher events | `watchers/manifest.yml` |
| `runs/` | Orchestration-facing run state and projections | `runs/index.yml` |
| `incidents/` | Runtime incident state and closure evidence | `incidents/index.yml` |
| `queue/` | Shared durable intake buffering for queueable work | `queue/registry.yml` |
| `_coordination/` | Internal lock state for target-global coordination | direct path |
| `_ops/scripts/validate-orchestration-runtime.sh` | Runtime validation dispatcher for live and planned orchestration surfaces | direct invocation |

## Operator Inspection

Preferred operator entry points for this runtime are:

- `harmony orchestration summary --surface all`
- `harmony orchestration lookup --run-id <run-id>`
- `harmony orchestration lookup --decision-id <decision-id>`
- `harmony orchestration lookup --incident-id <incident-id>`
- `harmony orchestration incident closure-readiness --incident-id <incident-id>`

Thin wrappers for common operator tasks live under `runtime/_ops/scripts/`,
including:

- `lookup-orchestration-lineage.sh`
- `inspect-run-health.sh`
- `summarize-watcher-health.sh`
- `summarize-queue-health.sh`
- `summarize-automation-health.sh`
- `summarize-mission-health.sh`
- `summarize-incident-health.sh`
- `check-incident-closure-readiness.sh`
- `generate-ops-snapshot.sh`

These helpers remain projection-only over canonical runtime, governance, and
continuity artifacts.

## Boundary

Only runtime orchestration artifacts belong here.
Governance contracts belong in `../governance/`.

Package-defined surface roots may appear here in groundwork form before they
become live canonical surfaces. A surface is not canonical until it has the
runtime discovery artifacts, practices, governance addenda, and validator
coverage established inside `/.harmony/orchestration/` itself.
