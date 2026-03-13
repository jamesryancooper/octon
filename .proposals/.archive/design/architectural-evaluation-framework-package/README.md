# Architectural Evaluation Framework Design Package

This is a temporary, implementation-scoped design package for
`architectural-evaluation-framework-package`. It is a build aid for engineers
and operators. It is not a canonical runtime, documentation, policy, or
contract authority.

Status: `archived`
Archive Disposition: `implemented`

## Purpose

- package class: `domain-runtime`
- summary: Blueprint for a Octon architecture-readiness evaluation capability
  that targets whole-harness audits and bounded-surface domain audits.

## Implementation Targets

- `/.octon/capabilities/runtime/skills/audit/audit-architecture-readiness/`
- `/.octon/orchestration/runtime/workflows/audit/audit-architecture-readiness/`
- `/.octon/cognition/practices/methodology/architecture-readiness/`
- `/.octon/scaffolding/governance/patterns/adr-architecture-readiness-matrix.md`

## Included Modules

- `contracts`
- `conformance`
- `reference`
- `canonicalization`

## Reading Order

1. `design-package.yml`
2. `navigation/source-of-truth-map.md`
3. `implementation/README.md`
4. `normative/architecture/domain-model.md`
5. `normative/architecture/runtime-architecture.md`
6. `normative/execution/behavior-model.md`
7. `normative/assurance/implementation-readiness.md`
8. optional module docs listed in the source-of-truth map

## Exit Path

This package has been promoted into the durable `/.octon/` surfaces listed
above and is archived under `/.design-packages/.archive/` as historical
implementation material. No live surface should depend on this package.
