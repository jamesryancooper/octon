---
name: create-skill
description: >
  Scaffold a new skill from template, initialize contract content, and register
  it in discovery artifacts.
steps:
  - id: validate-name
    file: 01-validate-name.md
    description: Validate skill id and path assumptions.
  - id: copy-template
    file: 02-copy-template.md
    description: Copy canonical skill template assets.
  - id: initialize-skill
    file: 03-initialize-skill.md
    description: Initialize SKILL.md and supporting references.
  - id: update-registry
    file: 04-update-registry.md
    description: Register skill metadata in manifests/registries.
  - id: update-catalog
    file: 05-update-catalog.md
    description: Update catalog/discovery docs.
  - id: report-success
    file: 06-report-success.md
    description: Emit completion summary and next steps.
---

# Create Skill Workflow

Use [00-overview.md](./00-overview.md) for prerequisites and conventions, then
execute step files in order.
