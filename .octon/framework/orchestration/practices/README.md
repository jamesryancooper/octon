# Orchestration Practices

`practices/` contains operating standards for running orchestration work.

## Scope

- Workflow authoring and maintenance standards.
- Mission operation standards and lifecycle discipline.
- Operator guidance that is not itself a runtime contract.

## Standards

- `workflow-authoring-standards.md` - required structure and quality rules for
  workflow authoring.
- `mission-lifecycle-standards.md` - operating discipline for mission creation,
  execution, completion, and archiving.
- `automation-authoring-standards.md` - canonical authoring rules for split
  automation definition artifacts.
- `automation-operations.md` - operating guidance for pause, replay, retry, and
  automation-local state.
- `watcher-authoring-standards.md` - canonical authoring rules for watcher
  definition families.
- `watcher-operations.md` - operating guidance for watcher health, cursors, and
  emissions.
- `queue-operations-standards.md` - deterministic claim, ack, retry, and
  dead-letter discipline for the queue surface.
- `run-linkage-standards.md` - operating rules for orchestration-facing run
  state and continuity linkage.
- `operator-lookup-and-triage.md` - preferred lookup order, command path, and
  triage flow for canonical orchestration identifiers.
- `incident-lifecycle-standards.md` - operating discipline for runtime incident
  state and evidence-backed closure.
- `orchestration-failure-playbooks.md` - scenario-specific operator playbooks
  for watcher, automation, queue, run, and incident failure handling.
- `campaign-promotion-criteria.md` - standing criteria for when optional
  `campaigns` should remain deferred or be promoted into live runtime.
- `orchestration-domain-implementation-agreement.md` - Phase 0 working
  agreement for promoting temporary design material into standalone live
  orchestration authority without inventing architecture.

## Boundary

Practice guidance belongs here.
Runtime artifacts belong in `../runtime/`; governance contracts belong in `../governance/`.
