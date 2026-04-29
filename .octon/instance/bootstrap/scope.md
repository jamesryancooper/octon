---
title: Scope
description: Boundaries and responsibilities for the root .octon/ harness.
---

# Scope: Root .octon/

## This Harness Covers

The root `.octon/` is the **repo-wide execution-governance harness** for repository-wide operations, decisions, and context.

This harness contains:

- Repository-wide durable context, ADRs, locality, and bootstrap guidance
- Repository-wide principles, methodology, and architecture guidance
- Progress tracking for repo-level work under `state/continuity/repo/`
- Mission definitions for time-bounded sub-projects under
  `instance/orchestration/missions/`
- Domain-specific workflows owned by the framework layer
- Governed lifecycle surfaces for Safe Start, Safe Continuation, Continuous
  Stewardship, Connector Admission Runtime, Constitutional Self-Evolution, and
  Federated Trust

**Note:** `.octon/` is class-first. Repo-owned authority lives under
`instance/**`, operational truth lives under `state/**`, and framework-owned
runtime/governance surfaces live under `framework/**`.

## In Scope

- Repository-wide context (decisions, lessons, glossary, constraints)
- Repository-wide architecture, principles, and methodology docs
- Repo-level progress tracking and session continuity under
  `state/continuity/repo/`
- Repository-wide workflows
- Managing missions (time-bounded sub-projects)
- Repo-specific conventions and style rules
- Preparing Engagement, Project Profile, Work Package, Decision Request,
  Evidence Profile, Preflight Evidence Lane, Tool/MCP Connector Posture, and
  Run Contract Candidate surfaces
- Managing mission-scoped Autonomy Window, Mission Queue, Action Slice,
  Continuation Decision, Mission Run Ledger, and Mission Evidence Profile
  surfaces
- Maintaining finite Stewardship Program, Stewardship Epoch, Stewardship
  Trigger, Stewardship Admission Decision, Idle Decision, Renewal Decision, and
  Stewardship Ledger surfaces
- Governing Connector Operation, Connector Trust Dossier, Connector Evidence
  Profile, Connector Drift Record, Connector Quarantine, support-target proof
  hooks, and operation-level capability mapping
- Preparing Constitutional Self-Evolution surfaces without self-authorization:
  Evolution Candidate, Evidence-to-Candidate Distillation Record, Governance
  Impact Simulation, Assurance Lab Promotion Gate, Evolution Proposal Compiler,
  Constitutional Amendment Request, Promotion Runtime, Recertification Runtime,
  and Evolution Ledger
- Classifying Federated Trust evidence through Octon Compatibility Profile,
  external project compatibility inspection, safe external adoption posture,
  Portable Proof Bundle, Attestation Envelope, Local Acceptance Record,
  Trust-Domain hook, proof import/export, attestation verify/accept/reject,
  revocation, and expiry behavior

## Out of Scope

- Domain-specific content (belongs in domain's own `.octon/` harness)
- General project documentation (belongs in `/docs`)
- Code implementation (belongs in `/packages`, `/apps`)
- Human onboarding beyond `.octon/` usage
- Browser-driving autonomy, arbitrary API autonomy, broad MCP execution,
  effectful connector live operation, external execution authority, production
  deployment automation, autonomous governance amendments, automatic
  support-target widening, automatic evidence-distillation promotion, external
  proof as authority, and non-Octon federation peers unless the existing local
  gates explicitly admit them

## Content Placement Guide

| Content Type | Location | Example |
|--------------|----------|---------|
| **Shared (in `.octon/`)** | | |
| Harness templates | `.octon/framework/scaffolding/runtime/templates/` | `octon/` |
| Execution roles | `.octon/framework/execution-roles/runtime/` | `orchestrator/`, `specialists/`, `verifiers/`, `composition-profiles/` |
| Harness management workflows | `.octon/framework/orchestration/runtime/workflows/meta/` | `migrate-harness`, `update-harness` |
| Mission management workflows | `.octon/framework/orchestration/runtime/workflows/missions/` | `create-mission`, `complete-mission` |
| Generic skills | `.octon/framework/capabilities/runtime/skills/` | `synthesize-research/` |
| **Repo-wide (in `.octon/`)** | | |
| Repository-wide tool workflows | `.octon/framework/orchestration/runtime/workflows/<tool>/` | _None currently_ |
| Repo-level missions | `.octon/instance/orchestration/missions/` | `auth-overhaul/`, `billing-v2/` |
| Repo-wide context | `.octon/instance/cognition/context/shared/` | `decisions.md`, `lessons.md` |
| **Domain-specific** | | |
| Domain workflows | Repo-root `.octon/framework/orchestration/runtime/workflows/` grouped by domain | `docs/`, `packages/`, `services/` concerns represented under the root harness |
| Domain conventions | Repo-root `.octon/instance/cognition/context/shared/` or domain docs | Package- or area-specific style rules |
| **Harness entry points** | | |
| Cursor command wrappers | `.cursor/commands/` | `evaluate-harness.md`, `update-harness.md` |
| Global Cursor commands | `~/.cursor/commands/` | Git utilities, personal workflows |

## Decision Authority

**Decide locally:**

- File naming within this `.octon/`
- Prompt templates and workflow definitions
- Progress tracking format

**Escalate:**

- Changes to the `.octon/` pattern that affect other harnesses
- New conventions that should apply project-wide

## Adjacent Areas

| Area | Relationship |
|------|--------------|
| `.octon/` | Shared foundation — execution roles, templates, workflows, skills |
| `.octon/framework/scaffolding/runtime/templates/` | Harness scaffolding (base and scoped variants) |
| `.cursor/` | IDE-specific agent configuration (complementary) |
| `.octon/framework/cognition/_meta/architecture/` | Canonical documentation for harness pattern |
