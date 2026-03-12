---
name: implementation-simulation
title: Run Implementation Simulation
description: Execute prompt 06 and persist the buildability report after short-mode remediation or rigorous integration.
---

# Step 7: Run Implementation Simulation

## Input

- current target package state
- short-mode remediation output or rigorous integration output
- canonical stage prompt for implementation simulation

## Purpose

Treat the package as if implementation starts today and identify remaining
blockers or ambiguities that would prevent deterministic construction.

## Actions

1. Load the canonical implementation-simulation stage prompt.
2. Substitute `<PACKAGE_PATH>` with the current target package path.
3. Execute the prompt against the current package state.
4. Persist the report at:
   - `bundle/reports/06-implementation-simulation.md`
5. Record whether true implementation blockers remain.

## Output

- `bundle/reports/06-implementation-simulation.md`
- Blocker list for the specification-closure step

## Proceed When

- [ ] Implementation Simulation Report exists
- [ ] Required components, data structures, and algorithms are enumerated
- [ ] Remaining blockers are explicit
