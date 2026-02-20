---
name: plan
description: >
  Native planning synthesis service that compiles validated spec and playbook inputs
  into canonical plan.json outputs.
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
  integratesWith: [spec, playbook, flow]
observability:
  service_name: "harmony.service.plan"
  required_spans: ["service.plan.plan"]
policy:
  rules: [plan-graph-acyclic, plan-output-canonical]
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [goalHash, constraintsHash]
impl:
  entrypoint: "impl/plan.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash(bash)
---

# Plan Service

Compiles planning inputs into canonical execution plans.
