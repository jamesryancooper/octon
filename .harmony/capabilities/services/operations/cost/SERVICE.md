---
name: cost
description: >
  Budget tracking and cost estimation service with durable usage records and
  tier-aware pricing calculations.
interface_type: shell
version: "0.1.0"
metadata:
  author: "harmony"
  created: "2026-02-12"
  updated: "2026-02-12"
input_schema: schema/input.schema.json
output_schema: schema/output.schema.json
stateful: true
deterministic: false
dependencies:
  requires: []
  orchestrates: []
  integratesWith: [flow, prompt]
observability:
  service_name: "harmony.service.cost"
  required_spans: ["service.cost.estimate", "service.cost.record"]
policy:
  rules: [budget-check, tier-compliance]
  enforcement: block
  fail_closed: false
idempotency:
  required: true
  key_from: [model, inputTokens, outputTokens, workflowType]
impl:
  entrypoint: "impl/cost.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Write(../../_state/runs/*) Glob Grep
---

# Cost Service

Shell-backed cost estimator and usage recorder. Supports `estimate` and `record` operations with typed contracts.
