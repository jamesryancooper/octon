---
title: Reference Artifacts
description: Archetype-based reference file system for progressive disclosure in skills.
---

# Reference Artifacts

Reference files in the `references/` directory provide **progressive disclosure** — detailed content loaded only when needed. **Reference files are optional.** Choose the appropriate archetype based on your skill's complexity.

**Design Principle:** Keep individual reference files focused. Agents load these on demand, so smaller files mean less context usage.

---

## Skill Archetypes

Skills fall into **two archetypes** based on complexity, each with an optional expanded variant. Choose the archetype that matches your skill — simpler skills need fewer files.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Skill Archetypes                                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  UTILITY ────────────────────────────────────────────────────────────────── │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  SKILL.md only — all instructions, edge cases inline                │    │
│  │                                                                     │    │
│  │  Best for: Single-purpose skills with clear I/O                     │    │
│  │  Examples: format-json, validate-schema, count-tokens               │    │
│  │                                                                     │    │
│  │  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │    │
│  │                                                                     │    │
│  │  Optional (with examples):                                          │    │
│  │  ┌─────────────┐                                                    │    │
│  │  │  examples   │  ← Add when worked examples clarify behavior       │    │
│  │  │    .md      │                                                    │    │
│  │  └─────────────┘                                                    │    │
│  │                                                                     │    │
│  │  Best for: Simple skills where output format isn't obvious          │    │
│  │  Examples: summarize-text, extract-keywords, normalize-paths        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  WORKFLOW ───────────────────────────────────────────────────────────────── │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Core files:                                                        │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                    │    │
│  │  │io-contract  │ │  safety     │ │  examples   │                    │    │
│  │  │    .md      │ │    .md      │ │    .md      │                    │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘                    │    │
│  │  ┌─────────────┐ ┌─────────────┐                                    │    │
│  │  │ behaviors   │ │ validation  │                                    │    │
│  │  │    .md      │ │    .md      │                                    │    │
│  │  └─────────────┘ └─────────────┘                                    │    │
│  │                                                                     │    │
│  │  Optional (for domain-oriented skills):                             │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                    │    │
│  │  │  errors     │ │  glossary   │ │  <domain>   │                    │    │
│  │  │    .md      │ │    .md      │ │    .md      │                    │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘                    │    │
│  │                                                                     │    │
│  │  Best for: Multi-phase execution with defined steps                 │    │
│  │  Examples: refine-prompt, synthesize-research, audit-compliance     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

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

---

## Choosing an Archetype

**Two-step decision:**

> **Step 1: What kind of skill is this?**
>
> - **Utility** → Does one thing, obvious I/O → `SKILL.md` only (or with examples)
> - **Workflow** → Multi-phase, complex execution → Add core references (plus optional domain files)
>
> **Step 2: Does it need examples?**
>
> - **Utility** → Output format obvious? → `SKILL.md` only
> - **Utility** → Output format needs demonstration? → Add `examples.md`
> - **Workflow** → Always includes `examples.md` as a core file

### Decision Heuristics

| Question | If Yes → |
|----------|----------|
| Does the skill do one thing with obvious inputs/outputs? | **Utility** |
| Is the output format non-obvious or would users benefit from seeing examples? | **Utility (with examples)** |
| Do execution phases need documentation for correct execution? | **Workflow** |
| Does the skill operate in a specialized domain (finance, legal, security)? | **Workflow** + optional domain files |
| Does the skill require domain-specific terminology definitions? | **Workflow** + `glossary.md` |
| Does the skill have complex error handling or compliance requirements? | **Workflow** + `errors.md` |

---

## Archetype Definitions

### Utility Skill

Single-purpose skills with clear I/O and minimal documentation needs.

**Structure:**

```
<skill-name>/
└── SKILL.md              # All content in one file
```

**When to use:**

- Skill does one thing well
- Obvious inputs and outputs (1-2 inputs, 1 output)
- All instructions fit comfortably in a single file (complexity matters more than line count)
- No complex edge cases or domain-specific terminology
- Single-phase execution with clear success criteria
- Output format is self-explanatory

**Examples:** `format-json`, `validate-schema`, `count-tokens`, `generate-uuid`

**Upgrade signal:** If output format isn't obvious or users would benefit from seeing examples, add `examples.md`.

---

### Utility Skill (with examples)

Single-purpose skills where worked examples clarify expected behavior or output format.

**Structure:**

```
<skill-name>/
├── SKILL.md              # Core instructions
└── references/
    └── examples.md       # 2-3 worked input→output examples
```

**When to use:**

- Skill does one thing well (still single-purpose)
- Output format isn't immediately obvious from the description
- Users would benefit from seeing concrete input→output examples
- Edge cases exist that are best explained through examples
- All other instructions still fit in SKILL.md

**Examples:** `summarize-text`, `extract-keywords`, `normalize-paths`, `generate-slug`

**Upgrade signal:** If you need to document multi-phase execution, safety constraints, or I/O contracts beyond examples, upgrade to **Workflow**.

---

### Workflow Skill

Multi-phase execution skills with defined steps, examples, and validation criteria.

**Structure:**

```
<skill-name>/
├── SKILL.md              # Core instructions (<500 lines)
├── references/
│   ├── io-contract.md    # Inputs, outputs, dependencies, CLI usage
│   ├── safety.md         # Tool and file policies
│   ├── examples.md       # Full worked examples
│   ├── behaviors.md      # Phase-by-phase execution
│   ├── validation.md     # Acceptance criteria
│   ├── errors.md         # (optional) Error codes and recovery procedures
│   ├── glossary.md       # (optional) Domain-specific terminology
│   └── <domain>.md       # (optional) Domain-specific reference
├── scripts/              # Optional: executable code
└── assets/               # Optional: static resources
```

**When to use:**

- Multiple execution phases requiring step-by-step documentation
- Non-trivial safety constraints or tool permissions
- Formal validation criteria needed
- Needs worked examples for clarity
- Skills that will be maintained over time

**Examples:** `refine-prompt`, `synthesize-research`, `code-reviewer`, `audit-compliance`

**Core reference file purposes:**

| File | Purpose | Key Question |
|------|---------|--------------|
| `io-contract.md` | Input/output specifications, CLI usage | "What does it accept and produce?" |
| `safety.md` | Tool permissions, file policies, boundaries | "What can it do and not do?" |
| `examples.md` | Complete worked input→output examples | "What does it look like in practice?" |
| `behaviors.md` | Phase-by-phase execution workflow | "What happens during execution?" |
| `validation.md` | Acceptance criteria, quality checklist | "How do I know it worked?" |

**Optional reference files (for domain-oriented skills):**

| File | Purpose | Key Question |
|------|---------|--------------|
| `errors.md` | Error codes, recovery procedures, troubleshooting | "What happens when something goes wrong?" |
| `glossary.md` | Domain-specific terminology definitions | "What do these terms mean?" |
| `<domain>.md` | Domain-specific reference material | "What domain knowledge is needed?" |

> **Domain-Oriented Skills:** Skills operating in specialized domains (finance, legal, security, compliance, healthcare) should consider adding `glossary.md` for terminology consistency, `errors.md` for audit-trail-friendly error handling, and a domain-specific reference file (e.g., `compliance.md`, `hipaa.md`).

---

## Optional Domain-Oriented Reference Files

For Workflow skills operating in specialized domains, add these optional files as needed:

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

---

## Validation Expectations by Archetype

Each archetype has different expectations for how skill execution is validated:

| Archetype | Validation Approach | Where Documented |
|-----------|---------------------|------------------|
| **Utility** | Inline success criteria | SKILL.md (e.g., "Success: output is valid JSON") |
| **Utility (with examples)** | Examples as test cases | `examples.md` — output should match demonstrated patterns |
| **Workflow** | Formal acceptance checklist | `validation.md` — explicit criteria for each phase |

### Utility Skills

For Utility skills, include a brief success criterion in SKILL.md:

```markdown
## Success Criteria

- Output is valid JSON
- All input fields are preserved
- Formatting matches specified style
```

### Utility (with examples) Skills

Examples serve as implicit test cases. The agent should produce output that matches the patterns demonstrated in `examples.md`. Include at least one example for:

- Typical input → expected output
- Edge case input → expected handling

### Workflow Skills

Workflow skills require formal validation in `validation.md`:

- Acceptance criteria for each phase
- Quality checklist for final output
- Error conditions and expected handling

---

## File Classification Summary

| File | Archetype | Purpose |
|------|-----------|---------|
| `examples.md` | Utility (with examples), Workflow | Complete worked examples demonstrating skill behavior |
| `io-contract.md` | Workflow | Input/output specifications, dependencies, CLI usage |
| `safety.md` | Workflow | Tool permissions, file policies, behavioral boundaries |
| `behaviors.md` | Workflow | Phase-by-phase execution workflow |
| `validation.md` | Workflow | Acceptance criteria and quality checklist |
| `errors.md` | Workflow (optional) | Error codes, recovery procedures, troubleshooting |
| `glossary.md` | Workflow (optional) | Domain-specific terminology definitions |
| `<domain>.md` | Workflow (optional) | Domain-specific reference material |

> **Note:** The optional files (`errors.md`, `glossary.md`, `<domain>.md`) are recommended for Workflow skills operating in specialized domains (finance, legal, security, compliance, healthcare) where terminology consistency, formal error handling, or auditability is important.

**Single Source of Truth:** Commands, triggers, and tool requirements (`allowed-tools`) are defined in `manifest.yml` and `SKILL.md` frontmatter for machine routing. Reference files document these values in prose but do NOT duplicate them in YAML frontmatter. This prevents drift between multiple sources.

---

## Directory Structure by Archetype

### Utility

```
<skill-name>/
└── SKILL.md              # Required: all content in one file
```

### Utility (with examples)

```
<skill-name>/
├── SKILL.md              # Required: core instructions
└── references/
    └── examples.md       # Required: 2-3 worked input→output examples
```

### Workflow

```
<skill-name>/
├── SKILL.md              # Required: core instructions (<500 lines)
├── references/
│   ├── io-contract.md    # Core: inputs, outputs, dependencies, CLI usage
│   ├── safety.md         # Core: tool and file policies
│   ├── examples.md       # Core: full worked examples
│   ├── behaviors.md      # Core: phase-by-phase execution
│   ├── validation.md     # Core: acceptance criteria
│   ├── errors.md         # Optional: error codes and recovery procedures
│   ├── glossary.md       # Optional: domain-specific terminology
│   └── <domain>.md       # Optional: domain-specific (finance.md, legal.md, etc.)
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

## Core Workflow Reference Files

These files apply to **Workflow** skills. Copy from the template and fill in skill-specific values.

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

These files are optional additions for Workflow skills, particularly those operating in specialized domains. Create from scratch based on skill requirements.

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
│     │ • Single-purpose, obvious I/O?  ──────▶ Utility (SKILL.md only)       │
│     │ • Multi-phase execution?        ──────▶ Workflow (+ references/)      │
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
│  3. ADD REFERENCE FILES (if Workflow)                                       │
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

| File | Archetype | Key Question It Answers |
|------|-----------|-------------------------|
| `examples.md` | Utility (with examples), Workflow | "What does this look like in practice?" |
| `io-contract.md` | Workflow | "What does this skill accept, produce, and how do I run it?" |
| `safety.md` | Workflow | "What can this skill do and not do?" |
| `behaviors.md` | Workflow | "What happens during execution?" |
| `validation.md` | Workflow | "How do I know it worked?" |
| `errors.md` | Workflow (optional) | "What happens when something goes wrong?" |
| `glossary.md` | Workflow (optional) | "What do these terms mean?" |
| `<domain>.md` | Workflow (optional) | "What domain knowledge is needed?" |

**Note:** Commands and triggers are defined in `manifest.yml` and `registry.yml`, not in reference files. This single-source-of-truth approach prevents duplication and drift.

### Archetype Summary

| Archetype | Structure | When to Use |
|-----------|-----------|-------------|
| **Utility** | `SKILL.md` only | Single-purpose, obvious I/O, output format self-explanatory |
| **Utility (with examples)** | `SKILL.md` + `examples.md` | Single-purpose, but output format benefits from demonstration |
| **Workflow** | `SKILL.md` + 5 core refs | Multi-phase execution, safety constraints, formal validation |
| **Workflow (domain)** | Workflow + optional refs | Specialized domain requiring glossary, error codes, or domain docs |

---

## See Also

- [Skill Format](./skill-format.md) — SKILL.md structure
- [Architecture](./architecture.md) — Progressive disclosure model
- [Creation](./creation.md) — Creating new skills with reference files
