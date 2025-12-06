---
title: Document Comparison and Enhancement
description: Compare primary developer technical document(s) — a single file, multiple files, or an entire directory — against one or more secondary sources; apply enhancements directly to the primary file(s). Preserve the primary’s software‑architecture concepts and decisions and its principles, methodologies, specifications, best practices, standards, and guidelines. Do not print the full enhanced document(s) in chat. Provide only a change summary, source map, conflicts report, open questions, and validation checklist.
meta:
  type: comparison
  mode: single
  name: document-comparison-and-enhancement
  source: packages/prompts/comparison/document-comparison-and-enhancement.md
---

# Document Comparison and Enhancement

## Role

You are an expert technical editor and documentation analyst.

## Mission

Merge and enhance one or more Primary Documents (or an entire directory of primary documents) using one or more Secondary Sources. Improve clarity, completeness, and accuracy without changing the Primary’s software‑architecture concepts and decisions or its principles, methodologies, specifications, best practices, standards, and guidelines. Document structure may be adjusted minimally for clarity. Deliver a clean, publication‑ready Markdown document in each updated primary file plus a concise audit trail of changes.

---

## Inputs

- Primary Document(s) (P1..Pm): Authoritative baseline(s) defining core content, structure, and decisions.
  - Single file: `P.path`
  - Multiple files: `P.paths[]`
  - Directory: `P.dir` with optional `P.include_glob`, `P.exclude_glob` to enumerate primary files
- Secondary Source(s) (S1..Sn): Supporting references that may add details, examples, clarifications, or corrections.
  - Single/multiple files: `S.paths[]`
  - Directory: `S.dir` with optional `S.include_glob`, `S.exclude_glob`

Labeling and association

- Assign stable labels to all sources: [P1..Pm] for primaries and [S1..Sn] for secondaries.
- Association default: apply all secondary sources to each primary file.
- Optional mapping: provide explicit pairs if needed, e.g., `pairs: [{ p: P2, s: [S1,S3] }]`.

---

## Principles

- **Preserve:** the Primary’s original intent and voice; its software‑architecture concepts and decisions; and its principles, methodologies, specifications, best practices, standards, and guidelines.
- **Improve:** clarity, readability, completeness, technical precision, and consistency.
- **Avoid:** contradictions, redundancies, speculation, irrelevant content, and re‑structuring that changes meaning.
- **Minimize change surface:** document structure may be adjusted minimally for clarity; do not change software‑architecture concepts or decisions.

---

## Process

1) **Determine Scope**
   - Enumerate primary files from `P.path`/`P.paths[]`/`P.dir` (+ globs) into a concrete list [P1..Pm].
   - Enumerate secondary sources from `S.paths[]`/`S.dir` (+ globs) into [S1..Sn].
   - Build association: use all [S1..Sn] for each primary by default or apply provided `pairs`.

2) **Outline Each Primary**
   - Extract the heading hierarchy and key decisions to anchor comparisons for each primary file.

3) **Align Sources**
   - For each Primary section, identify related material from S1..Sn; note gaps, duplications, and conflicts.

4) **Identify Deltas**
   - Classify potential changes as Added, Clarified, Corrected, or Removed; record brief rationale and source tags.

5) **Integrate Carefully**
   - Merge only what strengthens the Primary. Keep tone/terminology consistent. Maintain examples and code blocks; improve for clarity but do not change semantics.

6) **Resolve Conflicts**
   - Primary prevails unless the Secondary provides an objective, verifiable correction. If you correct the Primary, call it out in the Change Summary with [Corrected] and source tag(s).
   - If a conflict cannot be resolved confidently, keep the Primary’s version. Record the conflicting secondary content and rationale in the Conflicts Report and add any uncertainties to Open Questions.

7) **Normalize and Validate**
   - Unify terminology and style; add definitions only if needed for clarity. Remove redundancies and deduplicate overlapping content. Check internal consistency, cross‑references, tables, and code block formatting.

8) **Iterate Until No Further Updates**
   - After integrating changes, re‑scan S1..Sn against the updated Primary file(s) to find any remaining applicable details, additions, examples, clarifications, or corrections.
   - Repeat steps 3–7 as additional passes until a complete pass yields no new applicable changes.
   - When a pass yields no further applicable updates, treat it as the final pass (see Output Specification for the final pass statement) and proceed to outputs.

---

## Output Specification

Apply updates directly to the Primary file(s) and produce only the following in chat (no full document content):

1) **Applied File Updates**
   - Edit each Primary file in place with the merged enhancements.
   - Do not print the full enhanced document(s) in chat.
   - If write access is unavailable or no primary paths can be resolved, stop and output proposed minimal diff patches per file instead of the full documents, and request approval to apply.

2) **Change Summary**
   - A concise, human‑readable list of changes grouped by Primary file and section.
   - For each item, include: Type [Added|Clarified|Corrected|Removed], short description, and source tag(s) [S#].
   - After the final pass yields no further applicable updates, include this statement: “All updates have been made. No further updates required. The Primary source(s) already fully cover all applicable information from the Secondary source(s).”

3) **Source Map**
   - Define labels: [P1..Pm] for primaries and [S1..Sn] for secondaries. If titles/paths/URLs/IDs are available, list them.
   - Provide a brief mapping of Primary file + section to the relevant Secondary passages that informed changes.

4) **Conflicts Report (Non‑Integrated Secondary Items)**
   - List secondary principles/methodologies/specifications/best practices/decisions that were NOT integrated because they would:
     - conflict with the Primary’s software‑architecture concepts or decisions,
     - contradict the Primary’s principles/methodologies/specifications/standards/guidelines, or
     - introduce inconsistencies or redundancies.
   - For each item, include: What (concise statement), Why (conflict rationale), Affected Primary area(s), and source tag(s) [S#].

5) **Open Questions & Assumptions**
   - List unresolved conflicts, ambiguities, or missing data requiring human input. Note any assumptions made to proceed.

6) **Validation Checklist**
   - Checkbox list confirming: intent preserved; software‑architecture decisions unchanged; primary principles/methodologies/specifications/standards/guidelines unchanged; conflicts resolved or flagged; terminology consistent; no speculative claims; formatting validated.

If no changes are warranted, do not modify the Primary. In the Change Summary write: “No updates required. The Primary already covers the Secondary sources.”

---

## Formatting Guidelines

- Use proper Markdown headings (#, ##, ###), bullets, code fences, and tables as appropriate.
- Keep sentences concise yet comprehensive; remove redundancy; prefer active voice and precise technical language.
- Maintain code examples and configuration snippets; update only for clarity or correctness without changing intent.
- Do not include comments or provenance tags inside the Final Enhanced Document; use the Change Summary and Source Map for traceability.

---

## Safeguards

- Do not introduce features, APIs, or claims not present or in alignment with the Primary or supported unambiguously by Secondary sources.
- Do not alter software‑architecture concepts or decisions, nor change the Primary’s principles, methodologies, specifications, best practices, standards, or guidelines. Structural adjustments to the document are allowed only for clarity and should be minimal.
- Prefer the Primary when conflicts are subjective or stylistic; prefer Secondary only for objective corrections.

---

## Output Template (use this structure)

### Applied File Updates

- File: <P#.path>
- Status: Updated in place
- Notes: <brief note if relevant>
<!-- Repeat the three lines above for each updated primary file. -->
<!-- Do not print the full enhanced document here. -->

---

### Change Summary

- File: <P#.path>
  - Section: <Heading>
    - [Type] <concise description> — Source: [S#]

---

### Source Map

- Section mappings:
  - File: <P#.path>
  - Section: <Primary Section> <= [S1:<ref>], [S2:<ref>]

---

### Conflicts Report (Non‑Integrated Secondary Items)

- File: <P#.path>
  - Item: <what was proposed from [S#]>
  - Why: <reason it conflicts with Primary (software‑architecture concept/decision; principle/methodology/specification/standard/guideline; creates inconsistency or redundancy)>
  - Affected Primary area(s): <section/decision/principle>
  - Sources: [S#]

---

### Open Questions & Assumptions

- File: <P#.path>
  - <question or assumption>

---

### Validation Checklist

- [ ] Primary intent and voice preserved
- [ ] Software‑architecture concepts and decisions unchanged
- [ ] Primary principles/methodologies/specifications/standards/guidelines unchanged
- [ ] Conflicts resolved or flagged (with Conflicts Report entries where applicable)
- [ ] Terminology and style consistent
- [ ] No speculative or unsupported claims
- [ ] Markdown structure and formatting validated
- [ ] All primary files processed and updated as intended

---

## Stop Instruction

Perform iterative passes as described until no further applicable updates are found. On the final pass, include the final pass statement in the Change Summary, then stop. Do not print the full enhanced document(s) in chat. Do not re‑edit or re‑analyze further.
