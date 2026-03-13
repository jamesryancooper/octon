# Package Reading And Precedence Map

## Purpose

This file defines the package-local reading order for implementers using this
temporary design package. It does not make the package a canonical repository
authority.

## External Authorities

Durable runtime and assurance surfaces under `/.octon/` remain higher
precedence than this package once they disagree.

## Durable Runtime Authorities

When repository runtime surfaces disagree, resolve them in this order:

1. `/.octon/orchestration/runtime/workflows/audit/audit-design-package/workflow.yml`
2. `/.octon/orchestration/runtime/workflows/audit/audit-design-package/stages/`
3. generated `/.octon/orchestration/runtime/workflows/audit/audit-design-package/README.md`
4. `/.octon/orchestration/runtime/workflows/registry.yml`
5. `/.octon/orchestration/runtime/workflows/manifest.yml`
6. `/.octon/orchestration/governance/capability-map-v1.yml`
7. `/.octon/engine/runtime/crates/kernel/src/workflow.rs`
8. `/.octon/assurance/runtime/_ops/scripts/validate-audit-design-package-workflow.sh`
9. `/.octon/assurance/runtime/_ops/tests/`

Interpretation rule:

- `workflow.yml` defines the canonical runtime contract.
- generated workflow README and registry/manifest entries are projections and
  must not override `workflow.yml`.
- runner code and tests are conformance surfaces; drift from `workflow.yml` is a
  runtime defect or readiness blocker.

## Primary Package Inputs

1. `design-package.yml`
2. `README.md`
3. `pipeline-overview.md`
4. `stage-contracts.md`
5. `artifact-contract.md`
6. `octon-integration.md`
7. `normative/architecture/domain-model.md`
8. `normative/architecture/runtime-architecture.md`
9. `normative/execution/behavior-model.md`
10. `normative/execution/run-lifecycle.md`
11. `normative/execution/executor-interface.md`
12. `normative/execution/executor-runtime-prerequisites.md`
13. `normative/execution/failure-and-recovery-model.md`
14. `normative/assurance/observability-and-bundle-contract.md`
15. `normative/assurance/implementation-readiness.md`
16. `implementation/minimal-implementation-blueprint.md`
17. `implementation/workflow-alignment-delta.md`
18. `implementation/first-implementation-plan.md`
19. `prompts/`

## Conflict Resolution

1. durable repository governance and runtime authorities
2. `design-package.yml`
3. package-level contract docs
4. normative docs
5. implementation guidance
6. prompt assets

If package docs and durable runtime authorities disagree on already-implemented
runtime behavior, keep the durable runtime authority and update the package
before treating the package as a safe implementation aid.
