---
name: domain-architecture-audit
title: "Run Domain Architecture Audit"
description: "Optionally run the external domain-architecture critique as supplemental evidence for bounded-domain mode."
---

# Step 5: Run Domain Architecture Audit

## Purpose

Collect supplemental bounded-domain evidence without changing the primary audit
semantics.

## Run Condition

- Execute only when:
  - target classification is `bounded-domain`
  - `run_domain_architecture=true`

## Actions

1. Invoke `audit-domain-architecture` against `target_path`.
2. Capture the report and any bundle references.
3. Preserve supplemental findings as evidence inputs to the merge step.

## Skip When

- [ ] Target is not `bounded-domain`
- [ ] `run_domain_architecture=false`
