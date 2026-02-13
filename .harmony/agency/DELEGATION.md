---
title: Agency Delegation Contract
description: Cross-agent delegation authority, handoff protocol, and escalation rules for delegated execution.
---

# Agency Delegation Contract

## Contract Scope

- This file defines how work is delegated across agents, assistants, teams, and skills.
- This file applies to all delegated tasks in `.harmony/agency/`.
- This file is subordinate only to `AGENTS.md` and `CONSTITUTION.md`.

## Delegation Principles

- Delegate only bounded tasks with explicit outcomes.
- Keep authority aligned with actor role and allowed capabilities.
- Avoid recursive delegation unless explicitly permitted.
- Prefer minimal handoff chains to preserve accountability.

## Delegation Packet Requirements

Every delegated task must specify:

- goal and completion criteria,
- scope boundaries and out-of-scope items,
- constraints (security, compliance, quality, timeline),
- required artifacts and verification expectations,
- escalation conditions.

## Authority Boundaries

- Agents may delegate to assistants and invoke workflows/skills.
- Assistants execute bounded tasks and escalate when out of scope.
- Skills do not orchestrate agency actors unless explicitly policy-approved.
- Teams coordinate compositions but do not bypass agent ownership.

## Handoff and Acceptance

- Delegator remains accountable for final integration and approval.
- Delegatee must return structured output aligned with the request contract.
- Missing evidence, failed checks, or ambiguity must be surfaced explicitly.

## Escalation Triggers

Escalate instead of continuing delegation when:

- task scope conflicts with contract boundaries,
- authority is unclear or exceeds delegate permissions,
- high-risk or irreversible action is requested without explicit approval,
- required validation cannot be completed.

## Anti-Patterns

- Delegating undefined "figure it out" tasks with no acceptance criteria.
- Delegation loops between assistants.
- Silent scope expansion without confirmation.
- Treating delegation as accountability transfer.
