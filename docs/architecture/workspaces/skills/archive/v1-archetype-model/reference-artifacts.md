---
title: Reference Artifacts
description: Archetype-based reference file system for progressive disclosure in skills.
---

# Reference Artifacts

Reference files in the `references/` directory provide **progressive disclosure** — detailed content loaded only when needed. **Reference files are optional.** Choose the appropriate archetype based on your skill's complexity.

**Design Principle:** Keep individual reference files focused. Agents load these on demand, so smaller files mean less context usage.

---

## Skill Archetypes

Skills are **labeled** Atomic or Complex based on their coordination complexity. Both archetypes use pattern-triggered reference files — Complex skills simply exhibit more patterns.

**Archetypes are descriptive, not prescriptive.** They describe what a skill *is*, not what files it *must have*. See [Archetype Design Philosophy](#archetype-design-philosophy) for details.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Skill Archetypes (Descriptive Labels)                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ATOMIC ─────────────────────────────────────── "The Specialist" ────────── │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  SKILL.md — single-purpose, stateless, deterministic               │    │
│  │                                                                     │    │
│  │  Best for: One discrete action with clear I/O                      │    │
│  │  Examples: format-json, validate-schema, count-tokens              │    │
│  │                                                                     │    │
│  │  Add reference files as patterns emerge:                           │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                   │    │
│  │  │  examples   │ │  errors     │ │  glossary   │                   │    │
│  │  │    .md      │ │    .md      │ │    .md      │                   │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘                   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  COMPLEX ───────────────────────────────────────── "The Strategist" ───────── │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Add reference files as patterns emerge (progressive complexity):  │    │
│  │                                                                     │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐    │    │
│  │  │io-contract  │ │ behaviors   │ │  safety     │ │  examples   │    │    │
│  │  │    .md      │ │    .md      │ │    .md      │ │    .md      │    │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘    │    │
│  │   (Non-trivial    (Distinct       (Tool/file     (Output needs     │    │
│  │    I/O)            phases)         policies)      demonstration)   │    │
│  │                                                                     │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐    │    │
│  │  │checkpoints  │ │orchestration│ │ decisions   │ │ composition │    │    │
│  │  │    .md      │ │    .md      │ │    .md      │ │    .md      │    │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘    │    │
│  │    (Stateful)     (Orchestrated)   (Phased)        (Composable)     │    │
│  │                                                                     │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐    │    │
│  │  │ validation  │ │  errors     │ │  glossary   │ │  <domain>   │    │    │
│  │  │    .md      │ │    .md      │ │    .md      │ │    .md      │    │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘    │    │
│  │   (Quality        (Complex        (Domain         (Specialized     │    │
│  │    gates)          errors)         terms)          knowledge)      │    │
│  │                                                                     │    │
│  │  Best for: Multi-phase execution, state management, coordination   │    │
│  │  Examples: refine-prompt, synthesize-research, audit-compliance     │    │
│  │  Complexity: Minimal → Growing → Typical → Enterprise (see below)  │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Archetype Design Philosophy

### Descriptive, Not Prescriptive

Archetypes are **descriptive labels**, not prescriptive buckets. They describe *what the skill is* based on its coordination complexity — they do not dictate *what files it must have*.

**Core principle:** Skills are labeled Atomic or Complex based on their coordination complexity. Both archetypes use pattern-triggered reference files — Complex skills simply exhibit more patterns.

| Archetype | What It Describes | Documentation Pattern |
|-----------|-------------------|----------------------|
| **Atomic** | Single-purpose, stateless operations | SKILL.md + optional refs as patterns emerge |
| **Complex** | Multi-concern coordination with state | SKILL.md + refs triggered by exhibited patterns |

This framing means:
- **No mandatory file lists** — Files are added because patterns are present, not because an archetype requires them
- **Smooth graduation** — A skill naturally accumulates reference files as complexity grows
- **No artificial boundaries** — The same pattern triggers apply to both archetypes; Complex skills just hit more triggers

### Key Traits

| Feature | Atomic | Complex |
|---------|--------|---------|
| Logic | Fixed / Deterministic | Multi-phase / Coordinated |
| State | Stateless | State-aware (phases, checkpoints) |
| Scope | Vertical (deep but narrow) | Horizontal (broad, integrative) |
| Reusability | Universal | Contextual (domain-specific) |

**Semantic categories** (validator, transformer, generator) are expressed as `tags` in manifest.yml, not as archetypes. Tags help with discovery; archetypes determine documentation scope.

See [Architecture](./architecture.md#why-documentation-based-archetypes) for the full design rationale.

---

## Choosing an Archetype

### Quick Decision Matrix

Use this matrix for fast archetype selection:

| If your skill... | Use | Rationale |
|------------------|-----|-----------|
| Does one thing with obvious I/O | **Atomic** | Single transformation, minimal docs |
| Has ≤2 optional reference files | **Atomic** | Still fits Atomic token budget |
| Has ≥3 phases with state | **Complex** | Coordination logic is non-trivial |
| Needs ≥3 reference files | **Complex** | Exceeds Atomic documentation scope |
| Maintains checkpoints for recovery | **Complex** | Requires state management patterns |
| Coordinates multiple sub-tasks | **Complex** | Requires orchestration documentation |
| Has approval gates or decision points | **Complex** | Requires interaction documentation |

**Token budget guideline:**
- **Atomic:** SKILL.md (~2000 tokens) + ≤2 optional refs (~1000 tokens each) = ~4000 tokens max
- **Complex:** SKILL.md (~5000 tokens) + pattern-triggered refs = ~10000+ tokens

#### Token Budget Validation

Token budgets are **enforced by validation tooling** in `.harmony/skills/scripts/validate-skills.sh`:

| File | Budget | Validated |
|------|--------|-----------|
| SKILL.md | 5000 tokens | Yes |
| Manifest entry | 100 tokens | Yes |
| io-contract.md | 1000 tokens | Yes |
| safety.md | 1000 tokens | Yes |
| examples.md | 2000 tokens | Yes |
| behaviors.md | 1500 tokens | Yes |
| validation.md | 800 tokens | Yes |

**Measurement:** Uses tiktoken (cl100k_base encoding) when available; falls back to word count approximation (±20% variance). Install tiktoken for accurate CI validation: `pip install tiktoken`

**Exceeding budgets:** Validation warns but doesn't fail. If consistently exceeding budgets, split content into pattern-specific reference files or extract to domain files.

### Decision Flowchart

```text
Does this skill do ONE thing with obvious I/O?
          │
          ├─ YES ──▶ ATOMIC
          │           └─ SKILL.md only
          │           └─ Add references/ as needed (examples, errors, glossary)
          │
          └─ NO ───▶ Does it coordinate sub-tasks, maintain state, OR have phases?
                      │
                      ├─ ANY YES ──▶ COMPLEX
                      │               └─ Add pattern-triggered files based on exhibited patterns
                      │               └─ Must have at least one of: io-contract, behaviors,
                      │                  checkpoints, orchestration, decisions, interaction, etc.
                      │
                      └─ ALL NO ───▶ ATOMIC (reconsider — skill may be simpler than expected)
```

**Reference file triggers (both archetypes):**

| Trigger                             | File to Add   |
| ----------------------------------- | ------------- |
| Output format needs demonstration   | `examples.md` |
| Complex failure modes exist         | `errors.md`   |
| Domain terminology needs definition | `glossary.md` |

### Decision Heuristics

| Signal | Threshold | Recommendation |
|--------|-----------|----------------|
| Does the skill do one discrete action with obvious I/O? | Yes | **Atomic** |
| Does the skill coordinate multiple concerns or maintain state? | Yes | **Complex** |
| Would you write >3 example cases to show expected output? | >3 examples | Add `examples.md` |
| Are there >5 domain-specific terms needing definitions? | >5 terms | Add `glossary.md` |
| Does error handling exceed 30 lines with recovery procedures? | >30 lines | Add `errors.md` |
| Does safety documentation exceed 100 lines with domain content? | >100 lines | Extract to domain file |

### Atomic → Complex Upgrade Heuristics

Upgrade to Complex when ANY of these conditions apply:

| Condition | Threshold | Why It Matters |
|-----------|-----------|----------------|
| Multiple discrete sub-tasks | ≥3 sub-tasks | Coordination logic becomes non-trivial |
| State persistence required | Any checkpoint needed | Requires `checkpoints.md` for recovery |
| Phase transitions | ≥3 phases with documented transitions | Requires `behaviors.md` for execution flow |
| Documentation size | >3000 tokens total | Exceeds Atomic budget; needs progressive disclosure |
| Conditional execution paths | ≥3 branches | Requires `decisions.md` for path selection |
| Human-in-the-loop | Any approval gate | Requires `interaction.md` for runtime input |
| Sub-agent coordination | Any delegation | Requires `agents.md` for coordination |

Stay Atomic when ALL of these apply:

| Condition | Threshold | Example |
|-----------|-----------|---------|
| Single transformation | 1 input → 1 output | `format-json`, `validate-schema` |
| Stateless execution | No intermediate state | `count-tokens`, `extract-keywords` |
| No branching logic | Linear execution | `generate-uuid` |
| Self-explanatory behavior | <2000 tokens to document | `summarize-text` |

#### Edge Case: Validate-then-Transform

An Atomic skill that validates input *then* transforms it is still Atomic if:

- Both operations are tightly coupled (validation determines transformation)
- No user decision needed between validation and transformation
- Total documentation fits in ~2000 tokens

If the user must approve validation results before transformation, upgrade to Complex with `interaction.md`.

### What "Complex" Means

**Complex Architecture** enables enterprise-grade, multi-phase skills that require both flexibility and control. The Complex archetype encompasses several **capability patterns**:

| Pattern | Description | Example | Optional File |
|---------|-------------|---------|---------------|
| **Stateful** | Maintains state across phases via checkpoints and intermediate outputs | `synthesize-research` — preserves gathered sources while analyzing | `checkpoints.md` |
| **Orchestrated** | Coordinates multiple sub-tasks or concerns into a unified workflow | `refine-prompt` — combines context analysis, persona assignment, refinement | `orchestration.md` |
| **Phased** | Executes defined phases in sequence with documented transitions | `refactor` — scope → audit → plan → execute → verify | `decisions.md` |
| **Validation-Heavy** | Includes formal acceptance criteria and quality gates | `audit-compliance` — evidence collection with framework-specific validation | `validation.md` |
| **Domain-Oriented** | Requires specialized knowledge and terminology consistency | Compliance, finance, legal, or healthcare skills | `<domain>.md`, `glossary.md` |
| **Composable** | Designed as building blocks for other skills or pipelines | Skills explicitly designed for multi-skill composition | `composition.md` |
| **Agentic** | Spawns or coordinates sub-agents for parallel work | Skills that delegate to sub-agents | `agents.md` |
| **Interactive** | Requires human-in-the-loop at runtime | Skills with approval gates or decision points | `interaction.md` |

**Complex archetype** is appropriate when the skill:

- Coordinates multiple sub-tasks or concerns (orchestrated)
- Executes defined phases with documented transitions (phased)
- Maintains state across phases via checkpoints or intermediate outputs (stateful)
- Requires formal validation and quality gates (validation-heavy)
- Operates in specialized domains requiring terminology consistency (domain-oriented)
- Is designed as a building block for pipelines (composable)
- Has safety constraints that need formal documentation

A single Complex skill often combines multiple patterns—for example, a compliance audit skill may be orchestrated (coordinates evidence gathering, analysis, and reporting), phased (follows a defined audit workflow), stateful (preserves evidence across phases), and domain-oriented (requires compliance framework knowledge).

### Progressive Complexity

Complex is not monolithic — it encompasses a **spectrum of complexity** from minimal to enterprise-grade. Skills graduate along this spectrum as they exhibit more patterns.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Progressive Complexity Spectrum                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  MINIMAL ──────────────────────────────────────────────────────── ENTERPRISE │
│                                                                              │
│  ┌───────────┐    ┌───────────┐    ┌───────────┐    ┌───────────┐          │
│  │ 1 pattern │ →  │ 2 patterns│ →  │ 3-4       │ →  │ 5+ patterns│          │
│  │ ~2000 tok │    │ ~4000 tok │    │ ~7000 tok │    │ ~12000 tok │          │
│  │           │    │           │    │           │    │            │          │
│  │ "Just     │    │ "Growing  │    │ "Typical  │    │ "Enterprise│          │
│  │  Complex" │    │  Complex" │    │  Complex" │    │  Complex"  │          │
│  └───────────┘    └───────────┘    └───────────┘    └───────────┘          │
│                                                                              │
│  Example:         Example:         Example:         Example:                │
│  Phased-only      Phased +         Workflow Skill   Domain Expert           │
│  refactor         Stateful         profile          profile                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Complexity Tiers

| Tier | Patterns | Token Budget | Typical Use Case |
|------|----------|--------------|------------------|
| **Minimal Complex** | 1 | ~2000 | Just crossed from Atomic; single coordination need |
| **Growing Complex** | 2 | ~4000 | Common pairing like Phased + Stateful |
| **Typical Complex** | 3-4 | ~7000 | Standard multi-phase workflows (Workflow Skill profile) |
| **Enterprise Complex** | 5+ | ~12000 | Cross-cutting coordination (Coordinator Skill profile) |
| **Domain Expert** | 5+ | ~15000 | Specialized domains requiring extensive knowledge |

**Key insight:** A skill with one pattern is still Complex if that pattern involves coordination (e.g., phased execution with 3+ phases). The archetype describes the skill's nature, not its documentation volume.

#### Graduation Path

Skills naturally graduate along the spectrum as requirements evolve:

1. **Atomic → Minimal Complex**: Skill gains a coordination need (e.g., phased execution)
   - *Add:* First pattern-triggered file (e.g., `decisions.md` for phase branching)

2. **Minimal → Growing**: Skill needs state persistence
   - *Add:* `checkpoints.md` alongside existing pattern files

3. **Growing → Typical**: Skill becomes a standard workflow
   - *Consider:* Adopting a [Common Profile](#common-profiles) for guidance

4. **Typical → Enterprise**: Skill coordinates multiple concerns at scale
   - *Monitor:* Aggregate token budget; consider skill decomposition if approaching limits

**Anti-pattern:** Don't pre-emptively add files for patterns not yet exhibited. Let complexity emerge from actual requirements.

### Pattern Selection Checklist

Use this yes/no checklist to determine which optional reference files your Complex skill needs. Answer each question honestly—if in doubt, the answer is probably "no."

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Pattern Selection Checklist                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Does your skill...                                    Add this file:        │
│  ─────────────────────────────────────────────────────────────────────────── │
│                                                                              │
│  □ Maintain state across phases?                       checkpoints.md        │
│    (checkpoints, intermediate outputs, recovery)                             │
│                                                                              │
│  □ Coordinate multiple sub-tasks?                      orchestration.md      │
│    (delegate to other skills, manage dependencies)                           │
│                                                                              │
│  □ Have conditional execution paths?                   decisions.md          │
│    (branching logic, decision trees, >2 paths)                               │
│                                                                              │
│  □ Design as a pipeline building block?                composition.md        │
│    (defined I/O contracts for chaining with other skills)                    │
│                                                                              │
│  □ Spawn or coordinate sub-agents?                     agents.md             │
│    (parallel agent work, agent delegation)                                   │
│                                                                              │
│  □ Require human input at runtime?                     interaction.md        │
│    (approval gates, decision points, refinement loops)                       │
│                                                                              │
│  □ Have formal acceptance criteria?                    validation.md         │
│    (quality gates, verification steps)                                       │
│                                                                              │
│  □ Operate in a specialized domain?                    glossary.md           │
│    (>5 domain terms needing definition)                <domain>.md           │
│                                                                              │
│  □ Have complex error scenarios?                       errors.md             │
│    (>30 lines of error handling, recovery procedures)                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Stateful Pattern → `checkpoints.md`

| Question | If YES |
|----------|--------|
| Can the skill be interrupted mid-execution and need to resume later? | Add `checkpoints.md` |
| Does the skill produce intermediate outputs that must persist between phases? | Add `checkpoints.md` |
| Would losing progress after phase 2 require re-running phases 1-2? | Add `checkpoints.md` |

**If all NO:** Skill is stateless—no checkpoint file needed.

#### Orchestrated Pattern → `orchestration.md`

| Question | If YES |
|----------|--------|
| Does the skill have 3+ distinct sub-tasks with their own inputs/outputs? | Add `orchestration.md` |
| Do sub-tasks have dependencies (task B needs output from task A)? | Add `orchestration.md` |
| Could sub-tasks fail independently, requiring per-task error handling? | Add `orchestration.md` |

**If all NO:** Skill has simple linear flow—no orchestration file needed.

#### Phased Pattern → `decisions.md`

| Question | If YES |
|----------|--------|
| Are there 3+ distinct execution paths based on input characteristics? | Add `decisions.md` |
| Does the skill branch differently for "small scope" vs "large scope"? | Add `decisions.md` |
| Are there explicit decision points where the path forward changes? | Add `decisions.md` |

**If all NO:** Skill follows a single path—no decisions file needed.

#### Composable Pattern → `composition.md`

| Question | If YES |
|----------|--------|
| Is this skill explicitly designed to receive output from another skill? | Add `composition.md` |
| Will other skills consume this skill's output as their input? | Add `composition.md` |
| Is this skill a deliberate building block in a larger pipeline? | Add `composition.md` |

**If all NO:** Skill is standalone—no composition file needed.

#### Agentic Pattern → `agents.md`

| Question | If YES |
|----------|--------|
| Does the skill spawn sub-agents to work in parallel? | Add `agents.md` |
| Does the skill delegate specialized work to other agents? | Add `agents.md` |
| Must results from multiple agents be collected and merged? | Add `agents.md` |

**If all NO:** Skill works alone—no agents file needed.

#### Interactive Pattern → `interaction.md`

| Question | If YES |
|----------|--------|
| Must the user approve something before the skill continues? | Add `interaction.md` |
| Does the user choose between options at runtime? | Add `interaction.md` |
| Is there a refinement loop ("Is this acceptable? [Yes/Revise]")? | Add `interaction.md` |

**If all NO:** Skill runs autonomously—no interaction file needed.

#### Validation-Heavy Pattern → `validation.md`

| Question | If YES |
|----------|--------|
| Are there formal acceptance criteria beyond "it runs without errors"? | Add `validation.md` |
| Does each phase have specific quality gates? | Add `validation.md` |
| Would a reviewer need a checklist to verify the output? | Add `validation.md` |

**If all NO:** Inline success criteria in SKILL.md suffice.

#### Domain-Oriented Pattern → `glossary.md` / `<domain>.md`

| Question | If YES |
|----------|--------|
| Are there 5+ domain-specific terms the agent must understand? | Add `glossary.md` |
| Does the skill require specialized knowledge (legal, finance, security)? | Add `<domain>.md` |
| Would a general-purpose agent misunderstand key concepts without training? | Add both |

**If all NO:** General knowledge suffices—no domain files needed.

#### Summary: Quick Decision Matrix

| If you answered YES to... | Add these files |
|---------------------------|-----------------|
| Any Stateful questions | `checkpoints.md` |
| Any Orchestrated questions | `orchestration.md` |
| Any Phased questions | `decisions.md` |
| Any Composable questions | `composition.md` |
| Any Agentic questions | `agents.md` |
| Any Interactive questions | `interaction.md` |
| Any Validation-Heavy questions | `validation.md` |
| Any Domain-Oriented questions | `glossary.md`, `<domain>.md` |

**Common Pattern Combinations:**

| Skill Type | Typical Patterns | Files Needed |
|------------|------------------|--------------|
| Multi-phase workflow | Phased + Stateful | `decisions.md`, `checkpoints.md` |
| Sub-task coordinator | Orchestrated + Phased | `orchestration.md`, `decisions.md` |
| Pipeline component | Composable + Validation-Heavy | `composition.md`, `validation.md` |
| Compliance audit | Domain + Stateful + Validation | `<domain>.md`, `checkpoints.md`, `validation.md` |
| Interactive refiner | Interactive + Stateful | `interaction.md`, `checkpoints.md` |
| Agent coordinator | Agentic + Orchestrated | `agents.md`, `orchestration.md` |

### Common Profiles

Profiles are pre-validated pattern bundles for common skill types. Using a profile gives you confidence that your pattern combination is well-tested and avoids pattern explosion.

#### Profile: Workflow Skill

**Use when:** Skill executes a multi-phase process with clear transitions and needs to recover from interruption.

| Files | Pattern Coverage |
|-------|------------------|
| `behaviors.md` | Phase definitions and transitions |
| `checkpoints.md` | State persistence between phases |
| `decisions.md` | Branching logic between phases |

**Token budget:** ~4000-5000 tokens across all reference files

**Example skills:** `refactor`, `migrate-schema`, `audit-codebase`

**Note:** Rarely needs both `orchestration.md` and `decisions.md` — use orchestration when delegating to other skills, decisions when branching within this skill.

#### Profile: Coordinator Skill

**Use when:** Skill manages multiple sub-tasks that may run in parallel or have complex dependencies.

| Files | Pattern Coverage |
|-------|------------------|
| `orchestration.md` | Sub-task coordination and dependencies |
| `safety.md` | Scope limits for delegated work |
| `validation.md` | Aggregate success criteria |

**Token budget:** ~3500-4500 tokens across all reference files

**Example skills:** `build-pipeline`, `parallel-test-runner`, `multi-repo-sync`

**Note:** Rarely needs both `orchestration.md` and `agents.md` — use orchestration for skill delegation, agents only when spawning actual agent instances.

#### Profile: Interactive Skill

**Use when:** Skill requires human input at runtime (approvals, choices, refinement loops).

| Files | Pattern Coverage |
|-------|------------------|
| `interaction.md` | Human-in-the-loop touchpoints |
| `checkpoints.md` | State preservation while waiting for input |
| `examples.md` | Demonstration of interaction patterns |

**Token budget:** ~3500-4500 tokens across all reference files

**Example skills:** `refine-prompt`, `guided-migration`, `interactive-review`

**Note:** Interactive skills almost always need checkpoints — users may step away mid-execution.

#### Profile: Domain Expert Skill

**Use when:** Skill operates in a specialized domain requiring terminology consistency and domain knowledge.

| Files | Pattern Coverage |
|-------|------------------|
| `glossary.md` | Domain terminology definitions |
| `<domain>.md` | Specialized domain knowledge |
| `validation.md` | Domain-specific acceptance criteria |

**Token budget:** ~4000-6000 tokens across all reference files (domain files can be larger)

**Example skills:** `audit-compliance`, `legal-review`, `security-assessment`

**Note:** Domain files may exceed typical token budgets — this is acceptable when the domain knowledge is essential.

#### Profile: Pipeline Component

**Use when:** Skill is explicitly designed as a building block for multi-skill workflows.

| Files | Pattern Coverage |
|-------|------------------|
| `composition.md` | Input/output contracts for chaining |
| `io-contract.md` | Detailed parameter specifications |
| `validation.md` | Output guarantees for downstream skills |

**Token budget:** ~3000-4000 tokens across all reference files

**Example skills:** `extract-entities`, `transform-schema`, `validate-output`

**Note:** Pipeline components should have minimal internal state — prefer stateless transforms.

#### Profile Selection Guide

| If your skill... | Start with Profile |
|------------------|-------------------|
| Has 3+ phases with state persistence | Workflow Skill |
| Delegates to other skills or spawns sub-tasks | Coordinator Skill |
| Requires user approval or choices | Interactive Skill |
| Operates in legal, compliance, finance, security | Domain Expert Skill |
| Is designed for multi-skill composition | Pipeline Component |

**Combining Profiles:** Some skills combine profile characteristics. When this happens:
1. Identify the **primary** profile (the skill's main purpose)
2. Add individual files from secondary profiles as needed
3. Monitor aggregate token budget (see [Complexity Budget](#complexity-budget))

### Complexity Budget

Pattern flexibility means skills can accumulate many reference files. The **complexity budget** provides guardrails to prevent pattern explosion while preserving flexibility.

#### Aggregate Token Limits

Rather than limiting file counts, Harmony limits total reference file tokens:

| Skill Scope | Aggregate Token Budget | Typical File Count |
|-------------|------------------------|-------------------|
| Standard Complex | ~7000 tokens | 2-4 reference files |
| Enterprise Complex | ~12000 tokens | 4-6 reference files |
| Domain Expert | ~15000 tokens | 5-8 reference files (domain knowledge may be extensive) |

**Measurement:** Run `validate-skills.sh` to see aggregate token counts for each skill.

#### Budget Enforcement

Validation tooling provides **warnings** (not errors) when skills approach or exceed complexity thresholds:

| Aggregate Tokens | Validation Response |
|-----------------|---------------------|
| ≤7000 | ✓ Within standard budget |
| 7001-12000 | ⚠ Approaching complexity ceiling — consider splitting or extracting domain files |
| >12000 | ⚠ Exceeds typical budget — ensure all files are essential; consider skill decomposition |

**Why warnings, not errors:** Domain-expert skills may legitimately need extensive documentation. The budget is a code smell detector, not a hard constraint.

#### Reducing Complexity

When aggregate tokens exceed budget:

1. **Check for redundancy** — Are similar concepts documented in multiple files? Consolidate.
2. **Extract domain knowledge** — Move specialized knowledge to `<domain>.md` files that can be shared across skills.
3. **Split the skill** — If complexity is intrinsic, the skill may be doing too much. Consider decomposition.
4. **Challenge file necessity** — For each file, ask: "Would an agent fail without this?" Remove files that merely elaborate.

#### Why Not Limit File Count?

File count limits are problematic:

- A skill with 2 files at 3000 tokens each (6000 total) is heavier than one with 5 files at 800 tokens each (4000 total)
- Domain-expert skills legitimately need more files without being "over-engineered"
- Token budget directly correlates with agent context usage — the actual concern

Token budgets are **functionally meaningful**; file counts are not.

### What "Atomic" Means

**Atomic Architecture** enables focused, reusable skills that do one thing well. The Atomic archetype encompasses several execution patterns:

| Pattern | Description | Example |
|---------|-------------|---------|
| **Transformer** | Converts input from one format or structure to another | `format-json` — reformats JSON with specified style |
| **Validator** | Checks input against rules and returns pass/fail with details | `validate-schema` — validates data against JSON Schema |
| **Generator** | Produces output from parameters without requiring complex input | `generate-uuid` — creates unique identifiers |
| **Extractor** | Pulls specific information from larger input | `extract-keywords` — identifies key terms from text |
| **Calculator** | Computes a value from input parameters | `count-tokens` — counts tokens in text |

**Atomic archetype** (with optional refs) is appropriate when:

- Performs a single, discrete transformation (transformer)
- Validates input against defined rules (validator)
- Generates output from simple parameters (generator)
- Extracts specific data from input (extractor)
- Computes values without side effects (calculator)
- Execution is stateless — no internal phase management
- An agent can infer correct execution from the description

Unlike Complex skills, Atomic skills do **not** combine patterns. An Atomic skill that needs to validate *and then* transform should remain two separate skills, or be upgraded to Complex if the coordination logic is non-trivial.

---

## Archetype Definitions

### Atomic Skill

Single-purpose skills with clear I/O and minimal documentation needs. The "Specialist" — does one thing well.

**Structure:**

```
<skill-name>/
├── SKILL.md              # Core instructions (required)
└── references/           # Optional — add files as needed
    ├── examples.md       # When output format needs demonstration
    ├── errors.md         # When complex failure modes exist
    └── glossary.md       # When domain terminology needs definition
```

**When to use:**

- Skill does one discrete action
- Obvious inputs and outputs (1-2 inputs, 1 output)
- Stateless — no internal phase management
- Output format is self-explanatory (or can be clarified with examples)

**Examples:** `format-json`, `validate-schema`, `count-tokens`, `generate-uuid`, `extract-keywords`, `summarize-text`

**Optional reference files for Atomic skills:**

| File | When to Add | Threshold |
|------|-------------|-----------|
| `examples.md` | Output format needs demonstration | >3 example cases needed |
| `errors.md` | Complex failure modes or external dependencies | >30 lines of error handling |
| `glossary.md` | Domain-specific terminology | >5 terms needing definition |

**Key principle:** Add reference files when they reduce agent confusion. Don't add structure for structure's sake.

**Upgrade to Complex when:** The skill coordinates multiple concerns, maintains state across phases, or requires documented phase transitions.

#### Inline Validation for Atomic Skills

Atomic skills include validation criteria directly in SKILL.md rather than a separate `validation.md` file. Use this template:

```markdown
## Success Criteria

**Output validation:**
- [ ] Output matches expected format (describe format)
- [ ] All required fields are present
- [ ] No error messages in output

**Behavioral validation:**
- [ ] Skill completes without errors
- [ ] Input is not modified
- [ ] Output is deterministic for same input

**Edge cases handled:**
- [ ] Empty input → (expected behavior)
- [ ] Invalid input → (expected error message)
- [ ] Large input → (expected behavior or limits)
```

**Example for `format-json` skill:**

```markdown
## Success Criteria

**Output validation:**
- [ ] Output is valid JSON (parseable)
- [ ] Indentation matches requested style (2-space, 4-space, or tabs)
- [ ] Keys are sorted alphabetically (if `--sort-keys` flag used)

**Behavioral validation:**
- [ ] Original JSON semantics preserved (no data loss)
- [ ] Whitespace-only changes (no value modifications)

**Edge cases handled:**
- [ ] Empty object `{}` → Returns `{}`
- [ ] Invalid JSON → Returns error: "Invalid JSON: {parse error details}"
- [ ] Input >1MB → Returns error: "Input exceeds 1MB limit"
```

This inline approach keeps Atomic skills self-contained while providing clear verification criteria.

---

### Complex Skill

Multi-phase execution skills with defined steps, examples, and validation criteria. The "Strategist" — coordinates multiple concerns.

**Structure:**

```
<skill-name>/
├── SKILL.md              # Core instructions (<500 lines)
├── references/           # At least one pattern-triggered file required
│   ├── io-contract.md    # When: non-trivial I/O (>2 inputs OR structured output)
│   ├── behaviors.md      # When: distinct phases with transitions
│   ├── safety.md         # When: tool/file policies need documentation
│   ├── examples.md       # When: output format needs demonstration
│   ├── validation.md     # When: formal acceptance criteria exist
│   ├── checkpoints.md    # When: state persists across phases (Stateful)
│   ├── orchestration.md  # When: coordinates sub-tasks (Orchestrated)
│   ├── decisions.md      # When: branching logic exists (Phased)
│   ├── interaction.md    # When: human-in-the-loop (Interactive)
│   ├── agents.md         # When: spawns sub-agents (Agentic)
│   ├── composition.md    # When: designed for pipelines (Composable)
│   ├── errors.md         # When: complex error handling needed
│   ├── glossary.md       # When: domain terminology (>5 terms)
│   └── <domain>.md       # When: specialized domain knowledge needed
├── scripts/              # Optional: executable code
└── assets/               # Optional: static resources
```

**When to use:**

- Coordinates multiple sub-tasks or concerns
- Maintains state across phases (checkpoints, intermediate outputs)
- Requires documented phase transitions for correct execution
- Has safety constraints that need formal documentation
- Skills that will be maintained over time

**Examples:** `refine-prompt`, `synthesize-research`, `code-reviewer`, `audit-compliance`

**Pattern-triggered reference files:**

Complex skills must have **at least one** reference file. Add files based on which patterns your skill exhibits:

| Pattern | Trigger | File to Add | Key Question |
|---------|---------|-------------|--------------|
| Non-trivial I/O | >2 inputs OR structured output | `io-contract.md` | "What does it accept and produce?" |
| Distinct phases | ≥2 phases with transitions | `behaviors.md` | "What happens during execution?" |
| Tool/file policies | Restricted operations | `safety.md` | "What can it do and not do?" |
| Output demonstration | Format needs examples | `examples.md` | "What does it look like in practice?" |
| Quality gates | Formal acceptance criteria | `validation.md` | "How do I know it worked?" |
| Stateful | State persists across phases | `checkpoints.md` | "How is state preserved?" |
| Orchestrated | Coordinates sub-tasks | `orchestration.md` | "How are sub-tasks coordinated?" |
| Phased | Branching logic | `decisions.md` | "What determines execution path?" |
| Interactive | Human-in-the-loop | `interaction.md` | "Where does user input occur?" |
| Agentic | Spawns sub-agents | `agents.md` | "How is agent work coordinated?" |
| Composable | Pipeline building block | `composition.md` | "How does this chain with others?" |
| Complex errors | Recovery procedures | `errors.md` | "What happens when something goes wrong?" |
| Domain-specific | >5 domain terms | `glossary.md` | "What do these terms mean?" |
| Specialized knowledge | Domain expertise needed | `<domain>.md` | "What domain knowledge is needed?" |

> **Validation Rule:** Complex skills are valid if they have at least one pattern-triggered reference file. This ensures the archetype distinction is meaningful while allowing simpler Complex skills to avoid unnecessary scaffolding.

---

## Optional Pattern-Specific Reference Files

These files support specific Complex capability patterns. Add them based on which patterns your skill exhibits.

### `checkpoints.md` — State Management (Stateful Pattern)

**Purpose:** Documents how state is preserved across phases, enabling recovery from interruption and audit of intermediate results.

**When to Add:** Skill maintains state across phases, supports checkpoint/resume, or produces intermediate outputs that must persist.

**YAML Schema:**

```yaml
---
checkpoints:
  strategy: phase | step | time-based    # When checkpoints are created
  storage: ".workspace/skills/runs/{{skill-id}}/{{run-id}}/"
  retention: session | permanent         # How long checkpoints persist

  schema:
    - name: "phase_1_complete"
      trigger: "After Phase 1 completes"
      contains:
        - "input_hash"                   # Hash of original input
        - "gathered_context"             # Intermediate data
        - "decisions_made"               # Choices recorded

    - name: "phase_2_complete"
      trigger: "After Phase 2 completes"
      contains:
        - "transformed_data"
        - "validation_results"

recovery:
  on_resume: "Load latest checkpoint, verify input unchanged, continue from saved phase"
  on_input_change: "Warn user, offer to restart or continue with stale context"
  on_corruption: "Log error, restart from beginning, preserve corrupted checkpoint for debugging"
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Checkpoint Strategy` | When and why checkpoints are created |
| `## State Schema` | What data is preserved at each checkpoint |
| `## Recovery Procedures` | How to resume from interruption |
| `## Intermediate Outputs` | Files produced during execution (not just final output) |

---

### `orchestration.md` — Sub-task Coordination (Orchestrated Pattern)

**Purpose:** Documents how the skill coordinates multiple sub-tasks, delegates to other skills, or manages parallel concerns.

**When to Add:** Skill coordinates multiple sub-skills, manages parallel execution, or has complex dependency relationships between sub-tasks.

**YAML Schema:**

```yaml
---
orchestration:
  pattern: sequential | parallel | dag    # How sub-tasks are coordinated

  sub_tasks:
    - id: "gather_context"
      description: "Collect relevant codebase information"
      delegates_to: null                  # Inline execution
      inputs: ["user_prompt", "codebase_path"]
      outputs: ["context_summary"]

    - id: "analyze_requirements"
      description: "Extract actionable requirements"
      delegates_to: "extract-requirements" # Delegates to another skill
      inputs: ["context_summary", "user_prompt"]
      outputs: ["requirements_list"]
      depends_on: ["gather_context"]

    - id: "validate_approach"
      description: "Verify proposed approach is sound"
      delegates_to: null
      inputs: ["requirements_list", "context_summary"]
      outputs: ["validation_result"]
      depends_on: ["analyze_requirements"]

  coordination:
    failure_handling: fail-fast | continue | retry
    timeout_per_task: 300000              # ms, optional
    max_parallel: 3                       # For parallel patterns
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Orchestration Pattern` | Sequential, parallel, or DAG-based coordination |
| `## Sub-task Definitions` | Each sub-task with inputs, outputs, dependencies |
| `## Delegation Rules` | When and how to delegate to other skills |
| `## Failure Handling` | What happens when a sub-task fails |
| `## Coordination Diagram` | Visual representation of task flow (optional) |

---

### `decisions.md` — Branching Logic (Phased/Procedural Pattern)

**Purpose:** Documents conditional execution paths, decision points, and branching logic within the skill.

**When to Add:** Skill has multiple execution paths based on input characteristics, intermediate results, or user choices.

**YAML Schema:**

```yaml
---
decisions:
  - id: "scope_classification"
    point: "Phase 1: Scope Analysis"
    question: "What is the scope of the requested change?"
    branches:
      - condition: "Single file, <50 lines affected"
        label: "minor"
        next_phase: "Phase 2a: Quick Edit"

      - condition: "Multiple files, <500 lines affected"
        label: "moderate"
        next_phase: "Phase 2b: Standard Refactor"

      - condition: ">500 lines OR architectural change"
        label: "major"
        next_phase: "Phase 2c: Comprehensive Audit"
        escalate: true

  - id: "validation_result"
    point: "Phase 4: Validation"
    question: "Did all validations pass?"
    branches:
      - condition: "All checks pass"
        label: "success"
        next_phase: "Phase 5: Output"

      - condition: "Recoverable failures"
        label: "retry"
        next_phase: "Phase 3: Execute (retry)"
        max_retries: 2

      - condition: "Unrecoverable failures"
        label: "abort"
        next_phase: "Escalate to user"

default_path: ["Phase 1", "Phase 2b", "Phase 3", "Phase 4", "Phase 5"]
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Decision Points` | Each branch point with conditions and outcomes |
| `## Execution Paths` | Named paths through the skill (happy path, edge cases) |
| `## Escalation Triggers` | Conditions that require user intervention |
| `## Decision Tree` | Visual flowchart of branching logic (optional) |

---

### `composition.md` — Building Block Design (Composable Pattern)

**Purpose:** Documents how the skill is designed to be composed with other skills, including input/output compatibility and pipeline integration points.

**When to Add:** Skill is explicitly designed as a building block for pipelines or multi-skill workflows.

#### Orchestration vs Composition vs Agents: Clarifying the Distinction

These three patterns address different coordination concerns. Understanding when to use each prevents confusion and file bloat.

**The Core Question Each Pattern Answers:**

| Pattern | Core Question | Focus |
|---------|---------------|-------|
| **Orchestration** | "How does this skill break down its work internally?" | Internal sub-task coordination |
| **Composition** | "How does this skill fit into a larger pipeline?" | External skill-to-skill interfaces |
| **Agents** | "Does this skill spawn other agents to do work?" | Agent-level parallelism and delegation |

**Key Distinctions:**

| Aspect | Orchestration | Composition | Agents |
|--------|---------------|-------------|--------|
| **Scope** | Within the skill | Between skills | Between agent instances |
| **Coordination level** | Sub-tasks (logical) | Skills (functional) | Agents (runtime) |
| **Who does the work** | This skill | Other skills | Other agents |
| **When determined** | Design time | Design time | Runtime |
| **Parallelism** | Optional (DAG) | N/A (sequential pipeline) | Primary use case |
| **Documents** | Sub-task dependencies | I/O compatibility | Spawn/collect patterns |

**Decision Flowchart:**

```text
Does your skill break work into sub-tasks internally?
  └─ YES → Does it delegate those sub-tasks to other SKILLS?
              └─ YES → Does it call skills by name/ID? → orchestration.md
              └─ NO → Are sub-tasks just logical phases? → behaviors.md (not orchestration)
  └─ NO → Skip orchestration.md

Is your skill designed to chain with specific other skills?
  └─ YES → Does it explicitly define compatible inputs_from/outputs_to? → composition.md
  └─ NO → Skip composition.md (skill is standalone)

Does your skill spawn independent agent processes?
  └─ YES → Do those agents run in parallel? → agents.md
           └─ Must results be merged? → agents.md (with coordination strategy)
  └─ NO → Skip agents.md
```

**Common Confusion Scenarios:**

| Scenario | Wrong Choice | Right Choice | Why |
|----------|--------------|--------------|-----|
| Skill has 5 phases documented in behaviors.md | Add orchestration.md | Keep behaviors.md only | Phases aren't sub-tasks—they're sequential steps |
| Skill calls `extract-keywords` as a helper | Add composition.md | Add orchestration.md | This is internal delegation, not pipeline design |
| Skill output could be used by other skills | Add composition.md | Skip it | "Could be used" ≠ "designed for pipelines" |
| Skill uses Task tool to spawn parallel workers | Add orchestration.md | Add agents.md | Task tool spawns agents, not sub-tasks |
| Skill coordinates 3 sub-agents that do different things | Add orchestration.md | Add both | Sub-agents need agents.md; their coordination needs orchestration.md |

**When to Use Multiple Files:**

| Combination | When Appropriate | Example |
|-------------|------------------|---------|
| `orchestration.md` + `composition.md` | Complex internal flow AND designed for pipelines | `synthesize-research`: internal phases + receives from `gather-sources` |
| `orchestration.md` + `agents.md` | Coordinates sub-tasks, some via sub-agents | `code-review`: orchestrates review phases, spawns parallel analyzers |
| `composition.md` + `agents.md` | Pipeline component that spawns agents | `parallel-transform`: pipeline stage that fans out to workers |
| All three | Rare—reconsider if skill is too complex | Consider breaking into multiple skills |

**Anti-patterns:**

- **Orchestration for linear flow:** If sub-tasks always run sequentially with no dependencies, use `behaviors.md` instead
- **Composition for potential reuse:** Don't add `composition.md` just because the skill "might" be used in a pipeline
- **Agents for delegation:** If you're delegating to other skills (not spawning agents), use `orchestration.md`
- **All three files by default:** Each file should be justified by the pattern checklist questions above

#### Example: When Each File Applies

**Standalone skill with phases (behaviors.md only):**

```text
refine-prompt: Gather context → Assign persona → Refine → Output
→ This is sequential phases, not orchestrated sub-tasks
→ behaviors.md documents the phases, no orchestration.md needed
```

**Skill that delegates internally (orchestration.md):**

```text
audit-compliance:
  Sub-tasks: gather-evidence, analyze-controls, generate-report
  Dependencies: analyze depends on gather, report depends on analyze
→ orchestration.md documents sub-task graph
```

**Skill designed for pipelines (composition.md):**

```text
extract-entities:
  Inputs from: parse-document (document_ast)
  Outputs to: enrich-entities (entity_list)
→ composition.md documents pipeline contracts
```

**Skill that spawns agents (agents.md):**

```text
parallel-file-analysis:
  Spawns: 1 agent per file for parallel analysis
  Collects: Results merged into unified report
→ agents.md documents spawn/collect pattern
```

**YAML Schema:**

```yaml
---
composition:
  role: source | transformer | sink    # Position in typical pipelines

  compatible_with:
    inputs_from:
      - skill_id: "gather-sources"
        output_field: "sources_list"
        description: "Accepts source list from gather-sources skill"

    outputs_to:
      - skill_id: "generate-report"
        input_field: "synthesis_document"
        description: "Produces synthesis for report generation"

  integration_points:
    - name: "pre_execution_hook"
      type: optional
      description: "Called before execution begins"

    - name: "post_execution_hook"
      type: optional
      description: "Called after execution completes"

  pipeline_examples:
    - name: "Full Research Pipeline"
      skills: ["gather-sources", "synthesize-research", "generate-report"]
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Composition Role` | Source, transformer, or sink in pipeline context |
| `## Input Compatibility` | Skills that can feed into this skill |
| `## Output Compatibility` | Skills that can consume this skill's output |
| `## Integration Points` | Hooks or extension points for customization |
| `## Pipeline Examples` | Example pipelines that include this skill |

---

### `agents.md` — Sub-Agent Coordination (Agentic Pattern)

**Purpose:** Documents how the skill spawns or coordinates sub-agents for parallel work or specialized tasks.

**Status:** Current pattern. Add when implementing skills that delegate to sub-agents.

**When to Add:** Skill needs to spawn sub-agents, coordinate parallel agent work, or delegate specialized tasks to other agents.

**YAML Schema:**

```yaml
---
agents:
  pattern: spawn | delegate | coordinate    # How agents are used

  sub_agents:
    - id: "code_reviewer"
      purpose: "Review code changes for quality"
      delegation_type: parallel | sequential
      timeout: 300000

    - id: "test_writer"
      purpose: "Generate test cases"
      delegation_type: parallel
      depends_on: ["code_reviewer"]

  coordination:
    strategy: fan-out-fan-in | pipeline | hierarchical
    failure_handling: fail-fast | continue | retry
    max_concurrent: 3
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Agent Pattern` | How sub-agents are used (spawn, delegate, coordinate) |
| `## Sub-Agent Definitions` | Each sub-agent with purpose and delegation type |
| `## Coordination Strategy` | How results are collected and merged |
| `## Failure Handling` | What happens when a sub-agent fails |

**Agent Patterns Explained:**

| Pattern | Description | Use When | Example |
|---------|-------------|----------|---------|
| **spawn** | Creates new agent instances for parallel execution | Independent tasks that can run simultaneously | Analyzing multiple files in parallel |
| **delegate** | Passes work to specialized agents | Task requires expertise the parent skill lacks | Delegating code review to a specialized reviewer agent |
| **coordinate** | Orchestrates multiple agents with dependencies | Complex workflows with inter-agent dependencies | Multi-stage analysis where results feed into next stage |

**Coordination Strategies:**

| Strategy | Flow | Best For |
|----------|------|----------|
| **fan-out-fan-in** | Distribute → Parallel execution → Collect results | Parallelizable independent tasks (e.g., analyze 10 files) |
| **pipeline** | Agent A → Agent B → Agent C (sequential chain) | Each agent transforms previous output |
| **hierarchical** | Parent coordinates children, children may have sub-children | Nested delegation with multiple levels |

#### Example: Code Review Skill with Sub-Agents

```yaml
---
agents:
  pattern: coordinate

  sub_agents:
    - id: "security_scanner"
      purpose: "Scan for security vulnerabilities"
      delegation_type: parallel
      timeout: 120000

    - id: "style_checker"
      purpose: "Check code style and formatting"
      delegation_type: parallel
      timeout: 60000

    - id: "logic_reviewer"
      purpose: "Review business logic and algorithms"
      delegation_type: parallel
      timeout: 180000

    - id: "report_synthesizer"
      purpose: "Combine all reviews into unified report"
      delegation_type: sequential
      depends_on: ["security_scanner", "style_checker", "logic_reviewer"]
      timeout: 60000

  coordination:
    strategy: fan-out-fan-in
    failure_handling: continue    # Continue even if one scanner fails
    max_concurrent: 3
---
```

**Key Design Decisions:**

1. **Timeout per agent:** Set realistic timeouts based on expected work. Security scanning may need longer than style checking.
2. **Failure handling:** Use `fail-fast` for critical dependencies, `continue` when partial results are acceptable.
3. **Max concurrent:** Limit to prevent resource exhaustion. Consider API rate limits and memory constraints.
4. **Dependencies:** Ensure `depends_on` creates a valid DAG (no cycles).

---

### `interaction.md` — Human-in-the-Loop (Interactive Pattern)

**Purpose:** Documents interaction points where the skill requires human input at runtime, including decision gates and approval workflows.

**Status:** Current pattern. Add when implementing skills that require runtime user decisions.

**When to Add:** Skill has decision points requiring user input, approval gates, or interactive refinement loops.

**YAML Schema:**

```yaml
---
interaction:
  pattern: approval | decision | iterative    # Type of interaction

  interaction_points:
    - id: "scope_approval"
      phase: 2
      type: approval
      question: "Proceed with this scope?"
      options: ["Yes", "No", "Modify"]
      required: true
      timeout: null    # Wait indefinitely

    - id: "ambiguity_resolution"
      phase: 3
      type: decision
      question: "Which interpretation is correct?"
      options: dynamic    # Generated at runtime
      required: true

  fallback:
    on_timeout: abort | use_default | escalate
    default_option: null
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Interaction Pattern` | Type of human interaction (approval, decision, iterative) |
| `## Interaction Points` | Each point where user input is required |
| `## User Prompts` | Templates for user-facing questions |
| `## Fallback Behavior` | What happens if user doesn't respond |
| `## Decision Flow` | Visual diagram of interaction points (optional) |

**Interaction Patterns Explained:**

| Pattern | Description | Use When | Example |
|---------|-------------|----------|---------|
| **approval** | Binary yes/no gate before proceeding | High-stakes actions that need explicit consent | "Proceed with deleting 47 files?" |
| **decision** | User chooses between multiple options | Multiple valid approaches, user preference matters | "Which refactoring strategy: A, B, or C?" |
| **iterative** | Refinement loop until user is satisfied | Quality-sensitive output that benefits from feedback | "Is this summary acceptable? [Accept/Revise]" |

**Interaction Types:**

| Type | Options | When to Use |
|------|---------|-------------|
| **approval** | Yes / No / Modify | Confirming scope, approving changes, proceeding past warnings |
| **decision** | 2-5 predefined choices | Selecting approach, choosing format, picking priority |
| **input** | Free-form text | Providing additional context, clarifying ambiguity |

#### Example: Refactor Skill with Approval Gates

```yaml
---
interaction:
  pattern: approval

  interaction_points:
    - id: "scope_approval"
      phase: 2
      type: approval
      question: "The refactor will modify {{file_count}} files. Proceed?"
      options: ["Yes, proceed", "No, cancel", "Show me the files first"]
      required: true
      timeout: null

    - id: "destructive_warning"
      phase: 3
      type: approval
      question: "This will rename {{symbol}} across the codebase. This cannot be undone. Continue?"
      options: ["Yes, I understand", "No, abort"]
      required: true
      timeout: 300000    # 5 minute timeout

    - id: "verification_review"
      phase: 5
      type: decision
      question: "Verification found {{issue_count}} potential issues. How to proceed?"
      options: ["Fix automatically", "Review each issue", "Ignore and complete", "Abort refactor"]
      required: true
      timeout: null

  fallback:
    on_timeout: abort
    default_option: null
---
```

#### Example: Interactive Research Synthesis

```yaml
---
interaction:
  pattern: iterative

  interaction_points:
    - id: "theme_selection"
      phase: 2
      type: decision
      question: "I identified these themes. Which should I focus on?"
      options: dynamic    # Generated from discovered themes
      required: true
      timeout: null

    - id: "draft_review"
      phase: 4
      type: iterative
      question: "Here's the draft synthesis. Is this acceptable?"
      options: ["Accept", "Revise focus", "Add more detail", "Shorten"]
      required: true
      max_iterations: 3    # Prevent infinite loops
      timeout: null

  fallback:
    on_timeout: use_default
    default_option: "Accept"    # After 3 iterations, accept current draft
---
```

#### Example: Database Migration with Safety Gates

A skill that modifies database schema needs multiple approval points due to the irreversible nature of migrations.

```yaml
---
interaction:
  pattern: approval

  interaction_points:
    - id: "dry_run_review"
      phase: 2
      type: approval
      question: |
        Migration preview complete. Changes:
        - Add column: users.last_login_at (timestamp)
        - Drop column: users.legacy_flag (boolean, 1,247 rows have data)
        - Add index: idx_users_email

        The DROP COLUMN will delete data. Proceed to production?
      options: ["Yes, I have backups", "No, abort", "Run on staging first"]
      required: true
      timeout: null
      context_required: ["backup_verified", "staging_tested"]

    - id: "post_migration_verify"
      phase: 4
      type: decision
      question: "Migration complete. Verification shows 3 slow queries. How to proceed?"
      options:
        - "Rollback immediately"
        - "Keep changes, optimize queries later"
        - "Keep changes, add indexes now"
      required: true
      timeout: 600000    # 10 minutes - urgent decision

  fallback:
    on_timeout: abort    # Never auto-proceed with DB changes
    default_option: null
---
```

**Key insight:** For destructive operations, use `timeout: null` to force explicit decisions. Never auto-proceed.

#### Example: Code Review with Iterative Feedback

A skill that reviews code and suggests changes, iterating based on author feedback.

```yaml
---
interaction:
  pattern: iterative

  interaction_points:
    - id: "severity_calibration"
      phase: 1
      type: decision
      question: "What level of feedback do you want?"
      options:
        - "Critical issues only"
        - "Critical + warnings"
        - "Everything including style"
      required: true
      timeout: 30000    # Quick decision, default if no response

    - id: "finding_review"
      phase: 3
      type: iterative
      question: |
        Found {{finding_count}} issues:
        - {{critical_count}} critical
        - {{warning_count}} warnings
        - {{style_count}} style suggestions

        Review each finding?
      options:
        - "Show critical only"
        - "Show all findings"
        - "Accept all suggestions"
        - "Dismiss all"
      required: false    # Can skip to summary
      max_iterations: 1

    - id: "per_finding_action"
      phase: 3
      type: iterative
      question: "{{finding_description}}\n\nAction?"
      options:
        - "Fix this"
        - "Skip this"
        - "Fix all similar"
        - "Stop reviewing"
      required: true
      max_iterations: 50    # Cap at 50 findings
      exit_on: "Stop reviewing"

  fallback:
    on_timeout: use_default
    default_option: "Skip this"
---
```

**Key insight:** Use `exit_on` to allow users to break out of long iterative loops.

#### Example: Multi-Stakeholder Approval Workflow

A skill that requires sign-off from multiple parties (common in enterprise settings).

```yaml
---
interaction:
  pattern: approval

  interaction_points:
    - id: "author_confirmation"
      phase: 2
      type: approval
      question: "You're about to publish {{doc_name}} to production docs. Confirm?"
      options: ["Confirm", "Cancel"]
      required: true
      role: author
      timeout: null

    - id: "tech_review"
      phase: 3
      type: approval
      question: "Technical review required for {{doc_name}}. Accuracy verified?"
      options: ["Approved", "Needs revision", "Escalate to architect"]
      required: true
      role: tech_reviewer
      timeout: 172800000    # 48 hours
      notify: ["tech-reviewers@company.com"]

    - id: "legal_review"
      phase: 4
      type: approval
      question: "Legal review for {{doc_name}}. Cleared for publication?"
      options: ["Approved", "Requires changes", "Hold for legal consultation"]
      required: true
      role: legal
      timeout: 604800000    # 7 days
      skip_if: "doc_type != 'external'"

  fallback:
    on_timeout: escalate
    escalate_to: "doc-admins@company.com"
---
```

**Key insight:** Use `role` to specify which user role should respond. Use `skip_if` for conditional interaction points.

#### Example: Guided Wizard with Dependent Questions

A skill that walks users through a complex setup process where later questions depend on earlier answers.

```yaml
---
interaction:
  pattern: decision

  interaction_points:
    - id: "deployment_target"
      phase: 1
      type: decision
      question: "Where will this application be deployed?"
      options:
        - label: "AWS"
          next_questions: ["aws_region", "aws_service"]
        - label: "GCP"
          next_questions: ["gcp_region", "gcp_service"]
        - label: "On-premises"
          next_questions: ["server_specs"]
        - label: "Local development only"
          next_questions: []
      required: true

    - id: "aws_region"
      phase: 1
      type: decision
      question: "Which AWS region?"
      options: ["us-east-1", "us-west-2", "eu-west-1", "ap-southeast-1"]
      required: true
      depends_on: "deployment_target == 'AWS'"

    - id: "aws_service"
      phase: 1
      type: decision
      question: "Which AWS compute service?"
      options:
        - label: "ECS Fargate"
          sets: { container_runtime: "docker", serverless: true }
        - label: "EC2"
          sets: { container_runtime: "none", serverless: false }
        - label: "Lambda"
          sets: { container_runtime: "none", serverless: true }
      required: true
      depends_on: "deployment_target == 'AWS'"

  fallback:
    on_timeout: abort
    default_option: null
---
```

**Key insight:** Use `depends_on` for conditional questions and `sets` to capture structured data from choices.

**Key Design Decisions:**

1. **Timeout handling:** Use `null` for critical decisions, set timeouts for non-blocking workflows.
2. **Required vs optional:** Mark approval gates as `required: true`; informational prompts can be `required: false`.
3. **Max iterations:** For iterative patterns, set a limit to prevent infinite refinement loops.
4. **Fallback behavior:** Choose based on risk—use `abort` for destructive actions, `use_default` for recoverable situations.
5. **Dynamic options:** Use `options: dynamic` when choices depend on runtime analysis results.

---

## Optional Domain-Oriented Reference Files

For Complex skills operating in specialized domains, add these optional files as needed:

| Domain | Artifact | Purpose |
|--------|----------|---------|
| **Finance** | `finance.md` | Regulations, calculation methods, audit requirements, reporting standards |
| **Legal** | `legal.md` | Jurisdiction rules, document types, privilege handling, citation formats |
| **Security** | `security.md` | Threat models, control frameworks, evidence collection, vulnerability handling |
| **Compliance** | `compliance.md` | Framework mappings (SOC2, HIPAA, PCI), evidence types, audit trails |
| **Healthcare** | `hipaa.md` | PHI handling, consent requirements, audit trails, de-identification rules |
| **Data** | `data.md` | Schema definitions, transformation rules, quality metrics, lineage |
| *Custom* | `<domain>.md` | Any domain-specific reference material |

**When to add domain files:**

- Skill operates in a regulated or specialized domain
- Domain-specific terminology needs consistent definitions
- Compliance or audit trail requirements exist
- External dependencies may fail and need formal error handling

**Creating domain artifacts:**

1. Identify domain-specific knowledge the skill requires
2. Create `<domain>.md` with terminology, rules, and constraints
3. Reference the domain file from SKILL.md and behaviors.md
4. Add `glossary.md` with domain terms if terminology consistency is needed
5. Add `errors.md` if formal error codes and recovery procedures are required

### Domain File Extraction Heuristics

Extract content from `safety.md` to a domain-specific file when:

| Trigger | Threshold | Action |
|---------|-----------|--------|
| **Size** | `safety.md` exceeds 100 lines AND >30 lines are domain-specific | Extract domain content |
| **Terminology** | >5 domain terms requiring definitions | Create `glossary.md` |
| **Content type mismatch** | Implementation details (algorithms, patterns) mixed with constraints | Extract implementation to domain file |

### Content Type Reference

| Content Type | Belongs In | Example |
|--------------|------------|---------|
| **Constraints** (must/must-not rules) | `safety.md` | "Never auto-commit changes" |
| **Policies** (tool/file permissions) | `safety.md` | "Write only to `logs/` and `runs/`" |
| **Algorithms** (how to detect/process) | Domain file | Detection algorithm for file patterns |
| **Pattern lists** (what to match) | Domain file | File path patterns, regex rules |
| **Rationale** (why rules exist) | Domain file (if >10 lines) | Why certain files are protected |
| **Recovery procedures** | `errors.md` | Steps to recover from partial execution |

### Example: When to Extract

A skill's `safety.md` contains "Protected File Patterns" (~45 lines including patterns, detection algorithm, and rationale). This is **implementation detail** (how to detect protected files) rather than **constraint** (what the skill must not do).

**Keep in `safety.md`:**

- "Must never modify protected files"
- "Stop and escalate if protected file modification detected"

**Extract to domain file:**

- Pattern list for protected files
- Detection algorithm
- Rationale for why files are protected

---

## Validation Expectations by Archetype

Each archetype has different expectations for how skill execution is validated:

| Archetype | Validation Approach | Where Documented |
|-----------|---------------------|------------------|
| **Atomic** | Inline success criteria | SKILL.md (e.g., "Success: output is valid JSON") |
| **Atomic** (with `examples.md`) | Examples as additional test cases | `examples.md` — output should match demonstrated patterns |
| **Complex** | Formal acceptance checklist | `validation.md` — explicit criteria for each phase |

### Atomic Skills

For Atomic skills, include a brief success criterion in SKILL.md:

```markdown
## Success Criteria

- Output is valid JSON
- All input fields are preserved
- Formatting matches specified style
```

If the skill includes `examples.md`, those examples serve as additional implicit test cases. The agent should produce output that matches the demonstrated patterns. Include at least one example for:

- Typical input → expected output
- Edge case input → expected handling

### Complex Skills

Complex skills require formal validation in `validation.md`:

- Acceptance criteria for each phase
- Quality checklist for final output
- Error conditions and expected handling

---

## File Classification Summary

**Pattern-triggered Complex files:**

Complex skills must have **at least one** reference file. Add files based on exhibited patterns:

| File | Pattern Trigger | Purpose |
|------|-----------------|---------|
| `io-contract.md` | Non-trivial I/O (>2 inputs OR structured output) | Input/output specifications, dependencies, CLI usage |
| `behaviors.md` | Distinct phases (≥2 with transitions) | Phase-by-phase execution workflow |
| `safety.md` | Tool/file policies need documentation | Tool permissions, file policies, behavioral boundaries |
| `examples.md` | Output format needs demonstration | Complete worked examples demonstrating skill behavior |
| `validation.md` | Formal acceptance criteria exist | Acceptance criteria and quality checklist |
| `checkpoints.md` | Stateful (state persists across phases) | State schema, recovery points, intermediate outputs |
| `orchestration.md` | Orchestrated (coordinates sub-tasks) | Sub-task coordination, delegation, dependency graphs |
| `decisions.md` | Phased (branching logic) | Branching logic, conditional paths, decision trees |
| `interaction.md` | Interactive (human-in-the-loop) | Human-in-the-loop points, approval gates |
| `agents.md` | Agentic (spawns sub-agents) | Sub-agent coordination, delegation patterns |
| `composition.md` | Composable (pipeline building block) | Building block design, pipeline integration points |
| `errors.md` | Complex error handling needed | Error codes, recovery procedures, troubleshooting |
| `glossary.md` | Domain-specific (>5 terms) | Domain-specific terminology definitions |
| `<domain>.md` | Specialized knowledge needed | Domain-specific reference material |

**Optional Atomic files:**

| File | When to Add | Purpose |
|------|-------------|---------|
| `examples.md` | Output format needs demonstration | Worked examples |
| `errors.md` | Complex failure modes exist | Error handling |
| `glossary.md` | >5 domain terms | Terminology definitions |

> **Note:** For Atomic skills, reference files are optional—add them when they reduce agent confusion. For Complex skills, at least one pattern-triggered file is required. The archetype distinction is based on documentation needs, not arbitrary file requirements.

**Single Source of Truth:** Commands, triggers, and tool requirements (`allowed-tools`) are defined in `manifest.yml` and `SKILL.md` frontmatter for machine routing. Reference files document these values in prose but do NOT duplicate them in YAML frontmatter. This prevents drift between multiple sources.

---

## Directory Structure by Archetype

### Atomic

```
<skill-name>/
├── SKILL.md              # Required: core instructions
└── references/           # Optional: add files as needed
    ├── examples.md       # Optional: when output format needs demonstration
    ├── errors.md         # Optional: when complex failure modes exist
    └── glossary.md       # Optional: when domain terminology needs definition
```

### Complex

```
<skill-name>/
├── SKILL.md              # Required: core instructions (<500 lines)
├── references/           # At least one pattern-triggered file required
│   ├── io-contract.md    # When: non-trivial I/O
│   ├── behaviors.md      # When: distinct phases
│   ├── safety.md         # When: tool/file policies
│   ├── examples.md       # When: output needs demonstration
│   ├── validation.md     # When: formal acceptance criteria
│   ├── checkpoints.md    # When: stateful (state persists)
│   ├── orchestration.md  # When: orchestrated (sub-tasks)
│   ├── decisions.md      # When: phased (branching logic)
│   ├── interaction.md    # When: interactive (human-in-the-loop)
│   ├── agents.md         # When: agentic (sub-agents)
│   ├── composition.md    # When: composable (pipeline)
│   ├── errors.md         # When: complex error handling
│   ├── glossary.md       # When: domain terms (>5)
│   └── <domain>.md       # When: specialized knowledge
├── scripts/              # Optional: executable code
└── assets/               # Optional: static resources
```

**Note:** Invocation patterns (commands, triggers) are defined in `manifest.yml` at the skill collection level. Tool permissions are defined in the `allowed-tools` frontmatter field in SKILL.md. Reference files document these values in prose but do NOT duplicate them to prevent drift.

---

## Reference File Format

Each reference file follows this pattern:

```markdown
---
# YAML frontmatter for machine parsing
field: value
nested:
  - item1
  - item2
---

# Human-Readable Title

Prose explanation of the content.

## Section 1
...
```

The YAML frontmatter provides structured data that agents can parse programmatically, while the Markdown body provides human-readable documentation.

**Design Principle:** Keep individual reference files focused. Agents load these on demand, so smaller files mean less context usage.

---

## Token Budget Guidelines

Reference files should stay within these budgets to ensure efficient context usage:

**Core files:**

| File | Target Budget | Hard Limit | Rationale |
|------|---------------|------------|-----------|
| `SKILL.md` | <2000 tokens | 5000 tokens | Core instructions loaded on every activation |
| `io-contract.md` | <500 tokens | 1000 tokens | Loaded for input validation |
| `safety.md` | <500 tokens | 1000 tokens | Loaded before execution |
| `examples.md` | <1000 tokens | 2000 tokens | Loaded on demand for clarification |
| `behaviors.md` | <800 tokens | 1500 tokens | Loaded during execution |
| `validation.md` | <400 tokens | 800 tokens | Loaded post-execution |

**Pattern-specific files:**

| File | Target Budget | Hard Limit | Rationale |
|------|---------------|------------|-----------|
| `checkpoints.md` | <500 tokens | 1000 tokens | Loaded for state recovery |
| `orchestration.md` | <600 tokens | 1200 tokens | Loaded when coordinating sub-tasks |
| `decisions.md` | <500 tokens | 1000 tokens | Loaded at decision points |

**Domain-oriented files:**

| File | Target Budget | Hard Limit | Rationale |
|------|---------------|------------|-----------|
| `errors.md` | <400 tokens | 800 tokens | Loaded only on error conditions |
| `glossary.md` | <300 tokens | 600 tokens | Loaded when terminology unclear |
| `<domain>.md` | <800 tokens | 1500 tokens | Loaded for domain-specific operations |

**Aggregate budgets by archetype:**

| Archetype                       | Typical Load   | Maximum Load                                              |
|---------------------------------|----------------|-----------------------------------------------------------|
| **Atomic** (minimal)            | ~2000 tokens   | 5000 tokens (SKILL.md only)                               |
| **Atomic** (with optional refs) | ~3000 tokens   | 7000 tokens (SKILL.md + examples/errors/glossary)         |
| **Complex** (minimal)           | ~3500 tokens   | 7500 tokens (SKILL.md + 1-2 pattern-triggered refs)       |
| **Complex** (typical)           | ~5500 tokens   | 11000 tokens (SKILL.md + 3-5 pattern-triggered refs)      |
| **Complex** (with pattern refs) | ~7000 tokens   | 13000 tokens (typical + checkpoints/orchestration/etc.)   |
| **Complex** (full load)         | ~9000 tokens   | 18000 tokens (all files including pattern + domain)       |

**Budget enforcement:**

- Files exceeding target budget should be reviewed for extraction opportunities
- Files exceeding hard limits must be split or content moved to domain-specific files
- Use the extraction heuristics in [Domain File Extraction](#domain-file-extraction-heuristics) when files grow too large

---

## Complex Reference Files

These files apply to **Complex** skills. Copy from the template and fill in skill-specific values. Add files based on which patterns your skill exhibits—Complex skills must have at least one pattern-triggered reference file.

### `io-contract.md` — Input/Output Contract

**Purpose:** Defines what the skill accepts and produces, enabling agents to validate inputs and route outputs correctly.

**When to Load:** When agent needs to validate input format or determine output location.

**YAML Schema:**

```yaml
---
# I/O Contract Documentation
# Note: Tool requirements are authoritative in SKILL.md frontmatter (allowed-tools)
# This file documents the contract for human reference
---
```

**Note:** The YAML frontmatter is minimal. Tool permissions are defined in SKILL.md frontmatter via `allowed-tools` (single source of truth). Dependencies (`depends_on`) are defined in `registry.yml`. The io-contract.md file documents these values in prose but does not duplicate them in frontmatter to prevent drift.

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Inputs` | Table with Name, Type, Required, Description columns |
| `## Outputs` | Subsection per output with path, format, content description |
| `## Output Structure` | Example of expected output format |
| `## Dependencies` | Prose explanation of required tools and external dependencies |
| `## Command-Line Usage` | Invocation examples with parameters and flags |

**Template Usage:**

1. Copy `_template/references/io-contract.md`
2. Replace `[input_name]` placeholders with actual input names
3. Define all outputs with correct paths (use `{{timestamp}}` placeholder)
4. List required tools (start with standard set, add as needed)
5. Add output structure example
6. Add command-line usage examples showing parameter syntax

---

### `safety.md` — Safety Policies

**Purpose:** Defines security boundaries, tool permissions, and behavioral constraints that prevent harmful actions.

**When to Load:** Before execution to verify permissions; when agent encounters boundary condition.

**YAML Schema:**

```yaml
---
# Safety Policy Documentation
# Note: Tool permissions are authoritative in SKILL.md frontmatter (allowed-tools)
# This file documents policies and boundaries for human reference
safety:
  tool_policy:
    mode: deny-by-default         # Always deny-by-default
    # Allowed tools defined in SKILL.md frontmatter (allowed-tools)
  file_policy:
    write_scope:                   # Paths where writing is allowed
      - ".workspace/{{category}}/**"     # Deliverables (final destination)
      - ".workspace/skills/runs/**"      # Execution state (session recovery)
      - ".workspace/skills/logs/**"      # Logs (always allowed)
      # Custom paths as defined in registry I/O mapping
      # Must be within workspace's hierarchical scope
    scope_authority:               # Hierarchical scope rules
      down: allowed                # Can write into descendant workspaces
      up: blocked                  # Cannot write into ancestor workspaces
      sideways: blocked            # Cannot write into sibling workspaces
    destructive_actions: never     # Always 'never'
---
```

**Note:** The `allowed` tools list is NOT included in safety.md frontmatter. Tool permissions are defined in SKILL.md frontmatter via `allowed-tools` as the single source of truth. The safety.md file documents which tools are used in prose but does not duplicate the authoritative list to prevent drift.

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Tool Policy` | Table of allowed tools with purpose for each |
| `## File Policy` | Write scope paths and hierarchical scope authority |
| `## Behavioral Boundaries` | Bulleted list of must/must-not rules |
| `## Escalation Triggers` | Conditions requiring user intervention |

**Universal Content (copy verbatim):**

```markdown
### Destructive Actions

**Policy:** Never

The skill must never:
- Delete files
- Overwrite source code
- Modify files outside designated output paths
- Write to ancestor or sibling workspace paths
```

---

### `examples.md` — Worked Examples

**Purpose:** Provides complete input-to-output examples that demonstrate skill behavior and serve as test cases.

**When to Load:** When user requests examples; when agent needs to understand expected behavior.

**YAML Schema:**

```yaml
---
examples:
  - input: "[raw input]"           # What user provides
    invocation: "[full command]"   # How to invoke with this input
    output: "[output path]"        # Where output is written
    description: "[what this demonstrates]"
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Example N: [Name]` | Descriptive name for each example |
| `### Input` | Code block with invocation command |
| `### Expected Output` | Full example of output content |
| `### Notes` | Edge cases, special behavior, lessons |

**Best Practices:**

| Practice | Rationale |
|----------|-----------|
| Include 2-4 examples | Enough to show range without overwhelming |
| Cover basic and advanced usage | Show both simple and complex scenarios |
| Include option variations | Demonstrate different parameter combinations |
| Show edge cases | Document boundary behavior |
| Keep examples realistic | Use plausible inputs, not lorem ipsum |

---

### `behaviors.md` — Phase-by-Phase Execution

**Purpose:** Documents the detailed execution workflow — what the skill does in each phase, in what order, and why.

**When to Load:** When agent needs detailed execution guidance; during debugging or optimization.

**YAML Schema:**

```yaml
---
behavior:
  phases:
    - name: "[Phase Name]"         # Human-readable phase name
      steps:
        - "[Step 1]"               # Discrete action within phase
        - "[Step 2]"
        - "[Step 3]"
    - name: "Output"               # Final phase (universal)
      steps:
        - "Save deliverable to .workspace/{{category}}/{{timestamp}}-{{name}}.md"
        - "Log to logs/{{skill-id}}/{{run-id}}.md"
  goals:
    - "[Primary goal]"             # What the skill aims to achieve
    - "[Secondary goal]"
---
```

**Universal Elements (copy from template):**

```yaml
- name: "Output"
  steps:
    - "Structure output with all context"
    - "Save to .workspace/{{category}}/{{timestamp}}-{{name}}.md"
    - "Log execution to logs/{{skill-id}}/{{run-id}}.md"
```

**Customization Guide:**

| Element | How to Customize |
|---------|------------------|
| Phase names | Use action-oriented names: "Context Analysis", "Transformation", "Validation" |
| Steps | 2-5 steps per phase; each step is a discrete, verifiable action |
| Goals | 2-5 goals; order by priority |
| Reference tables | Add lookup tables for categories, levels, patterns as needed |

**Phase Design Patterns:**

| Pattern | When to Use | Example Phases |
|---------|-------------|----------------|
| **Linear** | Sequential steps, no branching | Gather → Transform → Output |
| **Analysis-First** | Needs context before action | Analyze → Plan → Execute → Output |
| **Iterative** | Refinement through cycles | Draft → Critique → Revise → Output |
| **Validation-Heavy** | High-risk outputs | Execute → Validate → Confirm → Output |

---

### `validation.md` — Acceptance Criteria

**Purpose:** Defines what constitutes successful execution — the criteria that must be met for output to be valid.

**When to Load:** After execution to verify success; when defining test cases.

**YAML Schema:**

```yaml
---
acceptance_criteria:
  - "[Skill-specific criterion 1]"
  - "[Skill-specific criterion 2]"
  - "Output exists in .workspace/{{category}}/"   # Universal
  - "Run log captures input, context, and output"  # Universal
---
```

**Universal Criteria (always include):**

```yaml
acceptance_criteria:
  - "Output exists in .workspace/{{category}}/"
  - "Run log captures input, context, and output"
  - "No errors during execution"
  - "Output follows expected format"
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Acceptance Criteria` | Checklist (checkbox format) of all criteria |
| `## Quality Checklist` | Subsections for Completeness, Accuracy, Format |
| `## Validation Rules` | Output requirements, scope limits, path rules |

**Universal Quality Checklist (copy from template):**

```markdown
## Quality Checklist

### Completeness
- Is all necessary information included?
- Are there gaps in the output?
- Would someone unfamiliar understand the result?

### Accuracy
- Is the output factually correct?
- Are all references valid?
- Are assumptions explicitly stated?

### Format
- Is the output properly structured?
- Are sections clearly labeled?
- Is the formatting consistent?
```

---

## Optional Reference Files

These files are optional additions for Complex skills, particularly those operating in specialized domains. Create from scratch based on skill requirements.

### `errors.md` — Error Handling

**Purpose:** Documents error conditions, recovery procedures, and troubleshooting guidance.

**When to Add:** When skill has complex failure modes, external dependencies, or user-facing error messages.

**YAML Schema:**

```yaml
---
errors:
  - code: "E001"                   # Error identifier
    condition: "[When this occurs]"
    severity: fatal|recoverable|warning
    message: "[User-facing message]"
    action: "[Recovery action]"

  - code: "E002"
    condition: "[When this occurs]"
    severity: recoverable
    message: "[User-facing message]"
    action: "[Recovery action]"

fallback_behavior: "[What skill does when error is unrecoverable]"
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Error Codes` | Table with Code, Condition, Severity, Action columns |
| `## Common Issues` | Prose troubleshooting for frequent problems |
| `## Recovery Procedures` | Step-by-step recovery for each severity level |
| `## Fallback Behavior` | What happens when skill cannot complete |

**Example Content:**

```yaml
---
errors:
  - code: "E001"
    condition: "Referenced file does not exist"
    severity: recoverable
    message: "File not found: {{path}}"
    action: "Escalate to user with file path; suggest alternatives"

  - code: "E002"
    condition: "Scope exceeds maximum (>50 files)"
    severity: warning
    message: "Scope too large: {{count}} files"
    action: "Suggest narrowing focus; offer to proceed with subset"

  - code: "E003"
    condition: "External service unavailable"
    severity: fatal
    message: "Cannot reach {{service}}"
    action: "Abort with clear error; suggest retry later"

fallback_behavior: "Log partial results if any; preserve user input for retry"
---
```

---

### `glossary.md` — Terminology

**Purpose:** Defines domain-specific terms used by the skill, ensuring consistent understanding.

**When to Add:** When skill operates in a specialized domain or introduces its own terminology.

**YAML Schema:**

```yaml
---
terms:
  - term: "[term]"
    definition: "[meaning in this skill's context]"
    aliases: ["[alias1]", "[alias2]"]
    see_also: ["[related_term]"]

  - term: "[term]"
    definition: "[meaning]"
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Terms` | Alphabetical list with definitions |
| `## Domain Context` | Background on the domain if needed |
| `## Related Concepts` | Connections between terms |

**Example Content:**

```yaml
---
terms:
  - term: "persona"
    definition: "The expertise level and perspective assigned to execute a refined prompt"
    aliases: ["role", "execution persona"]
    see_also: ["context_depth"]

  - term: "context_depth"
    definition: "How deeply the skill analyzes repository context: minimal, standard, or deep"
    aliases: ["depth", "analysis level"]

  - term: "negative constraints"
    definition: "Explicit statements of what NOT to do, including anti-patterns and forbidden approaches"
    aliases: ["anti-patterns", "forbidden"]
---
```

---

### `<domain>.md` — Domain-Specific Reference

**Purpose:** Provides domain-specific reference material that agents need to execute the skill correctly.

**When to Add:** When skill requires specialized knowledge that doesn't fit in other reference files.

**Structure varies by domain.** Common sections include:

| Domain | Typical Sections |
|--------|------------------|
| **Finance** | Regulations, Calculation Methods, Reporting Standards, Audit Requirements |
| **Legal** | Jurisdiction Rules, Document Types, Citation Formats, Privilege Handling |
| **Security** | Threat Models, Control Frameworks, Evidence Collection, Severity Levels |
| **Compliance** | Framework Mappings, Control Objectives, Evidence Types, Audit Trails |
| **Healthcare** | PHI Categories, Consent Requirements, De-identification Rules, Audit Trails |

**Best Practices:**

- Keep focused on actionable reference material
- Include lookup tables for quick reference
- Link to authoritative external sources where appropriate
- Update when regulations or standards change

---

## Implementation Workflow

When creating a new skill, follow this sequence:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Skill Creation Workflow                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. CHOOSE ARCHETYPE                                                        │
│     ┌────────────────────────────────────────┐                              │
│     │ What kind of skill is this?            │                              │
│     │                                        │                              │
│     │ • Single-purpose, stateless?    ──────▶ Atomic (SKILL.md only)        │
│     │ • Coordinates, maintains state? ──────▶ Complex (+ references/)       │
│     └────────────────────────────────────────┘                              │
│           │                                                                 │
│           ▼                                                                 │
│  2. CREATE SKILL.md                                                         │
│     ┌────────────────────────────────────────┐                              │
│     │ Copy _template/SKILL.md                │                              │
│     │ Set name, description, allowed-tools   │                              │
│     │ Write core instructions                │                              │
│     └────────────────────────────────────────┘                              │
│           │                                                                 │
│           ▼                                                                 │
│  3. ADD REFERENCE FILES (if Complex)                                     │
│     ┌────────────────────────────────────────┐                              │
│     │ Core files:                            │                              │
│     │   • io-contract.md ──▶ I/O specs       │                              │
│     │   • safety.md ──────▶ Permissions      │                              │
│     │   • examples.md ────▶ Worked examples  │                              │
│     │   • behaviors.md ───▶ Phase steps      │                              │
│     │   • validation.md ──▶ Acceptance       │                              │
│     │                                        │                              │
│     │ Optional (for domain-oriented skills): │                              │
│     │   • errors.md ──────▶ Error handling   │                              │
│     │   • glossary.md ────▶ Terminology      │                              │
│     │   • <domain>.md ────▶ Domain reference │                              │
│     └────────────────────────────────────────┘                              │
│           │                                                                 │
│           ▼                                                                 │
│  4. UPDATE MANIFEST & REGISTRY                                              │
│     ┌────────────────────────────────────────┐                              │
│     │ manifest.yml ──▶ id, summary, triggers │                              │
│     │ registry.yml ──▶ commands, parameters  │                              │
│     │ workspace registry ──▶ I/O paths       │                              │
│     └────────────────────────────────────────┘                              │
│           │                                                                 │
│           ▼                                                                 │
│  5. VALIDATE                                                                │
│     ┌────────────────────────────────────────┐                              │
│     │ Run: validate-skills.sh <skill-id>     │                              │
│     │ Fix any errors or warnings             │                              │
│     └────────────────────────────────────────┘                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Quick Reference: File Purposes

**Pattern-triggered files (Complex):**

Complex skills must have at least one of these files, based on exhibited patterns:

| File | Pattern Trigger | Key Question It Answers |
|------|-----------------|-------------------------|
| `io-contract.md` | Non-trivial I/O | "What does this skill accept, produce, and how do I run it?" |
| `behaviors.md` | Distinct phases | "What happens during execution?" |
| `safety.md` | Tool/file policies | "What can this skill do and not do?" |
| `examples.md` | Output demonstration | "What does this look like in practice?" |
| `validation.md` | Quality gates | "How do I know it worked?" |
| `checkpoints.md` | Stateful | "How is state preserved across phases?" |
| `orchestration.md` | Orchestrated | "How are sub-tasks coordinated?" |
| `decisions.md` | Phased | "What determines execution path?" |
| `interaction.md` | Interactive | "Where is human input required?" |
| `agents.md` | Agentic | "How are sub-agents coordinated?" |
| `composition.md` | Composable | "How is this skill composed with others?" |
| `errors.md` | Complex errors | "What happens when something goes wrong?" |
| `glossary.md` | Domain terms | "What do these terms mean?" |
| `<domain>.md` | Specialized knowledge | "What domain knowledge is needed?" |

**Optional files (Atomic):**

| File | When to Add | Key Question It Answers |
|------|-------------|-------------------------|
| `examples.md` | Output needs demonstration | "What does this look like in practice?" |
| `errors.md` | Complex failure modes | "What happens when something goes wrong?" |
| `glossary.md` | >5 domain terms | "What do these terms mean?" |

**Note:** Commands and triggers are defined in `manifest.yml` and `registry.yml`, not in reference files. This single-source-of-truth approach prevents duplication and drift.

### Archetype Summary

| Archetype | Structure | When to Use |
|-----------|-----------|-------------|
| **Atomic** | `SKILL.md` + optional refs | Single-purpose, stateless; add examples/errors/glossary as needed |
| **Complex** (minimal) | `SKILL.md` + 1-2 pattern refs | Simple multi-phase or coordinated skill |
| **Complex** (typical) | `SKILL.md` + 3-5 pattern refs | Coordinates concerns, maintains state, has phases |
| **Complex** (full) | `SKILL.md` + many pattern refs | Enterprise-grade with checkpoints, orchestration, domain docs |

---

## See Also

- [Skill Format](./skill-format.md) — SKILL.md structure
- [Architecture](./architecture.md) — Progressive disclosure model
- [Creation](./creation.md) — Creating new skills with reference files
