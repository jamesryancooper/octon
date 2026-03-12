---
name: design-integration
title: Run Rigorous-Mode Design Integration
description: Execute prompt 05, apply required package changes, and persist the rigorous-mode integration report.
---

# Step 6: Run Rigorous-Mode Design Integration

## Input

- `bundle/plan.md`
- target package at `package_path`
- `bundle/reports/04-design-hardening.md`
- injected prior report: `<HARDENING_REPORT>`
- canonical stage prompt for design integration

## Purpose

Integrate the rigorous-mode hardening changes into one coherent package state
before buildability simulation.

## Actions

1. Load the canonical design integration stage prompt.
2. Substitute:
   - `<PACKAGE_PATH>`
   - `<HARDENING_REPORT>`
3. Update the target package directly when possible.
4. Persist `bundle/reports/05-design-integration.md`.
5. Record a `CHANGE MANIFEST` or explicit zero-change receipt.
6. Aggregate all changed or reviewed files into `bundle/package-delta.md`.

## Output

- `bundle/reports/05-design-integration.md`
- Package mutations or an explicit zero-change receipt
- Aggregate package delta summary

## Proceed When

- [ ] Design Integration Report exists
- [ ] The stage includes a change manifest or zero-change receipt
- [ ] `package-delta.md` reflects the integration-stage review
