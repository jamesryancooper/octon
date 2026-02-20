---
title: Behavior Phases
description: Phase-by-phase instructions for audit-documentation-standards.
---

# Behavior Phases

## Phase 1: Configure

- Parse `docs_root`, `template_root`, `policy_doc`, `severity_threshold`.
- Validate all required paths exist.
- Record scope and selected thresholds.

## Phase 2: Inventory

- Enumerate markdown files under `docs_root`.
- Detect expected artifact families: specs, ADRs, component guides, runbooks,
  and contracts references.
- Build a coverage manifest.

## Phase 3: Policy Checks

- Check for docs-as-code expectations:
  - behavior/contract/operations changes are documented
  - decision traceability exists (ADR or equivalent)
  - operational rollback guidance exists for deployable changes

## Phase 4: Template Checks

- Compare discovered docs against expected sections from canonical templates.
- Validate links to contracts and related docs.
- Flag structural drift and unresolved placeholders.

## Phase 5: Report

- Emit severity-tiered findings.
- Emit clean coverage proof.
- Group fixes into phased remediation batches.
