# Operator Read Models and Run Health Views

## Purpose

Generates non-authoritative operator read models and run-health views with freshness, source traceability, and forbidden-consumer boundaries.

## Boundary

This note explains the product boundary for `operator-read-models`. The machine-readable catalog entry remains navigation-only and does not mint runtime authority, support claims, generated-effective state, or retained execution evidence.

Authoritative policy, schema, and runtime references keep their own authority classes. Generated outputs and operator read models are derived/non-authority. Retained evidence proves events or checks occurred, but it does not authorize future execution. Raw inputs, host UI state, chat/model memory, and tool availability are not authority for this feature.

## Documentation Action

Keep `catalog.yml` current when command surfaces, runtime specs, validators, evidence roots, generated projections, implementation status, grouping, or authority boundaries materially change.
