---
title: Reference Artifacts
description: Reference file system for progressive disclosure in skills.
---

# Reference Artifacts

Reference files in the `references/` directory provide **progressive disclosure** — detailed content loaded only when needed. Each reference file has **YAML frontmatter** for machine parsing and a **Markdown body** for human reading.

This document describes the reference file system, including which files are universal across all skills, which require customization, and which are recommended additions.

---

## Overview

```markdown
┌─────────────────────────────────────────────────────────────────────────────┐
│  Reference File Classification                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  UNIVERSAL (copy from template, minimal customization)              │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐    │    │
│  │  │io-contract  │ │  safety     │ │  triggers   │ │  examples   │    │    │
│  │  │    .md      │ │    .md      │ │    .md      │ │    .md      │    │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  PARTIALLY GENERALIZABLE (structure universal, content customized)  │    │
│  │  ┌─────────────┐ ┌─────────────┐                                    │    │
│  │  │ behaviors   │ │ validation  │                                    │    │
│  │  │    .md      │ │    .md      │                                    │    │
│  │  └─────────────┘ └─────────────┘                                    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  RECOMMENDED ADDITIONS (optional, add as needed)                    │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐    │    │
│  │  │  errors     │ │  glossary   │ │integration  │ │   FORMS     │    │    │
│  │  │    .md      │ │    .md      │ │    .md      │ │    .md      │    │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Classification Summary

| File | Classification | What to Copy | What to Customize |
|------|----------------|--------------|-------------------|
| `io-contract.md` | **Universal** | Entire structure | Input/output names, types, paths |
| `safety.md` | **Universal** | Tool policy, file policy, destructive actions | Allowed tools, behavioral boundaries, escalation triggers |
| `triggers.md` | **Universal** | Entire structure | Commands, triggers, parameters |
| `examples.md` | **Universal** | Entire structure | Example inputs, outputs, notes |
| `behaviors.md` | **Partial** | Phase/steps/goals structure | Phase names, step details, reference tables |
| `validation.md` | **Partial** | Checklist structure, output rules | Acceptance criteria, scope limits |
| `errors.md` | **Recommended** | Create from scratch | All content (skill-specific) |
| `glossary.md` | **Recommended** | Create from scratch | All content (domain-specific) |
| `integration.md` | **Recommended** | Create from scratch | All content (composition-specific) |
| `FORMS.md` | **Recommended** | Create from scratch | All content (domain-specific) |

---

## Directory Structure

```markdown
<skill-name>/
├── SKILL.md              # Required: core instructions (<500 lines)
├── references/           # Optional: progressive disclosure
│   ├── io-contract.md    # Universal: inputs, outputs, dependencies
│   ├── safety.md         # Universal: tool and file policies
│   ├── triggers.md       # Universal: commands, invocation patterns
│   ├── examples.md       # Universal: full worked examples
│   ├── behaviors.md      # Partial: phase-by-phase execution
│   ├── validation.md     # Partial: acceptance criteria
│   ├── errors.md         # Recommended: error handling (if complex)
│   ├── glossary.md       # Recommended: terminology (if domain-specific)
│   ├── integration.md    # Recommended: composition (if composable)
│   └── FORMS.md          # Recommended: templates (if structured I/O)
├── scripts/              # Optional: executable code
└── assets/               # Optional: static resources
```

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

## Universal Reference Files

These files have **standardized structure and content** that applies to all skills. Copy from the template and fill in skill-specific values.

### `io-contract.md` — Input/Output Contract

**Purpose:** Defines what the skill accepts and produces, enabling agents to validate inputs and route outputs correctly.

**Why Universal:** Every skill has inputs and outputs. The schema structure is identical across all skills.

**When to Load:** When agent needs to validate input format or determine output location.

**YAML Schema:**

```yaml
---
inputs:
  - name: "[input_name]"           # Unique identifier
    type: text|boolean|file|folder # Data type
    required: true|false           # Whether input is mandatory
    path_hint: "[hint]"            # Where to find/expect input
    schema: null|"[schema_ref]"    # Optional JSON schema reference
    description: "[description]"   # Human-readable purpose

outputs:
  - name: "[output_name]"          # Unique identifier
    type: markdown|json|log        # Output format
    path: "[output_path]"          # Where output is written
    format: "[format]"             # File format details
    determinism: stable|variable   # Whether output is reproducible
    description: "[description]"   # Human-readable purpose

requires:
  tools:                           # Required tool permissions
    - filesystem.read
    - filesystem.write.outputs
  packages: []                     # External package dependencies
  services: []                     # External service dependencies

depends_on: []                     # Other skills this depends on
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Inputs` | Table with Name, Type, Required, Description columns |
| `## Outputs` | Subsection per output with path, format, content description |
| `## Output Structure` | Example of expected output format |
| `## Dependencies` | Prose explanation of required tools and external dependencies |

**Template Usage:**

1. Copy `_template/references/io-contract.md`
2. Replace `[input_name]` placeholders with actual input names
3. Define all outputs with correct paths (use `<timestamp>` placeholder)
4. List required tools (start with standard set, add as needed)
5. Add output structure example

---

### `safety.md` — Safety Policies

**Purpose:** Defines security boundaries, tool permissions, and behavioral constraints that prevent harmful actions.

**Why Universal:** Every skill must operate within defined boundaries. The deny-by-default model applies universally.

**When to Load:** Before execution to verify permissions; when agent encounters boundary condition.

**YAML Schema:**

```yaml
---
safety:
  tool_policy:
    mode: deny-by-default         # Always deny-by-default
    allowed:                       # Explicit allowlist
      - filesystem.read
      - filesystem.write.outputs
      - filesystem.glob
      - filesystem.grep
  file_policy:
    write_scope:                   # Paths where writing is allowed
      - ".workspace/skills/outputs/**"   # Tier 1: Default (always allowed)
      - ".workspace/skills/logs/**"      # Tier 1: Logs (always allowed)
      # Tier 2 & 3: Custom paths as defined in registry I/O mapping
      # Must be within workspace's hierarchical scope
    scope_authority:               # Hierarchical scope rules
      down: allowed                # Can write into descendant workspaces
      up: blocked                  # Cannot write into ancestor workspaces
      sideways: blocked            # Cannot write into sibling workspaces
    destructive_actions: never     # Always 'never'
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Tool Policy` | Table of allowed tools with purpose for each |
| `## File Policy` | Write scope paths by tier and hierarchical scope authority |
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

**Customization Points:**

| Element | What to Customize |
|---------|-------------------|
| `allowed` tools | Add skill-specific tools (e.g., `network.fetch` for web skills) |
| `write_scope` | Tier 2/3 paths defined in registry (must be within hierarchical scope) |
| Behavioral Boundaries | Add skill-specific must/must-not rules |
| Escalation Triggers | Add skill-specific conditions |

---

### `triggers.md` — Invocation Patterns

**Purpose:** Defines how users invoke the skill — commands, explicit patterns, and natural language triggers.

**Why Universal:** Every skill needs documented invocation methods. The structure is identical across skills.

**When to Load:** During skill discovery and routing; when user asks how to invoke.

**YAML Schema:**

```yaml
---
commands:
  - /skill-name                    # Primary slash command

explicit_call_patterns:
  - "use skill: skill-name"        # Explicit skill invocation

triggers:                          # Natural language activation
  - "[phrase 1]"
  - "[phrase 2]"
  - "[phrase 3]"
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Commands` | List of slash commands with descriptions |
| `## Explicit Call Patterns` | Literal phrases that invoke skill |
| `## Natural Language Triggers` | Phrases that activate skill via matching |
| `## Parameters` | Subsection per parameter with examples |
| `## Example Invocations` | Code block with multiple usage examples |

**Template Usage:**

1. Copy `_template/references/triggers.md`
2. Replace `/skill-name` with actual command
3. Add 3-6 natural language triggers (verb phrases that describe intent)
4. Document all parameters with type, default, and examples
5. Provide 3-5 example invocations covering common use cases

---

### `examples.md` — Worked Examples

**Purpose:** Provides complete input-to-output examples that demonstrate skill behavior and serve as test cases.

**Why Universal:** Every skill benefits from concrete examples. The structure is identical across skills.

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

## Partially Generalizable Reference Files

These files have **universal structure** but require **skill-specific content**. Copy the structure from the template, then customize the content.

### `behaviors.md` — Phase-by-Phase Execution

**Purpose:** Documents the detailed execution workflow — what the skill does in each phase, in what order, and why.

**Why Partial:** The phase/steps/goals structure is universal, but the specific phases and steps are unique to each skill.

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
        - "Save to outputs/[category]/<timestamp>-[name].md"
        - "Log to logs/runs/<timestamp>-skill-name.md"
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
    - "Save to outputs/[category]/<timestamp>-[name].md"
    - "Log execution to logs/runs/"
```

**Customization Guide:**

| Element | How to Customize |
|---------|------------------|
| Phase names | Use action-oriented names: "Context Analysis", "Transformation", "Validation" |
| Steps | 2-5 steps per phase; each step is a discrete, verifiable action |
| Goals | 2-5 goals; order by priority |
| Reference tables | Add lookup tables for categories, levels, patterns as needed |

**Markdown Body Structure:**

```markdown
# Behavior Reference

## Phase 1: [Phase Name]

[One-paragraph description of what this phase accomplishes]

1. **[Step 1 name]**
   - [Detail 1]
   - [Detail 2]

2. **[Step 2 name]**
   - [Detail 1]
   - [Detail 2]

## Phase N: Output

Produce the final output:
1. **Structure output** — [formatting guidance]
2. **Save artifacts** — Write to designated paths
3. **Log execution** — Record run metadata

## [Optional Reference Tables]

| Category | Description |
|----------|-------------|
| [Item 1] | [Description] |
```

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

**Why Partial:** The checklist structure and output rules are universal, but specific acceptance criteria are skill-unique.

**When to Load:** After execution to verify success; when defining test cases.

**YAML Schema:**

```yaml
---
acceptance_criteria:
  - "[Skill-specific criterion 1]"
  - "[Skill-specific criterion 2]"
  - "Output exists in outputs/[category]/"    # Universal
  - "Run log captures input, context, and output"  # Universal
---
```

**Universal Criteria (always include):**

```yaml
acceptance_criteria:
  - "Output exists in outputs/[category]/"
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

**Customization Points:**

| Element | What to Customize |
|---------|-------------------|
| Acceptance criteria | Add skill-specific success conditions |
| Scope limits | Define maximum items, file counts, complexity bounds |
| Output path patterns | Specify category subdirectory and naming convention |

---

## Recommended Additional Reference Files

These files are **optional** but add value for specific skill types. Create from scratch as needed.

### `errors.md` — Error Handling (High Priority)

**Purpose:** Documents error conditions, recovery procedures, and troubleshooting guidance.

**When to Add:** When skill has complex failure modes, external dependencies, or user-facing error messages.

**Priority:** **High** — Missing from current template; valuable for production skills.

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
    message: "File not found: {path}"
    action: "Escalate to user with file path; suggest alternatives"

  - code: "E002"
    condition: "Scope exceeds maximum (>20 files)"
    severity: warning
    message: "Scope too large: {count} files"
    action: "Suggest narrowing focus; offer to proceed with subset"

  - code: "E003"
    condition: "External service unavailable"
    severity: fatal
    message: "Cannot reach {service}"
    action: "Abort with clear error; suggest retry later"

fallback_behavior: "Log partial results if any; preserve user input for retry"
---
```

---

### `glossary.md` — Terminology (Medium Priority)

**Purpose:** Defines domain-specific terms used by the skill, ensuring consistent understanding.

**When to Add:** When skill operates in a specialized domain (finance, legal, security) or introduces its own terminology.

**Priority:** **Medium** — Valuable for complex or domain-specific skills.

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

### `integration.md` — Skill Composition (Medium Priority)

**Purpose:** Documents how the skill composes with other skills in pipelines and workflows.

**When to Add:** When skill is designed to be part of larger workflows; when output feeds other skills.

**Priority:** **Medium** — Valuable for composable skill ecosystems.

**YAML Schema:**

```yaml
---
integration:
  upstream:                        # Skills that can feed this one
    - skill_id: "[skill-id]"
      handoff: "[what this skill receives]"

  downstream:                      # Skills this can feed
    - skill_id: "[skill-id]"
      handoff: "[what this skill provides]"

  pipelines:                       # Pre-defined pipeline compositions
    - id: "[pipeline-id]"
      sequence: ["[skill1]", "[this-skill]", "[skill3]"]
      description: "[what the pipeline accomplishes]"
---
```

**Markdown Body Sections:**

| Section | Content |
|---------|---------|
| `## Upstream Skills` | Skills that produce input for this skill |
| `## Downstream Skills` | Skills that consume this skill's output |
| `## Pipeline Patterns` | Common multi-skill workflows |
| `## Handoff Protocols` | Format and conventions for inter-skill communication |

**Example Content:**

```yaml
---
integration:
  upstream:
    - skill_id: "gather-requirements"
      handoff: "Raw requirements text to be refined"

  downstream:
    - skill_id: "execute-task"
      handoff: "Refined prompt ready for execution"
    - skill_id: "review-output"
      handoff: "Execution results for review"

  pipelines:
    - id: "full-task-pipeline"
      sequence: ["gather-requirements", "refine-prompt", "execute-task", "review-output"]
      description: "End-to-end task execution with refinement and review"
---
```

---

### `FORMS.md` — Structured Templates (Low Priority)

**Purpose:** Provides form templates and structured data formats for complex inputs or outputs.

**When to Add:** When skill accepts structured input (questionnaires, checklists) or produces structured output (reports, assessments).

**Priority:** **Low** — Add when skill requires structured data interchange.

**Markdown Structure:**

```markdown
# Forms Reference

## Input Forms

### [Form Name]

Use this form when [condition].

```yaml
# [Form Name] Input
field_1: "[value]"
field_2:
  - item_1
  - item_2
field_3: |
  Multi-line
  content
```

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `field_1` | text | Yes | [Description] |
| `field_2` | list | No | [Description] |

## Output Templates

### [Template Name]

```markdown
# [Output Title]

## Section 1
{field_1}

## Section 2
{field_2}
```

```markdown

---

## Implementation Workflow

When creating a new skill, follow this sequence for reference files:

```markdown

┌─────────────────────────────────────────────────────────────────────────────┐
│  Reference File Implementation Workflow                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. COPY UNIVERSAL FILES                                                    │
│     ┌──────────────┐                                                        │
│     │ _template/   │──copy──▶ io-contract.md ──▶ Fill input/output specs    │
│     │ references/  │──copy──▶ safety.md ──────▶ Add tool permissions        │
│     │              │──copy──▶ triggers.md ────▶ Add commands/triggers       │
│     │              │──copy──▶ examples.md ────▶ Add worked examples         │
│     └──────────────┘                                                        │
│           │                                                                 │
│           ▼                                                                 │
│  2. CUSTOMIZE PARTIAL FILES                                                 │
│     ┌──────────────┐                                                        │
│     │_template/   │──copy──▶ behaviors.md ───▶ Define phases & steps        │
│     │ references/  │──copy──▶ validation.md ──▶ Define acceptance criteria  │
│     └──────────────┘                                                        │
│           │                                                                 │
│           ▼                                                                 │
│  3. ASSESS NEED FOR ADDITIONAL FILES                                        │
│     ┌────────────────────────────────────────┐                              │
│     │ Does skill have complex error modes?   │──yes──▶ Add errors.md        │
│     │ Does skill use domain terminology?     │──yes──▶ Add glossary.md      │
│     │ Is skill part of pipelines?            │──yes──▶ Add integration.md   │
│     │ Does skill need structured I/O?        │──yes──▶ Add FORMS.md         │
│     └────────────────────────────────────────┘                              │
│           │                                                                 │
│           ▼                                                                 │
│  4. VALIDATE COMPLETENESS                                                   │
│     □ All universal files present and filled                                │
│     □ Behaviors cover full execution workflow                               │
│     □ Validation criteria match skill outputs                               │
│     □ Examples demonstrate primary use cases                                │
│     □ Safety boundaries are comprehensive                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

```

---

## Quick Reference: File Purposes

| File | One-Line Purpose | Key Question It Answers |
|------|------------------|-------------------------|
| `io-contract.md` | What goes in, what comes out | "What does this skill accept and produce?" |
| `safety.md` | What's allowed, what's forbidden | "What can this skill do and not do?" |
| `triggers.md` | How to invoke the skill | "How do I run this skill?" |
| `examples.md` | Concrete demonstrations | "What does this look like in practice?" |
| `behaviors.md` | Step-by-step execution | "What happens during execution?" |
| `validation.md` | Success criteria | "How do I know it worked?" |
| `errors.md` | Failure handling | "What happens when something goes wrong?" |
| `glossary.md` | Term definitions | "What do these terms mean?" |
| `integration.md` | Composition patterns | "How does this work with other skills?" |
| `FORMS.md` | Structured templates | "What format should input/output use?" |

---

## See Also

- [Skill Format](./skill-format.md) — SKILL.md structure
- [Architecture](./architecture.md) — Progressive disclosure model
- [Creation](./creation.md) — Creating new skills with reference files
