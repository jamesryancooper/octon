---
name: cross-subsystem-audit
title: "Run Cross-Subsystem Coherence Audit"
description: "Optionally run cross-subsystem coherence as supplemental evidence for whole-harness mode."
---

# Step 4: Run Cross-Subsystem Coherence Audit

## Purpose

Collect supplemental whole-harness evidence without replacing the primary
architecture-readiness verdict.

## Run Condition

- Execute only when:
  - target classification is `whole-harness`
  - `run_cross_subsystem=true`

## Actions

1. Invoke `audit-cross-subsystem-coherence` against `target_path`.
2. Capture the report and any bundle references.
3. Preserve supplemental findings as evidence inputs to the merge step.

## Skip When

- [ ] Target is not `whole-harness`
- [ ] `run_cross_subsystem=false`
