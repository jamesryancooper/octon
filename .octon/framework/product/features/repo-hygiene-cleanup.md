# Repo Hygiene Cleanup Authorization

## Purpose

Authorizes and evidences tightly scoped repository hygiene cleanup with protected-path, manual-review, rollback, and deletion-safety boundaries.

## Boundary

This note explains the product boundary for `repo-hygiene-cleanup`. The machine-readable catalog entry remains navigation-only and does not mint runtime authority, support claims, generated-effective state, or retained execution evidence.

Authoritative policy, schema, and runtime references keep their own authority classes. Generated outputs and operator read models are derived/non-authority. Retained evidence proves events or checks occurred, but it does not authorize future execution. Raw inputs, host UI state, chat/model memory, and tool availability are not authority for this feature.

## Documentation Action

Keep `catalog.yml` current when command surfaces, runtime specs, validators, evidence roots, generated projections, implementation status, grouping, or authority boundaries materially change.
