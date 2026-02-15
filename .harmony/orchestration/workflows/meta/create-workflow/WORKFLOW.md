---
name: create-workflow
description: >
  Scaffold a new workflow with gap-aware structure, integrate references, and
  verify discovery wiring.
steps:
  - id: validate-id
    file: 01-validate-id.md
    description: Validate workflow id and naming constraints.
  - id: analyze-requirements
    file: 02-analyze-requirements.md
    description: Analyze requested workflow behavior and scope.
  - id: select-template
    file: 03-select-template.md
    description: Select the correct workflow template pattern.
  - id: generate-structure
    file: 04-generate-structure.md
    description: Generate workflow directory and base files.
  - id: customize-steps
    file: 05-customize-steps.md
    description: Author step files and sequence.
  - id: integrate-gap-fixes
    file: 06-integrate-gap-fixes.md
    description: Apply known workflow quality remediations.
  - id: update-references
    file: 07-update-references.md
    description: Update registries/catalog references.
  - id: verify
    file: 08-verify.md
    description: Validate workflow integrity and readiness.
---

# Create Workflow Workflow

Use [00-overview.md](./00-overview.md) for full context, then execute each step
file in order.
