# Package Reading And Precedence Map

## Purpose

This file defines the package-local reading order and document precedence for
implementers using this temporary design package. It does not make the package
a canonical repository authority.

## External Authorities

Repository-wide governance and durable runtime, documentation, and policy
surfaces remain higher-precedence than this temporary package.

## Primary Package Inputs

### Core

- `design-package.yml`
- `implementation/README.md`
- `implementation/minimal-implementation-blueprint.md`
- `implementation/first-implementation-plan.md`
- `implementation/existing-surface-gap-analysis.md`

### Class-Specific Normative Docs

- `normative/architecture/domain-model.md`
- `normative/architecture/runtime-architecture.md`
- `normative/execution/behavior-model.md`
- `normative/assurance/implementation-readiness.md`

### Optional Modules

- `contracts/README.md`
- `contracts/schemas/architecture-readiness-target.schema.json`
- `contracts/schemas/architecture-readiness-report.schema.json`
- `conformance/README.md`
- `conformance/scenarios/*.json`
- `reference/README.md`
- `reference/source-material-map.md`
- `navigation/canonicalization-target-map.md`

## Conflict Resolution

1. repository-wide governance and durable authorities
2. `design-package.yml`
3. class-specific normative docs
4. implementation docs
5. optional module docs
6. reference material, including retained root source documents
