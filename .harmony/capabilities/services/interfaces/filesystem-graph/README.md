# Filesystem Graph Service

Native-first service for filesystem operations, deterministic snapshot artifacts,
knowledge-graph traversal, and progressive discovery.

## Purpose

- Provide a unified operation surface for files, snapshots, graph traversal, and discovery.
- Keep files as source-of-truth while exposing derived graph intelligence.
- Preserve provider-agnostic contracts and fail-closed governance behavior.

## Core Artifacts

- `SERVICE.md` - service metadata contract.
- `contract.md` - normative service behavior.
- `schema/*.json` - operation and artifact schemas.
- `rules/rules.yml` - policy and contract checks.
- `contracts/invariants.md` - non-negotiable invariants.
- `contracts/errors.yml` - typed error semantics.
- `contracts/slo-budgets.tsv` - per-operation latency/error SLO budgets.
- `service.json` / `service.wasm` - runtime-native service package.
- `rust/` - Rust/WASM implementation.
- `impl/generated.manifest.json` - implementation generation metadata.

## Operational Gates

- Determinism regression:
  - `.harmony/capabilities/services/_ops/scripts/test-filesystem-graph-determinism.sh`
- Runtime integration regression:
  - `.harmony/capabilities/services/_ops/scripts/test-filesystem-graph-integration.sh`
- Benchmark fixture generation:
  - `.harmony/capabilities/services/_ops/scripts/build-filesystem-graph-benchmark-fixture.sh`
- Latency/error SLO gate:
  - `.harmony/capabilities/services/_ops/scripts/test-filesystem-graph-slo.sh`
- CI-history budget tuning:
  - `.harmony/capabilities/services/_ops/scripts/download-filesystem-graph-slo-history.sh`
  - `.harmony/capabilities/services/_ops/scripts/tune-filesystem-graph-slo-budgets.sh`
  - `.github/workflows/filesystem-graph-slo-tune.yml`

## Safety Limits

- `snapshot.build` enforces default caps for `max_files`, `max_total_bytes`, and `max_op_ms`.
- `discover.start` enforces bounded `content_scan_limit` and `max_op_ms`.
- Corrupt snapshot artifacts fail with actionable rebuild remediation guidance.

## Failure Alerting

- Runtime and SLO tuning workflow failures upsert a GitHub issue with run metadata.
- Optional Slack delivery is enabled when repository secret `FILESYSTEM_GRAPH_SLO_ALERT_WEBHOOK` is configured.
