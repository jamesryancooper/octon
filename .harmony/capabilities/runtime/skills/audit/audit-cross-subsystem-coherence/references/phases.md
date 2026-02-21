---
title: Behavior Phases
description: Phase-by-phase instructions for audit-cross-subsystem-coherence.
---

# Behavior Phases

## Phase 1: Configure

- Parse `scope`, `subsystems`, `docs`, and `severity_threshold`.
- Resolve subsystem roots and required contract files.
- Build deterministic scope manifest.

## Phase 2: Contract Graph Build

- Enumerate subsystem manifests, registries, and key contract docs.
- Build cross-subsystem edge map (references, dependencies, ownership links).
- Record unresolved contract nodes.

## Phase 3: Cross-Subsystem Consistency

- Check manifest-to-registry ID parity across subsystem boundaries.
- Check declared paths and discovery entries resolve on disk.
- Check ownership mappings do not conflict.

## Phase 4: Conflict and Drift Analysis

- Detect contradictory policy statements between subsystem contracts.
- Detect stale cross-links to moved or removed architecture artifacts.
- Detect incompatible namespace or contract assumptions.

## Phase 5: Self-Challenge

- Re-verify each finding with direct file evidence.
- Check blind spots in unscanned file families.
- Add any missed findings discovered during challenge pass.

## Phase 6: Report

- Emit severity-tiered findings with file references.
- Group remediation into independent fix batches.
- Include coverage proof and idempotency metadata.
