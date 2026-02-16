---
name: scheduler
description: >
  Native planning-service scheduler that orders step-level work with deterministic
  dependency handling and optional parallel stage allocation.
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
  orchestrates: [critic]
  integratesWith: [plan]
observability:
  service_name: "harmony.service.scheduler"
  required_spans: ["service.scheduler.schedule"]
policy:
  rules: [scheduler-graph-valid, scheduler-partial-order]
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [planPath, maxParallel, blockedCount]
impl:
  entrypoint: "impl/scheduler.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash
---

# Scheduler Service

Deterministic DAG-aware scheduling service for planning steps.

It enforces dependency correctness, detects cycles, and produces stable execution
stages with optional `maxParallel` limits.
