---
title: Bounded Audits
description: SSOT policy hub for bounded, convergent audits with deterministic receipts, coverage accounting, stable findings, and explicit done gates.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/framework/execution-roles/governance/CONSTITUTION.md"
  - "/.octon/framework/execution-roles/governance/DELEGATION.md"
  - "/.octon/framework/execution-roles/governance/MEMORY.md"
  - "/.octon/framework/cognition/practices/methodology/authority-crosswalk.md"
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
  - `/.octon/instance/cognition/context/shared/audits/<YYYY-MM-DD>-<slug>/plan.md`
  - based on `/.octon/framework/scaffolding/runtime/templates/audits/template.bounded-audit.md`
- An evidence bundle at:
  - `/.octon/state/evidence/validation/audits/<YYYY-MM-DD>-<slug>/`
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

CI MUST validate these bundle keys at key level (not file-presence only), including determinism receipt fields required by `ci-gates.md`.

## Companion Documents

- `doctrine.md`
- `invariants.md`
- `exceptions.md`
- `ci-gates.md`
- `findings-contract.md`
- `surface-architecture.md`

## Single-Surface Architecture Analysis

Use `surface-architecture.md` as the canonical bounded-audit doctrine for
architecture analysis of one durable Octon surface or surface unit.

This doctrine complements, but does not replace:

- domain-scale critique under `audit-domain-architecture`
- readiness verdicts under `audit-architecture-readiness`

## Runtime Audit Records

Canonical runtime records and discovery index live at:

- `/.octon/instance/cognition/context/shared/audits/README.md`
- `/.octon/instance/cognition/context/shared/audits/index.yml`
