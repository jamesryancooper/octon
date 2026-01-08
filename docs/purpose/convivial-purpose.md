# Synthesizing Resonant Computing into Harmony

## 1. Distilling the Core Essence of RCDS

The Resonant Computing Design Stack (RCDS) can be compressed to a single through-line:

> **Technology should expand human capability, understanding, and connection—not extract attention, data, or agency.**

This manifests across four layers:

| Layer | Core Question | Essence |
|-------|---------------|---------|
| **Flourishing & Care** | *What is this for?* | The measure of success is human dignity and capability, not engagement or growth |
| **Structures & Scale** | *What shape enables this?* | Small, plural, local-first systems resist extraction; incentives must align with trust |
| **Attention & Interaction** | *How does it behave?* | Respect cognitive limits; prefer calm, transparent, controllable interfaces; AI as collaborator, not oracle |
| **Practice & Governance** | *How do we stay true?* | Craft iteration, participatory feedback, and ongoing evaluation of whether the tool still serves flourishing |

The unifying concept is **conviviality** (Illich): tools that remain small enough to understand, flexible enough to adapt, and principled enough to protect autonomy—tools that serve people rather than reshaping people to serve tools.

---

## 2. The Gap in Harmony's Current Pillars

Harmony's five pillars are **inward-facing**: they govern *how* a small team operates—safely, simply, deterministically, with agent assistance and modular architecture.

| Pillar | Orientation |
|--------|-------------|
| Speed with Safety | Engineering process |
| Simplicity over Complexity | Architecture & scope |
| Quality through Determinism | Verification & contracts |
| Guided Agentic Autonomy | Human-AI workflow |
| Evolvable Modularity | System boundaries |

**What's missing:** An explicit statement of *purpose*—what kind of technology Harmony teams put into the world, and for whom.

RCDS fills this gap. It answers: *We ship fast, safe, simple, deterministic, modular software—**to what end?***

Without this anchor, Harmony could produce technically excellent, ethically neutral (or harmful) systems. RCDS provides the **telos**: technology that expands human flourishing rather than extracting from it.

---

## 3. Proposed Synthesis: "Convivial Purpose"

I propose adding a **foundational principle** that sits *beneath* the five pillars as their shared purpose. This is not a sixth pillar (which would dilute the operational focus) but a **grounding statement** that gives the pillars their meaning.

### Convivial Purpose

> **The software we ship should expand human capability, respect attention, and foster connection—not extract, manipulate, or diminish.**
>
> Harmony's speed, safety, simplicity, determinism, and modularity serve this end: we build fast *because* humane tools should reach people quickly; we build safely *because* trust is the foundation of resonance; we modularize *because* convivial tools must be understandable and adaptable.

#### Definition (for onboarding)

**Convivial Purpose** means we build technology that leaves users more capable, coherent, and connected than before. A convivial tool:

- **Expands autonomy**: users can understand, control, and adapt the system to their needs
- **Respects attention**: interfaces are calm, predictable, and peripheral by default; interruptions are rare and meaningful
- **Fosters connection**: the tool strengthens relationships and communities rather than isolating or polarizing
- **Resists extraction**: data practices are minimal, local-first, and transparent; business models don't require manipulation

#### Primary Tension Managed

*Efficiency vs. Humanity.* The pressure to ship fast, automate aggressively, and optimize metrics can produce systems that are technically correct but ethically corrosive. Convivial Purpose holds that **humane outcomes are non-negotiable constraints**, not post-hoc considerations.

---

## 4. How Convivial Purpose Integrates with Existing Pillars

| Pillar | Without Convivial Purpose | With Convivial Purpose |
|--------|--------------------------|------------------------|
| **Speed with Safety** | Fast, safe delivery to... anyone, for any purpose | Fast, safe delivery of *tools that expand human capability* |
| **Simplicity over Complexity** | Minimal architecture for team efficiency | Minimal architecture *that users can also understand and trust* |
| **Quality through Determinism** | Verifiable, testable, reversible systems | Verifiable, testable, reversible systems *with explicit attention and dignity constraints* |
| **Guided Agentic Autonomy** | Agents operate within engineering bounds | Agents operate within engineering bounds *and cannot propose features that manipulate or extract* |
| **Evolvable Modularity** | Plug-and-play boundaries for tech choices | Plug-and-play boundaries *that also give users control over their data and experience* |

### Reinforcing Loops

1. **Convivial Purpose → Simplicity over Complexity**: If the goal is tools users can understand, we avoid unnecessary abstraction and opaque AI.

2. **Convivial Purpose → Guided Agentic Autonomy**: Agents must be constrained not just by engineering contracts but by humane design principles—they cannot propose dark patterns, addictive loops, or surveillance mechanisms.

3. **Convivial Purpose → Quality through Determinism**: "Flourishing" becomes a measurable constraint. We can track attention metrics (interruption frequency, time-on-task), user control indicators (undo rate, customization usage), and extraction signals (data collected, sold, inferred).

---

## 5. Operationalizing Convivial Purpose

### 5.1 Spec-First Integration

Add to `SpecKit` one-pager template:

```markdown
## Convivial Impact Assessment

### Capability Expansion
- What can users do after this feature that they couldn't before?
- Is this capability genuinely valuable, or does it create dependency?

### Attention Respect
- Does this feature require active attention, or can it live in the periphery?
- What notifications or interruptions does it introduce? Are they user-controllable?

### Connection vs. Isolation
- Does this feature strengthen user relationships and communities?
- Could it be weaponized for manipulation, polarization, or isolation?

### Extraction Risk
- What data does this feature collect? Is collection minimal and necessary?
- Could the data be misused if accessed by bad actors (internal or external)?
- Is the feature viable without surveillance or manipulation-based monetization?
```

### 5.2 Schema Constraints (Methodology-as-Code)

Add to `spec.schema.json`:

```json
{
  "convivial_impact": {
    "type": "object",
    "required": ["capability_expansion", "attention_class", "extraction_risk"],
    "properties": {
      "capability_expansion": {
        "type": "string",
        "minLength": 20,
        "description": "What users can do after this feature that they couldn't before"
      },
      "attention_class": {
        "type": "string",
        "enum": ["peripheral", "on_demand", "active", "interruptive"],
        "description": "How much attention this feature requires"
      },
      "notification_controls": {
        "type": "boolean",
        "description": "Are all notifications user-configurable?"
      },
      "extraction_risk": {
        "type": "string",
        "enum": ["none", "minimal_local", "moderate_shared", "high_centralized"],
        "description": "Data collection and centralization risk"
      },
      "manipulation_vectors": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Identified ways this feature could manipulate or extract"
      }
    }
  }
}
```

### 5.3 Agent Guardrails

Add to `AgentKit` system prompt / `PolicyKit` rules:

```yaml
# convivial_guardrails.yaml
rules:
  - id: no_dark_patterns
    description: "Agent cannot propose UI patterns from the deceptive design catalog"
    blocked_patterns:
      - infinite_scroll
      - hidden_unsubscribe
      - pre_checked_consent
      - confirmshaming
      - fake_scarcity
      - roach_motel
    action: reject_with_explanation

  - id: attention_budget
    description: "Features default to peripheral attention class"
    default_attention_class: peripheral
    escalation_requires: human_justification

  - id: data_minimalism
    description: "Agent must justify any data collection beyond session-local"
    collection_tiers:
      - session_local: auto_approve
      - user_owned_persistent: requires_purpose
      - shared_aggregate: requires_privacy_review
      - centralized_individual: requires_security_and_legal
    action: require_justification
```

### 5.4 Measurability & Signals

| Metric | Type | What It Signals |
|--------|------|-----------------|
| **Notification frequency per user-session** | Leading | Attention respect; should trend down or stay stable |
| **User control surface usage** (settings, customization, undo) | Leading | Autonomy; high usage suggests control is valued and discoverable |
| **Data collection delta per release** | Leading | Extraction risk; net increase requires justification |
| **Feature-to-capability ratio** | Lagging | Bloat vs. genuine expansion; more features without new capabilities is a warning |
| **Manipulation vector count per spec** | Leading | Risk surface; specs with >2 vectors require explicit mitigations |

### 5.5 Review Checklist Addition

Add to PR review rubric:

```markdown
## Convivial Purpose Check
- [ ] Feature expands genuine user capability (not artificial engagement)
- [ ] Attention class is appropriate; interruptive features have user controls
- [ ] No dark patterns or manipulative UI introduced
- [ ] Data collection is minimal and justified; no new centralized collection without review
- [ ] Feature strengthens (or is neutral to) user relationships and communities
```

---

## 6. Updated Harmony Framing

### Before (Five Pillars)

> Harmony unifies speed, safety, and simplicity so a tiny team can ship high-quality software quickly, safely, and predictably.

### After (Grounded in Convivial Purpose)

> **Harmony unifies speed, safety, and simplicity so a tiny team can ship *convivial* software—technology that expands human capability rather than extracting from it—quickly, safely, and predictably.**
>
> The five pillars (Speed with Safety, Simplicity over Complexity, Quality through Determinism, Guided Agentic Autonomy, Evolvable Modularity) are the *how*. **Convivial Purpose** is the *why*: we build this way because humane tools deserve fast delivery, trustworthy operation, and adaptable boundaries.

### Visual Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                    CONVIVIAL PURPOSE                        │
│  Technology that expands capability, respects attention,    │
│  fosters connection, and resists extraction                 │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     THE FIVE PILLARS                        │
├─────────────┬─────────────┬─────────────┬─────────────┬─────┤
│   Speed     │ Simplicity  │  Quality    │   Guided    │Evolv│
│    with     │    over     │  through    │  Agentic    │able │
│   Safety    │ Complexity  │Determinism  │  Autonomy   │Modul│
└─────────────┴─────────────┴─────────────┴─────────────┴─────┘
```

---

## 7. Summary

**Core synthesis:** RCDS distills to *technology should expand human flourishing, not extract from it*. This complements Harmony by providing the **purpose** that the five operational pillars serve.

**Integration approach:** Rather than adding a sixth pillar (which would dilute operational focus), add **Convivial Purpose** as a foundational grounding statement—the *why* beneath the *how*.

**Key additions:**

- Spec template section for Convivial Impact Assessment
- Schema constraints for attention class, extraction risk, manipulation vectors
- Agent guardrails blocking dark patterns and requiring data minimalism justification
- PR review checklist items for humane design

**The result:** Harmony teams don't just ship fast, safe, simple, deterministic, modular software—they ship software that *deserves* those qualities because it genuinely serves the people who use it.
