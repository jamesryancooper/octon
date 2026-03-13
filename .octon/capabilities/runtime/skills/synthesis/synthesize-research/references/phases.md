---
behavior:
  phases:
    - name: "Gather Materials"
      steps:
        - "Read all .md files in the input folder"
        - "Identify project.md, log.md, findings.md if present"
        - "Note the research goal and key questions"
    - name: "Extract Findings"
      steps:
        - "Pull out explicit findings, insights, and conclusions"
        - "Note supporting evidence for each finding"
        - "Flag contradictions or uncertain claims"
    - name: "Identify Themes"
      steps:
        - "Group related findings into 3-7 themes"
        - "Name each theme descriptively"
        - "Order themes by importance or logical flow"
    - name: "Synthesize"
      steps:
        - "Write executive summary (3-5 sentences)"
        - "For each theme, state insight with evidence and confidence"
        - "List resolved contradictions"
        - "List open questions and gaps"
    - name: "Output"
      steps:
        - "Write synthesis to .octon/output/drafts/{{topic}}-synthesis.md"
        - "Write run log to _ops/state/logs/synthesize-research/{{timestamp}}-synthesize-research.md"
  goals:
    - "Consolidate dispersed research into a single coherent document"
    - "Identify and organize findings by theme"
    - "Surface contradictions and resolve or flag them"
    - "Highlight remaining gaps and open questions"
    - "Produce audit trail via run log"
---

# Behavior Reference

Phase-by-phase execution details for the synthesize-research skill.

## Phase 1: Gather Materials

Collect and organize all source materials from the input folder.

1. **Read all markdown files**
   - Scan input folder for `.md` files
   - Read content of each file
   - Track file names for source attribution

2. **Identify special files**
   - Look for `project.md` (research context and goals)
   - Look for `log.md` (chronological research log)
   - Look for `findings.md` (explicit findings)
   - These files, if present, provide structure

3. **Note research goal**
   - Extract stated goal from project.md if present
   - Infer goal from content if not explicitly stated
   - Record key questions the research aims to answer

## Phase 2: Extract Findings

Identify discrete findings from the source materials.

1. **Pull out findings**
   - Look for explicit statements of findings, insights, conclusions
   - Look for patterns: "I found that...", "Key insight:", "Conclusion:"
   - Capture both stated and implied findings

2. **Note supporting evidence**
   - For each finding, identify supporting evidence
   - Note which source file contains the evidence
   - Assess strength of evidence (direct observation, inference, speculation)

3. **Flag contradictions**
   - Identify findings that conflict with each other
   - Note uncertain or hedged claims
   - Mark for resolution in synthesis phase

## Phase 3: Identify Themes

Group findings into coherent themes.

1. **Group related findings**
   - Cluster findings by topic or domain
   - Aim for 3-7 themes (enough to organize, not too many to overwhelm)
   - Each theme should have at least 2 supporting findings

2. **Name themes descriptively**
   - Use noun phrases that capture the theme's essence
   - Examples: "Authentication Patterns", "Performance Constraints", "User Preferences"
   - Avoid generic names like "Miscellaneous" or "Other"

3. **Order themes**
   - Order by importance (most significant first), OR
   - Order by logical flow (foundational → advanced), OR
   - Order by chronology (if research has temporal structure)

## Phase 4: Synthesize

Write the synthesis document.

1. **Write executive summary**
   - 3-5 sentences capturing key takeaways
   - Should be standalone—reader should grasp main points without reading further
   - Mention most important themes and conclusions

2. **Write themed sections**
   - For each theme:
     - State the key insight clearly
     - Provide supporting evidence (2-4 points)
     - Assign confidence level (High/Medium/Low)
   - High: Strong, consistent evidence
   - Medium: Some evidence, some uncertainty
   - Low: Limited evidence, significant uncertainty

3. **Document contradictions**
   - List contradictory findings in table format
   - For each, state resolution or mark as "Unresolved"
   - Unresolved contradictions become open questions

4. **List open questions**
   - Questions the research didn't answer
   - Gaps in coverage
   - Areas needing further investigation

## Phase 5: Output

Produce final artifacts.

1. **Write synthesis document**
   - Path: `.octon/output/drafts/{{topic}}-synthesis.md`
   - Use standard output format (see io-contract.md)
   - Include all sections: summary, themes, contradictions, questions, sources

2. **Write run log**
   - Path: `_ops/state/logs/synthesize-research/{{timestamp}}-synthesize-research.md`
   - Record: run_id, status, timestamps, inputs, outputs
   - Note any issues or decisions made during synthesis

---

## Confidence Level Guidelines

| Level | Criteria |
|-------|----------|
| **High** | Multiple independent sources agree; direct evidence; no contradictions |
| **Medium** | Some sources agree; evidence is indirect or limited; minor contradictions resolved |
| **Low** | Single source; speculative; significant contradictions unresolved |

## Theme Count Guidelines

| Source File Count | Recommended Themes |
|-------------------|-------------------|
| 1-3 files | 2-3 themes |
| 4-7 files | 3-5 themes |
| 8+ files | 5-7 themes |

If findings don't naturally cluster, consider whether themes are too narrow or too broad.
