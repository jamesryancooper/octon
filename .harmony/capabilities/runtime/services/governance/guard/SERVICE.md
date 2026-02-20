---
name: guard
description: >
  Content protection service for prompt injection, hallucination heuristics,
  secrets/PII detection, and code-safety checks.
interface_type: shell
version: "0.1.0"
metadata:
  author: "harmony"
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
  integratesWith: [prompt, flow]
observability:
  service_name: "harmony.service.guard"
  required_spans: ["service.guard.check", "service.guard.sanitize"]
policy:
  rules: [no-secrets, no-pii, no-injection]
  enforcement: block
  fail_closed: true
idempotency:
  required: false
  key_from: [contentHash, checkType]
impl:
  entrypoint: "impl/guard.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash(bash)
---

# Guard Service

Portable shell implementation of content safety checks.

## Actions

- `check`: detect risky content patterns.
- `sanitize`: emit redacted content when patterns are detected.
