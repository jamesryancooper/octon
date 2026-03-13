---
title: Runtime Audit Records
description: Canonical runtime records for bounded audits, separated from audit policy doctrine.
---

# Runtime Audit Records

This directory is the canonical runtime surface for bounded audit execution records.

## Purpose

- Keep audit plans in a runtime-owned location.
- Keep audit doctrine in `/.octon/cognition/practices/methodology/audits/`.
- Keep generated audit evidence bundles in
  `/.octon/output/reports/audits/<YYYY-MM-DD>-<slug>/`.

## Contract

- Each audit record MUST live in:
  - `/.octon/cognition/runtime/audits/<YYYY-MM-DD>-<slug>/plan.md`
- Machine discovery MUST resolve through:
  - `/.octon/cognition/runtime/audits/index.yml`
- Audit evidence bundle contract requires:
  - `bundle.yml`
  - `findings.yml`
  - `coverage.yml`
  - `convergence.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`
- `bundle.yml` metadata contract:
  - `kind: audit-evidence-bundle`
  - `id: <bundle-directory-name>`
  - `findings: findings.yml`
  - `coverage: coverage.yml`
  - `convergence: convergence.yml`
  - `evidence: evidence.md`
  - `commands: commands.md`
  - `validation: validation.md`
  - `inventory: inventory.md`
