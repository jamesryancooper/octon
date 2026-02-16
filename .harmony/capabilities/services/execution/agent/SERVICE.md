---
name: agent
description: >
  Native execution-domain agent service that runs canonical plans with checkpoint,
  resume, and human-in-the-loop control points.
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
contracts:
  invariants: contracts/invariants.md
  errors: contracts/errors.yml
compatibility_profile: compatibility.yml
generation_manifest: impl/generated.manifest.json
stateful: true
deterministic: true
dependencies:
  requires: []
  orchestrates: [flow]
  integratesWith: [plan, cost]
observability:
  service_name: "harmony.service.agent"
  required_spans: ["service.agent.execute", "service.agent.resume"]
policy:
  rules: [agent-plan-required, agent-checkpoint-required]
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [runId, planHash]
impl:
  entrypoint: "impl/agent.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash
---

# Agent Service

Executes plan contracts with resumable run semantics.
