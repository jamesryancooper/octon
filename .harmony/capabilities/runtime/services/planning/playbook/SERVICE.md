---
name: playbook
description: >
  Native reusable playbook service for validating and expanding template runbooks
  into plan-ready steps.
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
  service_name: "harmony.service.playbook"
  required_spans: ["service.playbook.expand", "service.playbook.validate"]
policy:
  rules: [playbook-template-required, playbook-output-structured]
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [playbookPath, paramsHash]
impl:
  entrypoint: "impl/playbook.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash(bash)
---

# Playbook Service

Validates and expands reusable planning templates.
