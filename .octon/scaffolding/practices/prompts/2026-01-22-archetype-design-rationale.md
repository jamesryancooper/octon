# Document Archetype Design Rationale

## Objective

Add documentation explaining **why** Octon uses documentation-based archetypes for skills, including the design rationale, pros/cons analysis, and guidance on using tags for semantic categories.

---

## Key Concepts to Document

### 1. Definition of Documentation-Based Archetypes

**Core principle:** Archetypes answer one question: *"How much documentation does this skill need for an agent to use it correctly?"*

| Approach | Question Answered | Used By |
|----------|-------------------|---------|
| Documentation-based | "How much context to load?" | Octon |
| Execution-based | "How does this execute?" | Traditional systems |
| Capability-based | "What permissions does this need?" | Traditional systems |

In AI-native systems, the consumer of skill definitions is an LLM, not a runtime engine. This changes what matters—agents need to understand intent, not dispatch to different execution paths.

### 2. Pros of Documentation-Based Archetypes

1. **Token efficiency is a first-class concern.** Progressive disclosure directly maps to "load only what you need." Archetypes signal how much to read before understanding a skill.

2. **Agent comprehension scales with complexity.** Simple skills need simple docs. Complex skills need structured docs. The archetype signals this proportionally.

3. **Avoids false taxonomies.** "Validator" vs "Transformer" is a semantic distinction that doesn't affect how an agent *uses* the skill—both are single-purpose, obvious I/O. Separate archetypes would add complexity without improving agent behavior.

4. **Composability stays external.** By not having Pipeline/Composite archetypes, orchestration is forced into Missions where it belongs. Skills stay atomic.

### 3. Cons / Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| **Execution characteristics get implicit.** Statefulness, interactivity, or side effects aren't surfaced by archetype. | Agent discovers these via `safety.md` or `behaviors.md`. For critical characteristics, use tags (e.g., `stateful`, `interactive`). |
| **Validation/testing expectations unclear.** Archetype doesn't signal "this skill's output is pass/fail." | Use semantic tags like `validator` in manifest.yml. Testing expectations documented in `validation.md` for Workflow skills. |
| **Tooling can't optimize by archetype.** Documentation-based archetypes don't enable batching or parallelization by execution type. | Use tags for tooling hints. Orchestration-level optimizations belong in Missions, not skill archetypes. |
| **Author confusion on edge cases.** "Is my skill a Utility or Workflow?" becomes "Do I need examples?" rather than "What does my skill do?" | Provide clear decision heuristics based on documentation needs, not semantic category. |

### 4. The Decision Framework

Archetypes are about **documentation needs**, not **semantic categories**.

| Documentation Need | Archetype |
|--------------------|-----------|
| None beyond SKILL.md | Utility |
| Examples clarify output | Utility (with examples) |
| Multi-phase + safety + validation | Workflow |
| Domain-specific terminology/compliance | Workflow + domain files |

**Semantic categories are tags, not archetypes:**

```yaml
# In manifest.yml
- id: validate-schema
  tags: [validator, json, utility]  # ← Semantic category as tag
  # Archetype is implicit from structure: SKILL.md only = Utility
```

Tags like `validator`, `transformer`, `generator`, `linter` help with discovery and filtering but don't change what documentation the agent needs.

### 5. Why This Fits AI-Native Systems

Documentation-based archetypes are the right fit for AI-native skills because:

1. **They optimize for the actual constraint (context window).** The primary bottleneck is token usage, not runtime dispatch.

2. **They keep skills atomic (orchestration elsewhere).** Multi-step workflows belong in Missions. Skills are single-purpose units.

3. **They avoid premature taxonomies that don't improve agent behavior.** Adding "Validator" and "Transformer" archetypes wouldn't change how agents load or execute skills.

---

## Implementation Plan

### File: `docs/architecture/workspaces/skills/architecture.md`

**Location:** Add new section after "Progressive Disclosure Model" or as a new top-level section.

**Section title:** `## Why Documentation-Based Archetypes`

**Content to add:**

- Definition of documentation-based archetypes
- Comparison table (documentation-based vs execution-based vs capability-based)
- The core insight: "In AI-native systems, the consumer is an LLM, not a runtime engine"
- Why this approach fits Octon

### File: `docs/architecture/workspaces/skills/reference-artifacts.md`

**Location:** Add after the "Skill Archetypes" diagram section, before "Choosing an Archetype".

**Section title:** `## Archetype Design Philosophy`

**Content to add:**

- The core question archetypes answer
- Brief pros summary (token efficiency, comprehension scaling, avoiding false taxonomies)
- Link to architecture.md for full rationale

### File: `docs/architecture/workspaces/skills/discovery.md`

**Location:** In the manifest.yml section, under tags documentation.

**Section title:** `### Semantic Tags vs Archetypes`

**Content to add:**

- Explanation that tags are for semantic categories (validator, transformer, generator)
- Tags help with discovery and filtering
- Tags don't change documentation requirements
- Example showing tags in manifest.yml

### File: `.octon/capabilities/runtime/skills/README.md`

**Location:** After the "Skill Archetypes" table.

**Content to add:**

- Brief note: "Archetypes are based on documentation needs, not execution type"
- Note that semantic categories (validator, transformer) should use `tags` in manifest.yml
- Link to full rationale in architecture.md

---

## Example Content Blocks

### For architecture.md

````markdown
## Why Documentation-Based Archetypes

In AI-native systems, the consumer of skill definitions is an LLM, not a runtime engine. This fundamentally changes what archetypes should represent.

### The Core Insight

| System Type | Archetype Answers | Optimizes For |
|-------------|-------------------|---------------|
| Traditional | "How to execute this?" | Runtime dispatch |
| AI-Native (Octon) | "How much context to load?" | Token efficiency |

Traditional systems create archetypes for execution characteristics: "Validator," "Transformer," "Pipeline," "Stateful." These distinctions help runtimes dispatch to different execution paths.

In Octon, the agent reads documentation to understand what a skill does. The relevant question becomes: *"How much documentation does this skill need for an agent to use it correctly?"*

### Benefits

1. **Token efficiency is a first-class concern.** Progressive disclosure maps directly to archetype choice—Utility loads one file, Workflow loads five+.

2. **Agent comprehension scales with complexity.** Simple skills need simple docs. The archetype signals this proportionally.

3. **Avoids false taxonomies.** "Validator" vs "Transformer" doesn't affect how an agent uses a skill. Both are single-purpose with obvious I/O—both are Utility.

4. **Keeps skills atomic.** No Pipeline/Composite archetype means orchestration stays in Missions where it belongs.

### Semantic Categories as Tags

For discoverability, use `tags` in manifest.yml:

```yaml
- id: validate-schema
  tags: [validator, json]

- id: format-json
  tags: [transformer, json, formatter]
```

Tags enable filtering ("show me all validators") without creating structural overhead.

````

### For reference-artifacts.md

```markdown
## Archetype Design Philosophy

Skill archetypes answer one question: **"How much documentation does this skill need for an agent to use it correctly?"**

This is a deliberate design choice for AI-native systems where token efficiency matters more than execution-type dispatch. The archetype determines how much context an agent loads, not how the skill executes.

| Documentation Need | Archetype |
|--------------------|-----------|
| None beyond SKILL.md | Utility |
| Examples clarify output | Utility (with examples) |
| Multi-phase + safety + validation | Workflow |
| Domain-specific terminology | Workflow + domain files |

**Semantic categories** (validator, transformer, generator) are expressed as `tags` in manifest.yml, not as archetypes. Tags help with discovery; archetypes determine documentation structure.

See [Architecture](./architecture.md#why-documentation-based-archetypes) for the full design rationale.
```

### For discovery.md

````markdown
### Semantic Tags vs Archetypes

Tags in manifest.yml express **semantic categories**—what kind of thing a skill is:

```yaml
skills:
  - id: validate-schema
    tags: [validator, json, schema]

  - id: format-json
    tags: [transformer, json, formatter]

  - id: generate-uuid
    tags: [generator, utility]
```

**Tags are not archetypes.** A skill's archetype (Utility, Utility with examples, Workflow) is determined by its documentation needs, not its semantic category.

| Concept | Determined By | Purpose |
|---------|---------------|---------|
| Archetype | Directory structure | How much documentation to load |
| Tags | manifest.yml `tags` field | Discovery, filtering, categorization |

Both `validate-schema` and `format-json` might be Utility skills (same archetype) but have different tags (different semantic categories).

````

---

## Validation Checklist

After implementation, verify:

- [ ] `architecture.md` explains why documentation-based archetypes fit AI-native systems
- [ ] `reference-artifacts.md` has brief philosophy section linking to architecture.md
- [ ] `discovery.md` documents semantic tags vs archetypes distinction
- [ ] `.octon/capabilities/runtime/skills/README.md` mentions tags for semantic categories
- [ ] No documentation suggests creating new archetypes for execution characteristics
- [ ] Examples show tags like `validator`, `transformer`, `generator` in manifest.yml

---

## Out of Scope

Do NOT:

- Create new archetypes for Validator, Transformer, Generator, etc.
- Add execution-type metadata to archetypes
- Change the archetype selection criteria from documentation-based to execution-based
- Remove the current archetype structure

The goal is to **document the rationale**, not change the system.
