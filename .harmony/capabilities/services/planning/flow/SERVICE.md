---
name: flow
description: >
  Workflow execution service that forwards typed run requests to a LangGraph-compatible
  HTTP endpoint and normalizes responses.
interface_type: mcp
version: "0.1.0"
metadata:
  author: "harmony"
  created: "2026-02-12"
  updated: "2026-02-12"
input_schema: schema/input.schema.json
output_schema: schema/output.schema.json
stateful: false
deterministic: false
dependencies:
  requires: []
  orchestrates: [prompt, guard, cost]
  integratesWith: []
observability:
  service_name: "harmony.service.flow"
  required_spans: ["service.flow.run"]
policy:
  rules: [workflow-exists, workflow-valid, runner-available]
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [flowName, canonicalPromptPath, workflowManifestPath]
impl:
  entrypoint: "impl/flow-client.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: WebFetch Read Glob Grep
---

# Flow Service

MCP-oriented service wrapper around an HTTP runner contract (LangGraph-compatible `/flows/run`).
