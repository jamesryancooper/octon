---
name: design-audit
title: Run Design Package Audit
description: Execute prompt 01 and persist the Design Audit Report.
---

# Step 2: Run Design Package Audit

## Input

- `bundle/plan.md`
- target package at `package_path`
- canonical stage prompt for the design audit

## Purpose

Reconstruct the target architecture, assess implementation readiness, and
produce the audit report that drives the rest of the workflow.

## Actions

1. Load the canonical design-audit stage prompt.
2. Substitute `<PACKAGE_PATH>` with the target package path.
3. Execute the prompt against the current package state.
4. Persist the resulting report at:
   - `bundle/reports/01-design-package-audit.md`
5. Record:
   - highest-severity gaps
   - missing artifacts
   - recommended remediation themes

## Output

- `bundle/reports/01-design-package-audit.md`
- Initial issue inventory for downstream stages

## Proceed When

- [ ] Design Audit Report exists
- [ ] Architecture reconstruction is explicit
- [ ] Missing design elements are identified
- [ ] Recommendations are captured for the next stage
