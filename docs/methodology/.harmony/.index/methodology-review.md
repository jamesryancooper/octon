---
title: Harmony Methodology Document Review
description: Review the Harmony Methodology document to ensure it is aligned with the rest of the Harmony handbooks.
version: 1.0.0
date: 2025-11-20
---

# Harmony Methodology Document Review

## Goal

Review `docs/handbooks/harmony/methodology/README.md` end-to-end, tighten structure and wording, and fix any conflicts, inconsistencies, ambiguities, or gaps while keeping it aligned with the rest of the Harmony handbooks.

## Scope

- Focus on the full contents of `docs/handbooks/harmony/methodology/README.md`.
- Cross-check critical concepts and terminology against nearby handbooks (e.g. `principles.md`, `architecture/*`, `operating-model.md`, `glossary-and-conventions.md`) where needed for alignment.

## Steps

### 1. Orient and map the document

- Skim the entire methodology README to identify major sections, subsections, and the overall narrative flow.
- Note key concepts (e.g. phases, roles, artifacts, feedback loops) and where they are defined.
- List any obvious redundancies, contradictions, or confusing passages to revisit later.

### 2. Check structure and narrative consistency

- Verify heading hierarchy and section ordering are logical and consistent with other Harmony handbooks.
- Ensure each section has a clear purpose, with smooth transitions between sections and no circular or duplicated content.
- Confirm that early sections introduce terms and concepts before they are used later.

### 3. Align terminology and definitions

- Identify all key terms, acronyms, and role names used in the methodology (e.g. “Harmony”, “agent”, “runtime”, “handbook” concepts, roles and responsibilities).
- Cross-reference these with `glossary-and-conventions.md`, `principles.md`, and relevant `architecture/*.md` documents.
- For any mismatches (different names for the same concept, conflicting definitions, or undefined terms), decide on the canonical term/definition and plan to update the methodology README to match.

### 4. Validate process, responsibilities, and cross-doc alignment

- Trace the methodology as a process: identify stages, inputs/outputs, decision points, and feedback loops.
- Check that responsibilities and roles described in the methodology agree with `operating-model.md` and any relevant architecture docs.
- Look for missing transitions (e.g. how you move from one phase to the next), unclear ownership, or steps that contradict other Harmony guidance.

### 5. Identify and resolve conflicts, ambiguities, and gaps

- Create a concrete list of issues:
- Conflicts (statements that contradict each other or other handbooks).
- Inconsistencies (different terminology, style, or guidance for the same scenario).
- Ambiguities (vague, overloaded, or underspecified statements).
- Gaps (missing steps, missing rationale, or unaddressed edge cases).
- For each issue, determine the minimal, clear fix (rewording, adding a definition, restructuring a subsection, or adding a short example or note).
- Update the methodology README so that each fix is applied directly in context, keeping tone and style consistent with existing Harmony docs.

### 6. Perform an editorial and style pass

- Read through the updated methodology README linearly as a new reader would.
- Tighten language (remove unnecessary repetition, clarify long sentences, and ensure active, consistent voice).
- Ensure formatting (lists, callouts, code or config snippets, links) follows the existing documentation standards.

### 7. Final consistency and link check

- Verify all internal anchors and cross-links within the document work and use consistent link text.
- Re-check a small sample of cross-references to other handbooks to confirm terminology and guidance are still aligned after edits.
- Capture any remaining follow-up items (if deeper cross-handbook refactors are needed) as separate tasks outside this pass.
