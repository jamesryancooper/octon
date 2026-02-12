---
name: {{service-id}}
description: >
  Domain capability with typed I/O contract.
interface_type: shell
version: "0.1.0"
metadata:
  author: "{{author}}"
  created: "YYYY-MM-DD"
  updated: "YYYY-MM-DD"
input_schema: schema/input.schema.json
output_schema: schema/output.schema.json
rules: rules/
fixtures: fixtures/
compatibility_profile: compatibility.yml
generation_manifest: impl/generated.manifest.json
stateful: false
deterministic: true
dependencies:
  requires: []
  orchestrates: []
  integratesWith: []
observability:
  service_name: "harmony.service.{{service-id}}"
  required_spans: ["service.{{service-id}}.{{action}}"]
policy:
  rules: []
  enforcement: block
  fail_closed: true
idempotency:
  required: false
  key_from: []
impl:
  entrypoint: null  # optional; implementation may be generated from contract
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep
---

# {{service-id}}

Document runtime contract, behavioral guarantees, and failure semantics.
Contract artifacts are authoritative; implementations are derived.
