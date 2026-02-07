# Workflows Primitive vs Workflow Archetype Skills: Architecture Decision Analysis

**Generated:** 2026-01-18
**Status:** Complete Analysis

---

## Executive Summary

After comprehensive analysis of the skills system (production-ready, agentskills.io-compliant) and the workflows primitive (draft scaffolding), this analysis concludes that **a separate workflows primitive is not justified**. The capabilities that workflows appear to provide can be adequately served by extending or properly implementing skills within the agentskills.io specification.

**Primary Recommendation:** Consolidate to Skills (Option B) - Migrate suitable workflows to skills, deprecate the workflows primitive.

---

## Phase 1: Current State Inventory

### 1.1 Production Skills Catalog

| Skill ID | Purpose | Has I/O Contract | Has Logging | Triggers |
|----------|---------|------------------|-------------|----------|
| `refine-prompt` | Transform rough prompts into clear, actionable instructions with codebase context | Yes (outputs/prompts/, logs/runs/) | Yes | "refine my prompt", "improve this prompt", "expand this prompt" |
| `synthesize-research` | Synthesize scattered research notes into coherent findings documents | Yes (outputs/drafts/, logs/runs/) | Yes | "synthesize my research", "consolidate findings", "summarize research notes" |

**Observations:**

- Both production skills implement multi-step procedural workflows (10 phases for refine-prompt, 5 phases for synthesize-research)
- Both have typed I/O contracts with explicit output paths
- Both require audit logging
- Both use progressive disclosure (SKILL.md + references/)
- Both define `allowed-tools` in frontmatter for tool permissions

### 1.2 Draft Workflow Scaffolding

| Path | Files Present | Apparent Purpose | Maturity |
|------|---------------|------------------|----------|
| `.harmony/orchestration/workflows/_template/` | 00-overview.md, 01-step.md, NN-verify.md, README.md | Scaffolding template | Draft |
| `.harmony/orchestration/workflows/workspace/create-workspace/` | 00-overview.md + 6 step files | Scaffold new .harmony directory | Draft/Functional |
| `.harmony/orchestration/workflows/workspace/update-workspace/` | 00-overview.md + 5 step files | Align workspace with canonical definition | Draft/Functional |
| `.harmony/orchestration/workflows/workspace/evaluate-workspace/` | 00-overview.md + 3 step files | Assess token efficiency | Draft/Functional |
| `.harmony/orchestration/workflows/workspace/migrate-workspace/` | 00-overview.md + 4 step files | Migrate workspace structure | Draft |
| `.harmony/orchestration/workflows/workflows/create-workflow/` | 00-overview.md + 8 step files | Scaffold new workflow | Draft/Meta |
| `.harmony/orchestration/workflows/workflows/update-workflow/` | 00-overview.md + 5 step files | Modify existing workflow | Draft/Meta |
| `.harmony/orchestration/workflows/workflows/evaluate-workflow/` | 00-overview.md + 5 step files | Assess workflow quality | Draft/Meta |
| `.harmony/orchestration/workflows/refactor/` | 00-overview.md + 6 step files | Execute verified codebase refactor | Draft/Functional |
| `.harmony/orchestration/workflows/missions/create-mission/` | 00-overview.md | Scaffold new mission | Draft |
| `.harmony/orchestration/workflows/missions/complete-mission/` | 00-overview.md | Archive completed mission | Draft |
| `.harmony/orchestration/workflows/skills/create-skill/` | 00-overview.md + 6 step files | Scaffold new skill | Draft/Functional |
| `.harmony/orchestration/workflows/promote-from-scratchpad.md` | Single file | Promote scratchpad content | Placeholder |

**Observations:**

- Workflows use frontmatter with: `title`, `description`, `access`, `version`, `depends_on`, `checkpoints`, `parallel_steps`
- Numbered step files (00-overview.md, 01-step.md, etc.) provide sequential instructions
- "Verification gates" are a common pattern (final step validates completion)
- No I/O contracts defined
- No required logging infrastructure
- Some have `checkpoints.enabled: true` but no clear checkpoint implementation
- The `create-skill` workflow creates skills - showing workflows can produce skill artifacts

---

## Phase 2: Skills Architecture Analysis

### 2.1 What Skills Provide

| Capability | How Skills Implement It | Spec Requirement |
|------------|-------------------------|------------------|
| **I/O Contract** | Typed paths in registry.yml, explicit output locations | Required |
| **Composability** | Pipeline-friendly design, defined inputs/outputs enable chaining | Core philosophy |
| **Auditability** | Required run logs in `logs/runs/` | Required |
| **Invocation** | `/command`, natural triggers, `use skill: {{id}}` | Supported |
| **Progressive Disclosure** | 4-tier model (manifest → registry → SKILL.md → references) | Required |
| **Portability** | Harness-agnostic via symlinks to `.claude/`, `.cursor/`, `.codex/` | Supported |
| **Multi-Phase Workflows** | `refine-prompt` has 10 phases, `synthesize-research` has 5 phases | Supported within SKILL.md |
| **Tool Permissions** | `allowed-tools` in frontmatter restricts tool access | Supported via extension |
| **Scope Validation** | Output paths validated against workspace hierarchy | Supported via extension |
| **Version Tracking** | `metadata.updated` in frontmatter, `version` in registry.yml | Supported |

### 2.2 What Skills Constrain

| Constraint | What the Spec Requires | Potential Limitation |
|------------|------------------------|---------------------|
| Defined I/O | Must declare inputs/outputs | Forces explicit contracts (this is a feature, not a bug) |
| Single-session focus | Designed for completion in one session | May limit multi-session tasks (needs evaluation) |
| Audit logging | Every run must be logged | Requires logging infrastructure (minimal overhead) |
| Composability priority | Must work in pipelines | May discourage tightly-coupled procedures |
| Progressive disclosure | Must follow 4-tier model | Keeps documentation organized but requires structure |
| Output-focused | Skills produce artifacts | May feel awkward when process is the goal |
| Spec compliance | Must follow agentskills.io format | Limits freeform experimentation |

### 2.3 Use Cases Skills Handle Well

| Use Case | Why Skills Excel |
|----------|------------------|
| Composable operations with defined I/O | I/O contracts enable chaining; `refine-prompt` → `execute-prompt` pipeline |
| Tasks requiring audit trails | Logging is built-in; every run produces traceable artifacts |
| Reusable capabilities across workspaces | Portable by design; symlinks enable multi-harness access |
| Token-conscious environments | Progressive disclosure manages context effectively |
| Multi-phase procedural tasks | Both production skills prove this works (10 phases in refine-prompt) |
| Context-aware tasks | `refine-prompt` demonstrates deep codebase analysis within skill framework |
| Tasks with clear success criteria | Output artifacts provide concrete "done" signals |

### 2.4 Use Cases That May Challenge Skills

| Use Case | Potential Challenge | Can Skills Adapt? |
|----------|---------------------|-------------------|
| Human approval gates mid-execution | Not native to spec | **Yes** - See Phase 3.1 |
| Dynamic branching at runtime | Linear phase model assumed | **Yes** - See Phase 3.2 |
| Process documentation as primary output | Output-focused design | **Yes** - See Phase 3.3 |
| Multi-session long-running tasks | Single-session focus | **Yes** - See Phase 3.4 |
| Verification loops with retry | Skills are execute-once | **Yes** - See Phase 3.5 |
| Scaffolding/creation tasks | May feel like overkill | **Yes** - See Phase 3.6 |

---

## Phase 3: Skills Limitation Deep-Dive

### 3.1 Human Checkpoint Support

**The Question:** Can skills support mandatory human approval gates mid-execution?

**Analysis:**

- The agentskills.io spec does not prohibit checkpoints; it simply doesn't address them
- Skills already have a natural checkpoint: the "Intent Confirmation" phase in `refine-prompt` (Phase 9)
- The skill can prompt the user at any phase and wait for confirmation
- `skip_confirmation` parameter in `refine-prompt` shows optional checkpoint is already implemented

**How it works in practice:**

```markdown
## Phase 9: Intent Confirmation

1. Summarize understanding
2. Present key decisions
3. **Ask user: "Is this what you intended?"** ← Human checkpoint
4. Incorporate feedback if provided
```

**Evidence:** `refine-prompt` already implements this with the `skip_confirmation` parameter.

**Verdict:** **Skills CAN handle this.** Human checkpoints are implemented via user prompts within phases. No spec violation required.

---

### 3.2 Dynamic Branching

**The Question:** Can skills handle "if X then do A, else do B" at runtime?

**Analysis:**

- Skill phases are not inherently linear - they're guidelines, not constraints
- The agent executing a skill can make runtime decisions within each phase
- `refine-prompt` demonstrates this: Phase 6 (Decomposition) creates variable sub-tasks based on complexity
- The skill says "Break complex requests into 2-7 sub-tasks depending on complexity"

**How it works in practice:**

```markdown
## Phase 6: Decomposition

1. Identify sub-tasks (number varies by complexity)
2. Map dependencies
3. Order execution

// Runtime decision: Simple prompt → 2 sub-tasks, Complex prompt → 7 sub-tasks
```

**Evidence:** Phase instructions can contain conditional logic; the agent interprets and branches appropriately.

**Verdict:** **Skills CAN handle this.** Branching occurs within phase instructions as agent-interpreted logic.

---

### 3.3 Process Documentation as Output

**The Question:** Can skills produce "the process itself" as the primary artifact?

**Analysis:**

- Skills are output-focused, but nothing prevents the output from being process documentation
- The run log (`logs/runs/`) already captures execution trace
- A skill could explicitly output a "process report" as its primary artifact

**How it works in practice:**

```yaml
# In .harmony/capabilities/skills/registry.yml
skill_mappings:
  refactor-skill:
    outputs:
      - path: "outputs/refactors/{{timestamp}}-process-report.md"
        description: "Documentation of the refactor process"
```

**Evidence:** `synthesize-research` outputs a document that includes "Sources Reviewed" and process metadata. The format is flexible.

**Verdict:** **Skills CAN handle this.** Process documentation is simply another output type.

---

### 3.4 Multi-Session Execution

**The Question:** Can skills handle tasks that span multiple sessions?

**Analysis:**

- Single-session is an assumption, not a hard constraint
- Skills can checkpoint by:
  1. Writing partial outputs to designated paths
  2. Resuming by reading prior outputs as inputs
  3. Using the workspace `progress/` directory for state
- The `refine-prompt` skill already supports this implicitly - a refined prompt can be saved and executed later

**How it works in practice:**

```markdown
## Resumption Pattern

1. Check for prior outputs in outputs/{{category}}/
2. If partial output exists, load and continue from last phase
3. Otherwise, start fresh
```

**Evidence:** Workflow frontmatter includes `checkpoints.storage: ".harmony/continuity/checkpoints/"` - this pattern can be adopted by skills.

**Verdict:** **Skills COULD be extended to handle this.** Requires adding checkpoint/resume patterns, but no spec violation needed.

---

### 3.5 Verification Loops with Retry

**The Question:** Can skills support "verify, then retry if failed" patterns?

**Analysis:**

- The `refactor` workflow's strength is its mandatory verification gate
- Skills can implement this as a phase pattern:
  1. Execute phase
  2. Verify phase (check success criteria)
  3. If failed → return to prior phase, re-execute

**How it works in practice:**

```markdown
## Phase 7: Validation

1. Re-run all audit searches
2. If any return results → return to Phase 4, address remaining items
3. If all pass → proceed to output

// This is a loop, not linear execution
```

**Evidence:** The workflow pattern can be encoded in skill instructions. The agent interprets and loops as needed.

**Verdict:** **Skills CAN handle this.** Verification loops are agent-interpreted instruction patterns.

---

### 3.6 Scaffolding/Creation Tasks

**The Question:** Are skills overkill for simple scaffolding tasks like `create-workspace`?

**Analysis:**

- The `create-skill` workflow creates skills - a meta relationship that works fine
- Skills can scaffold anything; the I/O contract would be: input = target path, output = created files
- The overhead is minimal: a SKILL.md file with instructions

**However:**

- Scaffolding tasks may benefit less from I/O contracts (no input file, output is "existence of new structure")
- Audit logging for scaffolding may be less valuable than for data transformation skills

**Verdict:** **Skills CAN handle this, but may feel like slight overkill.** The value proposition is weaker for pure scaffolding. This is the closest to a legitimate workflow use case.

---

### 3.7 Summary: Are Skills Sufficient

| Capability | Skills Handle It | Extension Feasible | Justifies New Primitive |
|------------|------------------|-------------------|------------------------|
| Human checkpoints | **Yes** | N/A | **No** |
| Dynamic branching | **Yes** | N/A | **No** |
| Process documentation | **Yes** | N/A | **No** |
| Multi-session tasks | Partially | Yes (checkpoint patterns) | **No** |
| Verification loops | **Yes** | N/A | **No** |
| Scaffolding tasks | **Yes** (slight overhead) | N/A | **No** |

**Conclusion:** No gaps identified that justify a non-skills primitive. Skills either already handle these capabilities or can be trivially extended to do so without violating the agentskills.io specification.

---

## Phase 4: Non-Skills Primitive Exploration

### 4.1 Skills Specification Constraints (Synthesis)

| Constraint | What Skills Require | What This Prevents |
|------------|---------------------|-------------------|
| I/O contracts | Defined inputs/outputs | Prevents "implicit" data flow (this prevents bugs) |
| Single-session execution | Assumed completion in one session | Nothing - can be extended |
| Composability focus | Pipeline-friendly design | Prevents tightly-coupled procedures (good) |
| Required logging | Audit trail for every run | Prevents silent execution (good for debugging) |
| Progressive disclosure | 4-tier token-conscious loading | Prevents monolithic documentation |
| Spec compliance | agentskills.io format | Prevents ad-hoc invention (enables portability) |

**Key Finding:** None of these constraints prevent useful capabilities. They enforce good practices.

### 4.2 Capability Gap Analysis

**Capability 1: Human Checkpoint Orchestration**

- Skills handle this via user prompts within phases
- `refine-prompt` demonstrates with `skip_confirmation` parameter
- **No gap exists**

**Capability 2: Dynamic/Conditional Branching**

- Skills handle this via agent-interpreted phase instructions
- Phases can include conditionals: "If X, do Y; otherwise Z"
- **No gap exists**

**Capability 3: Process Documentation as Primary Output**

- Process reports are valid skill outputs
- Run logs already capture execution traces
- **No gap exists**

**Capability 4: Multi-Session / Long-Running Tasks**

- Can be implemented via checkpoint patterns
- Would benefit from standardizing a checkpoint protocol
- **Minor extension opportunity, not a gap**

**Capability 5: Unconstrained Flexibility**

- "Freeform procedures" that don't need spec compliance
- This is explicitly what the analysis is evaluating
- **The value of "unconstrained flexibility" is dubious** - it trades portability and auditability for... what?

### 4.3 Evidence-Based Evaluation

| Capability | Real Use Cases | Frequency | Skills Workaround | Workaround Quality |
|------------|----------------|-----------|-------------------|-------------------|
| Human checkpoints | Code review approval, deploy gates | Common | User prompts in phases | Adequate |
| Dynamic branching | Error recovery, conditional features | Common | Conditional phase instructions | Adequate |
| Process documentation | Refactor audits, migration reports | Occasional | Output as process report | Adequate |
| Multi-session tasks | Large migrations, phased rollouts | Rare | Checkpoint patterns | Adequate (needs standardization) |
| Unconstrained flexibility | Ad-hoc experiments | Rare | N/A | Not needed |

### 4.4 Justification Threshold

A non-skills primitive is justified **only if**:

1. There are real, recurring use cases that skills cannot serve ❌ (Not demonstrated)
2. Skills cannot be reasonably extended to cover these cases ❌ (All cases covered or trivially extendable)
3. The value gained exceeds the cost of maintaining two systems ❌ (No additional value demonstrated)

**Answer:** A non-skills primitive is **NOT justified**. The evidence shows that workflow archetype skills can handle all identified use cases, either natively or with minor extensions.

---

## Phase 5: Cognitive Load Analysis

### 5.1 Confusion Risk Assessment

| Scenario | Confusion Risk | Explanation |
|----------|----------------|-------------|
| User wants to automate a task | **High** | "Should I create a skill or a workflow?" |
| Agent encounters a multi-step procedure | **High** | "Is this a skill's phases or a workflow's steps?" |
| Developer adds new capability | **High** | "Which primitive fits this use case?" |
| Onboarding new team member | **High** | "Why are there two systems for procedures?" |
| Documentation maintenance | **Medium** | "Do I document this in skills docs or workflow docs?" |

### 5.2 Decision Complexity

If both exist, users need a decision tree:

```
Is your task...
├── Has defined I/O and needs auditability? → Skill
├── Pure scaffolding with no data transform? → Workflow?
├── Multi-phase procedure? → Both could work
├── Needs human checkpoints? → Both could work
├── Needs verification loops? → Both could work
└── Unclear? → Confusion
```

**Questions:**

1. Can the decision criteria be made simple and unambiguous? **No** - significant overlap exists
2. How many criteria are needed to distinguish the two? **5+** - too many
3. Is there a "gray zone" where either could apply? **Yes** - most use cases
4. What happens when users choose wrong? **Inconsistency and maintenance burden**

### 5.3 Cognitive Load Mitigation Strategies

| Strategy | Description | Effectiveness | Implementation Cost |
|----------|-------------|---------------|---------------------|
| **Clear naming** | Distinct, descriptive names | Low | Low |
| **Single entry point** | One command that routes | Medium | Medium |
| **Decision checklist** | Documented criteria | Low | Low |
| **Unified discovery** | Single manifest for both | Medium | High |
| **Strict boundaries** | Hard rules with no overlap | Low (rules are artificial) | High |
| **Deprecate one** | Eliminate the decision entirely | **High** | Medium |

### 5.4 The "Just Use Skills" Question

1. **Could skills be extended** to cover the edge cases, even imperfectly?
   **Yes** - All analyzed cases can be covered

2. **Is the complexity of two systems** worth the capability gained?
   **No** - No unique capability was identified for workflows

3. **Would users prefer** one flexible system over two specialized ones?
   **Yes** - Simplicity reduces cognitive load

4. **What is the long-term maintenance burden** of two systems?
   - Duplicate documentation
   - Confusing routing logic
   - Inconsistent patterns
   - Training overhead

### 5.5 Cognitive Load Verdict

**Problematic** - The cognitive overhead of maintaining two overlapping systems outweighs any benefits. The distinction between "workflow archetype skills" and "workflows primitive" is too subtle and introduces unnecessary complexity.

---

## Phase 6: Recommendations

### 6.1 Primary Recommendation

**Option B: Consolidate to Skills (workflow archetype skills)**

- Migrate all suitable workflows to skills
- Deprecate the workflows primitive (`.harmony/orchestration/workflows/`)
- Position skills as the single primitive for multi-step procedures

### 6.2 Justification

1. **Primary rationale:** No capability gap justifies maintaining two systems. Skills already implement multi-phase procedures (proven by `refine-prompt` with 10 phases). The additional overhead of I/O contracts and logging is minimal and provides real benefits (auditability, composability, portability).

2. **Risk assessment:**
   - **Low risk:** Skills are production-ready and proven
   - **Migration effort:** Moderate - rewrite workflow content as SKILL.md files
   - **Lost capability:** None identified

3. **Migration effort:** **Medium**
   - ~15 workflows to evaluate
   - ~10 worth migrating (workspace/, refactor/, skills/create-skill)
   - ~5 may be deprecated (meta workflows about workflows)
   - Each migration: rewrite overview as SKILL.md, references as reference files

4. **Timeline considerations:**
   - Can be done incrementally
   - Start with highest-value workflows (refactor, create-workspace)
   - Meta-workflows (create-workflow, update-workflow) become unnecessary after migration

### 6.3 Migration Categories

| Category | Workflows | Migration Path |
|----------|-----------|----------------|
| **Migrate to Skills** | refactor/, create-workspace, update-workspace, evaluate-workspace, create-skill | Create SKILL.md with phases |
| **Deprecate (meta)** | create-workflow, update-workflow, evaluate-workflow | No longer needed post-consolidation |
| **Deprecate (specialized)** | promote-from-scratchpad, missions/* | Evaluate individual utility; may not need formal primitive |
| **Keep as templates only** | _template/ | Reference for SKILL.md structure |

### 6.4 Skill Archetype: "Workflow Skills"

For skills that implement procedural workflows, adopt this pattern:

```markdown
---
name: refactor
description: Execute a verified codebase refactor with exhaustive audit and mandatory verification.
allowed-tools: Read Glob Grep Edit Write(outputs/*) Write(logs/*)
metadata:
  archetype: workflow
  checkpoints: true
---

# Refactor

## Phases

1. **Define Scope** - Capture old/new patterns
2. **Audit** - Exhaustive search for all references
3. **Plan** - Create manifest of required changes
4. **Execute** - Make changes systematically
5. **Verify** - Re-run audit; must return zero results ← Verification gate
6. **Document** - Update continuity artifacts

## Verification Gate

A refactor is NOT complete until Phase 5 (Verify) passes with zero remaining references.
```

### 6.5 Action Items

1. **Create `refactor` skill** - Migrate `.harmony/orchestration/workflows/refactor/` to `.harmony/capabilities/skills/refactor/`
2. **Create `create-workspace` skill** - Migrate workspace scaffolding workflow
3. **Update `create-skill` workflow** to be a skill itself (meta but consistent)
4. **Deprecate `.harmony/orchestration/workflows/`** - Move templates to `.harmony/capabilities/skills/_template/`
5. **Update documentation** - Revise comparison.md to reflect consolidation
6. **Add skill archetype guidance** - Document "workflow skills" pattern in skills docs

---

## Phase 7: Documentation Updates

### 7.1 Files to Update

| File | Change Type | Description |
|------|-------------|-------------|
| `docs/architecture/workspaces/skills/comparison.md` | Update | Remove "workflows" from comparison table; note consolidation |
| `docs/architecture/workspaces/workflows.md` | Deprecate | Add deprecation notice, point to skills |
| `docs/architecture/workspaces/skills/README.md` | Update | Add "workflow skills" archetype section |
| `docs/architecture/workspaces/skills/archetypes.md` | Create | Document different skill archetypes (transform, workflow, etc.) |
| `.harmony/capabilities/skills/manifest.yml` | Update | Add new skills as they're migrated |
| `.harmony/capabilities/skills/registry.yml` | Update | Add new skill metadata |
| `CLAUDE.md` | Update | Remove workflow references, simplify skill discovery |

---

## Deliverables Checklist

- [x] Inventoried current workflow drafts and production skills
- [x] Identified skills specification constraints that limit capabilities
- [x] Evaluated whether non-skills capabilities are truly needed
- [x] Provided evidence for each claimed capability gap
- [x] Assessed cognitive load of maintaining two systems
- [x] Proposed mitigation strategies if keeping both
- [x] Made a primary recommendation with justification
- [x] Defined clear boundaries (N/A - consolidating to one system)
- [x] Listed specific action items
- [x] Drafted documentation updates

---

## Conclusion

The analysis demonstrates that **workflow archetype skills adequately serve all identified procedural use cases**. The workflows primitive exists as draft scaffolding that duplicates capabilities already present in the production skills system, while lacking the benefits of I/O contracts, required logging, progressive disclosure, and spec compliance.

**The recommendation is to consolidate to skills**, migrating valuable workflow content to skill definitions and deprecating the workflows primitive. This reduces cognitive load, eliminates system overlap, and leverages the production-ready skills infrastructure.

The key insight is that skills are not just "composable I/O operations" - they are capable of encoding complex, multi-phase procedures with human checkpoints, verification gates, and conditional branching. The `refine-prompt` skill with its 10 phases proves this conclusively.

---

## References

- `.harmony/capabilities/skills/manifest.yml` - Current skill definitions
- `.harmony/capabilities/skills/registry.yml` - Extended skill metadata
- `.harmony/capabilities/skills/refine-prompt/SKILL.md` - Example multi-phase skill
- `.harmony/capabilities/skills/refine-prompt/references/behaviors.md` - Detailed phase documentation
- `.harmony/orchestration/workflows/refactor/` - Example workflow (candidate for migration)
- `docs/architecture/workspaces/skills/` - Skills documentation
- `docs/architecture/workspaces/workflows.md` - Workflows documentation

---

# Addendum: Two-Layer Architecture with Missions

**Added:** 2026-01-18
**Status:** Approved Direction

Following discussion of requirements for **durable, long-running workflows with complex branching**, this addendum revises the recommendations to establish a two-layer architecture.

---

## Revised Requirements

The original analysis evaluated single-session procedural tasks. Additional requirements have been identified:

| Requirement | Skills Can Handle | Needs New Primitive |
|-------------|-------------------|---------------------|
| Multi-phase procedures (single session) | **Yes** | No |
| Simple branching (if/else) | **Yes** | No |
| Human checkpoints (within session) | **Yes** | No |
| **Durable execution (survives restarts)** | No | **Yes** |
| **Complex decision trees (>5 branch points)** | Awkward | **Yes** |
| **Multi-session by design (days/weeks)** | No | **Yes** |

**Conclusion:** Skills are appropriate for single-session procedural tasks. A separate primitive is justified for durable, long-running orchestration.

---

## Two-Layer Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  MISSIONS LAYER (Orchestration)                                 │
│  Durable, long-running, complex branching                       │
│                                                                 │
│  • Survives Claude Code restarts                               │
│  • Complex decision trees (YAML/JSON state machine)            │
│  • Multi-session by design (days/weeks)                        │
│  • First-class human approval gates                            │
│  • Interfaces with FlowKit runtime                              │
│                                                                 │
│  Location: .harmony/missions/                                   │
│  Format: mission.yml (state machine) + mission.md (docs)        │
│                                                                 │
│                      │ invokes                                  │
│                      ▼                                          │
├─────────────────────────────────────────────────────────────────┤
│  SKILLS LAYER (Execution)                                       │
│  Single-session, composable, spec-compliant                     │
│                                                                 │
│  • Composable I/O contracts                                     │
│  • Required audit logging                                       │
│  • Progressive disclosure                                       │
│  • agentskills.io compliant                                     │
│  • Harness-agnostic (Claude Code, Cursor, Codex)               │
│                                                                 │
│  Location: .harmony/capabilities/skills/                                     │
│  Format: SKILL.md + references/                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

| Aspect | Skills | Missions |
|--------|--------|----------|
| **Duration** | Single session | Days/weeks |
| **State** | Stateless (outputs only) | Durable state machine |
| **Branching** | Simple (prose instructions) | Complex (formal DSL) |
| **Restarts** | Start over | Resume from checkpoint |
| **Human gates** | Optional prompts | First-class checkpoints |
| **Runtime** | Agent-interpreted | FlowKit orchestrated |
| **Spec** | agentskills.io | Custom (FlowKit-native) |
| **Invocation** | `/skill-name` or triggers | `/start-mission`, `/resume-mission` |

### How They Interact

Missions orchestrate skills as execution units:

```yaml
# .harmony/missions/auth-migration/mission.yml
name: auth-migration
goal: "Migrate from session-based to JWT authentication"
runtime: flowkit

states:
  - id: audit-codebase
    type: skill
    skill: refactor           # ← Invokes skill
    params:
      phase: audit            # Can invoke specific phase
      scope: "session → jwt"
    transitions:
      - on: audit_complete → plan-migration
      - on: scope_exceeds_50_files → human-review-scope

  - id: human-review-scope
    type: checkpoint          # ← First-class human gate
    prompt: "Scope exceeds 50 files. Approve continuation?"
    timeout: 72h              # Can wait days
    transitions:
      - on: approved → plan-migration
      - on: rejected → rescope
      - on: timeout → cancelled

  - id: plan-migration
    type: skill
    skill: refactor
    params:
      phase: plan
    transitions:
      - on: plan_ready → human-review-plan
      - on: blocking_dependencies → resolve-dependencies

  - id: resolve-dependencies
    type: skill
    skill: dependency-resolver  # Another skill
    transitions:
      - on: resolved → plan-migration
      - on: cannot_resolve → human-escalation

  # ... more states with complex branching
```

---

## Revised Migration Plan

### Phase 1: Consolidate Current Workflows → Skills

Migrate single-session procedural content to skills:

| Current Location | Migrate To | Rationale |
|------------------|------------|-----------|
| `.harmony/orchestration/workflows/refactor/` | `.harmony/capabilities/skills/refactor/` | Single-session, clear phases |
| `.harmony/orchestration/workflows/workspace/create-workspace/` | `.harmony/capabilities/skills/create-workspace/` | Single-session scaffolding |
| `.harmony/orchestration/workflows/workspace/update-workspace/` | `.harmony/capabilities/skills/update-workspace/` | Single-session update |
| `.harmony/orchestration/workflows/workspace/evaluate-workspace/` | `.harmony/capabilities/skills/evaluate-workspace/` | Single-session analysis |
| `.harmony/orchestration/workflows/skills/create-skill/` | `.harmony/capabilities/skills/create-skill/` | Single-session scaffolding |

### Phase 2: Deprecate Workflow Meta-Content

These become unnecessary after consolidation:

| Deprecate | Reason |
|-----------|--------|
| `.harmony/orchestration/workflows/workflows/create-workflow/` | No longer creating workflows |
| `.harmony/orchestration/workflows/workflows/update-workflow/` | No longer maintaining workflows |
| `.harmony/orchestration/workflows/workflows/evaluate-workflow/` | No longer evaluating workflows |
| `.harmony/orchestration/workflows/_template/` | Move to `.harmony/capabilities/skills/_template/` |

### Phase 3: Evolve Missions into Durable Orchestration

Transform the draft `missions/` concept into the orchestration layer:

| Current State | Target State |
|---------------|--------------|
| `.harmony/orchestration/workflows/missions/` (draft) | `.harmony/missions/` (production) |
| Prose-based steps | YAML state machine |
| No runtime | FlowKit integration |
| No durability | Checkpoint/resume semantics |

**Key Design Decisions for Missions:**

1. **State Machine Format**

   ```yaml
   # mission.yml - Formal state machine
   states:
     - id: state-name
       type: skill | checkpoint | branch | terminal
       # ... state-specific config
       transitions:
         - on: event → next-state
   ```

2. **Checkpoint Semantics**

   ```yaml
   - id: human-approval
     type: checkpoint
     prompt: "Review and approve the migration plan"
     timeout: 72h
     notify: ["slack://channel", "email://owner"]
     transitions:
       - on: approved → execute
       - on: rejected → revise
       - on: timeout → escalate
   ```

3. **Skill Invocation**

   ```yaml
   - id: run-refactor
     type: skill
     skill: refactor
     params:
       scope: "{{mission.scope}}"
     outputs:
       audit_report: "{{skill.outputs.report}}"
     transitions:
       - on: success → verify
       - on: failure → diagnose
   ```

4. **State Persistence**

   ```
   .harmony/orchestration/missions/<mission-id>/
   ├── state.json          # Current state, checkpoint data
   ├── history.json        # State transition history
   ├── outputs/            # Skill outputs collected here
   └── logs/               # Execution logs
   ```

### Phase 4: FlowKit Integration

Missions delegate execution to FlowKit:

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Claude Code     │────▶│  Mission Engine  │────▶│  FlowKit Runtime │
│  /start-mission  │     │  (state machine) │     │  (execution)     │
└──────────────────┘     └──────────────────┘     └──────────────────┘
                                │
                                ▼
                         ┌──────────────────┐
                         │  Skills          │
                         │  (invoked by     │
                         │   mission steps) │
                         └──────────────────┘
```

---

## Revised Recommendations Summary

### Original Recommendation (Unchanged for Single-Session)

**Consolidate workflows → skills** for single-session procedural tasks.

### New Recommendation (Durable Orchestration)

**Evolve missions into a durable orchestration primitive** that:

1. Uses YAML state machines (not prose)
2. Integrates with FlowKit for execution
3. Invokes skills as execution units
4. Provides first-class checkpoint/resume semantics
5. Supports complex decision trees with >5 branch points
6. Survives Claude Code restarts
7. Spans multiple sessions by design

### Naming Clarification

| Primitive | Purpose | Location |
|-----------|---------|----------|
| **Skills** | Single-session composable capabilities | `.harmony/capabilities/skills/` |
| **Missions** | Durable multi-session orchestration | `.harmony/missions/` |
| ~~Workflows~~ | **Deprecated** - consolidated into skills | ~~`.harmony/orchestration/workflows/`~~ |

### Decision Heuristic (Revised)

```
Is your task...
├── Completes in one session? → Skill
├── Needs to survive restarts? → Mission
├── Has >5 decision branches? → Mission
├── Spans days/weeks? → Mission
├── Simple multi-phase procedure? → Skill
└── Orchestrates multiple skills? → Mission
```

---

## Action Items (Revised)

### Immediate (Skills Migration)

1. Create `refactor` skill from workflow
2. Create `create-workspace` skill from workflow
3. Create `update-workspace` skill from workflow
4. Create `evaluate-workspace` skill from workflow
5. Create `create-skill` skill from workflow
6. Deprecate `.harmony/orchestration/workflows/` (except missions/)

### Near-Term (Missions Design)

7. Design mission.yml schema (state machine format)
8. Define checkpoint semantics (timeout, notify, resume)
9. Design skill invocation contract (params, outputs, transitions)
10. Define state persistence format
11. Create mission template

### Medium-Term (FlowKit Integration)

12. Design Mission Engine ↔ FlowKit interface
13. Implement checkpoint/resume in FlowKit
14. Add mission commands (`/start-mission`, `/resume-mission`, `/mission-status`)
15. Create first production mission (candidate: `auth-migration`)

---

## Documentation Updates (Revised)

| File | Change |
|------|--------|
| `docs/architecture/workspaces/skills/comparison.md` | Add missions comparison |
| `docs/architecture/workspaces/workflows.md` | Deprecation notice → point to skills |
| `docs/architecture/workspaces/missions.md` | **Create** - Mission primitive docs |
| `docs/architecture/workspaces/missions/schema.md` | **Create** - mission.yml schema |
| `docs/architecture/workspaces/missions/flowkit-integration.md` | **Create** - FlowKit integration |
| `.harmony/missions/_template/` | **Create** - Mission template |
| `CLAUDE.md` | Update with two-layer model |

---

## Conclusion (Revised)

The analysis establishes a **two-layer architecture**:

1. **Skills** (agentskills.io) — Single-session, composable capabilities with I/O contracts and audit logging. Migrate current workflow content here.

2. **Missions** (FlowKit-native) — Durable, multi-session orchestration with complex branching, formal state machines, and first-class human checkpoints. Evolve the draft missions concept into this primitive.

This architecture provides clear separation of concerns:

- Skills handle *what* to do (execution)
- Missions handle *when* and *in what order* (orchestration)

The "workflows" primitive is deprecated and consolidated into skills, eliminating the cognitive overhead of distinguishing between workflows and skills for single-session tasks.

## Should we extend the skills to integrate a workflow artifact for workflow archetype skills

This is a great question that gets at a key architectural boundary. Based on the analysis and existing patterns, **the answer is no** — workflow archetype skills should NOT include a separate formal workflow artifact (like `workflow.yml`). Here's why:

### The Two-Layer Architecture Already Solves This

The analysis establishes a clear separation:

| Layer | Format | Execution Model |
|-------|--------|-----------------|
| **Skills** | Prose instructions (SKILL.md + behaviors.md) | Agent-interpreted, single-session |
| **Missions** | YAML state machine (mission.yml) | Runtime-orchestrated, durable, multi-session |

Adding a `workflow.yml` to skills would blur this boundary and create the same cognitive load problem the analysis warned against.

### What Already Exists Works

The `refine-prompt` skill demonstrates the pattern. Look at `behaviors.md`:

```yaml
---
behavior:
  phases:
    - name: "Context Analysis"
      steps:
        - "Analyze repository structure and tech stack"
        - "Identify scope: files and modules the prompt likely touches"
        # ...
    - name: "Intent Extraction"
      steps:
        - "Parse raw prompt and identify core intent"
        # ...
# ... 10 phases total
---

# Behavior Reference

Detailed phase-by-phase behavior...
```

This gives you:

- **Structured phase/step metadata** in YAML frontmatter (machine-scannable)
- **Prose instructions** in the markdown body (agent-interpreted)

### Why NOT a Formal Workflow Artifact for Skills

| Concern | Why Prose Is Better for Skills |
|---------|--------------------------------|
| **Flexibility** | Agents can interpret conditional logic ("if X, do Y") without rigid branching syntax |
| **Cognitive load** | Users learn one format (SKILL.md), not two |
| **Verification gates** | Encode as prose with strong language ("you MAY NOT proceed until...") |
| **Loop-back logic** | "Return to Phase 4 if verification fails" is agent-interpreted |
| **agentskills.io compliance** | The spec doesn't define a workflow DSL |

### When You DO Need a State Machine

If a workflow needs:

- **Durable execution** (survives restarts)
- **>5 complex branch points** with formal transitions
- **Multi-session execution** (days/weeks)
- **Runtime orchestration** (FlowKit)

Then it's a **Mission**, not a skill. The analysis says:

> Skills handle *what* to do (execution)  
> Missions handle *when* and *in what order* (orchestration)

### Recommendation for Refactor Skill

Use the existing pattern:

```yaml
# references/behaviors.md frontmatter
---
behavior:
  phases:
    - name: "Define Scope"
      steps: [...]
      gate: null
    - name: "Audit"
      steps: [...]
      gate: null
    - name: "Plan"
      steps: [...]
      gate: null
    - name: "Execute"
      steps: [...]
      gate: null
    - name: "Verify"
      steps: [...]
      gate: "verification_passed"  # Semantic marker
      on_fail: "return_to_execute"
    - name: "Document"
      steps: [...]
      gate: null
  verification_gate:
    description: "All audit searches must return zero results"
    fail_action: "Return to Execute phase"
---
```

Then encode the verification loop in prose in the body:

```markdown
### Phase 5: Verification Gate (MANDATORY)

**Agent instruction:** This phase implements a mandatory gate. You may NOT 
proceed to Phase 6 until verification passes. If any audit search returns 
results, document them and RETURN TO PHASE 4.
```

This gives you structured metadata for tooling (if needed later) while keeping execution agent-interpreted — which is the skills layer's design.
