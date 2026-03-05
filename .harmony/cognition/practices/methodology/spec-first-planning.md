---
title: Spec-First Planning Workflow
description: How to run Harmony's spec-first planning loop end-to-end, including tiered spec templates, the feature story pattern, and AI-assisted workflow.
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
→ Governance model: [Autonomous Control Points](../../governance/principles/autonomous-control-points.md), [Deny by Default](../../governance/principles/deny-by-default.md), [Arbitration & Precedence](../../governance/principles/README.md#arbitration--precedence).
→ Convivial contract: [Convivial Impact Minimums](../../governance/controls/convivial-impact-minimums.md).

### Tier Selection Flow

```
1. Human provides intent ("Add user profile endpoint")
2. AI classifies → T2 (new API endpoint)
3. AI loads spec-tier2.yaml template
4. AI fills template completely
5. Human reviews summary based on tier policy (T2 = 15-20 min)
6. AI proceeds via stage -> evidence -> ACP gate
```

---

## Spec-First Planning Workflow

### Fast Path: Spec -> Plan -> PR

Use this concise path for day-to-day execution while preserving full governance:

1. Author or update a tier-appropriate spec and ADR notes.
2. Record `change_profile`, `release_state`, and `Profile Selection Receipt` before implementation.
3. Convert spec outputs into a feature story with acceptance criteria.
4. Generate implementation diffs/tests in the AI IDE and run tier gates.
5. Open a small PR, validate preview smoke, and merge only when ACP/CI outcomes are green.

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
- Problem/solution, scope, convivial impact, contracts, STRIDE-lite, tests, rollout plan

**T3 (Elevated):** AI generates full spec in ~5 minutes
- Complete problem/solution, convivial impact, full STRIDE, data classification, migration plan, staged rollout

### Step 3: Evidence + ACP Gate (Tier-Appropriate)

**T1:** Build evidence pack and run ACP-1 gate
- Intent, diff, tests, rollback handle, counters

**T2:** Build evidence pack and run ACP-2 gate
- Includes verifier quorum and rollback proof
- If quorum is missing, ACP returns `STAGE_ONLY`

**T3:** Build full evidence pack and run ACP-3 gate
- Full STRIDE and critical-path tests
- Verifier + recovery attestations bound to plan/evidence hashes
- Escalate to humans only on policy thresholds or unresolved disagreements

**Human-on-the-loop option:** review digest/receipt artifacts before or after promotion; this is oversight, not a standing runtime dependency.

Promotion authority sentence:

`ACP receipt outcomes determine runtime promotion authority; humans retain policy authorship, exceptions, and escalation authority.`

### Step 4: AI Builds

After stage -> evidence -> ACP gate:

1. AI generates **plan** and **checklist**
2. AI proposes **code diffs** with tests
3. AI pins **AI config** (model, temperature, etc.)
4. AI creates **PR** with tier-appropriate summary
5. AI runs **CI gates** for the tier

### Step 5: Oversight Reviews PR (Tier-Appropriate)

**T1:** Optional quick digest check (1 min)

**T2:** Optional spot-check + verify receipt evidence (5-10 min)

**T3:** Recommended thorough oversight + watch window (15-20 min)

### Step 6: Ship

```bash
<platform-cli> promote <candidate-ref>
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
- Convivial impact assessment (capability, attention, extraction, manipulation safeguards)
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
- Review final PR digest/receipt when policy escalation is raised
- Make on-the-loop go/no-go call only on policy escalation or unresolved disagreement

**T2:**
- Review spec summary
- Spot-check implementation

**T3:**
- Review full spec and ACP evidence bundle for discretionary escalation
- Review full PR as part of post-run oversight required by tier policy
- Security evidence review when ACP returns `STAGE_ONLY`/`ESCALATE`
- Post-promotion watch

### AI IDE Integration

When using an AI IDE:

```
1. Paste spec summary → AI generates plan and checklist
2. AI proposes diffs with tests and contracts
3. Human pause points for on-the-loop review when required by policy thresholds
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

convivial_impact:
  capability_expansion: "Users can discover and understand peers they interact with."
  attention_class: on_demand
  extraction_risk: minimal_local
  manipulation_vectors:
    - "Over-emphasis on profile completion pressure"
  mitigations:
    - "No nag loops or interruptive prompts in profile view path"

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

convivial_impact:
  capability_expansion: "Users can access accounts with lower authentication friction while retaining control."
  attention_class: on_demand
  extraction_risk: moderate_shared
  manipulation_vectors:
    - "Provider lock-in pressure through OAuth-only nudges"
    - "Unclear consent on imported profile attributes"
  mitigations:
    - "Keep email/password path available and visible"
    - "Display explicit attribute import notice before account link"

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

oversight_touchpoints:
  spec_review:
    required: true # required for T3 by policy; execution may escalate further
    reviewers: [owner, verifier]
  receipt_review:
    required: true # required for T3 by policy; escalation rules still apply
    reviewers: [owner, verifier]
```

→ Full template: [templates/spec-tier3.yaml](./templates/spec-tier3.yaml)

---

## Historical Appendix: SpecKit One-Pager Template (Legacy, Non-Normative)

The legacy SpecKit one-pager outline is preserved as historical reference in:

- [archive/spec-one-pager-legacy.md](./archive/spec-one-pager-legacy.md)

This appendix is non-normative and superseded by the tiered templates linked above.
