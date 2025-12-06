# Research

**Goal:** Find the strongest peer-reviewed papers (and credible industry research) on software-architecture patterns that enable an **AI-guided self-improvement loop** in SaaS products. Emphasize designs that balance **Speed with Safety**, **Simplicity over Complexity**, **Quality through Determinism**, and **Guided Agentic Autonomy** (Harmony’s four pillars).

**What to return:** 20–30 papers (mix of proven and emerging). Prefer 2015–present with seminal pre-2015 work if still foundational.

**In-scope patterns (examples, not limits):** self-adaptive systems (MAPE-K), autonomic computing, control-loop architectures, online/continual learning with guardrails, RL/RLHF in production, agents & tool-use, microservices + eventing (CQRS, event sourcing), CRDTs, workflow/orchestration (sagas), feature flags & canaries, shadow deployments, typed/contract-driven interfaces, formal specs (TLA+, Alloy), property-based testing, deterministic pipelines, reproducible ML/MLOps, safety monitors/policies, verification + runtime monitoring.

**Venues to prioritize (if available):** ICSE/FSE/ASE/OOPSLA/POPL; SOSP/OSDI/NSDI; SEAMS/SASO; NeurIPS/ICLR/AAAI/AAMAS/MLSys; industry research (Google/Meta/Microsoft/Uber/Netflix/Stripe/AWS/GCP/Azure).

**Inclusion criteria (must have ≥5/7):**

1. Clear architecture or pattern;
2. Evidence (case study, benchmark, production report, or formal proof);
3. Guidance for small teams (2–6 devs) or low-ops overhead;
4. Safety or reliability mechanisms (e.g., rollout, policy, verification, guardrails);
5. Determinism/reproducibility or bounded nondeterminism;
6. Simplicity (composability, minimal moving parts);
7. Fits SaaS, multi-tenant, or cloud contexts.

**Exclusion:** purely theoretical without actionable architecture; papers focused only on model training algorithms unless they connect to system-level self-improvement loops.

**Deliverables (strict format):**
Return a ranked list with one item per paper using this schema:

- **Title** — link to open-access PDF (or publisher page if no PDF)
- **Venue & Year** — e.g., ICSE 2023
- **Type** — {academic, industry, survey, seminal}
- **Primary Pattern(s)** — e.g., MAPE-K + event sourcing
- **Core Idea (≤2 sentences)**
- **Evidence** — {prod case, benchmark, formal proof, simulation}
- **Why it matters for SaaS** — concrete takeaway for a 2–6 dev team
- **Harmony Pillars (0–5 each):** Speed/Safety, Simplicity, Determinism/Quality, Agentic Autonomy
- **Notable Trade-offs** — risks/complexity introduced
- **Tooling/Tech Fit** — e.g., workflow engines, feature flags, policy engines, formal tools

**Ranking rubric (compute and sort by total):**

- Pillar alignment (0–20; 5 each)
- Evidence strength (0–5)
- Implementation clarity for small teams (0–5)
- Real-world relevance (0–5)
- Simplicity/operational cost (0–5)

**Diversity requirement:** Ensure at least:

- 4 surveys/tutorials;
- 6 production/industry experience reports;
- 4 formal-methods or verification-oriented papers;
- 4 agent/LLM-oriented system papers;
- 4 self-adaptive/MAPE-K/control-loop papers.

**Output:** Provide the ranked list and the links. After the list, add a short “Starter Stack” paragraph mapping 5–7 patterns into a coherent baseline architecture for a small team.

---

## Power search helpers (optional to append to your query)

- Keywords: `"self-adaptive systems" MAPE-K`, autonomic computing architecture, *control loop* software, *runtime monitoring* verification, *deterministic* pipeline reproducibility, *event sourcing* CQRS saga, *formal specification* TLA+ Alloy runtime verification, *policy engine* OPA guardrails, *canary deployment* shadow traffic, *A/B online learning*, *agent* tool-use orchestration workflow, *CRDT* conflict-free replication.
- Scholar operators: `intitle:architecture`, `site:arxiv.org OR site:acm.org OR site:ieee.org`, `after:2015`.
- Include “experience report”, “case study”, or “survey” to widen coverage.

---

## Ultra-concise version

“Find 20–30 top papers (2015–now, plus seminal) on architectures enabling **AI-guided self-improvement loops** in SaaS. Prioritize MAPE-K/self-adaptive/control-loop, agents with guardrails, deterministic/reproducible pipelines, and safety mechanisms (formal methods, runtime monitors, canaries). For each paper, return: Title (PDF link), Venue/Year, Type, Pattern(s), 2-sentence idea, Evidence, SaaS takeaway for a 2–6 dev team, 0–5 scores for four pillars (Speed with Safety, Simplicity, Determinism/Quality, Guided Agentic Autonomy), Trade-offs, Tooling. Rank by total score (pillar fit, evidence, small-team clarity, relevance, simplicity). Ensure mix of surveys, industry reports, formal-methods, agent systems, and self-adaptive papers.”
