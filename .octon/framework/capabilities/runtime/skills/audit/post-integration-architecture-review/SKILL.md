---
name: post-integration-architecture-review
description: >
  Thin invocation surface for the native Post-Integration Architecture Review
  workflow. Runs an evidence-only architecture review after implementation has
  landed. The workflow contract is authoritative; this skill only routes the
  operator or agent to that workflow.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-06-11"
  updated: "2026-06-11"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/runs/workflows/*)
---

# Post-Integration Architecture Review

Use this skill to invoke the native workflow at:

- `/.octon/framework/orchestration/runtime/workflows/audit/post-integration-architecture-review/`

The workflow produces a schema-backed retained-evidence receipt. It does not
authorize closeout by itself. Implementation conformance and post-implementation
drift/churn remain the hard closeout gates unless a later policy explicitly
changes that boundary.

## Boundaries

- The workflow contract is the execution authority.
- This skill is only an invocation helper.
- The review is evidence-only under current policy.
- Lifecycle postmortems, generated projections, extension packetization, and
  proposal-local summaries cannot authorize closeout.
