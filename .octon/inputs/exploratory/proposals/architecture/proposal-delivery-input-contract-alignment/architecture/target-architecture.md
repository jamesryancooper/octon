# Target Architecture

The delivery input contract is stated once in canonical runtime and workflow surfaces, then mirrored consistently by commands, skills, validators, and docs.

## Required Input Model

- Delivery profile inputs are either required everywhere or explicitly derived by a documented preflight.
- Delivery run identifiers are either required everywhere or explicitly created by an owning route with retained evidence.
- Resume paths state which prior receipt or run evidence can satisfy an input.

## Validation Model

- Validators reject missing required inputs before mutating stages.
- Tests cover packet delivery and program delivery separately.
- Negative controls prove generated projections and proposal-local summaries cannot satisfy required inputs.

## Boundary Model

This child does not publish `.codex` host projections. It creates the stable source contract that host projections may later mirror.
