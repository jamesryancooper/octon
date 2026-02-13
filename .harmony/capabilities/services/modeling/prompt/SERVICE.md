---
name: prompt
description: >
  Prompt rendering and token estimation service with typed request/response
  contracts, implemented by the project runtime library.
interface_type: library
version: "0.1.0"
metadata:
  author: "harmony"
  created: "2026-02-12"
  updated: "2026-02-12"
input_schema: schema/input.schema.json
output_schema: schema/output.schema.json
stateful: false
deterministic: true
dependencies:
  requires: []
  orchestrates: []
  integratesWith: [guard, flow]
observability:
  service_name: "harmony.service.prompt"
  required_spans: ["service.prompt.compile"]
policy:
  rules: [prompt-exists, variables-valid, within-context-window]
  enforcement: block
  fail_closed: true
idempotency:
  required: false
  key_from: [promptId, variablesHash, variantId]
impl:
  entrypoint: "impl/LIBRARY.md"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep
---

# Prompt Service

Library-backed service that preserves PromptKit contracts while relocating discovery and policy into the harness.
