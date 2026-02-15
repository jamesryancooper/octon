---
name: create-harness
description: >
  Scaffold a new .harmony directory in a target location, then customize it to
  the target repository context.
steps:
  - id: validate-prerequisites
    file: 01-validate-prerequisites.md
    description: Confirm invocation and required local assets.
  - id: validate-target
    file: 02-validate-target.md
    description: Confirm the target path is valid and safe to scaffold.
  - id: analyze-context
    file: 03-analyze-context.md
    description: Inspect repository context for tailoring.
  - id: gather-input
    file: 04-gather-input.md
    description: Collect required customization inputs.
  - id: copy-templates
    file: 05-copy-templates.md
    description: Copy canonical template files into target.
  - id: customize
    file: 06-customize.md
    description: Apply target-specific customization.
  - id: verify
    file: 07-verify.md
    description: Validate scaffold completeness and correctness.
---

# Create Harness Workflow

Use [00-overview.md](./00-overview.md) for workflow context, then execute the
listed step files in order.
