---
name: run-flow
description: >
  Execute a FlowKit LangGraph flow from configuration, validate inputs, run the
  flow, and report execution results.
steps:
  - id: validate-input
    file: 01-validate-input.md
    description: Validate command arguments and file prerequisites.
  - id: parse-config
    file: 02-parse-config.md
    description: Parse and validate flow configuration.
  - id: execute-flow
    file: 03-execute-flow.md
    description: Execute the configured flow runtime.
  - id: report-results
    file: 04-report-results.md
    description: Report outputs, status, and follow-up guidance.
---

# Run Flow Workflow

Use [00-overview.md](./00-overview.md) for context, then execute step files in
order.
