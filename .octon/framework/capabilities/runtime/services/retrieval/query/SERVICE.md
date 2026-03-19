---
name: query
description: >
  Hybrid retrieval and answering service that fuses keyword, semantic, and
  graph signals and emits chunk-level citations with evidence packs.
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
deterministic: false
dependencies:
  requires: []
  orchestrates: []
  integratesWith: [index]
observability:
  service_name: "octon.service.query"
  required_spans:
    - "service.query.ask"
    - "service.query.retrieve"
    - "service.query.explain"
policy:
  rules:
    - native-first-required
    - provider-terms-adapter-only
    - citation-required
  enforcement: block
  fail_closed: true
idempotency:
  required: false
  key_from: []
impl:
  entrypoint: "impl/query.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep Bash(bash) Write(/.octon/state/evidence/runs/services/query/*)
---

# Query Service

Contract-first retrieval service for grounded answers and machine-actionable
evidence.

`guide.md` is design context. `SERVICE.md` and local contract artifacts are
authoritative.

Advanced routes (`hierarchical`, `graph_global`) and optional memory clues are
native runtime features. External backends are adapter-contract only under
`adapters/` and never required for core service behavior.
