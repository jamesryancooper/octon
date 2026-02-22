---
title: Bounded Audits
description: SSOT policy hub for bounded, convergent audits with deterministic receipts, coverage accounting, stable findings, and explicit done gates.
---

# Bounded Audits

This directory defines policy and governance for bounded audits in this repository.

## Purpose

Turn open-ended audit loops into finite, repeatable, mechanically verifiable checks.

A bounded audit must:

- use an explicit issue taxonomy,
- enforce a severity threshold,
- prove coverage for in-scope files,
- emit stable finding IDs with acceptance criteria,
- declare completion through a deterministic done gate.

## Machine Discovery

- `index.yml` - canonical machine-readable index for audit governance artifacts.

## Scope

A task is treated as an audit when it evaluates repository state against rules and can produce findings that may block release, merge, or completion.

## Default Policy

All audits are bounded by default. "Find issues" without bounded scope is non-compliant.

## Required Artifacts

Every bounded audit must include:

- A runtime audit plan record at:
  - `/.harmony/cognition/runtime/audits/<YYYY-MM-DD>-<slug>/plan.md`
  - based on `/.harmony/scaffolding/runtime/templates/audits/template.bounded-audit.md`
- An evidence bundle at:
  - `/.harmony/output/reports/audits/<YYYY-MM-DD>-<slug>/`
  - required files:
    - `bundle.yml`
    - `findings.yml`
    - `coverage.yml`
    - `convergence.yml`
    - `evidence.md`
    - `commands.md`
    - `validation.md`
    - `inventory.md`
  - required `bundle.yml` metadata:
    - `kind: audit-evidence-bundle`
    - `id: <bundle-directory-name>`
    - `findings: findings.yml`
    - `coverage: coverage.yml`
    - `convergence: convergence.yml`
    - `evidence: evidence.md`
    - `commands: commands.md`
    - `validation: validation.md`
    - `inventory: inventory.md`

## Companion Documents

- `doctrine.md`
- `invariants.md`
- `exceptions.md`
- `ci-gates.md`
- `findings-contract.md`

## Runtime Audit Records

Canonical runtime records and discovery index live at:

- `/.harmony/cognition/runtime/audits/README.md`
- `/.harmony/cognition/runtime/audits/index.yml`
