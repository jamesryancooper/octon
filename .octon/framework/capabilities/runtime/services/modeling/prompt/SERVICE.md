---
name: prompt
description: >
  Prompt compilation service with deterministic hashing, token estimation,
  and message assembly.
interface_type: shell
version: "0.1.0"
metadata:
  author: "octon"
  created: "2026-02-12"
  updated: "2026-02-13"
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
  orchestrates: []
  integratesWith: [guard, flow]
observability:
  service_name: "octon.service.prompt"
  required_spans: ["service.prompt.compile"]
policy:
  rules: [prompt-exists, variables-valid, within-context-window]
  enforcement: block
  fail_closed: true
idempotency:
  required: false
  key_from: [promptId, variablesHash, variantId]
impl:
  entrypoint: "impl/prompt.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash(bash)
---

# Prompt Service

Harness-native shell implementation for prompt compilation and deterministic outputs.
