---
name: capability-bind
description: >
  Deterministic capability binding service that matches declared plan execution
  requirements to available native and adapter capabilities.
interface_type: shell
version: "0.1.0"
metadata:
  author: "octon"
  created: "2026-02-16"
  updated: "2026-02-16"
input_schema: schema/input.schema.json
output_schema: schema/output.schema.json
rules: rules/
fixtures: fixtures/
compatibility_profile: compatibility.yml
contracts:
  invariants: contracts/invariants.md
  errors: contracts/errors.yml
generation_manifest: impl/generated.manifest.json
stateful: false
deterministic: true
dependencies:
  requires: []
  orchestrates: [critic]
  integratesWith: [plan, scheduler, contingency]
observability:
  service_name: "octon.service.planning.capability-bind"
  required_spans:
    - "service.planning.capability-bind.bind"
policy:
  rules: [capability-bind-schema]
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [planPath, command, requiredCapabilityHash]
impl:
  entrypoint: "impl/capability-bind.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash(bash)
---

# Capability Bind Service

Converts plan execution requirements into deterministic capability bindings.

## Operations

- `bind`: compute compatibility for all required capabilities.
- `validate`: fail-closed when unsupported required capabilities are detected.

## Outputs

- `status`: `success` for fully bindable plans, `partial` for degradations.
- `result.bindingSummary`: compact counts and capability health map.
- `result.stepBindings`: deterministic step-by-step binding map.

