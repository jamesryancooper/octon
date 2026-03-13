---
title: SpecKit One-Pager Template (Legacy Archive)
description: Historical, non-normative reference for the superseded SpecKit one-pager outline.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/agency/governance/CONSTITUTION.md"
  - "/.octon/agency/governance/DELEGATION.md"
  - "/.octon/agency/governance/MEMORY.md"
  - "/.octon/cognition/practices/methodology/spec-first-planning.md"
---

# SpecKit One-Pager Template (Legacy, Non-Normative)

This file preserves the original SpecKit one-pager outline for historical
reference only. Active planning guidance is in:

- [../spec-first-planning.md](../spec-first-planning.md)
- [../templates/spec-tier1.yaml](../templates/spec-tier1.yaml)
- [../templates/spec-tier2.yaml](../templates/spec-tier2.yaml)
- [../templates/spec-tier3.yaml](../templates/spec-tier3.yaml)

## SpecKit Spec One-Pager Template (Outline)

- Title & metadata
  - Working title, date, owner(s), related issue/PR links.
  - Risk class (T1/T2/T3) and affected slices/surfaces.
- Problem and goal
  - Concise problem statement and "why now".
  - Target outcome framed in user and system terms.
- Scope and appetite
  - In-scope vs out-of-scope behaviors.
  - Appetite (for example, 1-day change, 1-week mini-project).
- Contracts and surfaces
  - API contracts (OpenAPI/JSON-Schema paths) and UI surfaces touched.
  - Data classification for each surface (PII/PHI/SECRET/OTHER_SENSITIVE).
- Non-functionals and SLOs
  - Performance, reliability, and availability targets (SLIs/SLOs).
  - Cost and latency guardrails if AI or infra-heavy.
- Security and compliance
  - STRIDE threats per surface and mitigations.
  - Mapped OWASP ASVS controls and NIST SSDF tasks to be satisfied.
- Observability and knowledge
  - Required spans/logs/metrics and dashboards.
  - How traces/PRs/ADRs will be correlated in the Knowledge Plane.
- AI usage and determinism (when agents are involved)
  - Provider/model/version, parameters (temperature/top_p, max_tokens, seed if supported).
  - Golden tests plan (EvalKit/TestKit) and determinism expectations.
- Acceptance criteria and tests
  - User-visible acceptance criteria.
  - Test outline: unit, contract, e2e smoke, and AI golden tests where applicable.
- Rollout, flags, and rollback
  - Flag names and initial cohorts.
  - Rollback plan (for example, promote prior preview) and success/failure exit criteria.
