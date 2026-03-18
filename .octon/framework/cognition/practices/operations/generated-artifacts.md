---
title: Generated Runtime Artifacts Runbook
description: Fail-closed process for generating cognition runtime derived artifacts and preventing documentation drift.
---

# Generated Runtime Artifacts Runbook

## Purpose

Keep derived cognition artifacts deterministic, internally generated, and drift-free.

## Generated Artifact Set

- `/.octon/instance/cognition/context/shared/decisions.md`
- `/.octon/framework/cognition/runtime/projections/materialized/cognition-runtime-surface-map.latest.yml`
- `/.octon/framework/cognition/runtime/evidence/index.yml`
- `/.octon/framework/cognition/runtime/evaluations/digests/index.yml`
- `/.octon/framework/cognition/runtime/evaluations/actions/open-actions.yml`
- `/.octon/instance/cognition/context/shared/knowledge/graph/nodes.yml`
- `/.octon/instance/cognition/context/shared/knowledge/graph/edges.yml`
- `/.octon/instance/cognition/context/shared/knowledge/sources/ingestion-receipts.yml`

## Canonical Tooling

- Sync/apply: `bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`
- Drift check: `bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh --check`
- Targeted decisions sync: `bash .octon/framework/cognition/_ops/runtime/scripts/generate-runtime-decisions.sh`
- Targeted projections sync: `bash .octon/framework/cognition/_ops/runtime/scripts/generate-runtime-projections.sh`
- Targeted evidence sync: `bash .octon/framework/cognition/_ops/runtime/scripts/generate-runtime-evidence.sh`
- Targeted evaluations sync: `bash .octon/framework/cognition/_ops/runtime/scripts/generate-runtime-evaluations.sh`
- Targeted knowledge sync: `bash .octon/framework/cognition/_ops/runtime/scripts/generate-runtime-knowledge.sh`
- Full validator: `bash .octon/framework/cognition/_ops/runtime/scripts/validate-generated-runtime-artifacts.sh`
- Fixture tests: `bash .octon/framework/cognition/_ops/runtime/scripts/test-sync-runtime-artifacts-fixtures.sh`

## Procedure

1. Change source-of-truth artifacts only (ADR records/index, migration index, digest markdown files, evidence bundles).
2. Run the sync script to regenerate all derived artifacts in one pass.
3. Run the generated-artifact validator.
4. Run harness structure validation before merge.

## Maintenance Budget Policy (Drift-Elimination)

- Manual maintenance budget for generated artifacts: `0 minutes/week`.
- Allowed maintenance budget: source-of-truth artifact edits only.
- Operational budget for generation/validation: `<= 10 minutes` per change batch.
- CI policy: fail-closed on any generated-artifact drift.

This policy removes the manual-update pathway that causes stale summaries and index drift.

## Guardrails

- Do not manually edit files in the generated artifact set.
- Do not bypass `--check` validation in CI.
- Do not add alternate generation paths outside `sync-runtime-artifacts.sh` without ADR approval.
