---
name: specification-closure
title: Close Remaining Specification Gaps
description: Execute prompt 07 or emit an explicit no-op closure receipt.
---

# Step 8: Close Remaining Specification Gaps

## Input

- `bundle/reports/06-implementation-simulation.md`
- injected prior report: `<IMPLEMENTATION_SIMULATION_REPORT>`
- current target package state
- canonical stage prompt for specification closure

## Purpose

Close implementation blockers that remain after simulation, or record that no
further package changes are required.

## Actions

1. Inspect the Implementation Simulation Report for true build blockers.
2. If blockers remain:
   - run the canonical specification-closure stage prompt
   - update the target package directly when possible
   - persist `bundle/reports/07-specification-closure.md`
   - record a change manifest
3. If no blockers remain:
   - write `bundle/reports/07-specification-closure.md` as an explicit
     zero-change receipt
   - include rationale and reviewed files

## Output

- `bundle/reports/07-specification-closure.md`
- Additional package mutations or a zero-change closure receipt

## Proceed When

- [ ] Specification Closure output exists
- [ ] Remaining blockers are resolved or explicitly declared absent
- [ ] Package delta summary is updated when files changed
