---
name: agent
description: >
  Native execution-domain agent service that runs canonical plans with checkpoint
  and resume control points.
interface_type: shell
version: "0.1.0"
metadata:
  author: "octon"
  created: "2026-02-16"
  updated: "2026-02-19"
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
  requires: []
  orchestrates: [flow]
  integratesWith: [plan, cost]
observability:
  service_name: "octon.service.agent"
  required_spans: ["service.agent.execute", "service.agent.resume"]
policy:
  rules: [agent-plan-required, agent-checkpoint-required, deny-by-default-preflight-loop]
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [runId, planHash]
impl:
  entrypoint: "impl/agent.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash(bash)
---

# Agent Service

Executes plan contracts with resumable run semantics.

Agent-native deny-by-default support:

- preflight grant evaluation before execution
- low-risk auto-remediation with bounded retry (`OCTON_DDB_REMEDIATE_MAX_ATTEMPTS`)
- profile-aware grant path (`OCTON_POLICY_PROFILE`)
