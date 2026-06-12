---
name: pre-integration-architecture-review
description: >
  Thin invocation surface for the native Pre-Integration Architecture Review
  workflow. Runs the schema-backed review required before architecture proposal
  acceptance or implementation authorization. The workflow contract is
  authoritative; this skill only routes the operator or agent to that workflow.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-06-11"
  updated: "2026-06-11"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Bash Write(/.octon/state/evidence/runs/workflows/*)
---

# Pre-Integration Architecture Review

Use this skill to invoke the native workflow at:

- `/.octon/framework/orchestration/runtime/workflows/audit/pre-integration-architecture-review/`

The workflow produces a schema-backed
`architectural-review-support-receipt-v1` receipt. Architecture proposal
acceptance and implementation authorization depend on that receipt through
`validate-proposal-review-gate.sh` and `validate-architectural-review-receipts.sh`.

## Boundaries

- The workflow contract is the execution authority.
- This skill is only an invocation helper.
- Review reports and receipts are retained evidence unless a lifecycle contract
  explicitly gates on the strict receipt.
- Raw inputs, generated outputs, chat, host state, dashboards, and model memory
  cannot satisfy the lifecycle gate.
