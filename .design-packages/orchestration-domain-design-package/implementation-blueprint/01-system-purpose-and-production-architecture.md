# System Purpose And Minimal Production Architecture

## Build Target

Build a production orchestration control plane that can:

- discover workflows, automations, watchers, queue items, runs, incidents,
  approvals, and authority records
- evaluate schedule and event triggers
- admit or deny material actions through `allow`, `block`, and `escalate`
- acquire target-global coordination locks before side effects
- launch workflows with validated inputs
- persist decision evidence and run state
- monitor executor liveness and reconcile stale work
- manage incidents and privileged approvals

## In Scope

- orchestration-domain runtime control plane
- decision and run persistence
- queue, locking, approval verification, liveness, and reconciliation
- design-package validator and runtime enforcement points

## Explicitly Out Of Scope

- specific database, broker, or RPC product choices
- UI and dashboard implementation
- workflow authoring UX beyond required executable metadata
- product-specific capability logic invoked by workflow steps

## Minimal Production-Capable Components

| Component | Purpose | Responsibilities | Inputs | Outputs | State Owned | Critical Dependencies |
|---|---|---|---|---|---|---|
| Discovery Loader | Build resolved config view | load manifests, registries, contracts, object definitions | runtime artifacts | resolved refs, validation results | none durable | package contracts, runtime tree |
| Watcher Runner | Produce events | poll sources, evaluate watcher rules, update watcher health | watcher defs, watcher state | watcher events, health updates | watcher state | watcher schemas, event contract |
| Event Router | Convert events into work | match events to automations, apply routing decisions, enqueue queue items | watcher events, active automations | queue items, routing decisions | none durable | dependency resolution, automation trigger contract |
| Queue Manager | Manage machine-ingest work | claim, ack, retry, dead-letter, write receipts | queue items, claimant identity | claims, receipts, retries | queue lanes, receipts | queue contract, CAS storage |
| Automation Controller | Own launch policy | schedule eval, overlap/idempotency, bindings preflight, admission | automations, queue claims, schedule windows | decisions, launch requests, automation state updates | automation state | automation contract, bindings contract |
| Coordination Manager | Prevent conflicting side effects | derive coordination keys, acquire/renew/release locks | admitted launch requests | lock results, contention outcomes | coordination locks | concurrency model, lock contract |
| Workflow Launcher | Start workflow execution | create runs, send launch requests, finalize terminal transitions | admitted launch requests, workflow metadata | run lifecycle updates | active runs | workflow execution contract, run contract |
| Executor Supervisor | Track executor ownership | accept/reject launches, record executor ack, monitor workers | launch requests, executor responses | ack, heartbeat, terminal status events | executor runtime-local state | workflow execution contract |
| Decision Writer | Persist decision evidence | write canonical decision records | decision outcomes | decision artifacts | continuity decisions | decision contract |
| Run Writer | Persist run state | write authoritative runs and projections | run lifecycle events | run artifacts, projections | runtime runs | run contract |
| Reconciler / Liveness Manager | Heal incomplete work | detect orphan decisions, stale runs, expired claims, lost locks | runs, queue, decisions, locks | recovery actions, incidents, operator-visible errors | none primary | liveness spec, failure model |
| Incident Manager | Handle abnormal conditions | open/enrich/close incidents, launch remediation paths | failed runs, approvals | incident updates, remediation requests | incident state | incident contract, approval model |
| Validator | Prove static correctness | enforce schemas, fixtures, doc sections, semantic checks | package docs, schemas, fixtures | pass/fail report | none | validation script |

## Minimal End-To-End Path To Support

The first production-capable path should be:

1. watcher emits event
2. event router matches one automation
3. queue item created
4. queue claimed
5. bindings validated
6. coordination lock acquired
7. decision written
8. run created
9. executor accepts and acknowledges
10. run remains healthy or enters deterministic recovery
