---
title: Service Observability
scope: harness
applies_to: services
---

# Service Observability

Services use shared observability primitives with a service-oriented naming convention.

## Span Naming

Required naming convention:

- `service.{id}.{action}`

Examples:

- `service.guard.check`
- `service.cost.estimate`
- `service.flow.run`

This standard preserves event and attribute semantics while using service-native naming.

## Required Attributes

Per root operation span:

- `run.id`
- `service.name` (for services: `harmony.service.{id}`)
- `service.version`
- `stage`

Common optional correlation attributes:

- `git.sha`
- `repo`
- `branch`
- dependency-specific attributes (for example `provider`, `endpoint`)

## Event Vocabulary

Standard span events:

- `state.enter`
- `inputs.validated`
- `artifact.write`
- `gate.pass`
- `gate.block`
- `acp.requested`
- `acp.allow`
- `acp.stage_only`
- `acp.deny`
- `acp.escalate`
- `error`
- `policy.fail`
- `eval.fail`
- `flag.toggle`

## Error and Status Semantics

- Success path sets span status `OK`.
- Failures set span status `ERROR`, with recorded exception.
- Guard/policy/evaluation outcomes should emit explicit gate events for auditability.
