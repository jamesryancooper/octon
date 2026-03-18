---
name: filesystem-discovery
description: >
  Native-first query plane for graph traversal and progressive discovery over snapshots.
interface_type: library
version: "0.1.0"
metadata:
  author: "octon"
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
stateful: true
deterministic: true
dependencies:
  requires: [filesystem-snapshot]
  orchestrates: []
  integratesWith: [query, agent-platform]
observability:
  service_name: "octon.service.filesystem-discovery"
  required_spans:
    - "service.filesystem-discovery.kg"
    - "service.filesystem-discovery.discover"
policy:
  rules:
    - native-first-required
    - fail-closed-invalid-snapshot
    - provenance-required
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [command, snapshotId, payloadHash]
impl:
  entrypoint: "engine/runtime/run tool interfaces/filesystem-discovery"
  timeout_ms: 60000
  health_check: null
dry_run: true
allowed-tools: Read Glob
---

# Filesystem Discovery Service

Query plane for graph traversal and progressive discovery over deterministic snapshots.
