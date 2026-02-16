---
name: critic
description: |
  Plan graph quality assessment service that validates execution-readiness,
  dependency integrity, and deterministic risk scoring.
interface_type: shell
version: "0.1.0"
metadata:
  author: "harmony"
  created: "2026-02-16"
  updated: "2026-02-16"
tags: [planning, plan, dependency, quality, risk]
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
  orchestrates: [plan]
  integratesWith: [scheduler, capability-bind, contingency]
observability:
  service_name: "harmony.service.planning.critic"
  required_spans:
    - "service.planning.critic.validate"
    - "service.planning.critic.score"
policy:
  rules: [critic-graph-validity, critic-risk-profile]
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [planPath, command, commandHash]
impl:
  entrypoint: "impl/critic.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash
---

# Critic Service

Evaluates a plan graph for structural issues, dependency faults, and a deterministic
risk profile.

## Operations

- `validate`: fail-closed structural pass.
- `score`: advisory scoring with partial status on defects.

## Contracts

- Input schema: `schema/input.schema.json`
- Output schema: `schema/output.schema.json`
- Invariants: `contracts/invariants.md`
- Rules and errors: `rules/rules.yml`, `contracts/errors.yml`
