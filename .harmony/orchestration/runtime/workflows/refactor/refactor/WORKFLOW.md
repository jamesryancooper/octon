---
name: refactor
description: >
  Execute a verified refactor workflow: define scope, audit impact, plan
  changes, execute safely, verify outcomes, and document results.
steps:
  - id: define-scope
    file: 01-define-scope.md
    description: Define exact refactor scope and constraints.
  - id: audit
    file: 02-audit.md
    description: Audit blast radius and references.
  - id: plan
    file: 03-plan.md
    description: Build an executable refactor plan.
  - id: execute
    file: 04-execute.md
    description: Apply the refactor plan.
  - id: verify
    file: 05-verify.md
    description: Verify behavior and consistency after changes.
  - id: document
    file: 06-document.md
    description: Document outcomes and follow-ups.
---

# Refactor Workflow

Use [00-overview.md](./00-overview.md) for workflow context and run step files
in order.
