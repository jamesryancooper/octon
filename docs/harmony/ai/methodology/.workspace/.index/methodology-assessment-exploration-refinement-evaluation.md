# Methodology Assessment, Exploration, Refinement & Evaluation

Comprehensive evaluation of the **Harmony Methodology** for coherence, implementability, pillar alignment, and operational readiness.

## Evaluation Meta-Information

Before beginning, document the evaluation context:

| Field | Value |
|-------|-------|
| **Methodology Version Being Evaluated** | |
| **Evaluation Date** | |
| **Evaluator(s)** | |
| **Evaluator Background** | |
| **Previous Evaluation Date (if any)** | |
| **Trigger for This Evaluation** | New methodology / Major update / Scheduled review / Issue-driven |

---

## Evaluation Process Guidance

### Suggested Evaluation Order

1. **Skim all documents first** (2-3 hours) — Build mental model before deep assessment
2. **Part 1: Element Assessment** (4-6 hours) — Systematic document review
3. **Part 2: Cross-Element Analysis** (2-3 hours) — Look for patterns and inconsistencies
4. **Part 3: Exploration** (2-3 hours) — Identify gaps and opportunities
5. **Part 4: Guarantees Audit** (1-2 hours) — Verify enforceability
6. **Part 5: Stress Tests** (2-3 hours) — Practical scenario validation
7. **Part 6: Convivial Alignment** (1 hour) — Purpose verification
8. **Parts 7-9: Synthesis** (2-3 hours) — Consolidate and prioritize findings

**Estimated Total Time:** 16-24 hours (can be split across multiple sessions)

### Scoring Rubric

| Score | Meaning | Criteria |
|-------|---------|----------|
| **5** | Excellent | Clear, complete, actionable, no issues identified |
| **4** | Good | Minor gaps or clarifications needed |
| **3** | Adequate | Functional but notable improvements possible |
| **2** | Weak | Significant gaps affecting usability |
| **1** | Poor | Major issues, needs substantial rework |

### Validation Methods

- [ ] **Document walkthrough** — Read each document end-to-end
- [ ] **Scenario testing** — Walk through real scenarios mentally or on paper
- [ ] **Developer interview** (if available) — Get practitioner feedback
- [ ] **Tool verification** — Confirm referenced tools exist and work as described
- [ ] **Cross-reference checking** — Verify all links and references resolve

---

## Context

You are a senior methodology architect conducting a comprehensive assessment of Harmony's methodology. The methodology has been designed for **tiny teams (1-3 developers)** and claims to be **lean and AI-accelerated**. Your task is to **assess, explore, refine, and evaluate** the methodology for:

1. **Pillar alignment** — Does every methodology element serve one or more pillars?
2. **Operational clarity** — Can tiny teams apply the methodology day-to-day?
3. **Leanness** — Is the methodology actually lean, or is there hidden ceremony?
4. **Implementability** — Can a tiny team adopt this methodology in practice?
5. **Convivial alignment** — Does the methodology serve Harmony's foundational purpose?

### Tiny Team Definition

A **tiny team** is 1, 2, or 3 developers. The methodology must work across all three configurations:

| Team Size | Configuration | Key Considerations |
|-----------|--------------|-------------------|
| **1 dev** | Solo developer | No reviewer available; all roles collapse to one person |
| **2 devs** | Pair | Driver/Navigator model; one reviewer per PR |
| **3 devs** | Trio | Flexible pairing; multiple reviewers possible |

The methodology should degrade gracefully from 3 → 2 → 1 developers and provide explicit guidance for each configuration. Elements that *require* multiple people should be clearly identified.

---

## The Six Pillars (Reference)

The methodology should operationalize these six pillars:

```text
┌─────────────────────────────────────────────────────────────────┐
│                      CONVIVIAL PURPOSE                          │
│    Technology that expands capability, respects attention,      │
│    fosters connection, and resists extraction                   │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       THE SIX PILLARS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   PLAN      ┌─────────────────┬─────────────────┐               │
│             │    DIRECTION    │     FOCUS       │               │
│             │    Validated    │    Absorbed     │               │
│             │    Discovery    │   Complexity    │               │
│             └────────┬────────┴────────┬────────┘               │
│                      │                 │                        │
│                      ▼                 ▼                        │
│   SHIP      ┌─────────────────┬─────────────────┐               │
│             │    VELOCITY     │     TRUST       │               │
│             │    Agentic      │    Governed     │               │
│             │   Automation    │   Determinism   │               │
│             └────────┬────────┴────────┬────────┘               │
│                      │                 │                        │
│                      ▼                 ▼                        │
│   LEARN     ┌─────────────────┬─────────────────┐               │
│             │   CONTINUITY    │    INSIGHT      │               │
│             │  Institutional  │   Structured    │               │
│             │     Memory      │    Learning     │               │
│             └────────┬────────┴────────┬────────┘               │
│                      │                 │                        │
│                      └────────┬────────┘                        │
│                               │                                 │
│                               ▼                                 │
│                    (feeds back to DIRECTION)                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Pillar Quick Reference

| # | Pillar | Phase | Developer Receives | Harmony Provides |
|---|--------|-------|-------------------|------------------|
| 1 | Direction through Validated Discovery | PLAN | Confidence that effort is well-spent | Spec-first validation, user signals, scoped appetites |
| 2 | Focus through Absorbed Complexity | PLAN | Cognitive bandwidth freed for what matters | Kits, schemas, modular boundaries |
| 3 | Velocity through Agentic Automation | SHIP | Sustained, high-frequency delivery | AI agents, automated gates, trunk-based flow |
| 4 | Trust through Governed Determinism | SHIP | Confidence in correctness, security, recoverability | Typed contracts, bounded agents, reversibility |
| 5 | Continuity through Institutional Memory | LEARN | Context survives time and team changes | ADRs, traces, decision logs, audit trails |
| 6 | Insight through Structured Learning | LEARN | Understanding that makes tomorrow better | Postmortems, EvalKit feedback, retro-driven updates |

---

## Methodology Document Inventory

The methodology spans these documents:

| Category | Documents | Purpose |
|----------|-----------|---------|
| **Core** | `README.md` | Main overview and unifying narrative |
| **Flow** | `flow-and-wip-policy.md`, `risk-tiers.md`, `auto-tier-assignment.md` | Work management and risk classification |
| **Practices** | `spec-first-bmad.md`, `ci-cd-quality-gates.md`, `sandbox-flow.md` | Development workflows |
| **Standards** | `security-baseline.md`, `reliability-and-ops.md`, `performance-and-scalability.md` | Non-functional requirements |
| **Structure** | `architecture-and-repo-structure.md`, `tooling-and-metrics.md` | Technical architecture |
| **Governance** | `methodology-as-code.md` | Schema-first methodology encoding and enforcement |
| **Adoption** | `adoption-plan-30-60-90.md`, `implementation-guide.md`, `tiny-team-assessment.md` | Onboarding and adoption |
| **Templates** | `templates/spec-tier1.yaml`, `spec-tier2.yaml`, `spec-tier3.yaml` | Structured templates |

---

## Part 1: Methodology Element Assessment

For each major methodology element, conduct a comprehensive assessment across five dimensions.

### Assessment Template

For each methodology element, evaluate:

#### A. Clarity Assessment

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| **Purpose Clear**: Is it immediately obvious why this element exists? | | |
| **Self-Explanatory**: Can a developer understand it without extensive context? | | |
| **Action Clarity**: Is it clear what behaviors this element encourages/discourages? | | |
| **Audience Appropriate**: Is the content appropriate for its intended audience? | | |
| **Jargon Level**: Is technical jargon justified and explained where needed? | | |

**Overall Clarity Score**: ___/25

---

#### B. Pillar Alignment Assessment

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| **Primary Pillar**: Does this element clearly serve at least one pillar? | | |
| **Pillar Connection Explicit**: Is the pillar connection documented? | | |
| **Mechanism Match**: Does the element implement the pillar's *mechanism*, not just benefit? | | |
| **No Orphaned Content**: Is there content that doesn't serve any pillar? | | |
| **Phase Appropriate**: Does the element fit its implied phase (PLAN/SHIP/LEARN)? | | |

**Overall Pillar Alignment Score**: ___/25

---

#### C. Leanness Assessment

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| **Minimal Ceremony**: Does this element add the minimum necessary process? | | |
| **Value Justified**: Is every requirement justified by clear value? | | |
| **Automation Potential**: Are manual steps automatable? | | |
| **Tiny-Team Appropriate**: Is this practical for 1-3 developers? | | |
| **Scales Across Team Sizes**: Does this work for solo dev, pair, and trio? | | |

**Overall Leanness Score**: ___/25

---

#### D. Implementability Assessment

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| **Actionable**: Can a developer act on this immediately? | | |
| **Dependencies Clear**: Are tool/platform dependencies explicit? | | |
| **Examples Provided**: Are there concrete examples or templates? | | |
| **Edge Cases Addressed**: Does it handle common edge cases? | | |
| **Day-1 Ready**: Can a new team apply this on Day 1? | | |

**Overall Implementability Score**: ___/25

---

#### E. Coherence Assessment

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| **Internally Consistent**: Are there contradictions within this element? | | |
| **Cross-Document Consistent**: Does it align with related documents? | | |
| **Terminology Consistent**: Are terms used consistently? | | |
| **No Duplication**: Is content duplicated unnecessarily elsewhere? | | |
| **References Accurate**: Do cross-references work and point to current content? | | |

**Overall Coherence Score**: ___/25

---

### Element-by-Element Assessment Instructions

Complete the assessment template for each of the following methodology elements. For elements that are strong, explicitly note "✓ Sound design" rather than forcing critiques.

---

### Element 1: Core Overview (README.md)

**Purpose:** Provides the unifying narrative, System Guarantees, Method Lifecycle, and Quick-Start guidance.

**Assessment Questions:**

1. Does the README provide a clear "start here" entry point?
2. Are the System Guarantees achievable and enforceable?
3. Does the Method Lifecycle diagram accurately reflect the methodology?
4. Is the Quick-Start section actually quick (≤30 min to understand)?
5. How well does the README integrate the Six Pillars?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | | |
| Focus | | |
| Velocity | | |
| Trust | | |
| Continuity | | |
| Insight | | |

---

### Element 2: Flow & WIP Policy

**Purpose:** Defines Kanban board, WIP limits, Definitions of Ready/Done/Safe/Small, and risk tier integration.

**Assessment Questions:**

1. Are WIP limits practical for tiny teams (1-3 devs) with blocked cards?
2. Are the Definitions (DoR, DoD, DoSafe, DoSm) clear and enforceable?
3. How well do risk tiers integrate with the flow?
4. Is there guidance for handling blockers and exceptions?
5. Does the policy balance structure with flexibility?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | DoR requires validated specs | |
| Focus | WIP limits reduce cognitive load | |
| Velocity | Flow optimization via Little's Law | |
| Trust | DoSafe gates enforce safety | |
| Continuity | | |
| Insight | | |

---

### Element 3: Risk Tier System (T1/T2/T3)

**Purpose:** Classifies changes by risk level, determines required gates, and scales human effort appropriately.

**Assessment Questions:**

1. Are tier boundaries crisp and unambiguous?
2. Are the human time estimates (2-3/15-20/30-60 min) achievable?
3. Can AI agents reliably classify changes into tiers?
4. Are there change types that don't fit the tier system?
5. How does the tier system handle emergencies and hotfixes?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | T2/T3 require validated specs | |
| Focus | AI absorbs tier classification | |
| Velocity | T1 enables fast path | |
| Trust | Higher tiers require more gates | |
| Continuity | T3 requires ADRs | |
| Insight | Tier misclassification feeds learning | |

---

### Element 4: Spec-First & BMAD Workflow

**Purpose:** Defines the spec-first discipline, BMAD story pattern, and Cursor-assisted development loop.

**Assessment Questions:**

1. Is "every material change" clearly defined?
2. Are the spec templates (tier1/tier2/tier3) appropriately scoped?
3. Is the BMAD → Cursor workflow practical?
4. How does spec-first work for urgent fixes?
5. Is the Plan → Diff → Explain → Test loop clear?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | Core mechanism for validated discovery | |
| Focus | Templates absorb process complexity | |
| Velocity | AI-assisted workflow enables speed | |
| Trust | Specs define contracts and mitigations | |
| Continuity | Specs become institutional memory | |
| Insight | | |

---

### Element 5: CI/CD Quality Gates

**Purpose:** Defines the CI/CD pipeline, required checks by tier, and waiver policy.

**Assessment Questions:**

1. Are there too many gates for a lean methodology?
2. Is the T1 gate set truly trivial?
3. Are gates fail-closed (infra failure = block)?
4. Is the waiver policy clear and abuse-resistant?
5. How do gates integrate with Vercel previews?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | | |
| Focus | Automated gates absorb manual checking | |
| Velocity | Fast, parallelized CI | |
| Trust | Gates enforce safety | |
| Continuity | | |
| Insight | Gate failures inform improvement | |

---

### Element 6: Security Baseline

**Purpose:** Maps OWASP ASVS and NIST SSDF to specs, CI, and operations; includes STRIDE guidance.

**Assessment Questions:**

1. Is the ASVS/SSDF mapping actionable or overwhelming?
2. Is STRIDE practical at the feature level?
3. Are security controls appropriate for tiny teams (1-3 devs)?
4. Is there guidance for security-sensitive vs. routine changes?
5. How does security integrate with the tier system?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | STRIDE in specs | |
| Focus | Security absorbed into gates | |
| Velocity | | |
| Trust | Core mechanism for security | |
| Continuity | Security decisions documented | |
| Insight | Security postmortems | |

---

### Element 7: Reliability & Ops

**Purpose:** Defines SLIs/SLOs, error budgets, incidents, and postmortems.

**Assessment Questions:**

1. Are the starter SLOs appropriate for a new team?
2. Is the error budget policy practical?
3. Is the postmortem template usable?
4. How does reliability integrate with the tier system?
5. Is the Insight → Direction feedback loop clear?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | Postmortems inform future specs | |
| Focus | | |
| Velocity | Error budgets gate releases | |
| Trust | SLOs define trust boundaries | |
| Continuity | Postmortems preserve context | |
| Insight | Core mechanism for learning | |

---

### Element 8: Architecture & Repo Structure

**Purpose:** Defines 12-Factor, Hexagonal, Turborepo, and feature flag patterns.

**Assessment Questions:**

1. Is the monolith-first guidance clear?
2. Are Hexagonal boundaries practical for AI-generated code?
3. Is the feature flag discipline too heavy for small teams?
4. How does architecture integrate with the tier system?
5. Is there guidance for architectural evolution?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | | |
| Focus | Hexagonal boundaries absorb complexity | |
| Velocity | Turborepo enables fast builds | |
| Trust | Contracts at boundaries | |
| Continuity | | |
| Insight | | |

---

### Element 9: Tooling & Metrics

**Purpose:** Maps GitHub/Vercel/Turborepo tooling and DORA/SRE metrics.

**Assessment Questions:**

1. Are tooling dependencies explicit and justified?
2. Are metrics achievable for tiny teams (1-3 devs)?
3. Is there automation guidance for metrics collection?
4. How do metrics integrate with the tier system?
5. Are there leading vs. lagging indicator distinctions?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | | |
| Focus | Tooling absorbs operational complexity | |
| Velocity | DORA metrics measure velocity | |
| Trust | | |
| Continuity | | |
| Insight | Metrics enable learning | |

---

### Element 10: Adoption Plan (30/60/90)

**Purpose:** Provides staged adoption guidance for teams new to Harmony.

**Assessment Questions:**

1. Are the 30/60/90 milestones achievable?
2. Is Day 1 achievable (what's the minimum setup)?
3. Are dependencies sequenced correctly?
4. Is there guidance for partial adoption?
5. How does adoption relate to the tier system?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | | |
| Focus | Staged adoption reduces overwhelm | |
| Velocity | Fast time-to-value | |
| Trust | | |
| Continuity | | |
| Insight | | |

---

### Element 11: Sandbox Flow

**Purpose:** Defines the canonical end-to-end flow for validating changes in sandbox environments using previews, feature flags, CI gates, and observability before production rollout.

**Assessment Questions:**

1. Is the A→J lifecycle mapping clear and actionable?
2. Are sandbox surfaces (PR preview, trunk preview, runtime preview) well-defined?
3. Is the relationship between sandbox validation and production promotion clear?
4. Are human vs. agent vs. CI responsibilities adequately specified?
5. Are sandbox patterns by change type (feature, adapter, runtime) practical?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | Sandbox validates spec requirements | |
| Focus | Previews absorb deployment complexity | |
| Velocity | Fast feedback via preview deployments | |
| Trust | Flags and gates ensure safe rollout | |
| Continuity | Knowledge Plane integration for audit | |
| Insight | Sandbox telemetry informs learning | |

---

### Element 12: Methodology-as-Code

**Purpose:** Encodes methodology constraints (pillars, lifecycle stages, HITL requirements, policy rules) into machine-readable JSON schemas for deterministic AI agent consumption.

**Assessment Questions:**

1. Is the "schemas are authoritative, documentation is derived" principle consistently applied?
2. Are the layered methodology coupling levels (structural/operational/implementation) clear?
3. Is the versioning policy (semver for schemas and methodology) practical?
4. Are enforcement modes (block/warn/off) and transition procedures documented?
5. Is the deprecation policy (N-1 support, deprecation windows) reasonable for tiny teams?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | Schemas define what methodology expects | |
| Focus | Machine-readable contracts reduce ambiguity | |
| Velocity | Automated validation speeds adoption | |
| Trust | Deterministic enforcement via schemas | |
| Continuity | Versioned schemas preserve compatibility | |
| Insight | Schema validation surfaces methodology drift | |

---

### Element 13: Auto-Tier Assignment Algorithm

**Purpose:** Specifies the algorithm AI agents use to automatically classify changes into risk tiers (T1, T2, T3).

**Assessment Questions:**

1. Are the signal extraction categories (file, scope, content, surface) comprehensive?
2. Are T3/T2/T1 trigger patterns accurate and maintainable?
3. Is the "when in doubt, assign higher tier" principle consistently applied?
4. Are edge cases (ambiguous paths, size overrides, intent overrides) handled?
5. Is the bump-up/bump-down policy clear and enforceable?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | Tier assignment informs spec rigor | |
| Focus | AI absorbs tier classification burden | |
| Velocity | T1 enables fast path for trivial changes | |
| Trust | Higher tiers require more gates | |
| Continuity | Classification metrics enable improvement | |
| Insight | Feedback loop improves algorithm over time | |

---

### Element 14: Implementation Guide

**Purpose:** Provides detailed playbook for wiring Harmony's methodology into a Turborepo + Vercel stack, including the A→J lifecycle, kit integrations, and concrete snippets.

**Assessment Questions:**

1. Is the A→J lifecycle (Spec → Shape → Plan → Dev → PR → CI → Merge → Deploy → Operate → Learn) too granular or appropriately detailed?
2. Are the SpecKit, PlanKit, FlowKit relationships clear?
3. Are the concrete code snippets (turbo.json, vercel.json, CI workflows) maintainable?
4. Is the LLMOps vs PromptOps vs ContextOps distinction clear and valuable?
5. Are the custom modules (SRE, Security, QA, Perf, DevOps) appropriately scoped?

**Pillar Mapping:**

| Pillar | Connection | Strength (◉/◐/○) |
|--------|------------|------------------|
| Direction | SpecKit + PlanKit implement validated discovery | |
| Focus | Kits absorb implementation complexity | |
| Velocity | Concrete snippets enable fast setup | |
| Trust | Gates and guardrails baked into examples | |
| Continuity | A→J lifecycle captures full workflow | |
| Insight | Operate → Learn phases close the loop | |

---

## Part 2: Cross-Element Analysis

Evaluate the methodology elements as a system.

### 2.1 Pillar Coverage Analysis

**Instruction:** Verify each pillar is adequately operationalized by the methodology.

| Pillar | Primary Elements | Secondary Elements | Coverage (1-5) | Gaps? |
|--------|-----------------|-------------------|----------------|-------|
| Direction | Spec-First, Risk Tiers | Flow & WIP | | |
| Focus | Core, Architecture | Adoption | | |
| Velocity | CI/CD, Flow & WIP | Risk Tiers | | |
| Trust | CI/CD, Security | Reliability | | |
| Continuity | Reliability | Architecture | | |
| Insight | Reliability, Tooling | | | |

**Pillar Coverage Score:** ___/30

---

### 2.2 Phase Coherence Analysis

**Instruction:** Evaluate whether methodology elements form coherent phases.

#### PLAN Phase Coverage

| Criterion | Assessment |
|-----------|------------|
| Does the methodology clearly address "What to build?" (Direction) | |
| Does the methodology clearly address "How to think about it?" (Focus) | |
| Is there a clear handoff from PLAN to SHIP? | |
| Are PLAN activities appropriately lightweight? | |

**PLAN Phase Score:** ___/20

---

#### SHIP Phase Coverage

| Criterion | Assessment |
|-----------|------------|
| Does the methodology clearly address "How to deliver fast?" (Velocity) | |
| Does the methodology clearly address "How to deliver safely?" (Trust) | |
| Is there a clear handoff from SHIP to LEARN? | |
| Are SHIP activities appropriately automated? | |

**SHIP Phase Score:** ___/20

---

#### LEARN Phase Coverage

| Criterion | Assessment |
|-----------|------------|
| Does the methodology clearly address "How to remember?" (Continuity) | |
| Does the methodology clearly address "How to improve?" (Insight) | |
| Does LEARN feed back cleanly to PLAN? | |
| Are LEARN activities integrated into daily work? | |

**LEARN Phase Score:** ___/20

---

### 2.3 Concern Distribution Analysis

**Instruction:** Verify each major concern has exactly one primary owner.

| Concern | Primary Element | Secondary Element(s) | Overlap Risk |
|---------|-----------------|---------------------|--------------|
| Product discovery | | | |
| Risk classification | | | |
| Work management | | | |
| Code quality | | | |
| Security | | | |
| Reliability | | | |
| Performance | | | |
| Observability | | | |
| Agent governance | | | |
| Knowledge management | | | |
| Continuous improvement | | | |

**Concern Distribution Health:** Good / Needs Attention / Problematic

---

### 2.4 Terminology Consistency Analysis

**Instruction:** Verify consistent terminology across documents.

| Term | Variant A | Variant B | Variant C | Preferred | Inconsistent Documents |
|------|-----------|-----------|-----------|-----------|----------------------|
| Risk levels | T1/T2/T3 | Trivial/Standard/Elevated | Low/Medium/High | | |
| Validation gates | Gate | Check | Guard | | |
| Specification | Spec | One-pager | BMAD story | | |
| Safety | Safe | Safety | Trust | | |
| Work item | Card | Ticket | Issue | | |

---

### 2.5 Duplication Analysis

**Instruction:** Identify content that appears in multiple documents.

| Content | Document A | Document B | Intentional? | Identical? | Consolidate? |
|---------|------------|------------|--------------|------------|--------------|
| WIP limits | README | flow-and-wip-policy | | | |
| Risk tier gates | risk-tiers | ci-cd-quality-gates | | | |
| SLO definitions | README | reliability-and-ops | | | |
| Feature flag guidance | README | architecture | | | |
| STRIDE guidance | security-baseline | spec-first-bmad | | | |

---

### 2.6 Completeness Check

**Instruction:** Verify all referenced content exists and is complete.

| Question | Answer |
|----------|--------|
| Are there documents referenced but not yet written? | |
| Are there TODO markers or placeholder sections? | |
| Are there "coming soon" or aspirational references? | |
| Are all cross-document links functional? | |
| Are template files complete and usable? | |

**Documents to verify exist:**

| Referenced Document | Exists? | Complete? | Notes |
|--------------------|---------|-----------|-------|
| `spec-first-bmad.md` | | | |
| `ci-cd-quality-gates.md` | | | |
| `security-baseline.md` | | | |
| `reliability-and-ops.md` | | | |
| `performance-and-scalability.md` | | | |
| `architecture-and-repo-structure.md` | | | |
| `tooling-and-metrics.md` | | | |
| `adoption-plan-30-60-90.md` | | | |
| `sandbox-flow.md` | | | |
| `methodology-as-code.md` | | | |
| `auto-tier-assignment.md` | | | |
| `implementation-guide.md` | | | |
| `tiny-team-assessment.md` | | | |
| `templates/spec-tier1.yaml` | | | |
| `templates/spec-tier2.yaml` | | | |
| `templates/spec-tier3.yaml` | | | |

**Referenced Pillar Documents (from `../pillars/`):**

| Pillar Document | Exists? | Complete? | Notes |
|-----------------|---------|-----------|-------|
| `../pillars/README.md` | | | |
| `../pillars/direction.md` | | | |
| `../pillars/focus.md` | | | |
| `../pillars/velocity.md` | | | |
| `../pillars/trust.md` | | | |
| `../pillars/continuity.md` | | | |
| `../pillars/insight.md` | | | |

---

### 2.7 Kit-to-Methodology Integration Check

The Six Pillars reference specific kits as their implementation mechanisms. Verify these kits are properly integrated into methodology documents.

**Instruction:** For each pillar's key kits, verify they appear in the appropriate methodology documents.

| Kit | Pillar | Expected in Methodology | Actually Referenced? | Integration Quality |
|-----|--------|------------------------|---------------------|---------------------|
| SpecKit | Direction | Spec-First, Risk Tiers | | |
| PlanKit (BMAD) | Direction | Spec-First | | |
| kit-base | Focus | Architecture | | |
| PromptKit | Focus | Architecture, AI sections | | |
| AgentKit | Velocity | Core, CI/CD | | |
| FlowKit | Velocity | Core, CI/CD | | |
| CIKit | Velocity | CI/CD Quality Gates | | |
| PatchKit | Velocity | Core (if implemented) | | |
| PolicyKit | Trust | Security, CI/CD | | |
| GuardKit | Trust | Security, CI/CD | | |
| EvalKit | Trust, Insight | Reliability, CI/CD | | |
| FlagKit | Trust | Architecture, Core | | |
| Dockit | Continuity | Reliability, Core | | |
| ObservaKit | Continuity | Reliability, Core | | |
| DatasetKit | Insight | Reliability | | |

**Questions:**

1. Are all pillar kits mentioned in at least one methodology document?
2. Is the kit's role in the methodology clear (not just mentioned in passing)?
3. Are there kits referenced in methodology that aren't assigned to pillars?
4. Are kit maturity levels (Production/Beta/Aspirational) acknowledged?

**Integration Health:** Complete / Partial / Gaps Identified

---

### 2.8 Anti-Pattern Catalog Check

A mature methodology should document what *not* to do, not just best practices.

**Instruction:** Verify the methodology includes explicit anti-patterns or "don't do this" guidance.

| Category | Anti-Pattern Expected | Documented? | Where? |
|----------|----------------------|-------------|--------|
| Spec-First | Skipping specs for "quick fixes" | | |
| Risk Tiers | Always choosing T1 to avoid ceremony | | |
| WIP Limits | Violating limits "just this once" | | |
| AI Usage | Trusting AI output without review | | |
| Feature Flags | Leaving flags enabled indefinitely | | |
| Security | Deferring STRIDE "until later" | | |
| Observability | Shipping without traces | | |
| Postmortems | Blame-oriented incident response | | |
| Reviews | Rubber-stamping PRs | | |
| Waivers | Using waivers as standard practice | | |

**Questions:**

1. Does the methodology explicitly call out common failure modes?
2. Are anti-patterns linked to their corresponding best practices?
3. Would a new developer recognize when they're doing something wrong?

**Anti-Pattern Coverage:** Comprehensive / Partial / Missing

---

### 2.9 Comparative Differentiation Check

Teams adopting Harmony likely have experience with other methodologies. Evaluate whether Harmony's differentiation is clear.

**Instruction:** Assess how Harmony positions itself relative to common alternatives.

| Alternative | How Harmony Differs | Differentiation Clear? | Where Documented? |
|-------------|--------------------|-----------------------|-------------------|
| Pure Agile/Scrum | | | |
| Kanban (generic) | | | |
| XP (Extreme Programming) | | | |
| DevOps (generic) | | | |
| No methodology ("just ship") | | | |
| Heavy enterprise processes | | | |

**Key Differentiators to Verify:**

| Differentiator | Claimed? | Substantiated? | Evidence |
|----------------|----------|----------------|----------|
| AI-accelerated (not just AI-assisted) | | | |
| Lean for tiny teams (1-3 devs) | | | |
| Spec-first with tiered rigor | | | |
| Convivial Purpose integration | | | |
| Methodology-as-code (enforceable) | | | |
| PLAN → SHIP → LEARN feedback loop | | | |

**Questions:**

1. Can a team clearly articulate "why Harmony over X"?
2. Are there scenarios where Harmony is *not* the right choice?
3. Does the methodology acknowledge its boundaries and trade-offs?

**Differentiation Clarity:** Clear / Implicit / Unclear

---

### 2.10 Document Readability and Entry Point Analysis

**Instruction:** Evaluate whether documentation is approachable for new team members.

#### Document Length Analysis

| Document | Line Count | Reading Time (est.) | Appropriate Length? |
|----------|-----------|--------------------|--------------------|
| README.md | | min | Yes / Too long / Too short |
| flow-and-wip-policy.md | | min | |
| risk-tiers.md | | min | |
| spec-first-bmad.md | | min | |
| implementation-guide.md | | min | |
| Other critical docs: | | min | |

#### Entry Point Clarity

| Question | Answer |
|----------|--------|
| Is there a single "start here" document? | |
| Is the reading order clear? | |
| Can someone understand the core in 30 minutes? | |
| Are there quick-reference cards/cheatsheets? | |

#### Prerequisite Knowledge Check

| Assumed Knowledge | Explicitly Stated? | Linked to Resources? |
|-------------------|-------------------|---------------------|
| Git/GitHub basics | | |
| Vercel deployment model | | |
| TypeScript/JavaScript | | |
| OpenTelemetry concepts | | |
| Kanban/WIP concepts | | |
| Hexagonal architecture | | |
| STRIDE threat modeling | | |

**Document Readability Verdict:** Accessible / Moderate learning curve / Steep learning curve

---

### 2.11 HITL States and Semantics Evaluation

**Instruction:** The methodology defines specific Human-in-the-Loop states. Verify these are consistently used.

| HITL State | Definition Clear? | Used Consistently? | Where Documented? |
|------------|------------------|-------------------|-------------------|
| `planned` | | | |
| `requested` | | | |
| `approved` | | | |
| `rejected` | | | |
| `waived` | | | |

**HITL Checkpoints:**

| Checkpoint | Stage | Required For | Documented? |
|------------|-------|--------------|-------------|
| `pre-implement` | Before coding | T2+/T3 specs | |
| `pre-merge` | Before merge | All PRs | |
| `pre-promote` | Before production | All promotes | |
| `post-promote` | After production | T3 | |

**Questions:**

1. Are HITL state transitions logged/auditable?
2. Can waivers be traced back to their justification?
3. Is the approval chain clear for each tier?

**HITL Semantics Verdict:** Clear and consistent / Inconsistent / Underdefined

---

### 2.12 Kit Exit Codes and Error Handling Check

**Instruction:** The methodology defines standard kit exit codes. Verify these are documented and used.

| Exit Code | Meaning | HTTP Mapping | Documented? |
|-----------|---------|--------------|-------------|
| 0 | Success | 200 | |
| 1 | Generic failure | 500 | |
| 2 | Policy violation | 403/422 | |
| 3 | Evaluation/test failure | 422 | |
| 4 | Guard/redaction violation | 400 | |
| 5 | Invalid inputs/schema | 400 | |
| 6 | Upstream/provider error | 502 | |
| 7 | Idempotency conflict | 409 | |
| 8 | Cache integrity error | 500 | |

**Questions:**

1. Are error messages structured (typed errors)?
2. Do errors include trace_id for debugging?
3. Is error handling consistent across all kits?

**Error Handling Verdict:** Standardized / Partially standardized / Ad-hoc

---

### 2.13 A→J Lifecycle Granularity Check

The Implementation Guide defines a detailed A→J lifecycle that is more granular than the core PLAN → SHIP → LEARN phases.

**Instruction:** Evaluate whether the A→J lifecycle adds value or complexity.

| Stage | Maps to Phase | Value Added | Complexity Added | Net Assessment |
|-------|---------------|-------------|------------------|----------------|
| A — Spec | PLAN | | | |
| B — Shape & Scope | PLAN | | | |
| C — Plan (BMAD) | PLAN | | | |
| D — Dev in Cursor | SHIP | | | |
| E — PR → Preview | SHIP | | | |
| F — CI Gates | SHIP | | | |
| G — Merge | SHIP | | | |
| H — Deploy | SHIP | | | |
| I — Operate | LEARN | | | |
| J — Learn | LEARN | | | |

**Questions:**

1. Is A→J necessary for tiny teams, or does PLAN → SHIP → LEARN suffice?
2. Are there stages that could be combined without loss?
3. Is the A→J lifecycle consistently referenced across all methodology documents?

**Lifecycle Granularity Verdict:** Appropriate / Overly Granular / Inconsistently Applied

---

### 2.14 AI-Acceleration Evaluation

The methodology claims AI agents can handle repetitive, time-consuming, and complex tasks. Evaluate this claim.

#### 2.14.1 Agent Touchpoints

**Instruction:** Map where AI agents engage in the methodology.

| Touchpoint | Tier(s) | Agent Role | Human Role | Documented? |
|------------|---------|------------|------------|-------------|
| Spec generation | T1/T2/T3 | | | |
| Tier assignment | All | | | |
| Threat analysis (STRIDE) | T2/T3 | | | |
| Code generation (Plan → Diff → Explain → Test) | All | | | |
| Gate enforcement | All | | | |
| PR summaries | All | | | |
| Golden test creation | T2+/T3 | | | |
| Documentation generation | All | | | |
| Other: | | | | |

**Questions:**

1. Are agent touchpoints explicitly documented in the methodology?
2. Is it clear which tasks AI handles vs. which require humans?
3. Are there touchpoints where AI *could* help but currently doesn't?

---

#### 2.14.2 Agent Boundaries

**Instruction:** Verify limits on agent authority are clear and enforceable.

| Boundary | Documented? | Enforceable? | Enforcement Mechanism |
|----------|-------------|--------------|----------------------|
| Agents cannot approve PRs | | | |
| Agents cannot commit to protected branches | | | |
| Agents cannot handle secrets/credentials | | | |
| Agents produce artifacts for human review | | | |
| Agents operate with pinned config | | | |
| Agents default to `--dry-run` | | | |
| Agents record trace/logs for all operations | | | |

**Questions:**

1. Are these boundaries codified in tooling or just policy?
2. What prevents an agent from bypassing these boundaries?
3. Are boundary violations detectable?

---

#### 2.14.3 Determinism Achievability

**Instruction:** Evaluate whether AI determinism requirements are practical.

| Requirement | Achievable? | Current State | Challenges |
|-------------|-------------|---------------|------------|
| Provider/model/version pinned | | | |
| Temperature ≤ 0.3 for deterministic outputs | | | |
| Prompt hash recorded | | | |
| Golden tests guard drift | | | |
| Seed parameter used (if supported) | | | |

**Questions:**

1. Is this achievable with current LLM tooling?
2. What happens when a model is deprecated?
3. Are golden tests practical across all tiers, or should they be T2+/T3-only?
4. How is "material output drift" defined?

---

#### 2.14.4 Human-AI Handoff Clarity

**Instruction:** At each human checkpoint, evaluate handoff quality.

| Checkpoint | What Should Human Look For? | AI Summary Sufficient? | Hidden Decisions? |
|------------|----------------------------|----------------------|-------------------|
| Spec approval (T2+/T3) | | | |
| PR review (all tiers) | | | |
| Tier classification override | | | |
| Promotion to production | | | |
| Postmortem review | | | |

**Questions:**

1. Is it clear what the human should verify at each checkpoint?
2. Are there decisions embedded in AI outputs that humans might miss?
3. Is the AI-generated summary format standardized and sufficient?

---

## Part 3: Methodology Exploration

Explore concepts, patterns, tools, ideas, architectures, and approaches to determine what may be missing, needs expansion, or should be removed from the methodology.

### 3.1 Gap Exploration — Concepts That May Be Missing

**Instruction:** For each concept below, evaluate whether the methodology should cover it, and if so, how.

#### 3.1.1 Operational Patterns

| Concept | Currently Covered? | Should Be Covered? | If Yes, Where? | Priority |
|---------|-------------------|-------------------|----------------|----------|
| **Async job patterns** (beyond `next/after`) | Partial | | | |
| **Background worker architecture** | No | | | |
| **Event-driven patterns** (pub/sub, queues) | Minimal | | | |
| **Cron/scheduled job governance** | Minimal (vercel.json crons) | | | |
| **Multi-tenant isolation** | No | | | |
| **Data partitioning strategies** | No | | | |

#### 3.1.2 Data Management

| Concept | Currently Covered? | Should Be Covered? | If Yes, Where? | Priority |
|---------|-------------------|-------------------|----------------|----------|
| **Data migration strategies** | Brief mention | | | |
| **Database schema versioning** | Partial (migrations) | | | |
| **Data backup and recovery** | No | | | |
| **Data retention policies** | No | | | |
| **GDPR/privacy compliance workflows** | Partial (PII redaction) | | | |

#### 3.1.3 Resilience and Recovery

| Concept | Currently Covered? | Should Be Covered? | If Yes, Where? | Priority |
|---------|-------------------|-------------------|----------------|----------|
| **Disaster recovery planning** | No | | | |
| **Business continuity** | No | | | |
| **Chaos engineering** | Mentioned briefly | | | |
| **Circuit breaker patterns** | No | | | |
| **Graceful degradation** | Partial (flags) | | | |

#### 3.1.4 Team and Process

| Concept | Currently Covered? | Should Be Covered? | If Yes, Where? | Priority |
|---------|-------------------|-------------------|----------------|----------|
| **Technical debt tracking** | Brief mention | | | |
| **Debt budget management** | Mentioned but not detailed | | | |
| **Documentation standards** (beyond ADRs) | Partial | | | |
| **Knowledge transfer protocols** | No | | | |
| **On-call rotation guidance** | Partial | | | |
| **Vacation/absence coverage** | No | | | |
| **Remote/distributed team patterns** | No | | | |
| **Timezone handling for async work** | No | | | |
| **Communication channel guidance** (when to use what) | No | | | |
| **Decision-making authority matrix** | Partial (Driver/Navigator) | | | |
| **Escalation paths** | Partial | | | |
| **External stakeholder management** | No | | | |

#### 3.1.5 API and Integration

| Concept | Currently Covered? | Should Be Covered? | If Yes, Where? | Priority |
|---------|-------------------|-------------------|----------------|----------|
| **API versioning strategies** | Partial (OpenAPI diff) | | | |
| **Backward compatibility policies** | Partial (methodology-as-code) | | | |
| **Third-party integration governance** | Partial (adapters) | | | |
| **Webhook reliability patterns** | Partial (idempotency) | | | |
| **Rate limiting strategies** | Brief mention | | | |

#### 3.1.6 Product and User Research

| Concept | Currently Covered? | Should Be Covered? | If Yes, Where? | Priority |
|---------|-------------------|-------------------|----------------|----------|
| **User feedback integration** | No | | | |
| **User research governance** | No | | | |
| **A/B testing and experimentation** | Partial (flags) | | | |
| **Experiment result interpretation** | No | | | |
| **Feature success/failure criteria** | Partial (SLOs) | | | |
| **User-facing metrics vs. system metrics** | No | | | |
| **Analytics and privacy balance** | Partial (PII redaction) | | | |

#### 3.1.7 Methodology Self-Assessment

| Concept | Currently Covered? | Should Be Covered? | If Yes, Where? | Priority |
|---------|-------------------|-------------------|----------------|----------|
| **Methodology success criteria** | No | | | |
| **When to deviate from methodology** | Partial (waivers) | | | |
| **Methodology evolution process** | Partial (methodology-as-code) | | | |
| **Re-evaluation triggers** | No | | | |
| **Methodology health metrics** | No | | | |

**Gap Exploration Verdict:** Major gaps exist / Minor gaps exist / No significant gaps

---

### 3.2 Expansion Exploration — Concepts That Need More Depth

**Instruction:** For each concept that IS covered, evaluate whether it needs expansion.

| Concept | Current Coverage Level | Adequate? | Expansion Needed | Recommended Additions |
|---------|----------------------|-----------|------------------|----------------------|
| **Error budgets** | Conceptual + policy | | | |
| **Feature flag lifecycle** | Good | | | |
| **Postmortem process** | Template + guidance | | | |
| **STRIDE threat modeling** | Per-feature guidance | | | |
| **Contract testing** | Pact + Schemathesis | | | |
| **Observability requirements** | Span/log/metric baselines | | | |
| **Rollback procedures** | `vercel promote` | | | |
| **WIP limit enforcement** | Board policy | | | |
| **Kit-to-pillar alignment** | Mapping table | | | |
| **HITL checkpoint enforcement** | States + semantics | | | |

**Questions:**

1. Are there concepts where the depth is inconsistent (detailed in one doc, shallow in another)?
2. Are there concepts that are mentioned but never operationalized?
3. Are there concepts that assume prior knowledge without explaining?

**Expansion Verdict:** Significant expansion needed / Minor expansion needed / Coverage adequate

---

### 3.3 Removal/Simplification Exploration — Concepts That May Be Overcovered

**Instruction:** Evaluate whether any concepts are over-engineered or add unnecessary complexity for tiny teams.

#### 3.3.1 Tooling Specificity

| Item | Current State | Too Prescriptive? | Alternative Approach |
|------|--------------|-------------------|---------------------|
| **Vercel-specific patterns** | Detailed (promote, flags, previews) | | |
| **Turborepo-specific configs** | turbo.json examples | | |
| **Next.js/Astro-specific guidance** | PPR, caching, Edge vs Node | | |
| **GitHub Actions specifics** | Workflow examples | | |

**Question:** Should the methodology be more tool-agnostic, or is the specificity valuable for tiny teams?

#### 3.3.2 Process Ceremony

| Item | Current State | Justified? | Could Simplify? |
|------|--------------|-----------|-----------------|
| **11 System Guarantees** | Detailed invariants | | |
| **A→J Lifecycle (10 stages)** | Granular lifecycle | | |
| **5 Assessment Dimensions** per element | Clarity/Alignment/Leanness/Implementability/Coherence | | |
| **6 Pillars across 3 Phases** | Structural hierarchy | | |
| **3 Risk Tiers with detailed triggers** | T1/T2/T3 classification | | |

**Question:** Does the methodology maintain appropriate simplicity, or has it accumulated complexity?

#### 3.3.3 Day-1 vs. Day-90 Confusion

| Item | Marked as Day-1? | Actually Day-1 Practical? | Recommendation |
|------|-----------------|--------------------------|----------------|
| **CodeQL in CI** | Day 31-60 | | |
| **Pact/Schemathesis** | Day 61-90 | | |
| **Full OTel instrumentation** | Day 61-90 | | |
| **Perf budget enforcement** | Day 61-90 | | |
| **SBOM generation** | Day 1 (nightly) | | |

**Removal/Simplification Verdict:** Significant simplification possible / Minor tweaks possible / Complexity justified

---

### 3.4 Architectural Pattern Exploration

**Instruction:** Evaluate architectural patterns that could enhance or conflict with the methodology.

| Pattern | Relevant to Tiny Teams? | Currently Covered? | Should Add? | Conflicts? |
|---------|------------------------|-------------------|-------------|-----------|
| **Micro-frontends** | Maybe (at scale) | No | | |
| **Server Components (React 19)** | Yes | Partial | | |
| **Edge-first architecture** | Yes | Partial | | |
| **Serverless-first** | Yes (Vercel) | Implicit | | |
| **Event sourcing** | Rarely | No | | |
| **CQRS** | Rarely | No | | |
| **Vertical slice architecture** | Sometimes | No (Hexagonal preferred) | | |
| **Modular monolith boundaries** | Yes | Yes (Hexagonal) | | |

**Questions:**

1. Are there architectural patterns that should be explicitly discouraged?
2. Are there patterns that tiny teams commonly adopt that the methodology doesn't address?
3. Does the Hexagonal preference create problems for any common use cases?

---

### 3.5 Tool and Framework Exploration

**Instruction:** Evaluate tools and frameworks that might be missing from or conflict with the methodology.

#### 3.5.1 Potentially Missing Tools

| Tool/Framework | Category | Addresses Gap? | Should Add? | Where? |
|----------------|----------|---------------|-------------|--------|
| **Temporal/Inngest** | Workflow orchestration | Async jobs | | |
| **Trigger.dev** | Background jobs | Async jobs | | |
| **Upstash** | Serverless Redis/Kafka | Caching, queues | | |
| **Neon/PlanetScale** | Serverless DB | Data management | | |
| **Clerk/Auth.js** | Authentication | Auth patterns | | |
| **Stripe webhooks** | Payment processing | Already mentioned | | |
| **Axiom/Baselime** | Observability | OTel backends | | |
| **Checkly/Grafana k6** | Synthetic monitoring | Reliability | | |

#### 3.5.2 Tool Alignment Check

| Tool Currently Mentioned | Still Best Practice? | Alternatives to Consider |
|-------------------------|---------------------|-------------------------|
| **Pact** (contract testing) | Yes | MSW, Prism |
| **Schemathesis** (API fuzzing) | Yes | Dredd |
| **CodeQL** (SAST) | Yes | SonarQube |
| **Semgrep** (SAST) | Yes | — |
| **Syft** (SBOM) | Yes | Trivy |
| **Playwright** (E2E) | Yes | Cypress |
| **Size-Limit** (bundle) | Yes | Bundlewatch |

**Tool Exploration Verdict:** Tools are current / Some tools outdated / Major gaps in tooling

---

### 3.6 AI/LLM Pattern Exploration

**Instruction:** Evaluate AI/LLM patterns and practices for coverage and currency.

| Pattern | Currently Covered? | Adequate? | Expansion/Modification Needed |
|---------|-------------------|-----------|------------------------------|
| **Prompt versioning** | Yes (PromptKit, prompt_hash) | | |
| **Model fallback strategies** | No | | |
| **Token budget management** | Partial (cost guardrails) | | |
| **Streaming responses** | No | | |
| **RAG patterns** | Partial (ContextOps) | | |
| **Fine-tuning governance** | No | | |
| **Agent memory/state** | Partial (FlowKit, LangGraph) | | |
| **Multi-model orchestration** | Partial (ModelKit mentioned) | | |
| **Prompt injection prevention** | Partial (GuardKit) | | |
| **Output validation** | Yes (JSON-Schema, golden tests) | | |
| **Hallucination detection** | Partial (EvalKit) | | |
| **Human-AI attribution** | Partial (provenance) | | |

**Questions:**

1. Are there emerging AI/LLM patterns that the methodology should anticipate?
2. Is the determinism requirement (temperature ≤ 0.3) too restrictive for some use cases?
3. Is the golden test strategy practical as models evolve?

**AI Pattern Exploration Verdict:** AI coverage comprehensive / AI coverage needs update / Major AI gaps

---

### 3.7 Convivial Technology Exploration

**Instruction:** Evaluate whether the methodology adequately addresses convivial technology principles.

| Convivial Principle | How Methodology Addresses | Gaps? | Recommendations |
|--------------------|--------------------------|-------|-----------------|
| **Expands human capability** | Pillars, AI acceleration | | |
| **Respects attention** | WIP limits, focus blocks | | |
| **Fosters connection** | Driver/Navigator, retros | | |
| **Resists extraction** | Privacy-first, PII redaction | | |
| **User agency** | Feature flags (opt-in) | | |
| **Transparency** | Observability, traces | | |
| **Reversibility** | Rollback, flags | | |
| **Appropriate scale** | Tiny team focus | | |

**Questions:**

1. Does the methodology help teams *detect* when they're building non-convivial features?
2. Is there guidance for refusing or pushing back on extractive product requirements?
3. Does the Convivial Impact Assessment in specs have teeth, or is it checkbox compliance?

**Convivial Exploration Verdict:** Strong convivial alignment / Partial alignment / Needs strengthening

---

### 3.8 Exploration Summary Matrix

| Category | Gaps Found | Expansion Needed | Simplification Possible | Priority |
|----------|-----------|------------------|------------------------|----------|
| Operational Patterns | | | | |
| Data Management | | | | |
| Resilience and Recovery | | | | |
| Team and Process | | | | |
| API and Integration | | | | |
| Architectural Patterns | | | | |
| Tools and Frameworks | | | | |
| AI/LLM Patterns | | | | |
| Convivial Technology | | | | |

**Overall Exploration Verdict:**

- **Major additions recommended:** (list)
- **Expansions recommended:** (list)
- **Simplifications recommended:** (list)
- **No changes needed:** (list)

---

## Part 4: System Guarantees Audit

The methodology defines "System Guarantees (self-reinforcing invariants)". Evaluate each.

### 4.1 Guarantee Assessment Template

For each guarantee, evaluate:

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| **Clearly Defined**: Is the guarantee unambiguous? | | |
| **Technically Enforceable**: Can this be enforced by tooling? | | |
| **Actually Enforced**: Is enforcement implemented? | | |
| **Failure Mode Clear**: What happens if the guarantee breaks? | | |
| **Pillar Aligned**: Which pillar(s) does this serve? | | |

---

### Guarantee 1: Spec-First Changes

> Every material change starts with a one‑pager + ADR and micro‑STRIDE. No spec, no start.

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| Clearly Defined | | Is "material change" defined? |
| Technically Enforceable | | Can CI block non-spec PRs? |
| Actually Enforced | | Is this implemented? |
| Failure Mode Clear | | What if specs are skipped? |
| Pillar Aligned | | Direction |

---

### Guarantee 2: No Silent Apply

> Agents produce plans/diffs/tests only; humans gate side‑effects. Local runs default to `--dry-run`.

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| Clearly Defined | | What counts as "apply"? |
| Technically Enforceable | | How is dry-run enforced? |
| Actually Enforced | | Is this implemented? |
| Failure Mode Clear | | What if agents apply silently? |
| Pillar Aligned | | Trust |

---

### Guarantee 3: Deterministic AI

> Provider/model/version/params pinned; low variance (temperature ≤ 0.3); prompt hash recorded; golden tests guard drift.

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| Clearly Defined | | Are all params specified? |
| Technically Enforceable | | Can CI verify pinning? |
| Actually Enforced | | Is this implemented? |
| Failure Mode Clear | | What if AI drifts? |
| Pillar Aligned | | Trust |

---

### Guarantee 4: Observability Required

> Changed flows must emit OTel spans/logs; PRs link a `trace_id`. Evidence packs are assembled per PR.

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| Clearly Defined | | What flows require observability? |
| Technically Enforceable | | Can CI verify spans? |
| Actually Enforced | | Is this implemented? |
| Failure Mode Clear | | What if observability is missing? |
| Pillar Aligned | | Trust, Continuity |

---

### Guarantee 5: Idempotency & Rollback

> Mutations use idempotency keys; risky features ship behind flags; rollback is "promote prior preview".

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| Clearly Defined | | When are idempotency keys required? |
| Technically Enforceable | | Can CI verify idempotency? |
| Actually Enforced | | Is this implemented? |
| Failure Mode Clear | | What if rollback fails? |
| Pillar Aligned | | Trust |

---

### Guarantee 6: Fail-Closed Governance

> Policy/Eval/Test gates block on missing evidence or violations; High‑risk changes require navigator + security review.

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| Clearly Defined | | What triggers fail-closed? |
| Technically Enforceable | | Does infra failure = block? |
| Actually Enforced | | Is this implemented? |
| Failure Mode Clear | | What if gates fail to run? |
| Pillar Aligned | | Trust |

---

### Guarantee 7: Local-First & Privacy-First

> Secrets never leave Vault/env; PII redacted at log/write boundaries; offline telemetry buffers flush later.

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| Clearly Defined | | Where is redaction enforced? |
| Technically Enforceable | | Can CI verify PII handling? |
| Actually Enforced | | Is this implemented? |
| Failure Mode Clear | | What if PII leaks? |
| Pillar Aligned | | Trust |

---

### Guarantee 8: Cost & Efficiency Guardrails

> Publish monthly AI token and infra budgets; alert on cost anomalies; freeze risky merges/promotions on sustained anomalies.

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| Clearly Defined | | Who sets budgets? Thresholds? |
| Technically Enforceable | | Can CI enforce cost limits? |
| Actually Enforced | | Is this implemented? |
| Failure Mode Clear | | What if costs spike? |
| Pillar Aligned | | Trust, Focus |

---

### Guarantee 9: Supply Chain Provenance

> SBOMs are produced for releases and build artifacts are attested.

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| Clearly Defined | | What gets SBOMs? |
| Technically Enforceable | | Is SBOM generation automated? |
| Actually Enforced | | Is this implemented? |
| Failure Mode Clear | | What if provenance is missing? |
| Pillar Aligned | | Trust |

---

### Guarantee 10: Small Batches by Policy

> Trunk‑based, tiny PRs, explicit WIP limits, and preview smoke keep cycle time short.

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| Clearly Defined | | What's "small"? (DoSm) |
| Technically Enforceable | | Can CI enforce PR size? |
| Actually Enforced | | Is this implemented? |
| Failure Mode Clear | | What if PRs are large? |
| Pillar Aligned | | Velocity |

---

### Guarantee 11: Waiver Discipline

> Gate waivers are exceptional and rare; Navigator approval required; explicit scope/timebox (≤ 7 days).

| Criterion | Rating (1-5) | Evidence/Notes |
|-----------|--------------|----------------|
| Clearly Defined | | What can't be waived? |
| Technically Enforceable | | Is timebox auto-enforced? |
| Actually Enforced | | Is this implemented? |
| Failure Mode Clear | | What if waivers are abused? |
| Pillar Aligned | | Trust |

---

### 4.2 Guarantee Summary

| Guarantee | Defined | Enforceable | Enforced | Score |
|-----------|---------|-------------|----------|-------|
| Spec-first changes | /5 | /5 | /5 | /15 |
| No silent apply | /5 | /5 | /5 | /15 |
| Deterministic AI | /5 | /5 | /5 | /15 |
| Observability required | /5 | /5 | /5 | /15 |
| Idempotency & rollback | /5 | /5 | /5 | /15 |
| Fail-closed governance | /5 | /5 | /5 | /15 |
| Local-first & privacy-first | /5 | /5 | /5 | /15 |
| Cost & efficiency guardrails | /5 | /5 | /5 | /15 |
| Supply chain provenance | /5 | /5 | /5 | /15 |
| Small batches by policy | /5 | /5 | /5 | /15 |
| Waiver discipline | /5 | /5 | /5 | /15 |
| **Total** | | | | **/165** |

---

## Part 5: Stress Tests

Subject the methodology to rigorous practical tests.

### 5.1 The 30-Minute Comprehension Test

**Task:** Can a new developer understand the core methodology in 30 minutes?

**Test Procedure:**

1. What is the minimum reading list for Day 1 understanding?
2. Time yourself reading this minimum list.
3. Can you explain the methodology after reading?

| Content | Estimated Time | Essential? |
|---------|---------------|------------|
| README Quick-Start | min | Yes/No |
| Flow & WIP (summary) | min | Yes/No |
| Risk Tiers (overview) | min | Yes/No |
| Spec-First (overview) | min | Yes/No |
| Other: | min | Yes/No |

**Total Time:** ___ minutes

**Verdict:** Pass (≤30 min) / Fail (>30 min)

---

### 5.1.1 The 30-Second Verbal Pitch Test

**Task:** Can you explain the core methodology in 30 seconds to a new team member?

**Attempt your pitch:**

> *[Write your 30-second explanation here]*

**Evaluation Criteria:**

| Criterion | Achieved? |
|-----------|-----------|
| Mentions the three phases (PLAN → SHIP → LEARN) | |
| Explains risk tiers (T1/T2/T3) at a high level | |
| Conveys the "lean for tiny teams" positioning | |
| Mentions AI acceleration | |
| Communicates the feedback loop | |

**Timing:** ___ seconds

**Verdict:** Pass (≤30s, hits ≥3 criteria) / Fail

**Reference Pitch (for comparison):**

> "Harmony is a lean methodology for tiny teams of 1-3 developers. Every change goes through PLAN (validate what to build), SHIP (deliver fast and safely), and LEARN (remember and improve). Changes are tiered by risk—T1 is trivial and takes 2-3 minutes of human time, T2 is standard at 15-20 minutes, and T3 is elevated at 30-60 minutes. AI handles the repetitive work—spec generation, threat analysis, code review summaries—while humans make the decisions. What you learn feeds back into what you plan next."

---

### 5.2 The Day 1 Shipping Test

**Task:** Can a new team ship their first T1 change on Day 1?

| Step | Required? | Time | Blockers? |
|------|-----------|------|-----------|
| Set up GitHub repo | | | |
| Connect Vercel | | | |
| Configure CI | | | |
| Create T1 spec | | | |
| Make change | | | |
| Open PR | | | |
| Pass gates | | | |
| Merge | | | |

**Total Time to First Ship:** ___ hours

**Verdict:** Achievable / Challenging / Unrealistic

---

### 5.3 The Hotfix Test

**Task:** Production is down. Critical fix needed in 30 minutes.

| Question | Answer |
|----------|--------|
| What's the fastest compliant path? | |
| Can spec-first be deferred? | |
| Are there expedited gates? | |
| Is post-incident spec creation documented? | |
| Does the methodology handle this scenario? | |

**Verdict:** Covered / Partially Covered / Gap

---

### 5.4 The Team Change Test

**Task:** One developer leaves, a new one joins mid-project.

| Question | Answer |
|----------|--------|
| How long until the new dev is productive? | |
| What onboarding resources exist? | |
| Is institutional memory accessible? | |
| Can the new dev understand recent decisions? | |
| Does the methodology support this transition? | |

**Verdict:** Covered / Partially Covered / Gap

---

### 5.5 The Team Size Variation Tests

**Task:** Evaluate methodology effectiveness across tiny team sizes (1, 2, and 3 developers).

#### 5.5.1 Solo Developer (1 dev)

| Question | Answer |
|----------|--------|
| How do review processes work without a second reviewer? | |
| Is the "Navigator" role meaningful for a solo dev? | |
| Are WIP limits appropriate (In-Dev: 1 is the only option)? | |
| How does the "two-person rule" for T3 changes adapt? | |
| Can a solo dev maintain the methodology without burnout? | |
| What ceremonies can be eliminated or self-directed? | |

**Solo Dev Verdict:** Covered / Partially Covered / Gap

#### 5.5.2 Pair (2 devs)

| Question | Answer |
|----------|--------|
| Is the methodology optimized for this team size? | |
| Are Driver/Navigator roles clear and balanced? | |
| Do WIP limits work when one dev is blocked? | |
| Is ceremony load sustainable? | |

**Pair Verdict:** Covered / Partially Covered / Gap

#### 5.5.3 Trio (3 devs)

| Question | Answer |
|----------|--------|
| How does the third developer integrate into roles? | |
| Should WIP limits increase (In-Review: 3? Ready: 4?)? | |
| Does the review process change? | |
| Is there guidance for trio-specific dynamics? | |

**Trio Verdict:** Covered / Partially Covered / Gap

#### 5.5.4 Scale-Up (Tiny → Small Team: 3 → 4+ devs)

| Question | Answer |
|----------|--------|
| Which methodology elements change when leaving "tiny team" territory? | |
| Are WIP limits re-evaluated? | |
| Are review processes updated? | |
| Is there explicit guidance for this transition? | |
| Does the methodology acknowledge its boundaries? | |

**Scale-Up Verdict:** Covered / Partially Covered / Gap

---

### 5.6 The Solo Developer Feasibility Test

**Task:** A single developer is using Harmony alone. Evaluate critical adaptations.

| Methodology Element | Works for Solo? | Required Adaptation |
|--------------------|-----------------|---------------------|
| PR review (requires reviewer) | | |
| Navigator role (T3 changes) | | |
| Two-person rule (elevated risk) | | |
| Weekly retro (with whom?) | | |
| Driver/Navigator pairing | | |
| WIP limits (In-Review: 2) | | |
| Daily check-in (2 bullets) | | |

**Key Question:** Can a solo developer maintain methodology compliance, or are there elements that *require* a second person and therefore exclude solo developers?

**Solo Feasibility Verdict:** Fully Feasible / Feasible with Adaptations / Not Feasible

---

### 5.7 The Conflict Resolution Test

**Task:** Identify scenarios where methodology elements conflict.

#### Pillar Tensions

These are inherent tensions between pillars that the methodology must balance:

| Tension | Pillar A | Pillar B | How Methodology Resolves | Resolution Clear? |
|---------|----------|----------|-------------------------|-------------------|
| Validated specs vs. shipping fast | Direction | Velocity | | |
| Speed vs. safety gates | Velocity | Trust | | |
| Simplicity vs. comprehensive guardrails | Focus | Trust | | |
| Fast iteration vs. institutional memory | Velocity | Continuity | | |

#### Practical Conflicts

| Scenario | Elements Involved | Conflict | Resolution Documented? |
|----------|------------------|----------|----------------------|
| "Ship fast" vs. "spec-first" | Velocity vs. Direction | | |
| "Lean process" vs. "full gates" | Focus vs. Trust | | |
| "WIP limit 1" vs. "blocked card" | Flow vs. Reality | | |
| "T1 = 2-3 min" vs. actual overhead | Risk Tiers vs. Practice | | |
| "Two-person rule" vs. solo dev | Trust vs. Team Size | | |
| "Hotfix urgency" vs. "spec-first" | Emergency vs. Process | | |

---

### 5.8 The Leanness Ceremony Count

**Task:** Count every required ceremony in the methodology.

| Ceremony | Frequency | Time Required | Tier | Automatable? | Value Justified? |
|----------|-----------|---------------|------|--------------|-----------------|
| Daily check-in | Daily | | All | | |
| Weekly retro | Weekly | | All | | |
| Spec creation | Per change | | T2+ | | |
| PR review | Per change | | All | | |
| Preview smoke | Per change | | T2+ | | |
| Threat analysis | Per change | | T2+ | | |
| Watch window | Per promote | | T3 | | |
| Postmortem | Per incident | | All | | |
| Other: | | | | | |

**Total Weekly Ceremony Time:**

| Team Size | Estimated Hours/Week | Sustainable? |
|-----------|---------------------|--------------|
| 1 dev (solo) | hrs | Yes/No |
| 2 devs (pair) | hrs | Yes/No |
| 3 devs (trio) | hrs | Yes/No |

**Verdict:** Lean (<5 hrs/week) / Moderate (5-10 hrs) / Heavy (>10 hrs)

---

### 5.9 The Tool/Vendor Dependency Test

**Task:** Evaluate how dependent the methodology is on specific tools and vendors.

| Tool/Vendor | Required or Optional? | Alternatives Documented? | Lock-in Risk |
|-------------|----------------------|-------------------------|--------------|
| Vercel | | | High / Medium / Low |
| GitHub | | | High / Medium / Low |
| Turborepo | | | High / Medium / Low |
| OpenTelemetry backend | | | High / Medium / Low |
| Cursor IDE | | | High / Medium / Low |
| Pact Broker | | | High / Medium / Low |

**Questions:**

1. Can a team adopt Harmony without using Vercel?
2. Can a team use GitLab instead of GitHub?
3. Are there budget-free alternatives documented for each paid tool?
4. Is there guidance for migrating away from specific tools?

**Vendor Dependency Verdict:** Low lock-in / Medium lock-in / High lock-in

---

### 5.10 The Budget Constraint Test

**Task:** Evaluate if a team with limited/no budget can adopt Harmony.

| Cost Category | Required Investment | Free Alternative? | Documented? |
|---------------|--------------------|--------------------|-------------|
| CI/CD minutes | | | |
| Vercel Pro features | | | |
| Observability backend | | | |
| Pact Broker hosting | | | |
| AI/LLM tokens | | | |
| Cursor subscription | | | |

**Minimum Viable Budget:** $___ /month for 2-dev team

**Budget Constraint Verdict:** Accessible / Moderate cost / Expensive

---

### 5.11 The Legacy Integration Test

**Task:** A team has existing systems and wants to adopt Harmony incrementally.

| Question | Answer |
|----------|--------|
| Can Harmony coexist with non-Harmony systems? | |
| Is there guidance for brownfield adoption? | |
| How do existing non-Hexagonal codebases migrate? | |
| Can Harmony governance wrap existing CI/CD? | |
| Is incremental adoption path clear? | |

**Legacy Integration Verdict:** Covered / Partially Covered / Gap

---

### 5.12 The External Audit/Compliance Test

**Task:** An external auditor wants evidence of your development practices.

| Compliance Requirement | Methodology Produces Evidence? | Where? |
|-----------------------|-------------------------------|--------|
| Change traceability (SOC 2) | | |
| Code review evidence | | |
| Security testing evidence | | |
| Access control documentation | | |
| Incident response procedures | | |
| Risk assessment documentation | | |

**Questions:**

1. Can ComplianceKit evidence packs satisfy common audit requirements?
2. Are ADRs and postmortems structured for external review?
3. Is there guidance for mapping Harmony artifacts to compliance frameworks?

**Audit/Compliance Verdict:** Audit-ready / Needs work / Gap

---

### 5.13 The Remote/Distributed Team Test

**Task:** Evaluate if the methodology works for geographically distributed tiny teams.

| Question | Answer |
|----------|--------|
| Can async-first communication work with this methodology? | |
| How do timezone differences affect Driver/Navigator rotation? | |
| Is the daily check-in practical across timezones? | |
| Can the weekly retro work asynchronously? | |
| How do PR reviews work with timezone gaps? | |
| Is there guidance for "follow-the-sun" patterns? | |

**Remote/Distributed Verdict:** Covered / Partially Covered / Gap

---

### 5.14 The Experimentation/A-B Testing Test

**Task:** Evaluate how the methodology handles product experimentation.

| Question | Answer |
|----------|--------|
| Is there guidance for A/B test governance? | |
| How do experiments interact with feature flags? | |
| Are experiment success criteria documented? | |
| How long can experiments run? | |
| Who decides to ship or kill an experiment? | |
| How do experiments affect the tier system? | |

**Experimentation Verdict:** Covered / Partially Covered / Gap

---

### 5.15 The Stop-the-Line Trigger Evaluation

**Task:** Evaluate the documented stop-the-line triggers for completeness and enforceability.

| Stop-the-Line Trigger | Documented? | Automatically Enforced? | Manual Override Possible? |
|-----------------------|-------------|------------------------|--------------------------|
| Secret exposure | | | |
| License violation | | | |
| Security regression (ASVS high/critical) | | | |
| SLO burn-rate breach | | | |
| Missing rollback path/flag | | | |
| Preview e2e red | | | |
| OpenAPI breaking change without sign-off | | | |
| Missing observability on changed flows | | | |
| Missing PR risk rubric | | | |
| AI model/params not pinned | | | |
| Debt budget exceeded | | | |
| WIP limits breached >24h | | | |

**Questions:**

1. Are all stop-the-line triggers technically enforceable in CI?
2. Is escalation path clear when triggers fire?
3. Are there false-positive scenarios that could block legitimate work?

**Stop-the-Line Verdict:** Comprehensive / Partial / Gaps

---

## Part 6: Convivial Purpose Alignment

Evaluate how the methodology serves the foundational Convivial Purpose.

### 6.1 Convivial Purpose Definition

> **The software we ship should expand human capability, respect attention, and foster connection—not extract, manipulate, or diminish.**

### 6.2 Methodology-to-Convivial Alignment

| Methodology Element | Expands Capability | Respects Attention | Fosters Connection | Resists Extraction |
|--------------------|-------------------|-------------------|-------------------|-------------------|
| Spec-First | | | | |
| Risk Tiers | | | | |
| CI/CD Gates | | | | |
| WIP Limits | | | | |
| Agent Governance | | | | |
| Postmortems | | | | |
| Feature Flags | | | | |

### 6.3 Convivial Guardrail Check

**Instruction:** Verify the methodology includes convivial guardrails.

| Risk | Methodology Guardrail | Implemented? |
|------|----------------------|--------------|
| Shipping manipulative features fast | Convivial Impact Assessment in specs | |
| Agents enabling dark patterns | Agent guardrails blocking manipulation | |
| Surveillance through determinism | Privacy-aware constraints | |
| Extractive metrics | Flourishing metrics in eval | |
| Attention-hostile UX | Attention-class in specs | |

---

## Part 7: Refinement Recommendations

Based on the assessment, provide refinement recommendations **only where warranted**. If an element is sound, explicitly note "✓ No refinement needed" rather than forcing changes.

### 7.1 Element-Level Refinements

| Element | Current State | Refinement Needed? | Recommended Change (if any) | Rationale |
|---------|--------------|-------------------|----------------------------|-----------|
| Core Overview | | Yes / No | | |
| Flow & WIP | | Yes / No | | |
| Risk Tiers | | Yes / No | | |
| Spec-First | | Yes / No | | |
| CI/CD Gates | | Yes / No | | |
| Security Baseline | | Yes / No | | |
| Reliability & Ops | | Yes / No | | |
| Architecture | | Yes / No | | |
| Tooling & Metrics | | Yes / No | | |
| Adoption Plan | | Yes / No | | |
| Sandbox Flow | | Yes / No | | |
| Methodology-as-Code | | Yes / No | | |
| Auto-Tier Assignment | | Yes / No | | |
| Implementation Guide | | Yes / No | | |

---

### 7.2 Exploration-Driven Refinements

Based on the findings from Part 3 (Methodology Exploration), document recommended additions, expansions, and simplifications.

#### Gap-Filling Refinements (New Content Needed)

| Gap Identified | Proposed Addition | Target Document | Priority |
|----------------|------------------|-----------------|----------|
| | | | |
| | | | |
| | | | |

#### Expansion Refinements (Existing Content Needs Depth)

| Concept | Current Location | Proposed Expansion | Priority |
|---------|-----------------|-------------------|----------|
| | | | |
| | | | |
| | | | |

#### Simplification Refinements (Reduce Complexity)

| Item | Current State | Proposed Simplification | Impact |
|------|--------------|------------------------|--------|
| | | | |
| | | | |
| | | | |

#### Tool/Pattern Updates

| Item | Current State | Recommended Update | Rationale |
|------|--------------|-------------------|-----------|
| | | | |
| | | | |
| | | | |

---

### 7.3 Guarantee Refinements

| Guarantee | Current State | Refinement Needed? | Recommended Change (if any) |
|-----------|--------------|-------------------|----------------------------|
| Spec-first changes | | Yes / No | |
| No silent apply | | Yes / No | |
| Deterministic AI | | Yes / No | |
| Observability required | | Yes / No | |
| Idempotency & rollback | | Yes / No | |
| Fail-closed governance | | Yes / No | |
| Local-first & privacy-first | | Yes / No | |
| Cost & efficiency guardrails | | Yes / No | |
| Supply chain provenance | | Yes / No | |
| Small batches by policy | | Yes / No | |
| Waiver discipline | | Yes / No | |

---

### 7.4 Structural Refinements

| Issue | Current State | Recommended Change | Impact |
|-------|--------------|-------------------|--------|
| Document consolidation | | | |
| Terminology standardization | | | |
| Cross-reference cleanup | | | |
| Pillar alignment gaps | | | |
| Missing guidance | | | |

---

### 7.5 Risk Assessment of Unaddressed Gaps

**Instruction:** For significant gaps identified, assess the risk of NOT addressing them.

| Gap/Issue | Risk if Unaddressed | Likelihood | Impact | Priority |
|-----------|--------------------|-----------| --------|----------|
| | | High/Med/Low | High/Med/Low | P0/P1/P2 |
| | | | | |
| | | | | |

---

### 7.6 Implementation Roadmap

**Instruction:** If refinements are recommended, propose a phased implementation approach.

#### Phase 1: Quick Wins (1-2 weeks)

| Refinement | Effort | Owner | Dependencies |
|------------|--------|-------|--------------|
| | Low | | |
| | Low | | |

#### Phase 2: Medium-Term Improvements (1-2 months)

| Refinement | Effort | Owner | Dependencies |
|------------|--------|-------|--------------|
| | Medium | | |
| | Medium | | |

#### Phase 3: Strategic Enhancements (3+ months)

| Refinement | Effort | Owner | Dependencies |
|------------|--------|-------|--------------|
| | High | | |
| | High | | |

---

### 7.7 Success Criteria for Refinements

| Refinement Category | How to Measure Success | Target |
|--------------------|----------------------|--------|
| Gap-filling | | |
| Simplification | | |
| Tool updates | | |
| Structural changes | | |

---

## Part 8: Documentation Synthesis

Transform the assessed methodology into documentation-ready artifacts.

### 8.1 Minimum Viable Documentation

**Task:** Define the minimum documentation for Day 1 adoption.

| Document | Purpose | Priority |
|----------|---------|----------|
| | | P0 |
| | | P0 |
| | | P1 |
| | | P1 |
| | | P2 |

---

### 8.2 Visual Artifacts Checklist

| Artifact | Purpose | Status |
|----------|---------|--------|
| Method Lifecycle Diagram | Show PLAN → SHIP → LEARN | |
| Risk Tier Decision Tree | Help tier classification | |
| Gate-by-Tier Matrix | Show required gates | |
| Pillar-to-Element Mapping | Show what implements what | |
| Ceremony Calendar | Show recurring activities | |

---

### 8.3 Onboarding Checklist

| Content | Target | Format | Priority |
|---------|--------|--------|----------|
| 30-second methodology overview | All | Verbal | P0 |
| Day 1 setup guide | New teams | Checklist | P0 |
| Risk tier quick reference | Developers | Card | P0 |
| Gate reference | Developers | Table | P1 |
| Full methodology deep-dive | Architects | Doc | P2 |

---

## Part 9: Final Evaluation Summary

### 9.1 Overall Scores

| Category | Max Score | Achieved | Percentage |
|----------|-----------|----------|------------|
| Element 1 (Core) | 125 | | |
| Element 2 (Flow & WIP) | 125 | | |
| Element 3 (Risk Tiers) | 125 | | |
| Element 4 (Spec-First) | 125 | | |
| Element 5 (CI/CD) | 125 | | |
| Element 6 (Security) | 125 | | |
| Element 7 (Reliability) | 125 | | |
| Element 8 (Architecture) | 125 | | |
| Element 9 (Tooling) | 125 | | |
| Element 10 (Adoption) | 125 | | |
| Element 11 (Sandbox Flow) | 125 | | |
| Element 12 (Methodology-as-Code) | 125 | | |
| Element 13 (Auto-Tier Assignment) | 125 | | |
| Element 14 (Implementation Guide) | 125 | | |
| Pillar Coverage | 30 | | |
| PLAN Phase Coherence | 20 | | |
| SHIP Phase Coherence | 20 | | |
| LEARN Phase Coherence | 20 | | |
| A→J Lifecycle Coherence | 20 | | |
| Document Readability | 20 | | |
| HITL Semantics | 20 | | |
| Error Handling Standards | 15 | | |
| Exploration Gap Assessment | 50 | | |
| System Guarantees | 165 | | |
| Stress Tests (15 tests) | 75 | | |
| **TOTAL** | **2350** | | |

---

### 9.2 Health Indicators

| Indicator | Status | Notes |
|-----------|--------|-------|
| All elements map to pillars | ✅ / ⚠️ / ❌ | |
| All pillars are operationalized | ✅ / ⚠️ / ❌ | |
| Methodology is lean (<5 hrs/week ceremony) | ✅ / ⚠️ / ❌ | |
| Day 1 adoption is achievable | ✅ / ⚠️ / ❌ | |
| Hotfix scenario is covered | ✅ / ⚠️ / ❌ | |
| Team change scenario is covered | ✅ / ⚠️ / ❌ | |
| **Works for solo developer (1 dev)** | ✅ / ⚠️ / ❌ | |
| **Works for pair (2 devs)** | ✅ / ⚠️ / ❌ | |
| **Works for trio (3 devs)** | ✅ / ⚠️ / ❌ | |
| Scale-up guidance is provided (3 → 4+) | ✅ / ⚠️ / ❌ | |
| System guarantees are enforceable | ✅ / ⚠️ / ❌ | |
| Terminology is consistent | ✅ / ⚠️ / ❌ | |
| Cross-references are accurate | ✅ / ⚠️ / ❌ | |
| Convivial Purpose is integrated | ✅ / ⚠️ / ❌ | |
| **Kit-to-methodology integration complete** | ✅ / ⚠️ / ❌ | |
| **Anti-patterns documented** | ✅ / ⚠️ / ❌ | |
| **Differentiation from alternatives clear** | ✅ / ⚠️ / ❌ | |
| **30-second pitch achievable** | ✅ / ⚠️ / ❌ | |
| **A→J lifecycle adds value without complexity** | ✅ / ⚠️ / ❌ | |
| **Methodology-as-Code schemas are authoritative** | ✅ / ⚠️ / ❌ | |
| **Sandbox flow is clear and actionable** | ✅ / ⚠️ / ❌ | |
| **Auto-tier algorithm is accurate** | ✅ / ⚠️ / ❌ | |
| **No major operational gaps identified** | ✅ / ⚠️ / ❌ | |
| **No major data management gaps identified** | ✅ / ⚠️ / ❌ | |
| **AI/LLM patterns are current** | ✅ / ⚠️ / ❌ | |
| **Tools and frameworks are current** | ✅ / ⚠️ / ❌ | |
| **Vendor lock-in risk is acceptable** | ✅ / ⚠️ / ❌ | |
| **Budget-constrained adoption possible** | ✅ / ⚠️ / ❌ | |
| **Legacy integration path clear** | ✅ / ⚠️ / ❌ | |
| **Audit/compliance ready** | ✅ / ⚠️ / ❌ | |
| **Stop-the-line triggers are enforceable** | ✅ / ⚠️ / ❌ | |
| **HITL states are well-defined** | ✅ / ⚠️ / ❌ | |
| **Document entry points are clear** | ✅ / ⚠️ / ❌ | |
| **Pillar documents are complete** | ✅ / ⚠️ / ❌ | |
| **Remote/distributed teams supported** | ✅ / ⚠️ / ❌ | |
| **Experimentation governance clear** | ✅ / ⚠️ / ❌ | |

---

### 9.3 Comparison to Previous Evaluation (if applicable)

| Metric | Previous | Current | Trend |
|--------|----------|---------|-------|
| Total Score | /2350 | /2350 | ↑ / → / ↓ |
| Critical gaps | | | |
| Open refinements | | | |
| Health indicators ✅ | | | |
| Health indicators ⚠️ | | | |
| Health indicators ❌ | | | |

**Notable Changes Since Last Evaluation:**
1.
2.
3.

---

### 9.4 Final Verdict

**Overall Assessment:** Ready for Use / Needs Minor Refinement / Needs Major Refinement

> **Note:** "Ready for Use" with no refinements needed is a valid and valuable outcome. The purpose of this assessment is to validate and document, not to force changes. If the methodology is sound, say so confidently.

**Key Strengths:**
1.
2.
3.

**Key Gaps (if any):**
*If no significant gaps exist, state "No significant gaps identified" rather than inventing issues.*
1.
2.
3.

**Priority Refinements (if any):**
*If no refinements are warranted, state "No refinements recommended—methodology is operational-ready as designed."*
1.
2.
3.

**Recommended Next Steps:**
1.
2.
3.

---

### 9.5 Re-Evaluation Triggers

**Instruction:** Document when this methodology should be re-evaluated.

| Trigger | Threshold | Action |
|---------|-----------|--------|
| Time-based | Every ___ months | Full re-evaluation |
| Major methodology update | Version bump to x.0.0 | Full re-evaluation |
| Team size change | Crossing 3→4 or 2→1 boundary | Targeted re-evaluation |
| Significant incident | P0/P1 incident related to methodology | Targeted re-evaluation |
| Tool deprecation | Major tool no longer supported | Targeted re-evaluation |
| Adoption feedback | Consistent friction reported | Targeted re-evaluation |

---

### 9.6 Stakeholder Communication Plan

**Instruction:** How should evaluation findings be communicated?

| Stakeholder | What to Communicate | Format | When |
|-------------|--------------------| --------|------|
| Development team | Key findings + action items | Summary doc | Immediately |
| Leadership | Health status + major gaps | Executive summary | Within 1 week |
| Future evaluators | Full findings | This document | Archive |

---

### 9.7 Evaluation Quality Self-Check

Before finalizing, verify evaluation quality:

| Check | Passed? |
|-------|---------|
| All Parts completed (1-9) | ☐ |
| All element assessments have scores | ☐ |
| All stress tests have verdicts | ☐ |
| Exploration categories fully reviewed | ☐ |
| Refinements are specific and actionable | ☐ |
| Scoring is consistent across elements | ☐ |
| Evidence provided for low scores | ☐ |
| No placeholder text remaining | ☐ |

---

## Deliverables Checklist

Upon completing this assessment, you should have:

- [ ] **Element Assessments** — Clarity, Pillar Alignment, Leanness, Implementability, Coherence for each of the 14 methodology elements
- [ ] **Cross-Element Analysis** — Pillar coverage, phase coherence, concern distribution, terminology, duplication, completeness
- [ ] **Document Readability and Entry Point Analysis** — Document lengths, reading order, prerequisite knowledge
- [ ] **HITL States and Semantics Evaluation** — State definitions, checkpoints, audit trail
- [ ] **Kit Exit Codes and Error Handling Check** — Standardized exit codes and error typing
- [ ] **A→J Lifecycle Granularity Check** — Value vs. complexity of 10-stage lifecycle
- [ ] **Kit-to-Methodology Integration** — Verify pillar kits are properly referenced in methodology docs
- [ ] **Anti-Pattern Catalog Check** — Verify explicit "what not to do" guidance exists
- [ ] **Comparative Differentiation** — Verify Harmony's positioning vs. alternatives is clear
- [ ] **AI-Acceleration Evaluation** — Agent touchpoints, boundaries, determinism achievability, human-AI handoffs
- [ ] **Methodology Exploration** — Gap exploration (missing concepts), expansion exploration (needs depth), removal/simplification exploration (over-engineered), architectural patterns, tools/frameworks, AI/LLM patterns, convivial technology alignment
- [ ] **System Guarantee Audit** — Defined, enforceable, enforced for each of the 11 guarantees
- [ ] **Stress Test Results** — 30-min test, 30-second pitch test, Day 1 test, Hotfix test, Team Change test, Team Size Variations (1/2/3 devs), Solo Feasibility test, Conflict test, Ceremony count, Vendor Dependency test, Budget Constraint test, Legacy Integration test, Audit/Compliance test, Remote/Distributed test, Experimentation test, Stop-the-Line Trigger evaluation
- [ ] **Convivial Alignment** — Methodology-to-convivial mapping, guardrail check
- [ ] **Refinement Recommendations** — Element refinements, exploration-driven refinements, guarantee refinements, structural refinements *(may be "none needed" for some or all)*
- [ ] **Documentation Synthesis** — Minimum viable docs, visual artifacts, onboarding checklist
- [ ] **Final Evaluation Summary** — Scores, health indicators, verdict, next steps

---

*Proceed systematically through each part. Be rigorous in scoring. Be specific in recommendations—but only recommend changes where there is a clear, defensible improvement. "No changes needed" is a valid conclusion.*

*For the exploration phase (Part 3), actively seek out:*

- *Concepts, patterns, tools, ideas, architectures, and approaches that are NOT currently covered but SHOULD be*
- *Concepts that ARE covered but need EXPANSION or MODIFICATION*
- *Concepts that ARE covered but SHOULDN'T be (over-engineering, complexity without value)*

*The goal is an operational-ready methodology that teams can apply immediately and that serves Harmony's Convivial Purpose. Validation of a sound design is as valuable as identifying improvements. However, also ensure the methodology remains CURRENT with evolving best practices in AI/LLM development, DevOps, and tiny team dynamics.*
