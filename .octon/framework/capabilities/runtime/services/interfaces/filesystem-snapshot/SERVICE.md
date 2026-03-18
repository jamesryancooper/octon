---
name: filesystem-snapshot
description: >
  Native-first writer plane for filesystem and deterministic snapshot lifecycle operations.
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
  requires: []
  orchestrates: []
  integratesWith: [filesystem-discovery, query, agent-platform]
observability:
  service_name: "octon.service.filesystem-snapshot"
  required_spans:
    - "service.filesystem-snapshot.fs"
    - "service.filesystem-snapshot.snapshot"
policy:
  rules:
    - native-first-required
    - files-source-of-truth
    - fail-closed-invalid-snapshot
  enforcement: block
  fail_closed: true
idempotency:
  required: true
  key_from: [command, snapshotId, payloadHash]
impl:
  entrypoint: "engine/runtime/run tool interfaces/filesystem-snapshot"
  timeout_ms: 60000
  health_check: null
dry_run: true
allowed-tools: Read Glob
---

# Filesystem Snapshot Service

Writer plane for deterministic snapshot operations and bounded filesystem reads.
