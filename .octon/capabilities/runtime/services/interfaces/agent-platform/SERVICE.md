---
name: agent-platform
description: >
  Native-first interoperability service for session policy validation, context
  budget accounting, compaction memory flush policy, and adapter capability
  negotiation.
interface_type: shell
version: "0.1.0"
metadata:
  author: "octon"
  created: "2026-02-14"
  updated: "2026-02-14"
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
  integratesWith: [flow, cost]
observability:
  service_name: "octon.service.agent-platform"
  required_spans:
    - "service.agent-platform.context-budget"
    - "service.agent-platform.validate-session-policy"
    - "service.agent-platform.negotiate-capabilities"
    - "service.agent-platform.memory-flush-evidence"
policy:
  rules:
    - native-first-required
    - provider-terms-adapter-only
    - flush-before-compaction
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [sessionId, policyId, budgetSnapshotHash]
impl:
  entrypoint: "impl/context-budget.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash(bash)
---

# Agent Platform Service

Native service contract for interop semantics. Provider-specific mappings are
restricted to `adapters/`.
