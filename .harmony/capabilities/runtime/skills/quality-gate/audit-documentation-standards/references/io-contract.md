---
title: I/O Contract
description: Parameters, inputs, and outputs for audit-documentation-standards.
---

# I/O Contract

## Parameters

Defined in:

- `.harmony/capabilities/runtime/skills/registry.yml`

Expected parameters:

- `docs_root` (required)
- `template_root` (optional)
- `policy_doc` (optional)
- `severity_threshold` (optional)

## Inputs

- Documentation tree under `docs_root`
- Canonical policy document
- Canonical documentation standards guidance
- Canonical template bundle

## Outputs

- `.harmony/output/reports/YYYY-MM-DD-documentation-standards-audit.md`
- `_ops/state/logs/audit-documentation-standards/{{run_id}}.md`
- `_ops/state/logs/audit-documentation-standards/index.yml`
- `_ops/state/logs/index.yml`
