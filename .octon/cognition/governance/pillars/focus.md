---
title: Focus through Absorbed Complexity
description: Build features, not infrastructure — Octon handles the rest.
phase: PLAN
---

# Focus through Absorbed Complexity

> Build features, not infrastructure — Octon handles the rest.

---

## Overview

| Element | Content |
|---------|---------|
| **Developer Receives** | Focus — cognitive bandwidth freed for what matters |
| **Octon Provides** | Absorbed Complexity — kits, schemas, modular boundaries |
| **Phase** | PLAN |
| **Partner Pillar** | [Direction](./direction.md) |

**Phase Note:** Focus is a PLAN pillar because architectural decisions about complexity absorption are made during planning. The *benefit* of absorbed complexity extends into SHIP (and beyond), but the *commitment* to using kits and respecting boundaries is a planning decision.

> *"You decide to absorb complexity in PLAN; you enjoy the focus in SHIP."*

---

## Key Kits

| Kit | Maturity | Purpose |
|-----|----------|---------|
| kit-base | `[Production]` | Foundation for all kits |
| PromptKit | `[Production]` | AI prompt orchestration |
| Turborepo | `[Production]` | Monorepo build orchestration |
| Hexagonal adapters | `[Production]` | Modular port/adapter boundaries |

---

## Failure Mode

**Cognitive overload: developers manage process instead of building**

When this pillar fails, developers spend their mental energy on infrastructure, configuration, and plumbing instead of features. The result is slower delivery, increased errors, and developer burnout.

### Anti-Patterns

- **Building custom infrastructure** — Reinventing what kits already provide
- **Boundary violations** — Reaching across module boundaries
- **"Util" sprawl** — Accumulating undocumented shared code
- **Infrastructure-first thinking** — Solving infrastructure problems before feature problems

---

## RCDS Alignment

| RCDS Layer | Connection | Strength |
|------------|------------|----------|
| **Flourishing & Care** | Cognitive freedom supports developer flourishing | ◐ Secondary |
| **Structures & Scale** | Modularity enables convivial, human-scale tools | ◉ Strong |
| **Attention & Interaction** | Absorbed complexity directly reduces cognitive load | ◉ Strong |
| **Practice & Governance** | Absorbed complexity enables better craft practice | ◐ Secondary |

---

## Pillar Relationships

### Phase Partner: Direction

Direction tells you *what* to build; Focus gives you the cognitive bandwidth *to* build it. Without Focus, even a perfectly validated spec leads to overwhelmed developers drowning in infrastructure concerns.

### Enabler: Focus → Velocity

Focus enables Velocity: absorbed complexity removes the infrastructure bottlenecks that slow delivery. You can ship fast because you're not rebuilding the same plumbing every sprint.

### Foundation: Focus → Trust

Focus supports Trust: when complexity is absorbed into well-tested kits, the building blocks themselves are trustworthy. Developers can trust the boundaries and contracts that kits enforce.

### Knowledge Embedding: Focus → Continuity

Focus embeds knowledge in kits: the decisions that shaped kit-base, PromptKit, and module boundaries *are* institutional memory. Focus is Continuity made operational.

### Improvement Target: Insight → Focus

Insight improves Focus: postmortems reveal which complexity isn't yet absorbed ("we had to build custom X"), informing kit roadmaps. EvalKit feedback on AI orchestration improves PromptKit.

### Convivial Grounding

Focus serves Convivial Purpose: convivial tools must be understandable. Absorbed complexity keeps systems legible to developers *and* users. A system developers don't understand can't be a system users can trust.

---

## Actionability

### Developer Action

1. Use kit-base patterns for new functionality
2. Stay within your module boundaries
3. Don't build custom infrastructure — use existing kits
4. When you need new infrastructure, propose a kit

### Octon Enforcement

| Mechanism | Description | Status |
|-----------|-------------|--------|
| **Turborepo boundaries** | Enforces module import restrictions | Active |
| **Kit scaffolding** | Generates consistent kit structure | Active |
| **Schema validation** | Validates data structures against schemas | Active |
| **Dependency linters** | Detects boundary violations | Active |
| **Architecture rules in CI** | Blocks PRs with boundary violations | Active |

### Violation Signals

- Custom infrastructure commits outside of kits
- Boundary violations detected by linters
- "Util" directory growth
- PR comments asking "why didn't you use kit X?"

---

## Metrics

| Metric | What It Measures | Target | Collection Method |
|--------|------------------|--------|-------------------|
| **Feature-to-infrastructure ratio** | Ratio of feature PRs to infrastructure PRs | ≥4:1 | Label PRs as `feature` vs `infra`; compute ratio |
| **Kit adoption rate** | % of new code using kit-base patterns | ≥90% | Static analysis: detect kit-base imports/patterns |
| **Boundary violation trend** | Boundary violations over time | Decreasing | Turborepo/linter reports |
| **Time-to-first-feature** | How quickly new devs ship first feature | ≤2 weeks | Track onboarding → first merged PR |
| **Developer context-switch frequency** | How often devs leave feature work for infra | ≤1/week | Self-reported in standups |
| **"Yak-shave" incidents** | Times feature work was blocked by infra needs | ≤1/sprint | Track in issue labels |
| **Cognitive load survey score** | Quarterly developer survey on cognitive burden | Improving | NASA-TLX adapted for dev work |

---

## Convivial Alignment

| Dimension | How Focus Serves It |
|-----------|---------------------|
| **Expands Capability** | ✅ Cognitive freedom enables better building |
| **Respects Attention** | ✅ Absorbed complexity reduces cognitive load |
| **Fosters Connection** | ○ Indirect |
| **Resists Extraction** | ✅ Modularity resists complexity extraction |

---

## Related Documentation

- [Direction through Validated Discovery](./direction.md) — Phase partner
- [Velocity through Agentic Automation](./velocity.md) — Enabled by Focus
- [Pillars Overview](./README.md) — All six pillars
- [Kit Documentation](/.octon/capabilities/runtime/services/_meta/docs/kits-reference.md) — Tools that absorb complexity
- [Architecture Overview](../../_meta/architecture/overview.md) — Hexagonal boundaries
- [Convivial Purpose](../purpose/convivial-purpose.md) — The "why" this pillar serves
