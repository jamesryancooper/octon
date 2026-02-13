---
title: Spec-First Planning Workflow
description: How to run Harmony's spec-first planning loop end-to-end, including tiered spec templates, the feature story pattern, and AI-assisted workflow.
---

# Spec-First Planning (Step-by-Step)

This guide details Harmony's spec-first planning loop and AI-assisted workflow. It expands the methodology overview with concrete steps, templates, and prompts. For the high-level lifecycle diagram and context, see the main Harmony Methodology overview.

PlanKit exposes a planning kernel and feature story interface at the methodology level; its BMAD adapter is an internal implementation detail.

---

## Tiered Spec System

Harmony uses a **three-tier risk classification** to right-size specs and reviews. AI agents determine the tier and select the appropriate template automatically.

| Tier | Risk Level | Spec Template | Human Time |
|------|------------|---------------|------------|
| **T1** | Trivial | Minimal | 2-3 min |
| **T2** | Standard | Standard | 15-20 min |
| **T3** | Elevated | Full | 30-60 min |

**Key insight:** AI fills specs completely for all tiers. The tier determines how much human review is needed, not how much AI work is done.

→ See [risk-tiers.md](./risk-tiers.md) for full tier criteria.
→ See [auto-tier-assignment.md](./auto-tier-assignment.md) for classification algorithm.
→ See [templates/](./templates/) for spec templates.

### Tier Selection Flow

```
1. Human provides intent ("Add user profile endpoint")
2. AI classifies → T2 (new API endpoint)
3. AI loads spec-tier2.yaml template
4. AI fills template completely
5. Human reviews summary (T2 = 15-20 min)
6. AI builds when approved
```

---

## Spec-First Planning Workflow

### Step 1: Initiate Change

```bash
harmony spec "description of what you want"
# or
harmony fix "bug description or issue number"
```

AI automatically:
- Analyzes intent and files likely to be affected
- Classifies into T1, T2, or T3
- Selects appropriate spec template
- Begins filling the spec

### Step 2: AI Generates Spec (All Tiers)

**T1 (Trivial):** AI generates a minimal spec in ~30 seconds
- Intent, files, risk assessment, verification plan

**T2 (Standard):** AI generates standard spec in ~2 minutes
- Problem/solution, scope, contracts, STRIDE-lite, tests, rollout plan

**T3 (Elevated):** AI generates full spec in ~5 minutes
- Complete problem/solution, full STRIDE, data classification, migration plan, staged rollout

### Step 3: Human Review (Tier-Appropriate)

**T1:** Skim 1-paragraph summary (30 sec), approve if looks right

**T2:** Review spec summary (2-5 min)
- Does solution match intent?
- Any scope concerns?
- Threat summary reasonable?

**T3:** Full spec review (10-15 min) - **must approve before AI builds**
- Requirements captured correctly?
- Threat model comprehensive?
- Mitigations appropriate?
- Rollback plan viable?

```bash
# T3 only: explicitly approve spec before build
harmony approve-spec <id>
```

### Step 4: AI Builds

After human approval (explicit for T3, implicit for T1/T2):

1. AI generates **plan** and **checklist**
2. AI proposes **code diffs** with tests
3. AI pins **AI config** (model, temperature, etc.)
4. AI creates **PR** with tier-appropriate summary
5. AI runs **CI gates** for the tier

### Step 5: Human Reviews PR (Tier-Appropriate)

**T1:** Verify CI green, approve (1 min)

**T2:** Spot-check code, verify tests cover key paths (5-10 min)

**T3:** Thorough review + Navigator review + security check (15-20 min)

### Step 6: Ship

```bash
vercel promote <preview-url>
```

**T3 only:** 30-minute watch window after promotion.

---

## AI-Assisted Workflow Details

### AI Agent Responsibilities

For ALL tiers, AI handles:
- Spec generation (using tier-appropriate template)
- Code generation
- Test generation
- CI gate execution
- PR creation with summary
- License and dependency scanning
- SBOM generation

For T2+, AI also handles:
- STRIDE threat analysis (lite for T2, full for T3)
- Feature flag setup
- Rollout plan
- Observability setup

For T3, AI also handles:
- Data classification
- Migration planning
- ASVS control mapping
- ADR creation

### Human Responsibilities

**All Tiers:**
- Approve final PR
- Make go/no-go decision

**T2:**
- Review spec summary
- Spot-check implementation

**T3:**
- Review full spec before build
- Review full PR
- Navigator security review
- Post-promotion watch

### AI IDE Integration

When using an AI IDE:

```
1. Paste spec summary → AI generates plan and checklist
2. AI proposes diffs with tests and contracts
3. Human pauses for review at each stage
4. AI config pinned and recorded in PR
5. Threat model prompt generates security test cases
```

**AI Config Recording:**
- Provider, model/version
- Temperature/top_p, max_tokens
- Seed (if supported)
- Recorded in PR description and ObservaKit traces

---

## Spec Templates by Tier

### T1: Minimal Template

Use for: Typos, doc updates, tiny fixes, test additions

```yaml
tier: 1
title: "Fix typo in ErrorBoundary"
intent: "Change 'recieved' to 'received' in error message"

scope:
  files: ["src/components/ErrorBoundary.tsx"]
  surfaces: []
  
risk_assessment:
  classification: trivial
  security_impact: none
  data_impact: none
  rollback: "revert commit"

verification:
  tests_affected: existing_pass
  manual_check: not_required
```

→ Full template: [templates/spec-tier1.yaml](./templates/spec-tier1.yaml)

### T2: Standard Template

Use for: New features, endpoints, components, refactoring

```yaml
tier: 2
title: "Add user profile endpoint"

problem:
  statement: "Users cannot view other users' profiles"
  context: "Required for social features in Q1 launch"

solution:
  summary: "Add GET /api/users/:id returning public profile"
  approach: "New endpoint, auth required, filter to public fields"

scope:
  in_scope: ["Return public profile fields", "Require auth"]
  out_of_scope: ["Private fields", "Profile editing"]
  surfaces:
    - type: api
      path: "/api/users/:id"

threat_analysis:
  classification: standard
  stride_lite:
    information_disclosure:
      applicable: true
      risk: "Might expose private data"
      mitigation: "Filter to public fields only"
  summary: "Low risk. Info disclosure mitigated by field filtering."

rollout:
  flag:
    name: "feature.user-profiles"
    default: false
  rollback:
    immediate: "disable flag"
```

→ Full template: [templates/spec-tier2.yaml](./templates/spec-tier2.yaml)

### T3: Full Template

Use for: Auth, billing, security, data migrations, PII handling

```yaml
tier: 3
title: "Implement Google OAuth login"
navigator: "dev-b"  # Required for T3

problem:
  statement: "Users can only sign up with email/password"
  impact:
    users_affected: "All new and existing users"
    systems_affected: ["Auth service", "User DB", "Sessions"]

data_classification:
  categories_touched:
    - category: pii
      fields: ["email", "name"]
      handling: "Retrieved from Google, stored in users table"
    - category: auth
      fields: ["google_id", "tokens"]
      handling: "Tokens encrypted, short-lived"

threat_model:
  classification: elevated
  stride:
    spoofing:
      applicable: true
      threats:
        - description: "Attacker captures OAuth callback"
          mitigation: "State parameter with CSRF protection"
          tests: ["state_mismatch_returns_403"]
    # ... full STRIDE for each category

approval_checkpoints:
  spec_approval:
    required: true
    approvers: [owner, navigator]
  pr_approval:
    required: true
    approvers: [owner, navigator]
```

→ Full template: [templates/spec-tier3.yaml](./templates/spec-tier3.yaml)

---

## Legacy: SpecKit One-Pager Template

For reference, the original SpecKit one-pager outline (now superseded by tiered templates):

### SpecKit spec one‑pager template (outline)

- Title & metadata
  - Working title, date, owner(s), related issue/PR links.
  - Risk class (Trivial/Low/Medium/High) and affected slices/surfaces.
- Problem and goal
  - Concise problem statement and “why now”.
  - Target outcome framed in user and system terms.
- Scope and appetite
  - In‑scope vs out‑of‑scope behaviors.
  - Appetite (for example, 1‑day change, 1‑week mini‑project).
- Contracts and surfaces
  - API contracts (OpenAPI/JSON‑Schema paths) and UI surfaces touched.
  - Data classification for each surface (PII/PHI/SECRET/OTHER_SENSITIVE).
- Non‑functionals and SLOs
  - Performance, reliability, and availability targets (SLIs/SLOs).
  - Cost and latency guardrails if AI or infra‑heavy.
- Security and compliance
  - STRIDE threats per surface and mitigations.
  - Mapped **OWASP ASVS** controls and **NIST SSDF** tasks to be satisfied.
- Observability and knowledge
  - Required spans/logs/metrics and dashboards.
  - How traces/PRs/ADRs will be correlated in the Knowledge Plane.
- AI usage and determinism (when agents are involved)
  - Provider/model/version, parameters (temperature/top_p, max_tokens, seed if supported).
  - Golden tests plan (EvalKit/TestKit) and determinism expectations.
- Acceptance criteria and tests
  - User‑visible acceptance criteria.
  - Test outline: unit, contract, e2e smoke, and AI golden tests where applicable.
- Rollout, flags, and rollback
  - Flag names and initial cohorts.
  - Rollback plan (for example, promote prior preview) and success/failure exit criteria.
