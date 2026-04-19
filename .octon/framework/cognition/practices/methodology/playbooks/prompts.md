---
title: Prompt Playbook
description: Reusable AI IDE and terminal prompt patterns for Octon execution flows.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/framework/execution-roles/governance/CONSTITUTION.md"
  - "/.octon/framework/execution-roles/governance/DELEGATION.md"
  - "/.octon/framework/execution-roles/governance/MEMORY.md"
  - "/.octon/framework/cognition/practices/methodology/README.md"
---

# Prompt Playbook

Use these prompts verbatim in your AI IDE or terminal agent. Keep prompt files
under `/docs/prompts/` and paste final prompt usage context into PR evidence
where relevant.

## Prompt Catalog

- **Spec-to-code**:
  *"Given the spec below, propose a minimal design and file-by-file diff (TypeScript/Python). Include contract types, tests, and a step-by-step plan. Flag any security, privacy, or licensing concerns. Do NOT add new deps without justification."*
- **Refactor-safely**:
  *"Refactor `<path>` to match the Hexagonal boundary. Preserve public contracts and ensure existing tests pass. Propose additional tests for risky branches."*
- **Generate tests from spec**:
  *"From this Spec + OpenAPI/JSON-Schema, generate unit + contract tests. Include negative tests derived from STRIDE threats."*
- **Schema and contract tests**:
  *"Validate responses against `<schema>` using AJV/Zod. Add tests that fail on schema drift."*
- **Explain diff and risks**:
  *"Summarize this diff: intent, surface area, security/perf risks, rollback plan, and flags to guard."*
- **License-safe suggestion**:
  *"Recommend libraries with permissive licenses only (MIT/BSD/Apache). Provide license matrix and bundle impact. Avoid GPL."*
- **Threat-model from spec**:
  *"Enumerate STRIDE threats for this feature. For each, propose mitigations and tests (unit/contract/e2e)."*
- **Perf budget enforcement**:
  *"Check this change against our perf budgets. Identify bundle increases and server latency risks. Suggest reductions."*
- **PR risk rubric (summarize and gate)**:
  *"Classify this PR as T1/T2/T3 using the lightweight rubric. List gating steps met (flag, rollback, preview smoke, Navigator pass + security checklist) and any missing gates."*
- **Observability scaffolding**:
  *"Add OTel spans and structured logs to `<path/function>`. Ensure `trace_id` is logged on errors and key events. Show before/after snippets and a sample trace outline."*

## Suggested Prompt Files

```plaintext
/docs/prompts/spec-to-code.md
/docs/prompts/refactor-safely.md
/docs/prompts/threat-model-from-spec.md
/docs/prompts/perf-budget-enforcement.md
/docs/prompts/license-safe-suggestion.md
```
