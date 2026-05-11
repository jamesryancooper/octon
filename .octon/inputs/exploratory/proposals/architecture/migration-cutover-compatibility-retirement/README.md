# Migration Cutover Compatibility Retirement

_Status: Draft child architecture proposal_

This child packet belongs to the `governed-workflow-runtime-transition-program` parent program. It is a sibling proposal packet, not a nested child directory, and it remains non-authoritative proposal lineage under `inputs/**` unless promoted.

## Purpose

Perform the final compatibility, cutover, rollback, and retirement decision for canonical Governed Workflow Runtime framing after all prerequisite child packets have durable evidence.

## Scope

Cutover criteria, compatibility language, retirement register entries, migration receipts, rollback posture, disclosure updates, and final claim boundaries.

## Dependencies

- `framing-boundary-and-terminology-guardrails`
- `workflow-statechart-task-specific-execution-harness`
- `agent-node-model-call-contract`
- `workflow-history-replay-idempotency-compensation`
- `effect-token-enforcement-coverage`
- `evidence-provenance-hardening`
- `connector-operation-admission`

## Promotion Targets

- `.octon/framework/cognition/_meta/terminology/naming-constitution.md`
- `.octon/framework/cognition/_meta/terminology/glossary.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/README.md`
- `.octon/AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/instance/bootstrap/START.md`

## Authority Boundaries

- The parent program coordinates sequence only and does not own this child manifest, receipts, validation verdicts, or promotion targets.
- Existing run lifecycle, execution authorization, context-pack, effect-token, evidence-store, support-target, and fail-closed contracts remain canonical until durable promotion and cutover evidence replace them.
- Proposal-local material, generated projections, MCP/tool availability, Durable Object state, external workflow engines, and agent output are not authority.
- No architectural claim from this child becomes canonical before durable repository surfaces and promotion evidence prove it.

## Non-Goals

- No implementation of missing workflow, agent-node, replay, token, evidence, or connector primitives inside this cutover packet.
- No cutover while predecessor child receipts are missing, stale, failed, or child-owned only in proposal-local form.
- No retirement of compatibility language without rollback and support evidence.

## Required Evidence Before Canonical Claim

- Child terminal receipt index and freshness report.
- Cutover checklist and compatibility retirement receipt.
- Post-cutover drift/churn review.

## Validation Requirements

- Child receipt freshness and terminal outcome validation.
- Compatibility retirement readiness validation.
- No unsupported future-state claim scan.
- Rollback and cutover evidence completeness validation.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `architecture/target-architecture.md`
4. `architecture/implementation-plan.md`
5. `architecture/acceptance-criteria.md`
6. `validation-plan.md`
7. `RISK-REGISTER.md`
8. `support/implementation-grade-completeness-review.md`
