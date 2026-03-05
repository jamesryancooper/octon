---
title: Flow and WIP Policy
description: Harmony's Kanban policy for a solo developer, including board columns, WIP limits, tiered risk classification, and Definitions of Ready/Done/Safe/Small.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.harmony/agency/governance/CONSTITUTION.md"
  - "/.harmony/agency/governance/DELEGATION.md"
  - "/.harmony/agency/governance/MEMORY.md"
  - "/.harmony/cognition/practices/methodology/authority-crosswalk.md"
---

# Flow & WIP Policy (Kanban for Solo + AI)

This document expands the brief flow and WIP guidance in the Harmony Methodology overview. Use it as the canonical reference for board columns, WIP limits, Definitions of Ready/Done/Safe/Small, and the tiered risk classification system.

---

## Risk Tiers Overview

Harmony uses a **three-tier risk classification** that determines spec detail, gates, and human review requirements.

| Tier | Risk Level | Spec | Gates | Human Time |
|------|------------|------|-------|------------|
| **T1** | Trivial | BMAD-lite | Basic CI | 2-3 min |
| **T2** | Standard | Standard | Full CI + preview | 15-20 min |
| **T3** | Elevated | Full + STRIDE | Full CI + security review | 30-60 min |

→ See [risk-tiers.md](./risk-tiers.md) for full tier criteria.
→ See [ci-cd-quality-gates.md](./ci-cd-quality-gates.md) for canonical gate matrices and checklists.
→ See [auto-tier-assignment.md](./auto-tier-assignment.md) for classification algorithm.

**Key Principle:** AI assigns tiers automatically. Humans can always bump up (never down without justification).

---

## Flow & WIP Policy (Kanban for solo)

**Board columns**: *Backlog → Ready → In‑Dev → In‑Review → Preview → Release → Done → Blocked.*

**Explicit WIP limits (hard)**:

- Ready: 3 cards max; In‑Dev: 1; In‑Review: 1; Preview: 1.
  **Pull policies**: A card moves **only** when Definition of Ready/Done is satisfied.
- Blocked: 2 max across the board. If exceeded for >24h, freeze new pulls and remove root causes. Capture blockers in issues with owners and timestamps.
- Aging targets: median **In‑Dev** age < 2 days; 90th percentile card age < 5 days. Adjust WIP or cut scope if targets are missed for 2 consecutive weeks.

---

## Definitions by Tier

### Definition of Ready (DoR) - Tier-Specific

**T1 (Trivial):**
- AI-generated BMAD-lite spec present
- Files and intent identified
- Risk assessment: no security/data impact

**T2 (Standard):**
- AI-generated standard spec present with:
  - Problem/solution summary
  - Scope and surfaces
  - STRIDE-lite analysis
  - Test plan
  - Rollout plan with flag
- Contracts defined (if API changes)
- Observability plan noted

**T3 (Elevated):**
- AI-generated full spec present with:
  - Detailed problem/solution
  - Full STRIDE threat model
  - Data classification
  - Migration plan (if applicable)
  - ASVS controls mapped
  - Staged rollout plan
- **Spec approved by you (Navigator pass) before build**
- ADR created or updated
- AI determinism plan (provider/model/version pinned)

### Definition of Ready (DoR) - All Tiers

- Tier assigned (T1/T2/T3) with rollback and flag plan noted
- AI config recorded (if agents used)
- Profile governance recorded before implementation: `change_profile`, `release_state`, and `Profile Selection Receipt`

### Definition of Done (DoD) - Tier-Specific

**T1:**
- Basic CI gates pass (lint, typecheck, unit tests)
- PR summary reviewed and receipt digest checked
- Merged to trunk

**T2:**
- All standard CI gates pass
- Preview deployed and smoke tests pass
- Feature behind flag (default OFF)
- Observability verified
- PR approved

**T3:**
- All CI gates pass including security scans
- Preview deployed with extended testing
- Feature behind flag with documented kill-switch
- Navigator review pass (security-focused)
- Watch window scheduled post-promote
- ADR updated

### Definition of Safe (DoSafe)

Note: Terminology harmonization — we use **DoSafe** for "Definition of Safe" (to avoid confusion with Denial‑of‑Service).

**All Tiers:**
- Secrets absent from code
- License scan passed

**T2+:**
- License and provenance approved (no policy‑blocked licenses; note in PR)
- CSP/CSRF/SSRF defenses in place per surface
- Rollback path validated (previous preview ready)
- Feature flag kill‑switch documented
- Observability present: trace/span coverage on changed flows

**T3:**
- Security review completed
- SLOs unchanged or improved
- p95 latency and error rate within budgets on Preview

### Definition of Small (DoSm)

- One concern per PR (single user‑visible change or boundary)
- Default thresholds:
  - T1: ≤50 LOC, ≤5 files
  - T2: ≤300 LOC, ≤20 files
  - T3: No strict limit (split by concern, not size)
- Exceptions require a short "size‑override" note in the PR and Navigator approval before merge

### Tech Debt Budget

- Maintain a lightweight debt ledger (issues labeled `debt`) capped at a small, fixed budget (e.g., 10 items)
- If the budget is exceeded, freeze feature work and burn down debt until under the cap
- Daily Kaizen items (tiny PRs removing friction) do not count toward the debt budget
- Debt freeze policy: if debt budget is exceeded or error‑budget burn is high, pause new feature work and restore system health first

**Why strict WIP?** Keep WIP tiny to reduce cycle time per **Little's Law** (WIP = Throughput × Cycle Time).

---

## Tiered Gates Reference

Gate matrix and checklist ownership is canonical in [ci-cd-quality-gates.md](./ci-cd-quality-gates.md). This flow policy summarizes process expectations and links to the normative gate surface.

- Tier gate matrix: [Gates by Tier](./ci-cd-quality-gates.md#gates-by-tier)
- Complete checklist: [Gate Checklist (Complete Reference)](./ci-cd-quality-gates.md#gate-checklist-complete-reference)
- Tier bump/down policy: [Tier Override Rules](./ci-cd-quality-gates.md#tier-override-rules)
- Waiver handling: [Gate Waivers](./ci-cd-quality-gates.md#gate-waivers)

---

## Change Types → Tier Mapping

| Change Type | Tier | Key Gates |
|-------------|------|-----------|
| Docs/content only | T1 | Lint/typecheck |
| Typo/comment fixes | T1 | Lint/typecheck |
| Test additions | T1 | Unit tests pass |
| UI copy/style (no logic) | T1 | Lint/typecheck |
| UI logic/components | T2 | Standard + preview smoke |
| New API endpoints | T2 | Standard + contracts + flag |
| Refactoring | T2 | Standard + preview smoke |
| Contract changes | T2 | oasdiff + consumer sign-off |
| Auth/session changes | T3 | Full + security review |
| Billing/payment | T3 | Full + security review |
| Data migrations | T3 | Full + migration plan |
| Security config (CSP/CORS) | T3 | Full + security review |
| AI prompt/logic | T2 | Standard + golden tests |

**Notes:**
- AI auto-assigns tiers based on files and intent. See [auto-tier-assignment.md](./auto-tier-assignment.md)
- Humans can bump up tiers (always allowed) or down (requires justification)
- Breaking changes require explicit consumer approval regardless of tier
- For AI changes, pin provider/model/version/params and attach a cost note

---

## Pillar Alignment

The flow and WIP policy serves Harmony's [Six Pillars](../../governance/pillars/README.md) by operationalizing key principles from the PLAN and SHIP phases.

| Pillar | How This Policy Serves It |
|--------|---------------------------|
| [Focus](../../governance/pillars/focus.md) | WIP limits reduce cognitive load and context-switching. Developers work on one thing at a time, preserving mental bandwidth for what matters. |
| [Velocity](../../governance/pillars/velocity.md) | Flow optimization via Little's Law maximizes throughput. Strict WIP limits and aging targets keep cycle times low, enabling sustained high-frequency delivery. |
| [Trust](../../governance/pillars/trust.md) | Definition of Safe (DoSafe) gates enforce safety at every tier. Rollback paths, feature flags, and security reviews ensure changes are reversible and governed. |
| [Direction](../../governance/pillars/direction.md) | Definition of Ready (DoR) requires validated specs before work begins. No card moves to In-Dev without a tier-appropriate spec. |

### Key Pillar Connections

- **Focus through Absorbed Complexity**: The tiered system absorbs process complexity—AI assigns tiers and selects templates automatically, freeing developers from meta-work.
- **Velocity through Agentic Automation**: Automated tier assignment, gate enforcement, and AI-generated specs remove bottlenecks from the flow.
- **Trust through Governed Determinism**: Each tier has explicit, predictable gates. DoSafe ensures security is non-negotiable regardless of tier.
