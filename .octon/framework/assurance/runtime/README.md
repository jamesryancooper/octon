# Assurance Runtime

## Purpose

Canonical runtime surface for assurance execution and trust artifact runtime
contracts.

## Contents

- `_ops/scripts/` - assurance engine and alignment validation entrypoints.
- `/.octon/generated/effective/assurance/` - generated lock artifacts used by assurance execution.
- `trust/` - trust artifact runtime surfaces (`attestations/`, `evidence/`,
  `audits/`).

## Boundary

Executable assurance behavior belongs in `runtime/`.
Policy contracts belong in `../governance/`; operating standards belong in
`../practices/`.
