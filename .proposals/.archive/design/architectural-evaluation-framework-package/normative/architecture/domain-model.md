# Domain Model

## Purpose

Define the primary concepts, supported target classes, and ownership boundaries
for the future architecture-readiness evaluation capability.

## Supported Target Classes

- `whole-octon`
  - scope: `/.octon/`
  - evaluation mode: `whole-harness`
- `bounded-surface-domain`
  - scope: one top-level bounded-surface domain under `/.octon/`
  - evaluation mode: `bounded-domain`

Supported bounded-surface domains:

- `agency`
- `capabilities`
- `cognition`
- `orchestration`
- `assurance`
- `scaffolding`
- `engine`

## Explicit Non-Targets

- `state-tracking-domain`
  - current example: `continuity`
- `human-led-domain`
  - current example: `ideation`
- `artifact-sink-domain`
  - current example: `output`
- `surface-only-target`
  - examples: `governance/`, `practices/`, `_meta/`, `_ops/`

## Core Concepts

- `EvaluationTarget`
  - the scoped system or domain path under review
- `TargetProfile`
  - the applicability classification used before scoring
- `EvaluationMode`
  - `whole-harness` or `bounded-domain`
- `DimensionScore`
  - one scored framework dimension with evidence and gaps
- `HardGate`
  - a dimension whose failure blocks implementation-ready verdicts
- `FailureModeAssessment`
  - explicit resistance, weakness, consequence, and remediation per failure mode
- `RemediationArtifact`
  - exact file or surface that must be created or updated to close a gap

## Relationships

- `EvaluationTarget` must resolve to exactly one `TargetProfile`.
- `TargetProfile` determines whether an `EvaluationMode` is allowed.
- `EvaluationMode` determines which framework dimensions are in scope.
- `DimensionScore` and `FailureModeAssessment` feed the final verdict.
- `RemediationArtifact` ties gaps to durable Octon surfaces, never back to the
  design package.
