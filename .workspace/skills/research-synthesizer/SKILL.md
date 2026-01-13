---
# Identity
id: "research-synthesizer"
name: "Research Synthesizer"
version: "1.0.0"
summary: "Synthesize scattered research notes into coherent findings. Use when consolidating research."
description: |
  Transforms scattered research notes into a coherent, structured findings document.
  Use this skill when you need to consolidate research, summarize findings across
  multiple files, or create a synthesis document from dispersed notes.
access: agent

# Provenance
author:
  name: "Harmony Workspace"
  contact: "workspace@harmony"
created_at: "2025-01-12"
updated_at: "2025-01-12"
license: "MIT"

# Invocation
commands:
  - /synthesize-research
explicit_call_patterns:
  - "use skill: research-synthesizer"
triggers:
  - "synthesize my research"
  - "consolidate findings"
  - "summarize research notes"

# I/O Contract
inputs:
  - name: research_folder
    type: folder
    required: true
    path_hint: ".scratch/projects/<project>/ or sources/<topic>/"
    schema: null
    description: "Folder containing research notes, logs, and findings"

outputs:
  - name: synthesis_document
    type: markdown
    path: "outputs/drafts/<topic>-synthesis.md"
    format: "markdown"
    determinism: "stable"
    description: "Consolidated findings document"
  - name: run_log
    type: log
    path: "logs/runs/<timestamp>-research-synthesizer.md"
    format: "yaml-frontmatter-markdown"
    determinism: "stable"

# Dependencies
requires:
  tools:
    - filesystem.read
    - filesystem.write.outputs
  packages: []
  services: []
depends_on: []

# Safety Policies
safety:
  tool_policy:
    mode: deny-by-default
    allowed:
      - filesystem.read
      - filesystem.write.outputs
  file_policy:
    write_scope:
      - ".workspace/skills/outputs/**"
      - ".workspace/skills/logs/**"
    destructive_actions: never

# Behavior (structured for machine parsing)
behavior:
  goals:
    - "Consolidate dispersed research into a single coherent document"
    - "Identify and organize findings by theme"
    - "Surface contradictions and resolve or flag them"
    - "Highlight remaining gaps and open questions"
    - "Produce audit trail via run log"
  steps:
    - "Read all .md files in the input folder"
    - "Extract explicit findings, insights, and conclusions"
    - "Group related findings into 3-7 themes"
    - "Write executive summary and themed sections"
    - "Write outputs to declared paths and run log"

# Validation
acceptance_criteria:
  - "Synthesis document exists in outputs/drafts/"
  - "Document includes executive summary"
  - "Key findings are organized by theme"
  - "Open questions are clearly listed"
  - "Run log captures inputs and outputs"

# Examples (for testing and documentation)
examples:
  - input: ".scratch/projects/auth-patterns/"
    invocation: "/synthesize-research .scratch/projects/auth-patterns/"
    output: "outputs/drafts/auth-patterns-synthesis.md"
    description: "Synthesize authentication pattern research"
  - input: "sources/api-design/"
    invocation: "/synthesize-research sources/api-design/"
    output: "outputs/drafts/api-design-synthesis.md"
    description: "Consolidate API design research notes"
---

# Skill: research-synthesizer

## Mission

Transform scattered research notes into a coherent, structured findings document that distills key insights, identifies themes, and highlights gaps.

## Behavior

### Goals

1. Consolidate dispersed research into a single coherent document
2. Identify and organize findings by theme
3. Surface contradictions and resolve or flag them
4. Highlight remaining gaps and open questions
5. Produce audit trail via run log

### Steps

1. **Gather materials**
   - Read all `.md` files in the input folder
   - Identify `project.md`, `log.md`, `findings.md` if present
   - Note the research goal and key questions

2. **Extract findings**
   - Pull out explicit findings, insights, and conclusions
   - Note supporting evidence for each
   - Flag contradictions or uncertain claims

3. **Identify themes**
   - Group related findings into 3-7 themes
   - Name each theme descriptively
   - Order themes by importance or logical flow

4. **Synthesize**
   - Write executive summary (3-5 sentences)
   - For each theme:
     - State the key insight
     - Provide supporting evidence
     - Note confidence level (high/medium/low)
   - List resolved contradictions
   - List open questions and gaps

5. **Write outputs**
   - Write synthesis to `outputs/drafts/<topic>-synthesis.md`
   - Write run log to `logs/runs/<timestamp>-research-synthesizer.md`

## Output Format

```markdown
# Research Synthesis: [Topic]

**Generated:** [timestamp]
**Source:** [input folder path]

## Executive Summary

[3-5 sentence overview of key findings]

## Key Themes

### Theme 1: [Name]

**Insight:** [Clear statement]

**Evidence:**
- [Supporting point 1]
- [Supporting point 2]

**Confidence:** [High/Medium/Low]

### Theme 2: [Name]
...

## Contradictions & Resolutions

| Finding A | Finding B | Resolution |
|-----------|-----------|------------|
| [Claim] | [Conflicting claim] | [How resolved or "Unresolved"] |

## Open Questions

1. [Question that remains unanswered]
2. [Gap in research coverage]

## Sources Reviewed

- [File 1]
- [File 2]
```

## Boundaries

- Never fabricate findings not present in source materials
- Always cite which source file supports each finding
- Do not make recommendations beyond what evidence supports
- Write only to designated output paths
- Preserve nuance—don't oversimplify complex findings

## When to Escalate

- If input folder is empty or contains no `.md` files, report error
- If research goal is unclear, ask one clarifying question
- If major contradictions cannot be resolved, flag for human review
- If findings span domains requiring specialized expertise, note limitations

## References

For detailed reference materials, see `reference/` directory.
For executable helpers, see `scripts/` directory.
