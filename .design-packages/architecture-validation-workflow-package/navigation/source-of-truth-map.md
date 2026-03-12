# Package Reading And Precedence Map

## Purpose

This file defines the package-local reading order for implementers using this
temporary design package. It does not make the package a canonical repository
authority.

## External Authorities

Durable runtime and assurance surfaces under `/.harmony/` remain higher
precedence than this package once they disagree.

## Primary Package Inputs

1. `design-package.yml`
2. `README.md`
3. `pipeline-overview.md`
4. `stage-contracts.md`
5. `artifact-contract.md`
6. `harmony-integration.md`
7. `normative/architecture/domain-model.md`
8. `normative/architecture/runtime-architecture.md`
9. `normative/execution/behavior-model.md`
10. `normative/assurance/implementation-readiness.md`
11. `implementation/minimal-implementation-blueprint.md`
12. `implementation/first-implementation-plan.md`
13. `prompts/`

## Conflict Resolution

1. durable repository governance and runtime authorities
2. `design-package.yml`
3. package-level contract docs
4. normative docs
5. implementation guidance
6. prompt assets
