# Minimal Implementation Architecture Blueprint

This directory is the implementer-facing blueprint for the first production
build of the orchestration domain.

It is derived from the package's normative architecture and contracts. When this
blueprint and a normative package document differ, the normative package
document wins.

## Reading Order

1. `01-system-purpose-and-production-architecture.md`
2. `02-service-boundaries-and-data-model.md`
3. `03-state-machines-and-algorithms.md`
4. `04-runtime-enforcement-and-failure-handling.md`
5. `05-first-slice-and-implementation-order.md`

## What This Blueprint Is For

Use this blueprint to answer:

- what runtime components to build
- what data each component owns
- what invariants must be enforced
- what order the implementation should follow

## What This Blueprint Is Not

This blueprint does not replace the package's normative docs and contracts. It
is the practical bridge between the design package and engineering execution.
