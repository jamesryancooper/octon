---
name: first-implementation-plan
title: Produce First Implementation Plan
description: Execute prompt 09 and persist the production implementation plan.
---

# Step 10: Produce First Implementation Plan

## Input

- stabilized target package state
- `bundle/reports/08-minimal-implementation-architecture-blueprint.md`
- injected prior report: `<BLUEPRINT_REPORT>`
- canonical stage prompt for first implementation planning

## Purpose

Turn the blueprint into a practical first-build plan with workstreams,
dependencies, milestones, tests, and first-slice sequencing.

## Actions

1. Load the canonical first-implementation-plan stage prompt.
2. Substitute:
   - `<PACKAGE_PATH>`
   - `<BLUEPRINT_REPORT>`
3. Execute the prompt against the stabilized package and extracted blueprint.
4. Persist the result at:
   - `bundle/reports/09-first-implementation-plan.md`

## Output

- `bundle/reports/09-first-implementation-plan.md`

## Proceed When

- [ ] First Implementation Plan exists
- [ ] Workstreams and dependency order are explicit
- [ ] First end-to-end slice is identified
- [ ] Test and conformance plan is included
