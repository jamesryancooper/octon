---
title: Behavior Phases
description: Phase-by-phase instructions for audit-freshness-and-supersession.
---

# Behavior Phases

## Phase 1: Configure

- Parse `scope`, `artifact_globs`, `max_age_days`, and `severity_threshold`.
- Resolve freshness anchor surfaces and audit scope manifest.
- Record threshold configuration for deterministic classification.

## Phase 2: Artifact Inventory

- Enumerate context, decision, plan, and report artifacts in scope.
- Classify artifacts as authoritative, derivative, or archival.
- Build candidate supersession chains from metadata/link markers.

## Phase 3: Freshness Checks

- Compare artifact modification recency against `max_age_days` threshold.
- Compare artifacts against changed anchor surfaces where applicable.
- Detect stale artifacts still referenced by current operational docs.

## Phase 4: Supersession Integrity

- Verify declared supersedes/superseded-by references resolve.
- Detect chain forks, cycles, and orphan historical artifacts.
- Detect contradictory current-state pointers.

## Phase 5: Self-Challenge

- Re-verify all findings against source evidence.
- Search for unclassified artifact families and missed chains.
- Remove false positives and capture newly discovered findings.

## Phase 6: Report

- Emit severity-tiered findings with file evidence.
- Group fixes into independent remediation batches.
- Include coverage proof and idempotency metadata.
