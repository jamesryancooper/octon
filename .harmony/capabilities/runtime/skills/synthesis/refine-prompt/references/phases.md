---
behavior:
  phases:
    - name: "Context Analysis"
      steps:
        - "Analyze repository structure and tech stack"
        - "Identify scope: files and modules the prompt likely touches"
        - "Load project constraints from .harmony/cognition/context/constraints.md"
        - "Find existing patterns relevant to the request"
    - name: "Intent Extraction"
      steps:
        - "Parse raw prompt and identify core intent"
        - "Expand implicit goals into explicit requirements"
        - "Correct spelling, grammar, and formatting"
        - "Remove contradictions or flag for clarification"
    - name: "Persona Assignment"
      steps:
        - "Determine appropriate expertise level for the task"
        - "Assign execution persona (role, perspective, depth)"
        - "Set tone and style expectations"
    - name: "Reference Injection"
      steps:
        - "Add specific file paths the task will touch"
        - "Include relevant function/class names"
        - "Reference existing patterns to follow"
        - "Align with project naming and style conventions"
    - name: "Negative Constraints"
      steps:
        - "Identify anti-patterns to avoid"
        - "List forbidden approaches based on project rules"
        - "Surface common mistakes for this type of task"
        - "Define what NOT to do"
    - name: "Decomposition"
      steps:
        - "Break complex requests into ordered sub-tasks"
        - "Identify dependencies between sub-tasks"
        - "Order tasks by logical execution sequence"
    - name: "Validation"
      steps:
        - "Check feasibility given codebase state"
        - "Identify potential risks and breaking changes"
        - "Flag edge cases and dependencies"
        - "Define measurable success criteria"
    - name: "Self-Critique"
      steps:
        - "Review refined prompt for completeness"
        - "Check for missing context or ambiguity"
        - "Verify all assumptions are stated"
        - "Ensure success criteria are measurable"
        - "Fix any gaps found"
    - name: "Intent Confirmation"
      steps:
        - "Summarize understanding of the request"
        - "Present key decisions and assumptions"
        - "Ask user to confirm or correct"
        - "Incorporate feedback if provided"
    - name: "Output"
      steps:
        - "Structure refined prompt with all context"
        - "Save to .harmony/scaffolding/prompts/{{timestamp}}-refined.md"
        - "Log execution to _ops/state/logs/refine-prompt/"
        - "Optionally execute the refined prompt"
  goals:
    - "Ground the prompt in actual codebase context"
    - "Determine the true intent behind the raw prompt"
    - "Assign appropriate execution persona"
    - "Fill gaps with codebase-informed assumptions"
    - "Inject specific references (files, patterns, conventions)"
    - "Define what NOT to do (anti-patterns, forbidden approaches)"
    - "Decompose complex requests into actionable sub-tasks"
    - "Validate feasibility and identify risks"
    - "Self-critique to catch gaps before finalization"
    - "Confirm intent with user to prevent wasted effort"
    - "Produce a clear, actionable, context-aware refined prompt"
---

# Behavior Reference

Detailed phase-by-phase behavior for the refine-prompt skill.

## Phase 1: Context Analysis

Before refining, understand the codebase:

1. **Analyze repository**
   - Detect tech stack (languages, frameworks, build tools)
   - Map directory structure and module boundaries
   - Identify architectural patterns in use

2. **Identify scope**
   - Find files/modules the prompt likely touches
   - Use keyword matching and semantic analysis
   - Note related files that may need updates

3. **Load constraints**
   - Read `.harmony/cognition/context/constraints.md` if present
   - Check for project-specific rules (testing requirements, style guides)
   - Note any "always" or "never" rules that apply

4. **Find prior art**
   - Locate similar patterns already in the codebase
   - Find related implementations to reference
   - Identify conventions to follow

## Phase 2: Intent Extraction

Parse and clarify the raw prompt:

1. **Parse intent**
   - Identify the core goal and desired outcome
   - Note implicit assumptions and unstated context
   - Distinguish between requirements and preferences

2. **Expand scope**
   - Convert implicit goals into explicit requirements
   - Add context that makes the prompt self-contained
   - Fill gaps with codebase-informed assumptions

3. **Correct errors**
   - Fix spelling mistakes
   - Correct grammar issues
   - Improve formatting and structure

4. **Resolve ambiguity**
   - Identify contradictory statements
   - Resolve contradictions using codebase context
   - Flag unresolvable conflicts for user input

## Phase 3: Persona Assignment

Define who should execute this prompt:

1. **Determine expertise level**
   - Junior: Simple, well-documented tasks
   - Mid-level: Standard features, moderate complexity
   - Senior: Architecture decisions, complex refactoring
   - Principal/Staff: Cross-cutting concerns, system design

2. **Assign role perspective**
   - Backend engineer, Frontend developer, DevOps, Security engineer, etc.
   - Full-stack if task spans multiple areas
   - Specialist if domain expertise needed

3. **Set execution style**
   - Thorough vs. quick iteration
   - Conservative vs. innovative
   - Verbose documentation vs. minimal comments

4. **Define success mindset**
   - What does "excellent" look like for this task?
   - What quality bar should be met?

## Phase 4: Reference Injection

Ground the prompt in specific codebase details:

1. **Add file references**
   - List specific files that will be modified
   - Include paths to related files for context
   - Note files that may need coordinated changes

2. **Include code references**
   - Name specific functions, classes, or modules
   - Reference line numbers for targeted changes
   - Include type signatures where helpful

3. **Reference patterns**
   - Point to existing implementations as examples
   - Note conventions to follow (naming, structure, style)
   - Include test patterns if tests are needed

4. **Align conventions**
   - Match project naming conventions
   - Follow existing code organization patterns
   - Respect architectural boundaries

## Phase 5: Negative Constraints

Define what NOT to do:

1. **Identify anti-patterns**
   - Common mistakes for this type of task
   - Anti-patterns present elsewhere in codebase to avoid replicating
   - Known problematic approaches

2. **List forbidden approaches**
   - Approaches that violate project constraints
   - Deprecated patterns or APIs
   - Security-sensitive operations to avoid

3. **Surface project-specific rules**
   - "Never" rules from constraints.md
   - Team conventions that must be followed
   - Architectural boundaries not to cross

4. **Define scope boundaries**
   - What's out of scope for this task
   - Related changes to explicitly NOT make
   - Future work to defer (not solve now)

## Phase 6: Decomposition

Break complex requests into manageable pieces:

1. **Identify sub-tasks**
   - Break the request into discrete, atomic tasks
   - Each sub-task should be independently completable
   - Aim for 2-7 sub-tasks depending on complexity

2. **Map dependencies**
   - Identify which tasks depend on others
   - Note shared resources or potential conflicts
   - Flag tasks that can run in parallel

3. **Order execution**
   - Sequence tasks by logical dependency
   - Group related changes together
   - Place validation/testing steps appropriately

## Phase 7: Validation

Verify the refined prompt is achievable:

1. **Check feasibility**
   - Verify referenced files exist
   - Confirm patterns being referenced are applicable
   - Check for missing dependencies or prerequisites

2. **Identify risks**
   - Flag potential breaking changes
   - Note files with many dependents
   - Identify security-sensitive areas

3. **Surface edge cases**
   - List scenarios that need handling
   - Note error conditions to consider
   - Identify integration points that may break

4. **Define success criteria**
   - Specify measurable "done" conditions
   - Include verification steps (tests, manual checks)
   - Define rollback criteria if applicable

## Phase 8: Self-Critique

Review the refined prompt before finalization:

1. **Completeness check**
   - Is all necessary context included?
   - Are there gaps in the requirements?
   - Would someone unfamiliar with the codebase understand this?

2. **Ambiguity check**
   - Are there any remaining unclear terms?
   - Could any requirement be interpreted multiple ways?
   - Are all assumptions explicitly stated?

3. **Feasibility check**
   - Is the scope realistic?
   - Are the success criteria measurable?
   - Are there any contradictions?

4. **Quality check**
   - Is the persona appropriate?
   - Are the negative constraints comprehensive?
   - Is the decomposition logical?

5. **Fix gaps**
   - Address any issues found
   - Add missing context
   - Clarify ambiguities

## Phase 9: Intent Confirmation

Verify understanding with the user:

1. **Summarize understanding**
   - State the core intent in one sentence
   - List the key requirements (3-5 bullets)
   - Note the most significant assumptions

2. **Present key decisions**
   - Highlight choices made during refinement
   - Explain reasoning for non-obvious decisions
   - Flag any areas of uncertainty

3. **Request confirmation**
   - Ask user: "Is this what you intended?"
   - Provide option to adjust or proceed
   - If `skip_confirmation=true`, skip this step

4. **Incorporate feedback**
   - If user provides corrections, update the prompt
   - Re-run self-critique if significant changes made
   - Document any changes from original refinement

## Phase 10: Output

Produce the final refined prompt:

1. **Structure output**
   - Organize with clear sections
   - Lead with persona, then context, then requirements
   - End with negative constraints and success criteria

2. **Save artifacts**
   - Write to `.harmony/scaffolding/prompts/{{timestamp}}-refined.md`
   - Log to `_ops/state/logs/refine-prompt/{{timestamp}}-refine-prompt.md`

3. **Execute (optional)**
   - If `--execute`, run the refined prompt
   - Report execution result

## Context Depth Levels

| Level | Behavior |
|-------|----------|
| `minimal` | Skip repo analysis, basic intent expansion only |
| `standard` | Analyze immediate scope, find relevant patterns (default) |
| `deep` | Full repo analysis, dependency mapping, comprehensive risk assessment |

## Persona Selection Guide

| Task Type | Recommended Persona |
|-----------|---------------------|
| Bug fix (isolated) | Mid-level engineer, focused, minimal changes |
| New feature | Senior engineer, thorough, well-documented |
| Refactoring | Senior/Principal engineer, conservative, comprehensive testing |
| Performance optimization | Senior engineer with perf focus, data-driven |
| Security fix | Security-focused engineer, paranoid, thorough |
| Documentation | Technical writer perspective, clear, comprehensive |
| API design | Principal engineer, API design expertise, future-proof |

## Common Anti-Patterns by Task Type

| Task Type | Common Anti-Patterns |
|-----------|---------------------|
| Bug fix | Over-engineering, fixing unrelated code, missing root cause |
| New feature | Scope creep, premature optimization, insufficient error handling |
| Refactoring | Changing behavior, incomplete migration, breaking interfaces |
| Performance | Micro-optimizations, premature caching, sacrificing readability |
| Security | Security through obscurity, incomplete validation, logging secrets |
