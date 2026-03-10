# ADR 0005: Workflow Recurrence Stays Outside Workflows

## Status

- accepted

## Context

Workflows define bounded procedures. Recurrence and event-triggered launch
semantics belong to a different concern. If recurrence lives inside workflows,
procedure definition and launch policy become entangled.

## Decision

Workflow recurrence stays outside `workflows` and belongs to `automations`.
Event-trigger selection belongs in `trigger.yml`.

## Consequences

- keeps workflows reusable and bounded
- keeps launch policy explicit and operator-visible
- avoids turning workflows into schedulers

## Alternatives Considered

- Embed recurrence metadata and event selection directly in workflows
- Let external schedulers own all recurrence without a Harmony surface

## Relationship To Existing Contracts

- reinforces `contracts/automation-execution-contract.md`
- reinforces `reference/surfaces/workflows.md`
- aligns with `history/mature-harmony-orchestration-model.md`
