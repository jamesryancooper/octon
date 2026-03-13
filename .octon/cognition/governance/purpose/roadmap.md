# Roadmap

Welcome to the implementation roadmap for Octon's Convivial Purpose. The foundational philosophy is established—the Resonant Computing Design Stack (RCDS) has been synthesized into Octon's grounding statement, and the six pillars now reference this purpose as their *why*. The next phase focuses on operationalization: embedding Convivial Purpose into schemas, templates, guardrails, and measurement systems.

---

## Progress Checklist

### Immediate (P0)

- [ ] **1. Create Purpose Documentation Index**
- [ ] **2. Add Convivial Impact Schema**

### Short-Term (P1)

- [ ] **3. Enhance Spec Templates with Convivial Impact Assessment**
- [ ] **4. Create Convivial Guardrails Configuration**

### Medium-Term (P2)

- [ ] **5. Add Convivial Purpose PR Review Checklist**
- [ ] **6. Implement Measurability Metrics**
- [ ] **7. Create Onboarding Materials**

---

## Current State

### ✅ Completed

| Artifact | Location | Status |
|----------|----------|--------|
| RCDS Framework | `resonant-computing-design-stack.md` | Published |
| Convivial Purpose Synthesis | `convivial-purpose.md` | Published |
| Pillar Integration | `../pillars/README.md` | Pillars reference Convivial Purpose as their grounding |
| Direction Pillar | `../pillars/direction.md` | Convivial Impact Assessment listed as key kit |
| Methodology Integration | `../../practices/methodology/README.md` | Convivial Impact Assessment in Pillars → Practices Map |

### 🔲 Outstanding

| Artifact | Proposed Location | Status |
|----------|------------------|--------|
| Purpose `README.md` | `purpose/README.md` | Not created |
| `convivial_impact` schema | `packages/contracts/schemas/spec-frontmatter.schema.json` | Proposed in `convivial-purpose.md`, not implemented |
| `convivial_guardrails.yaml` | `packages/kits/policykit/` or similar | Proposed in `convivial-purpose.md`, not implemented |
| Spec template CIA section | `.octon/cognition/practices/methodology/templates/spec-tier*.yaml` | Not added |
| PR review checklist | CI/PR templates | Not added |
| Measurability dashboard | Observability infrastructure | Not implemented |

---

## Immediate Next Steps (P0)

### 1. Create Purpose Documentation Index

Create a `README.md` that provides an overview of the purpose documentation, connecting the RCDS framework to the Convivial Purpose synthesis:

```text
.octon/cognition/governance/principles/purpose/
├── README.md                          # Overview & 30-second summary (NEW)
├── convivial-purpose.md               # Synthesis & operationalization spec
└── resonant-computing-design-stack.md # Foundational RCDS framework
```

**Content should include:**

- 30-second summary of Convivial Purpose
- Visual hierarchy showing Purpose → Pillars relationship
- Quick reference to the four tenets (Expands Autonomy, Respects Attention, Fosters Connection, Resists Extraction)
- Links to operational implementation (spec templates, guardrails, metrics)

### 2. Add Convivial Impact Schema

Add the `convivial_impact` object to `packages/contracts/schemas/spec-frontmatter.schema.json`:

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

**Note:** Consider whether `convivial_impact` should be required for Tier 2+ specs or optional for all tiers.

---

## Short-Term Next Steps (P1)

### 3. Enhance Spec Templates with Convivial Impact Assessment

Add the Convivial Impact Assessment section to `spec-tier2.yaml` and `spec-tier3.yaml` templates:

```yaml
# ------------------------------------------------------------------------------
# Convivial Impact Assessment
# ------------------------------------------------------------------------------
convivial_impact:
  capability_expansion: ""
  # What can users do after this feature that they couldn't before?
  # Is this capability genuinely valuable, or does it create dependency?
  
  attention_class: "on_demand"
  # Options: peripheral | on_demand | active | interruptive
  # Default to least intrusive. Justify escalation.
  
  notification_controls: true
  # Are all notifications user-configurable?
  
  extraction_risk: "none"
  # Options: none | minimal_local | moderate_shared | high_centralized
  # Any collection beyond "none" requires justification.
  
  manipulation_vectors: []
  # Identified ways this feature could manipulate or extract
  # Specs with >2 vectors require explicit mitigations
  
  connection_impact: ""
  # Does this feature strengthen or weaken user relationships/communities?
```

**Tier-specific requirements:**

| Tier | Convivial Impact | Rationale |
|------|-----------------|-----------|
| Tier 1 | Optional | Trivial changes (typos, docs) don't need CIA |
| Tier 2 | Required | Features need convivial evaluation |
| Tier 3 | Required + mitigations | High-risk features need explicit safeguards |

### 4. Create Convivial Guardrails Configuration

Create `convivial_guardrails.yaml` for use by PolicyKit/GuardKit/AgentKit:

```yaml
# packages/kits/policykit/rules/convivial_guardrails.yaml

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

---

## Medium-Term Next Steps (P2)

### 5. Add Convivial Purpose PR Review Checklist

Add to PR templates and review rubrics:

```markdown
## Convivial Purpose Check

- [ ] Feature expands genuine user capability (not artificial engagement)
- [ ] Attention class is appropriate; interruptive features have user controls
- [ ] No dark patterns or manipulative UI introduced
- [ ] Data collection is minimal and justified; no new centralized collection without review
- [ ] Feature strengthens (or is neutral to) user relationships and communities
```

**Integration points:**

| System | Integration |
|--------|-------------|
| GitHub PR template | Add checklist section |
| CI checks | Optional: automated dark pattern scanning |
| PR review bots | Flag specs missing `convivial_impact` |

### 6. Implement Measurability Metrics

Create dashboards and telemetry for convivial signals (from `convivial-purpose.md` Section 5.4):

| Metric | Type | What It Signals |
|--------|------|-----------------|
| **Notification frequency per user-session** | Leading | Attention respect; should trend down or stay stable |
| **User control surface usage** (settings, customization, undo) | Leading | Autonomy; high usage suggests control is valued and discoverable |
| **Data collection delta per release** | Leading | Extraction risk; net increase requires justification |
| **Feature-to-capability ratio** | Lagging | Bloat vs. genuine expansion |
| **Manipulation vector count per spec** | Leading | Risk surface; specs with >2 vectors require explicit mitigations |

**Implementation:**

1. Define metrics in ObservaKit configuration
2. Add to standard dashboards (if applicable)
3. Consider release gates based on metric thresholds

### 7. Create Onboarding Materials

Create quick-reference materials for new team members:

| Material | Purpose | Format |
|----------|---------|--------|
| 30-second Convivial Purpose summary | Quick orientation | Card / README section |
| RCDS layer overview | Understanding the framework | Diagram + bullet points |
| CIA template walkthrough | Practical spec writing | Annotated example |
| Anti-pattern gallery | Recognizing dark patterns | Visual examples with explanations |

---

## Dependencies & Sequencing

```text
P0: README.md ──────────────────────────────┐
                                            │
P0: Schema addition ────────────────────────┤
                                            ▼
                              P1: Spec template enhancement
                                            │
P1: Convivial guardrails ───────────────────┤
                                            ▼
                              P2: PR checklist
                                            │
                              P2: Metrics implementation
                                            │
                              P2: Onboarding materials
```

**Notes:**

- Schema and README are independent and can be done in parallel
- Spec templates should reference the schema once it exists
- Guardrails can be developed independently but should align with schema enums
- Metrics depend on having clear definitions from schema and templates

---

## Success Criteria

The purpose documentation and operationalization is complete when:

1. ✅ Purpose `README.md` exists with 30-second summary
2. ✅ `convivial_impact` schema is validated in CI
3. ✅ Tier 2+ spec templates include CIA section
4. ✅ `convivial_guardrails.yaml` is consumed by PolicyKit/AgentKit
5. ✅ PR templates include Convivial Purpose Check
6. ⬜ Measurability metrics are tracked (stretch goal)
7. ⬜ Onboarding materials are available (stretch goal)

---

## Related Documentation

- [`../pillars/README.md`](../pillars/README.md) — The six pillars grounded in Convivial Purpose
- [`./convivial-purpose.md`](./convivial-purpose.md) — Full synthesis and operationalization spec
- [`./resonant-computing-design-stack.md`](./resonant-computing-design-stack.md) — Foundational RCDS framework
- [`../../practices/methodology/README.md`](../../practices/methodology/README.md) — Methodology implementation

