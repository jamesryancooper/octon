---
name: build-inventory
title: "Build Inventory"
description: "Resolve audit scope, inventory workflow artifacts, and build coverage accounting."
---

# Step 1: Build Inventory

## Purpose

Establish the complete bounded scope before any findings are created.

## Actions

1. Load `.harmony/orchestration/governance/workflow-system-audit-v1.yml`.
2. Resolve the workflow scope root, companion paths, and excluded roots.
3. Enumerate manifest workflows, registry entries, on-disk workflow artifacts, and capability-map workflow references.
4. Write coverage accounting inputs so every in-scope file is accounted for exactly once.

## Output

- Workflow inventory
- Coverage accounting inputs
- Scope receipt for later stages

## Proceed When

- [ ] Manifest, registry, disk, and capability-map inventories are built
- [ ] Coverage scope roots and exclusions are recorded

## Idempotency

Re-running this step must rebuild inventory deterministically from the same scope and parameters.
