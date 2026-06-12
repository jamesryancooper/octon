# Implementation Plan

1. Add strict JSON schemas for architectural review reports, routing decisions,
   and support receipts.
2. Add template updates for support receipts in proposal scaffolding.
3. Add validators and fixtures for positive and negative cases.
4. Require explicit `blocked`, `not_applicable`, or `deferred` outcomes where
   a pass is not legitimate.
5. Bind receipts to subject digests and validator refs.
6. Prove that lifecycle gate wiring child cannot proceed without these
   validators.

## Strict Receipt Requirements

The schema must require explicit verdicts, evidence refs, validator refs,
unresolved counts, blockers, non-authority classification, and mode-specific
coverage.
