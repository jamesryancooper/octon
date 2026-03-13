# Workflows Primitive vs Workflow Archetype Skills Architecture Decision Prompt

## Purpose

Determine whether there is a need for a multi-step procedural primitive (provisionally called "workflows") that exists **outside the constraints of the agentskills.io specification**.

If such a primitive is justified, define what capabilities it must offer that skills cannot. If not justified, recommend deprecating `.octon/workflows/` in favor of the production-ready skills system.

### Comparison Scope

This analysis explicitly compares:

| Term | Definition |
|------|------------|
| **Workflow archetype skills** | Skills that implement multi-step procedural patterns within the agentskills.io specification (e.g., `refine-prompt`, `synthesize-research`) |
| **workflows primitive** | A separate primitive (`.octon/workflows/`) that would exist outside the skills specification |

The question is: **Do workflow archetype skills adequately serve procedural use cases, or is a separate workflows primitive necessary?**

---

## Implementation Maturity

> **Critical Context:** The two systems being compared are at different maturity levels:
>
> | System | Maturity | Status |
> |--------|----------|--------|
> | **Skills** (`.octon/skills/`) | Production-ready | Follows agentskills.io spec, documented architecture, working implementations |
> | **Workflows** (`.octon/workflows/`) | Draft | Conceptual structure only, not fully designed or built |
>
> **Important:** Do not make assumptions about what workflows are or will be based on the current draft. The draft is incomplete and could change significantly. The current file structure in `.octon/workflows/` should be treated as **exploratory scaffolding**, not a design commitment.
>
> The core question is not "should we keep current workflows" but rather:
>
> **Is there a need for a primitive that exists outside the constraints of the agentskills.io specification?**
>
> If yes, what capabilities would justify that primitive's existence? If no, the workflows directory should be deprecated in favor of skills.

---

## Context Loading

Before beginning analysis, load the following resources:

1. **Primary Documentation:**
   - `docs/architecture/workspaces/skills/README.md` — Skills overview
   - `docs/architecture/workspaces/skills/comparison.md` — Skills vs other primitives
   - `docs/architecture/workspaces/skills/architecture.md` — Skills architecture
   - `docs/architecture/workspaces/workflows.md` — Workflows overview

2. **Current Implementations:**
   - `.octon/workflows/` — List all workflow directories
   - `.octon/skills/` — List all skill directories
   - `.octon/skills/manifest.yml` — Active skill index
   - `.octon/skills/registry.yml` — Extended skill metadata

---

## Phase 1: Current State Inventory

### 1.1 Production Skills Catalog

List each skill in `.octon/skills/` with:

| Skill ID | Purpose | Has I/O Contract | Has Logging | Triggers |
|----------|---------|------------------|-------------|----------|
| (id) | (from manifest summary) | Yes/No | Yes/No | (trigger phrases) |

### 1.2 Draft Workflow Scaffolding

List what exists in `.octon/workflows/` **without assuming intent**:

| Path | Files Present | Apparent Purpose | Maturity |
|------|---------------|------------------|----------|
| (path) | (list files) | (best guess) | Draft/Placeholder |

> **Note:** This inventory is for context only. Do not assume the draft workflows represent a finalized design or required functionality.

---

## Phase 2: Skills Architecture Analysis

### 2.1 What Skills Provide

Document what the production skills system offers. Start with these known capabilities, then identify additional ones:

| Capability | How Skills Implement It | Spec Requirement |
|------------|-------------------------|------------------|
| **I/O Contract** | Typed paths in registry.yml | Required |
| **Composability** | Pipeline-friendly design | Core philosophy |
| **Auditability** | Required run logs | Required |
| **Invocation** | `/command` or natural triggers | Supported |
| **Progressive Disclosure** | 4-tier token-conscious loading | Required |
| **Portability** | Harness-agnostic via adapters | Supported |
| (identify additional) | | |

### 2.2 What Skills Constrain

Document what the agentskills.io specification constrains. Start with these potential constraints, then explore others:

| Constraint | What the Spec Requires | Potential Limitation |
|------------|------------------------|---------------------|
| Defined I/O | Must declare inputs/outputs | (identify if limiting) |
| Single-session focus | Designed for completion in one session | (identify if limiting) |
| Audit logging | Every run must be logged | (identify if limiting) |
| Composability priority | Must work in pipelines | (identify if limiting) |
| Progressive disclosure | Must follow 4-tier model | (identify if limiting) |
| (identify additional) | | |

> **Note:** These are starting points. Thoroughly review the agentskills.io specification and existing skill implementations to identify constraints not listed here.

### 2.3 Use Cases Skills Handle Well

Start with these examples, then identify additional use cases where skills excel:

| Use Case | Why Skills Excel |
|----------|------------------|
| Composable operations with defined I/O | I/O contracts enable chaining |
| Tasks requiring audit trails | Logging is built-in |
| Reusable capabilities across workspaces | Portable by design |
| Token-conscious environments | Progressive disclosure manages context |
| (identify additional) | |

### 2.4 Use Cases That May Challenge Skills

Start with these potential challenges, then explore others through analysis:

| Use Case | Potential Challenge | Can Skills Adapt? |
|----------|---------------------|-------------------|
| ACP policy gates mid-execution | Not native to spec | (evaluate) |
| Dynamic branching at runtime | Linear phase model | (evaluate) |
| Process documentation as primary output | Output-focused design | (evaluate) |
| Multi-session long-running tasks | Single-session focus | (evaluate) |
| (identify additional) | | |

> **Note:** Do not limit analysis to these items. Explore the skills specification, existing implementations, and real-world use cases to identify additional challenges.

---

## Phase 3: Skills Limitation Deep-Dive

For **each** potential limitation identified in Phase 2.4, conduct a thorough analysis. The sections below provide a template and starting points—create additional sections for any new challenges identified.

### Deep-Dive Template

For each limitation, answer:

1. **The Question:** What specific capability is being evaluated?
2. **Analysis Points:**
   - Does the spec prohibit this, or just not address it?
   - Could skills be extended to support this? What would be lost?
   - Is this a common enough need to matter?
3. **Evidence:** Cite real use cases that require this capability
4. **Verdict:** Skills can / cannot / could be extended to handle this

---

### 3.1 ACP Checkpoint Support

**The Question:** Can skills support mandatory ACP policy gates mid-execution?

- What would checkpoints look like within a skill?
- Does the spec prohibit this, or just not address it?
- Would adding checkpoints violate skills' composability?
- Is this a common enough need to matter?

**Evidence:** (cite real use cases that require this)

**Verdict:** Skills can / cannot / could be extended to handle this

### 3.2 Dynamic Branching

**The Question:** Can skills handle "if X then do A, else do B" at runtime?

- Are skill phases inherently linear?
- Could conditional logic exist within a phase?
- Would branching skills still be composable?
- Is this a common enough need to matter?

**Evidence:** (cite real use cases that require this)

**Verdict:** Skills can / cannot / could be extended to handle this

### 3.3 Process Documentation as Output

**The Question:** Can skills produce "the process itself" as the primary artifact?

- Skills are output-focused; is "steps taken" a valid output?
- Could a skill's output be its own execution trace?
- Is this fundamentally different from skill design?
- Is this a common enough need to matter?

**Evidence:** (cite real use cases that require this)

**Verdict:** Skills can / cannot / could be extended to handle this

### 3.4 Multi-Session Execution

**The Question:** Can skills handle tasks that span multiple sessions?

- Is single-session execution a hard constraint or assumption?
- Could skills checkpoint and resume?
- How would this affect logging and auditability?
- Is this a common enough need to matter?

**Evidence:** (cite real use cases that require this)

**Verdict:** Skills can / cannot / could be extended to handle this

### 3.X Additional Limitations

For each additional challenge identified in Phase 2.4, create a new section following the template above. Number sequentially (3.5, 3.6, etc.).

### Summary: Are Skills Sufficient

Summarize findings for all capabilities analyzed (include any additional ones identified):

| Capability | Skills Handle It | Extension Feasible | Justifies New Primitive |
|------------|------------------|-------------------|------------------------|
| ACP checkpoints | (yes/no) | (yes/no) | (yes/no) |
| Dynamic branching | (yes/no) | (yes/no) | (yes/no) |
| Process documentation | (yes/no) | (yes/no) | (yes/no) |
| Multi-session tasks | (yes/no) | (yes/no) | (yes/no) |
| (additional from 3.X) | (yes/no) | (yes/no) | (yes/no) |

**Conclusion:** Based on evidence, do any gaps justify a non-skills primitive?

---

## Phase 4: Non-Skills Primitive Exploration

This phase explores whether there are capabilities that justify a primitive **outside the agentskills.io specification**. Do not assume what this primitive would look like—instead, identify the capabilities that skills cannot provide.

> **Note:** The items below are starting points for exploration. Do not constrain analysis to these—explore freely and identify additional constraints, capabilities, and considerations.

### 4.1 Skills Specification Constraints (Synthesis)

Synthesize findings from Phase 2.2 and Phase 3. For each constraint, identify what it **prevents** (not just what it requires):

| Constraint | What Skills Require | What This Prevents |
|------------|---------------------|-------------------|
| I/O contracts | Defined inputs/outputs | (identify limitations) |
| Single-session execution | Complete in one session | (identify limitations) |
| Composability focus | Pipeline-friendly design | (identify limitations) |
| Required logging | Audit trail for every run | (identify limitations) |
| Progressive disclosure | 4-tier token-conscious loading | (identify limitations) |
| (identify additional) | | |

**Key Question:** Are any of these constraints problematic for certain use cases?

### 4.2 Capability Gap Analysis

Identify capabilities that might require a non-skills primitive. Start with these examples, then explore additional possibilities:

**Capability 1: ACP Checkpoint Orchestration**

- What would ACP checkpoints look like in practice?
- Could skills be extended to support this? What would be lost?
- Is this fundamentally incompatible with the skills model?

**Capability 2: Dynamic/Conditional Branching**

- Are there tasks that require "if X then do A, else do B" at runtime?
- Would adding branching to skills harm their composability?
- Is this a distinct concern that warrants a separate primitive?

**Capability 3: Process Documentation as Primary Output**

- Are there tasks where "the steps taken" is more important than "the artifact produced"?
- Can skills emit process documentation, or does this violate their design?
- Is this a real need or an edge case?

**Capability 4: Multi-Session / Long-Running Tasks**

- Are there tasks that cannot complete in a single session?
- How would state persistence work outside skills?
- Is this common enough to justify a separate primitive?

**Capability 5: Unconstrained Flexibility**

- Are there tasks that need to evolve freely without spec compliance?
- Would a "freeform procedure" primitive serve a real purpose?
- Or does this just create inconsistency?

**Capability X: (Additional)**

Identify and analyze additional capabilities not listed above. For each, consider:

- What is the capability?
- Why might skills not support it?
- Is there evidence of real need?

### 4.3 Evidence-Based Evaluation

For each capability analyzed (including any additional ones identified), provide evidence:

| Capability | Real Use Cases | Frequency | Skills Workaround | Workaround Quality |
|------------|----------------|-----------|-------------------|-------------------|
| ACP checkpoints | (examples) | (how often) | (if any) | (adequate/poor/none) |
| Dynamic branching | (examples) | (how often) | (if any) | (adequate/poor/none) |
| Process documentation | (examples) | (how often) | (if any) | (adequate/poor/none) |
| Multi-session tasks | (examples) | (how often) | (if any) | (adequate/poor/none) |
| Unconstrained flexibility | (examples) | (how often) | (if any) | (adequate/poor/none) |
| (additional identified) | (examples) | (how often) | (if any) | (adequate/poor/none) |

### 4.4 Justification Threshold

A non-skills primitive is justified **only if**:

1. There are real, recurring use cases that skills cannot serve
2. Skills cannot be reasonably extended to cover these cases
3. The value gained exceeds the cost of maintaining two systems

**Answer:** Based on the evidence, is a non-skills primitive justified? Why or why not?

---

## Phase 5: Cognitive Load Analysis

If both systems coexist, users and agents must understand when to use each. This phase evaluates the cognitive burden and proposes mitigation strategies.

### 5.1 Confusion Risk Assessment

| Scenario | Confusion Risk | Example |
|----------|----------------|---------|
| User wants to automate a task | High/Medium/Low | "Should I create a skill or a workflow?" |
| Agent encounters a multi-step procedure | High/Medium/Low | "Is this a skill's phases or a workflow's steps?" |
| Developer adds new capability | High/Medium/Low | "Which primitive fits this use case?" |
| Onboarding new team member | High/Medium/Low | "Why are there two systems for procedures?" |
| Documentation maintenance | High/Medium/Low | "Do I document this in skills docs or workflow docs?" |

### 5.2 Decision Complexity

If both exist, users need a decision tree. How complex is it?

```
Is your task...
├── [criterion 1]? → Skill
├── [criterion 2]? → Workflow
├── [criterion 3]? → Skill
└── Unclear? → ???
```

**Questions:**

1. Can the decision criteria be made simple and unambiguous?
2. How many criteria are needed to distinguish the two?
3. Is there a "gray zone" where either could apply?
4. What happens when users choose wrong?

### 5.3 Cognitive Load Mitigation Strategies

If keeping both, how can confusion be minimized?

| Strategy | Description | Effectiveness | Implementation Cost |
|----------|-------------|---------------|---------------------|
| **Clear naming** | Distinct, descriptive names for each | (evaluate) | (evaluate) |
| **Single entry point** | One command that routes to correct primitive | (evaluate) | (evaluate) |
| **Decision guide** | Flowchart or checklist for choosing | (evaluate) | (evaluate) |
| **Unified discovery** | Single manifest that lists both | (evaluate) | (evaluate) |
| **Strict boundaries** | Hard rules with no overlap | (evaluate) | (evaluate) |
| **Deprecate one** | Eliminate the decision entirely | High | (evaluate) |

### 5.4 The "Just Use Skills" Question

Before committing to two systems, answer honestly:

1. **Could skills be extended** to cover the edge cases, even imperfectly?
2. **Is the complexity of two systems** worth the capability gained?
3. **Would users prefer** one flexible system over two specialized ones?
4. **What is the long-term maintenance burden** of two systems?

### 5.5 Cognitive Load Verdict

Based on the above:

- **Acceptable:** The distinction is clear enough that users won't be confused
- **Manageable:** Some confusion is likely, but mitigation strategies are sufficient
- **Problematic:** The cognitive overhead outweighs the benefits of two systems

**Recommendation:** (state verdict and reasoning)

---

## Phase 6: Recommendations

### 6.1 Primary Recommendation

Based on the analysis, provide ONE of these recommendations:

**Option A: Keep Both (Dual-Track)**

- Workflow archetype skills and workflows within the workflows primitive serve distinct purposes
- Define clear boundaries between them
- Document when to use each

**Option B: Consolidate to Skills (workflow archetype skills)**

- Migrate all suitable workflows from the workflows primitive to skills
- Deprecate the workflows primitive

**Option C: Consolidate to Workflows (workflows primitive)**

- Keep workflows as primary multi-step primitive
- Position skills for composable I/O operations only
- Avoid overlap by restricting skill scope

**Option D: Hybrid Approach**

- Convert specific workflows from the workflows primitive to skills (list which)
- Keep specific workflows from the workflows primitive as-is (list which)
- Define migration path for undecided cases

### 6.2 Justification

For the chosen recommendation, provide:

1. **Primary rationale:** Why this approach?
2. **Risk assessment:** What could go wrong?
3. **Migration effort:** High/Medium/Low with explanation
4. **Timeline considerations:** Dependencies and sequencing

### 6.3 Boundary Definition

If keeping both systems, define clear boundaries:

| Characteristic | Use Workflow | Use Skill |
|----------------|--------------|-----------|
| (characteristic) | ✓ | |
| (characteristic) | | ✓ |

### 6.4 Action Items

List specific next steps based on recommendation:

1. (action item with owner placeholder)
2. (action item with owner placeholder)
3. ...

---

## Phase 7: Documentation Updates

### 7.1 Files to Update

If recommendation is adopted, which documentation needs changes:

| File | Change Type | Description |
|------|-------------|-------------|
| (path) | Create/Update/Deprecate | (what changes) |

---

## Deliverables Checklist

Before completing this analysis, ensure you have:

- [ ] Inventoried current workflow drafts and production skills
- [ ] Identified skills specification constraints that limit capabilities
- [ ] Evaluated whether non-skills capabilities are truly needed
- [ ] Provided evidence for each claimed capability gap
- [ ] Assessed cognitive load of maintaining two systems
- [ ] Proposed mitigation strategies if keeping both
- [ ] Made a primary recommendation with justification
- [ ] Defined clear boundaries (if keeping both)
- [ ] Listed specific action items
- [ ] Drafted documentation updates

---

## References

- [agentskills.io Specification](https://agentskills.io/specification)
- `docs/architecture/workspaces/skills/` — Full skills documentation
- `docs/architecture/workspaces/workflows.md` — Workflows documentation
- `.octon/skills/` — Current skill implementations
- `.octon/skills/manifest.yml` — Current skill definitions
- `.octon/workflows/` — Current workflow implementations
