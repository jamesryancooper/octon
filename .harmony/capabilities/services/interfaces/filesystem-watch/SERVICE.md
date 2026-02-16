---
name: filesystem-watch
description: >
  Native-first, OS-agnostic polling watcher hints for repository change detection.
interface_type: library
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
  requires: [filesystem-snapshot]
  orchestrates: []
  integratesWith: [filesystem-snapshot, filesystem-discovery]
observability:
  service_name: "harmony.service.filesystem-watch"
  required_spans:
    - "service.filesystem-watch.poll"
policy:
  rules:
    - native-first-required
    - bounded-watch-scan
    - fail-closed-invalid-input
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [root, stateKey, payloadHash]
impl:
  entrypoint: "runtime/run tool interfaces/filesystem-watch"
  timeout_ms: 60000
  health_check: null
dry_run: true
allowed-tools: Read Glob
---

# Filesystem Watch Service

Portable watcher hints via deterministic bounded polling.
