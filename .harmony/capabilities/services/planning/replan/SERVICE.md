---
name: replan
description: |
  Applies deterministic replanning transforms to an existing plan when steps
  become blocked, stale, or invalid at runtime.
interface_type: shell
version: "0.1.0"
metadata:
  author: "harmony"
  created: "2026-02-16"
  updated: "2026-02-16"
tags: [planning, plan, replanning, recovery]
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
  integratesWith: [scheduler]
observability:
  service_name: "harmony.service.planning.replan"
  required_spans:
    - "service.planning.replan.replan"
policy:
  rules: [replan-order-stability]
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [planPath, blockedStepsHash]
impl:
  entrypoint: "impl/replan.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash
---

# Replan Service

Produces an adjusted plan from an existing plan input by removing blocked steps,
rewiring dependencies, and returning a deterministic delta.

## Operations

- `replan`: recalculate plan ordering with blocked steps removed.
