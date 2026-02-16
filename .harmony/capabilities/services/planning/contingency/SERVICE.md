---
name: contingency
description: >
  Deterministic contingency planning service that generates alternative executable
  paths for blocked or failed plan steps.
interface_type: shell
version: "0.1.0"
metadata:
  author: "harmony"
  created: "2026-02-16"
  updated: "2026-02-16"
input_schema: schema/input.schema.json
output_schema: schema/output.schema.json
rules: rules/
fixtures: fixtures/
compatibility_profile: compatibility.yml
contracts:
  invariants: contracts/invariants.md
  errors: contracts/errors.yml
generation_manifest: impl/generated.manifest.json
stateful: false
deterministic: true
dependencies:
  requires: []
  orchestrates: [capability-bind]
  integratesWith: [scheduler, replan]
observability:
  service_name: "harmony.service.planning.contingency"
  required_spans:
    - "service.planning.contingency.generate"
policy:
  rules: [contingency-plan]
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [planPath, failedStepsHash]
impl:
  entrypoint: "impl/contingency.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash
---

# Contingency Service

Produces deterministic alternative plans when one or more plan steps fail or are
blocked.

## Operations

- `generate`: return candidate fallback plans for a given failure set.
- `validate`: strict mode that fail-closes when any alternative is impossible.

## Outputs

- `alternatives`: deterministic list of fallback plans with delta summaries.
- `contingencySummary`: counts of candidates and removed steps.
