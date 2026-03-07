---
name: evaluate-workflow
description: >
  Evaluate an existing workflow for structure, gap coverage, and contract
  quality across directory and single-file formats, then emit findings and
  recommendations.
steps:
  - id: read-workflow
    file: 01-read-workflow.md
    description: Read workflow and step definitions.
  - id: assess-structure
    file: 02-assess-structure.md
    description: Assess structural conformance.
  - id: assess-gap-coverage
    file: 03-assess-gap-coverage.md
    description: Assess expected gap-handling behavior.
  - id: assess-quality
    file: 04-assess-quality.md
    description: Assess quality dimensions and risks.
  - id: generate-report
    file: 05-generate-report.md
    description: Generate evaluation report.
---

# Evaluate Workflow Workflow

Use [00-overview.md](./00-overview.md) for the evaluation rubric, then run the
listed steps in order.
