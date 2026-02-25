---
title: Next Actions
description: Immediate actionable steps.
---

# Next Actions

Immediate steps to take. Items here are typically derived from project findings or brainstorm conclusions.

## Current

- `intent-layer-wave1-contract-foundation`: Finalize Wave 1/2 schema and policy
  integration checks by running:
  `bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile intent-layer`.
- `intent-layer-wave2-enforcement`: Validate deny-by-default policy contract
  after new boundary/mode rules:
  `bash .harmony/capabilities/_ops/scripts/validate-deny-by-default.sh --profile dev-fast --all`.
- `intent-layer-wave3-capability-map`: Run workflow contract validation after
  capability-map linkage:
  `bash .harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh`.
- `test-scaffolding`: Run `/create-harness` on a real target directory and
  capture validation outcomes in `continuity/log.md`.

## Backlog

- `intent-layer-cutover`: Run full alignment and assurance gate before
  promotion: `bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,agency,workflows,weights,intent-layer`.
- `test-harness`: Execute an end-to-end agent session after
  `test-scaffolding` completes.
