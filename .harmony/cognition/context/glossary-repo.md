---
title: Glossary
description: Definitions of key terms used in the Harmony methodology.
---

# Glossary

This glossary defines key terms used throughout Harmony documentation.

---

## Core Concepts

### Harmony
The methodology itself—an AI-native, human-governed approach where developers orchestrate AI agents to build enterprise-quality software.

### Spec (Specification)
A structured document describing what you want to build. Includes problem statement, solution approach, contracts, and acceptance criteria. AI generates specs from your descriptions; you review and approve.

### Tier (Risk Tier)
A classification (T1, T2, T3) indicating the risk level of a change. Higher tiers require more human review.

| Tier | Risk | Your Time |
|------|------|-----------|
| T1 | Trivial | 2-3 min |
| T2 | Standard | 15-20 min |
| T3 | Elevated | 30-60 min |

### Preview
A deployed version of your code for testing before production. Every PR gets a preview URL automatically.

### Promote
The action of moving a preview deployment to production. In Vercel: `vercel promote <preview-url>`.

### Rollback
Reverting to a previous deployment. In Vercel: `vercel promote <previous-url>`. Should be your first response to production issues.

### Feature Flag (Flag)
A toggle that controls whether a feature is active. New features ship OFF by default, then are enabled gradually.

### Slice
A vertical feature module with explicit ports/adapters boundaries. Runtime code is organized by slices, not n-tier layers.

### Layer
Cross-cutting governance or control-plane concern (for example, quality gates, observability, Kaizen). Layers span slices.

### Thin Control Plane
The guardrail layer that includes flags, policy gates, contracts, and observability checks.

### Knowledge Plane (KP)
The unified, queryable engineering knowledge surface that links specs, code, tests, traces, and decisions.

### Improve Layer (Kaizen/Autopilot)
Autonomous, bounded hygiene and improvement loop that proposes small reversible changes with human approval gates.

---

## Roles

### Driver
The developer actively leading implementation for the current work item. Owns: implementation decisions, risk assessment, rollout planning.

### Navigator
The developer reviewing and supporting. Owns: PR review, security checks, T3 approvals, rollout readiness verification.

### Kit
A tool module that AI agents use internally. Examples: SpecKit, PlanKit, TestKit, GuardKit. Humans don't interact with Kits directly.

---

## Development Flow

### Feature Story
A structured planning artifact containing context, an agent plan, and acceptance criteria derived from an approved spec.

### ADR (Architecture Decision Record)
A document recording an important technical decision, its context, and consequences. AI generates these for significant changes.

### STRIDE
A threat modeling framework (Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation). AI applies this to assess security risks.

### Golden Test
A test that captures expected AI output for a specific prompt/scenario. Used to detect when AI behavior drifts unexpectedly.

---

## Workflow States

### Backlog
Work items that have been captured but not yet refined or prioritized.

### Ready
Work items with approved specs, ready for AI to build.

### In-Dev
Work actively being built by AI agents.

### In-Review
Work completed by AI, waiting for human review.

### Preview
Code deployed to a preview environment for testing.

### Release
Approved work waiting to be promoted to production.

### Done
Work that has been shipped and verified in production.

### Blocked
Work that cannot proceed due to a dependency or issue.

### Task Status Values

Status values for `tasks.json` in harness progress tracking:

| Status | Meaning |
|--------|---------|
| `pending` | Not started |
| `in_progress` | Currently working on |
| `blocked` | Cannot proceed; see `blockers` array |
| `completed` | Done |
| `cancelled` | No longer needed |

---

## Quality & Safety

### Gate
An automated check that must pass before work can proceed. Gates include: linting, type checking, tests, security scans, etc.

### CI/CD
Continuous Integration / Continuous Deployment. The automated pipeline that runs gates and deploys code.

### SLO (Service Level Objective)
A target for service quality, e.g., "99.9% availability" or "p95 latency < 300ms".

### Error Budget
The acceptable amount of "unreliability" based on SLOs. If error budget is depleted, feature work pauses until reliability improves.

### Postmortem
A blameless analysis of an incident, documenting what happened, why, and how to prevent recurrence.

---

## Security

### ASVS
OWASP Application Security Verification Standard. A framework of security requirements that Harmony maps to.

### SSDF
NIST Secure Software Development Framework. Security practices embedded in the development lifecycle.

### CSP
Content Security Policy. HTTP header that prevents XSS and other code injection attacks.

### CSRF
Cross-Site Request Forgery. An attack where malicious sites trick users into performing unwanted actions.

### SBOM
Software Bill of Materials. An inventory of all components/dependencies in your software.

---

## Deployment

### Trunk
The main branch (usually `main` or `master`). All work merges here.

### Trunk-Based Development
A development approach using short-lived branches that merge frequently to trunk. Harmony's default approach.

### Vercel
The deployment platform Harmony integrates with for previews, production, and feature flags.

### Edge
Vercel's edge runtime. Used for low-latency, lightweight operations like flag evaluation.

### Serverless
Functions that run on-demand without managing servers. Used for API routes and heavier processing.

---

## AI-Specific

### Prompt
Instructions given to an AI model. In Harmony, prompts are structured and versioned.

### Hallucination
When AI generates content that sounds plausible but is incorrect. Harmony uses validation and golden tests to catch these.

### Temperature
An AI model parameter controlling randomness. Lower temperature (≤0.3) = more deterministic outputs.

### Context Window
The maximum amount of text an AI model can process at once. Affects how much code/documentation can be analyzed together.

### Pinned Model
A specific AI model version locked for consistency. Prevents unexpected behavior changes from model updates.

---

## Abbreviations

| Abbrev | Meaning |
|--------|---------|
| DoR | Definition of Ready |
| DoD | Definition of Done |
| DoSafe | Definition of Safe |
| DoSm | Definition of Small |
| PR | Pull Request |
| HITL | Human-in-the-Loop |
| WIP | Work in Progress |
| MTTR | Mean Time to Recovery |
| DORA | DevOps Research and Assessment (metrics) |
| OTel | OpenTelemetry |

---

## Composite Service

A harness-only composition concept that defines higher-level capabilities by
orchestrating multiple services under `.harmony/capabilities/services/`.
Composite Services are declarative contracts and orchestration metadata, not a
runtime package layer.

Legacy "engine" wording in historical notes maps to Composite Services:

| Legacy Term | Composite Service Mapping |
|--------|---------|
| Spec Engine | `planning/spec` |
| Plan Engine | `planning/plan` |
| Work Engine | `execution/agent` + `execution/flow` + `operations/tool` |
| Context Engine | `retrieval/*` |
| Governance Engine | `governance/*` + `quality/*` |
| Release Engine | `delivery/*` |
| Kaizen Engine | quality-gate and improvement workflows across service domains |

---

## Composite Skill

A harness-only composition concept that defines reusable capability bundles in
`.harmony/capabilities/skills/`.

Composite Skills orchestrate multiple skills under a stable skill contract.
They differ from workflows (procedural sequences) and teams (actor handoffs).

---

## See Also

- [Start Here](../../agency/practices/start-here.md) — Entry point for human developers
- [Conventions](../../conventions.md) — Repository naming and formatting rules
- [Methodology](../methodology/README.md) — Complete methodology documentation
