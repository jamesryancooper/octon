---
name: flow
description: >
  Workflow execution service with a native Harmony runtime default and optional
  LangGraph HTTP adapter path.
interface_type: mcp
version: "1.0.0"
metadata:
  author: "harmony"
  created: "2026-02-12"
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
stateful: false
deterministic: true
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
  entrypoint: "service.wasm"
  timeout_ms: 120000
  health_check: null
adapters:
  registry: adapters/registry.yml
  validator: impl/validate-adapters.sh
dry_run: true
allowed-tools: Read Glob Grep
---

# Flow Service

Native-first runtime service that validates manifest/prompt inputs, executes
workflow steps deterministically, writes stable run records, and optionally
forwards to an external LangGraph-compatible `/flows/run` endpoint when the
`langgraph-http` adapter is selected.
