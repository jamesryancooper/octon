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

## Boundary

Only runtime orchestration artifacts belong here.
Governance contracts belong in `../governance/`.

Package-defined surface roots may appear here in groundwork form before they
become live canonical surfaces. A surface is not canonical until it has the
runtime discovery artifacts, practices, governance addenda, and validator
coverage defined by the orchestration design package.
