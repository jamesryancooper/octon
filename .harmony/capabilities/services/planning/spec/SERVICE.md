---
name: spec
description: >
  Native planning specification service for initializing, validating, and publishing
  Harmony-aligned specification artifacts.
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
stateful: false
deterministic: true
dependencies:
  requires: []
  orchestrates: []
  integratesWith: [plan]
observability:
  service_name: "harmony.service.spec"
  required_spans: ["service.spec.init", "service.spec.validate", "service.spec.render", "service.spec.diagram"]
policy:
  rules: [spec-contract-required, spec-output-structured]
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [command, targetPath]
impl:
  entrypoint: "impl/spec.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash
---

# Spec Service

Native-first spec lifecycle service.
