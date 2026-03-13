---
title: Surface Architecture Audit Doctrine
description: Canonical doctrine for bounded architecture analysis of one durable Octon surface or surface unit.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-12
canonical_links:
  - "/AGENTS.md"
  - "/.octon/agency/governance/CONSTITUTION.md"
  - "/.octon/agency/governance/DELEGATION.md"
  - "/.octon/agency/governance/MEMORY.md"
  - "/.octon/cognition/practices/methodology/authority-crosswalk.md"
  - "/.octon/cognition/practices/methodology/audits/README.md"
  - "/.octon/cognition/practices/methodology/audits/findings-contract.md"
---

# Surface Architecture Audit Doctrine

## Purpose

Define the canonical bounded-audit rule set for evaluating one durable Octon
surface or surface unit without collapsing domain-level and surface-level
architecture concerns into the same audit.

This doctrine applies to units such as:

- one workflow
- one skill
- one watcher
- one automation definition
- one service or contract surface
- one methodology surface

It does not replace domain-scale critique or whole-harness readiness scoring.

## Primary Rule

Every surface architecture audit must determine the smallest robust authority
model for the target surface on its own terms.

The audit optimizes for:

1. clear canonical authority
2. contract-first execution, discovery, and validation semantics where required
3. explicit separation between authoritative artifacts and explanatory material
4. minimal sufficient complexity
5. low drift risk
6. strong operator and agent usability

## Authority Model Classification

Every run must classify the target surface as exactly one of:

- `contract-first`
- `mixed`
- `markdown-first`
- `human-led/non-executable`

Classification is mandatory before findings are emitted.

## Evaluation Lenses

Every run must explicitly evaluate:

1. surface responsibilities
2. surface consumers
3. machine-readable authority requirements
4. allowed prose roles
5. discovery and index surfaces
6. schema and validator coverage
7. hidden conventions and incidental authority
8. split-brain duplication between human and agent/operator surfaces

### Responsibilities

The audit must state what the surface is responsible for and what is out of
scope for that surface.

### Consumers

The audit must identify which actors consume the surface:

- agents
- workflows
- validators
- humans
- runtime components
- scaffolding or generators

### Machine-Readable Requirements

If the surface drives execution, discovery, validation, or machine-interpreted
behavior, the audit must identify which behavior belongs in structured
machine-readable artifacts.

### Allowed Prose Roles

Markdown or other prose content may exist only as:

- executor-facing instruction content subordinate to a contract
- explanatory or reference documentation
- intentionally human-led content for non-executable surfaces

Human-readable Markdown must not be the canonical execution contract for an
execution-bearing surface.

## Universal Anti-Patterns

The audit must treat these as architecture smells or direct violations when
applicable:

- prose-first canonical execution contracts
- hidden authority in conventions, examples, or historical notes
- avoidable split-brain surfaces for humans vs agents
- validator coverage that targets docs while skipping true authority artifacts
- cargo-culted structure imported from unrelated surfaces
- temporary design artifacts treated as lasting authority
- one file carrying incompatible responsibilities when a small explicit split is
  safer

## Surface-Local Variation Rule

The audit must not force all surfaces into one filename or directory pattern.

These may vary when justified by the surface:

- number of contract files
- filenames such as `workflow.yml`, `manifest.yml`, `registry.yml`, `schema.json`
- support-asset directory names
- whether Markdown instruction assets are needed
- whether human-readable docs are generated, authored, or omitted
- whether the surface is executable, declarative, governance-oriented, or
  intentionally human-led

## Findings and Remediation Shape

Every blocking or material finding must name:

- the exact durable artifact to create or update
- the artifact class:
  - machine-readable contract
  - discovery/index artifact
  - validator or schema
  - explanatory documentation
  - methodology guidance
- the purpose of the artifact
- objective acceptance criteria for closing the finding

The audit must prefer the smallest robust correction rather than maximum
uniformity.

## Output Contract

Every surface architecture audit report must include:

1. executive summary
2. surface definition
3. current authority model
4. surface needs analysis
5. prioritized findings
6. recommended target architecture
7. acceptance criteria
8. keep-as-is decisions
9. non-goals

## Composition With Other Audits

- Use `audit-domain-architecture` for external critique of a whole Octon
  domain or prospective domain.
- Use `audit-architecture-readiness` for whole-harness or bounded-domain
  implementation-readiness verdicts.
- Use a surface architecture audit when a finding or design question must be
  narrowed to one durable surface unit.

## Non-Goals

This doctrine does not:

- score whole-harness or bounded-domain readiness
- force workflow-shaped artifacts onto unrelated surfaces
- treat prompt files or design packages as durable authority
- replace domain-scale architecture critique
