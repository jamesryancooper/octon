---
title: Agency Delegation Contract
description: Cross-agent delegation authority, handoff protocol, and escalation rules for delegated execution.
---

# Agency Delegation Contract

## Contract Scope

- This file defines how work is delegated across agents, assistants, teams, and skills.
- This file applies to all delegated tasks in `.octon/framework/agency/`.
- This file is subordinate to `AGENTS.md`, the constitutional kernel under
  `/.octon/framework/constitution/**`, and the orchestrator execution contract.

## Delegation Principles

- Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.
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
- escalation conditions,
- selected governance `change_profile` and rationale,
- profile facts used for hard-gate selection.

## Authority Boundaries

- Agents may delegate to assistants and invoke workflows/skills.
- Assistants execute bounded tasks and escalate when out of scope.
- Skills do not orchestrate agency actors unless explicitly policy-approved.
- Teams coordinate compositions but do not bypass agent ownership.

## Machine-Readable Delegation Boundaries

Delegation routing MUST resolve against the machine-readable boundary contract:

- `governance/delegation-boundaries-v1.yml`
- `governance/delegation-boundaries-v1.schema.json`

Runtime behavior for each decision class is deterministic:

- `allow` - proceed autonomously within delegated scope.
- `escalate` - route to a human/policy owner before continuation.
- `block` - deny execution and require explicit scope or authority correction.

## Handoff and Acceptance

- Delegator remains accountable for final integration and approval.
- Delegatee must return structured output aligned with the request contract.
- Missing evidence, failed checks, or ambiguity must be surfaced explicitly.
- For migration/governance-impacting work, delegate output MUST include:
  - `Profile Selection Receipt`
  - `Implementation Plan`
  - `Impact Map (code, tests, docs, contracts)`
  - `Compliance Receipt`
  - `Exceptions/Escalations`

## Escalation Triggers

Escalate instead of continuing delegation when:

- task scope conflicts with contract boundaries,
- authority is unclear or exceeds delegate permissions,
- high-risk or irreversible action is requested without explicit approval,
- requested action attempts to delete protected branch `main`,
- required validation cannot be completed,
- profile tie-break ambiguity exists (both `atomic` and `transitional` conditions appear true).

## Anti-Patterns

- Delegating undefined "figure it out" tasks with no acceptance criteria.
- Delegation loops between assistants.
- Silent scope expansion without confirmation.
- Treating delegation as accountability transfer.
- Starting implementation without profile selection and receipt evidence.
