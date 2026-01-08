# Roadmap

Welcome to the implementation roadmap for Harmony's Principles documentation. The core content exists in `principles.md` as a draft stub, but significant work is needed to elevate principles to the same level of documentation maturity as pillars and purpose.

Currently, principles serve as the operational translation of pillars into day-to-day decisions—the *how* that connects the philosophical *why* (Convivial Purpose) and structural *what* (Six Pillars) to actual engineering choices.

---

## Progress Checklist

### Immediate (P0)

- [ ] **1. Finalize `principles.md`**
- [ ] **2. Create Principles Documentation Index**

### Short-Term (P1)

- [ ] **3. Create Core Principles Guides**
- [ ] **4. Create Agentic Principles Guides**
- [ ] **5. Create Anti-Patterns Gallery**

### Medium-Term (P2)

- [ ] **6. Add Principle-to-Kit Mapping**
- [ ] **7. Create Principle Enforcement Mechanisms**
- [ ] **8. Create Onboarding Materials**

---

## Current State

### ✅ Completed

| Artifact | Location | Status |
|----------|----------|--------|
| Principles draft | `principles.md` | Draft stub (needs finalization) |
| Pillars alignment | `principles.md` references `./pillars/README.md` | Cross-references exist |
| Core Principles | `principles.md` (12 principles) | Listed but not detailed |
| Agentic Principles | `principles.md` (5 principles) | Listed but not detailed |
| Anti-Principles | `principles.md` (6 items) | Listed but not detailed |
| Defaults and Guardrails | `principles.md` (5 items) | Listed but not detailed |

### 🔲 Outstanding

| Artifact | Proposed Location | Status |
|----------|------------------|--------|
| Principles `README.md` | `principles/README.md` | Not created |
| Individual principle guides | `principles/core/`, `principles/agentic/` | Not created |
| Anti-patterns gallery | `principles/anti-patterns/` | Not created |
| Principle-to-kit mapping | `principles/README.md` or dedicated file | Not created |
| Principle enforcement schema | `packages/contracts/schemas/` | Not created |
| PR template principle checklist | `.github/` or methodology docs | Not created |
| Principle quick-reference cards | `principles/` | Not created |

---

## Immediate Next Steps (P0)

### 1. Finalize `principles.md`

The current `principles.md` is marked as "Draft stub (confirm team-specific thresholds and examples)". This needs to be finalized:

**Tasks:**

1. **Remove draft status** — Change the status line to "Production"
2. **Add concrete examples** for each Core Principle (currently abstract)
3. **Add threshold values** where applicable:
   - Coverage thresholds for "Coverage & budgets"
   - Specific timeout values for "API behavior"
   - Risk tier definitions for "Risk rubric"
4. **Verify all Related Docs links** — Several referenced paths may not exist:
   - `docs/methodology/README.md` ✅ Exists
   - `docs/architecture/overview.md` — Verify
   - `docs/architecture/governance-model.md` — Verify
   - Others listed need verification
5. **Add "Last Updated" date** for version tracking

**Example enhancement for "Small diffs, trunk-based":**

```markdown
## Before (current)
- Small diffs, trunk‑based: short‑lived branches, tiny PRs, preview deploys, fast review.

## After (with examples)
- **Small diffs, trunk‑based**: Short‑lived branches (≤1 day), tiny PRs (≤400 lines diff), preview deploys per PR, first review response within 4 working hours.
  - ✅ Good: "Add user avatar upload endpoint" — 150 lines, single feature
  - ❌ Avoid: "Refactor auth + add billing + update tests" — 1200 lines, multiple concerns
```

### 2. Create Principles Documentation Index

Create `README.md` as the entry point for principles documentation:

```text
docs/ai/principles/
├── README.md                    # Overview & navigation (NEW)
├── core/                        # Core principles detailed guides (P1)
│   ├── README.md
│   ├── monolith-first.md
│   ├── contract-first.md
│   ├── small-diffs.md
│   ├── flags-by-default.md
│   ├── determinism.md
│   ├── observability-as-contract.md
│   ├── security-privacy-baseline.md
│   ├── accessibility-baseline.md
│   ├── documentation-is-code.md
│   ├── reversibility.md
│   ├── ownership-boundaries.md
│   └── learn-continuously.md
├── agentic/                     # Agentic principles detailed guides (P1)
│   ├── README.md
│   ├── no-silent-apply.md
│   ├── determinism-provenance.md
│   ├── idempotency.md
│   ├── guardrails.md
│   └── hitl-checkpoints.md
└── anti-patterns/               # Anti-patterns gallery (P1)
    ├── README.md
    └── gallery.md
```

**README.md content should include:**

- 30-second summary of what principles are
- Visual showing Purpose → Pillars → Principles relationship
- Quick reference table of all principles with one-line descriptions
- Links to detailed principle guides
- How to cite principles in PRs and design docs

---

## Short-Term Next Steps (P1)

### 3. Create Core Principles Guides

Create detailed documentation for each of the 12 Core Principles. Each guide should follow a consistent template:

```markdown
# [Principle Name]

> One-sentence essence

## What This Means

2-3 paragraphs explaining the principle in detail.

## Why It Matters

Connection to Convivial Purpose and pillars.

## In Practice

### ✅ Do

- Concrete examples of following this principle
- Code snippets where applicable

### ❌ Don't

- Common violations
- Anti-patterns

## Kit Support

| Kit | How It Supports This Principle |
|-----|-------------------------------|
| ... | ... |

## Enforcement

How this principle is enforced (CI gates, review checklist, etc.)

## Exceptions & Waivers

When and how to request exceptions.

## Related

- Links to related principles
- Links to methodology docs
```

**Priority order** (based on frequency of reference and risk):

1. `determinism.md` — Core to AI safety and reproducibility
2. `security-privacy-baseline.md` — Non-negotiable for trust
3. `contract-first.md` — Foundation for API discipline
4. `small-diffs.md` — Key to velocity and reversibility
5. Remaining principles in listed order

### 4. Create Agentic Principles Guides

Create detailed documentation for the 5 Agentic Principles using the same template as Core Principles, with additional emphasis on:

- Human-AI boundary enforcement
- Audit and provenance requirements
- Failure modes and recovery

### 5. Create Anti-Patterns Gallery

Create a visual gallery of anti-patterns with:

- **Pattern name** and one-sentence description
- **Risk level** (High/Medium/Low)
- **Pillar violated** (which of the six pillars)
- **Principles violated** (which principles)
- **Recognition signals** (how to spot this pattern)
- **Remediation** (how to fix or avoid)
- **Real examples** (anonymized if necessary)

**Example entry:**

```markdown
## Big-Bang PR

**Risk:** High | **Pillar:** Velocity, Trust | **Principles:** Small diffs, Reversibility

### Recognition Signals
- PR with >500 lines changed
- Multiple unrelated concerns in one PR
- Long-lived branch (>2 days)
- "Refactor + feature + fix" in PR title

### Why It's Problematic
- Hard to review thoroughly → defects slip through
- Difficult to rollback partially
- Blocks other work on overlapping files
- Cognitive overload for reviewers

### Remediation
1. Split by concern (refactor vs. feature vs. fix)
2. Use feature flags to ship incomplete features
3. Stack PRs when dependencies require sequencing
4. Apply "one idea per PR" rule
```

---

## Medium-Term Next Steps (P2)

### 6. Add Principle-to-Kit Mapping

Create a comprehensive mapping showing which kits support which principles:

| Principle | Primary Kits | Supporting Kits |
|-----------|-------------|-----------------|
| Monolith-first | StackKit | DepKit |
| Contract-first | SpecKit, PromptKit | TestKit, GuardKit |
| Small diffs | PatchKit, CIKit | FlowKit |
| Flags by default | FlagKit | PolicyKit |
| Determinism | EvalKit, PromptKit | ObservaKit |
| Observability | ObservaKit | FlowKit |
| Security/privacy | GuardKit, VaultKit | PolicyKit |
| Accessibility | A11yKit | TestKit |
| Documentation | Dockit | SpecKit |
| Reversibility | FlagKit, PatchKit | ReleaseKit |
| Ownership | PolicyKit | — |
| Learn continuously | EvalKit, DatasetKit | ObservaKit |
| No silent apply | AgentKit, FlowKit | PolicyKit |
| Determinism/provenance | PromptKit, ObservaKit | EvalKit |
| Idempotency | FlowKit, CacheKit | — |
| Guardrails | GuardKit, PolicyKit | EvalKit |
| HITL checkpoints | AgentKit, FlowKit | PolicyKit |

### 7. Create Principle Enforcement Mechanisms

**7a. Add principle validation schema:**

```json
// packages/contracts/schemas/principle-compliance.schema.json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "principles_addressed": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": [
          "monolith-first",
          "contract-first",
          "small-diffs",
          "flags-by-default",
          "determinism",
          "observability-as-contract",
          "security-privacy-baseline",
          "accessibility-baseline",
          "documentation-is-code",
          "reversibility",
          "ownership-boundaries",
          "learn-continuously",
          "no-silent-apply",
          "determinism-provenance",
          "idempotency",
          "guardrails",
          "hitl-checkpoints"
        ]
      },
      "description": "Principles relevant to this change"
    },
    "principle_waivers": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["principle", "justification", "expiry"],
        "properties": {
          "principle": { "type": "string" },
          "justification": { "type": "string", "minLength": 20 },
          "expiry": { "type": "string", "format": "date" }
        }
      }
    }
  }
}
```

**7b. Add PR template checklist:**

```markdown
## Principles Check

- [ ] Change follows "small diffs" principle (≤400 lines, single concern)
- [ ] Contract changes are backwards-compatible or versioned
- [ ] Feature is behind a flag (if applicable)
- [ ] Observability added for new flows (traces, logs)
- [ ] No secrets or PII in logs/code
- [ ] Tests cover principle boundaries (contracts, rollback)
- [ ] AI-generated code has pinned config and trace ID
```

**7c. CI enforcement gates:**

| Gate | Principle Enforced | Implementation |
|------|-------------------|----------------|
| PR size check | Small diffs | GitHub Action checking diff stats |
| OpenAPI diff | Contract-first | `oasdiff` in CI |
| Secret scanning | Security baseline | GitHub secret scanning + TruffleHog |
| Trace ID presence | Observability | Custom lint rule for changed handlers |
| Flag check | Flags by default | Lint for feature paths without flag guards |

### 8. Create Onboarding Materials

| Material | Purpose | Format |
|----------|---------|--------|
| Principles cheat sheet | Quick reference for all 17 principles | 1-page PDF/card |
| "Principles in 5 minutes" | New engineer orientation | Short doc or video script |
| Decision flowchart | "Which principle applies?" | Visual flowchart |
| Violation examples | Learning from mistakes | Anonymized case studies |
| PR annotation guide | How to cite principles in PRs | Template + examples |

---

## Dependencies & Sequencing

```text
P0: Finalize principles.md ─────────────────┐
                                            │
P0: Create README.md ───────────────────────┤
                                            ▼
                              P1: Core principle guides
                                            │
                              P1: Agentic principle guides
                                            │
                              P1: Anti-patterns gallery
                                            │
                                            ▼
                              P2: Principle-to-kit mapping
                                            │
                              P2: Enforcement mechanisms
                                            │
                              P2: Onboarding materials
```

**Notes:**

- `principles.md` finalization and `README.md` creation are independent (can be parallel)
- Core and Agentic guides can be developed in parallel
- Anti-patterns gallery benefits from having principle guides as references
- Enforcement mechanisms should align with the principle definitions established in P1
- Onboarding materials are best created after all principle documentation is stable

---

## Success Criteria

The principles documentation is complete when:

1. ✅ `principles.md` is finalized with examples and thresholds
2. ✅ `README.md` exists as navigation index
3. ✅ All 12 Core Principles have detailed guides
4. ✅ All 5 Agentic Principles have detailed guides
5. ✅ Anti-patterns gallery has ≥10 documented patterns
6. ✅ Principle-to-kit mapping is published
7. ⬜ CI gates enforce key principles (stretch goal)
8. ⬜ Onboarding materials are available (stretch goal)

---

## Relationship to Other Documentation

```text
┌─────────────────────────────────────────────────────────────────┐
│                      CONVIVIAL PURPOSE                          │
│    Technology that expands capability, respects attention,      │
│    fosters connection, and resists extraction                   │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       THE SIX PILLARS                           │
│   Direction │ Focus │ Velocity │ Trust │ Continuity │ Insight   │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        PRINCIPLES ◀── YOU ARE HERE              │
│   Core (12) + Agentic (5) + Anti-Principles (6)                 │
│   Day-to-day decision rules that implement the pillars          │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        METHODOLOGY                              │
│   Operational procedures, templates, workflows                  │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                           KITS                                  │
│   Tooling that enforces and enables principles                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Related Documentation

- [`../principles.md`](../principles.md) — Current principles document (draft)
- [`../pillars/README.md`](../pillars/README.md) — The six pillars that principles implement
- [`../purpose/convivial-purpose.md`](../purpose/convivial-purpose.md) — The *why* beneath the pillars
- [`../methodology/README.md`](../methodology/README.md) — Operational implementation
- [`../kits/README.md`](../kits/README.md) — Tools that enforce principles
