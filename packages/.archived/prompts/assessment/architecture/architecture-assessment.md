---
title: Harmony Architecture Assessment Prompt
description: Guide for assessing and aligning all documents in docs/harmony/architecture so architectural decisions are consistent, clear, conflict-free, and complete.
---

# Harmony Architecture Alignment

Use this prompt to perform a precise, scope-limited alignment assessment of the Harmony architecture documentation in `docs/harmony/architecture`. It follows the methodology assessment style: clear role, mission, objectives, process, focus areas, expected outputs, a deterministic “no updates” message, and an explicit stop instruction.

## Role

You are a senior documentation architect and systems architect specializing in small-team, AI-accelerated software delivery. You optimize for clarity, determinism, and sustainable maintainability.

## Mission

Assess and align all Harmony architecture documentation in `docs/harmony/architecture` so architectural decisions (concepts, patterns, technologies, practices, structures, paradigms, constraints, and quality attributes) are internally consistent, unambiguous, conflict‑free, and as complete as possible — with minimal, high‑leverage edits applied directly to the relevant files.

## Scope (strict)

- Analyze only files under `docs/harmony/architecture` (including subfolders).
- Do not reference or depend on content outside this directory.
- Do not change methodology or AI‑Toolkit documents; align purely within the Architecture set.

---

## Objectives (What success looks like)

1) Internal consistency and clarity
   - Terms, definitions, roles, processes, and invariants are consistent across all files.
   - Ambiguous statements are clarified; contradictory guidance is removed or reconciled.
   - Architectural decisions read as a coherent, non‑contradictory whole across all documents.

2) Minimal, surgical edits
   - Apply the smallest set of changes to resolve conflicts, reduce duplication, and improve determinism.
   - Preserve the existing voice, structure, and intent of each file.

3) Strong cross-referencing
   - Canonical concepts are clearly referenced across the set (e.g., overview, governance, monorepo layout, runtime policy, observability, kaizen, knowledge plane, tooling integration, slices vs layers, repository blueprint).
   - Duplicated content points to a single canonical source with “See also” links.

4) Deterministic outcomes
   - Every edit is justified with evidence (path:line and a short quote).
   - The final set reads cohesively as a single, conflict‑free architecture handbook.

5) Decision coverage and gap detection
   - Architectural decisions (covering concepts, patterns, technologies, practices, structures, paradigms, runtime and deployment models, data strategies, operational practices, constraints, assumptions, and quality attributes) are explicitly identified and checked for alignment.
   - Missing, implied, or conflicting decisions are surfaced; conflicts are either resolved in the docs or captured as Open Questions that require clarifying input before edits proceed.
   - Decision coverage across the documentation set is visible (for example, via a concise matrix of decisions → files/sections → coverage status), making it clear where decisions are fully, partially, or not yet represented.

---

## How to work (Process)

Work in two passes:

- Pass 1: Inventory and Analysis.
- Pass 2: Edits and Validation.

1) Inventory
   - List all Markdown files under `docs/harmony/architecture` with relative paths.
   - For each file, extract: title, frontmatter, H1/H2 headings, key terms/definitions, roles, processes, invariants, controls/policies, and referenced artifacts/links.

2) Analysis
   - Terminology map: term → definitions/usages across files; flag discrepancies or synonyms needing normalization.
   - Architectural decision map: capture key architectural decisions (concepts, patterns, technologies, practices, structures, paradigms, runtime and deployment models, data and consistency strategies, operational practices, constraints, assumptions, and quality attributes); list where each decision appears and flag conflicts, ambiguity, or missing coverage.
   - Conflict scan: identify contradictory statements, diverging role names/scopes, misaligned invariants or practices, conflicting or duplicated architectural patterns/technologies/paradigms, version drift (e.g., HSP naming), and inconsistent acceptance/quality gates.
   - Duplication scan: detect overlapping content; select a canonical home and plan concise cross‑links in non‑canonical locations.
   - Ambiguity scan: flag vague or underspecified statements; draft precise clarifications.
   - Coverage/gap scan: identify missing but implied architectural decisions or areas where required guidance is absent; mark these as coverage gaps and potential Open Questions.
   - Cross‑link coverage: ensure each file references relevant counterparts (for example):
     - `overview.md`
     - `repository-blueprint.md`
     - `monorepo-layout.md`
     - `governance-model.md`
     - `runtime-policy.md`
     - `observability-requirements.md`
     - `knowledge-plane.md`
     - `kaizen-subsystem.md`
     - `tooling-integration.md`
     - `slices-vs-layers.md`

3) Edits (minimal, targeted)
   - Normalize terminology and role names; reconcile conflicting guidance.
   - Add or adjust cross‑links; consolidate duplicates by pointing to a canonical source.
   - Clarify ambiguous statements with precise language and, when helpful, short examples, where the intended meaning is already implied by existing text; when intent is unclear, capture it as an Open Question instead of guessing.
   - Align frontmatter/title conventions and heading structures where inconsistent.
   - Resolve architectural misalignments wherever the existing documentation clearly indicates an intended decision. When resolving a conflict requires choosing between competing architectural options (e.g., patterns, technologies, layering strategies) and the intended choice is not explicit, pause and ask clarifying questions; do not update affected guidance until those questions are answered or the decision is otherwise made explicit.

4) Validation
   - Re‑scan for residual conflicts, dead/incorrect links, inconsistent term usage, and structural drift.
   - Confirm edits resolved the flagged issues without introducing new ones.

Stop when alignment is confirmed and your report is complete.

---

## Focus Areas (Assessment lenses)

- Terminology and roles: consistent definitions; normalized glossary and role scope.
- Architectural paradigms: consistent use of Modulith/Hexagonal, vertical slices vs layers, contract‑first boundaries.
- Architectural decisions: concepts and models, patterns and styles, technology stacks and versions, integration and communication mechanisms, data and consistency strategies, structural decomposition (modules, slices, layers), runtime and deployment models, operational practices (observability, resilience, security, privacy), constraints and assumptions, and quality attributes/trade‑offs; ensure these decisions are explicit, aligned, and non‑conflicting across documents.
- Invariants and gates: pillars, trunk‑based flow, determinism, flags/rollback, CI policy/eval, observability, provenance.
- Cross‑file coherence: overview ↔ blueprint ↔ layout ↔ governance ↔ runtime policy ↔ observability ↔ knowledge plane ↔ kaizen ↔ tooling integration.
- Ambiguity hotspots: vague requirements, undefined terms, conflicting acceptance criteria or quality bars.
- Duplication and drift: repeated explanations, diverging versions of the same concept, outdated references.

---

## Evidence and Citations

- For each finding or edit, cite `relative/path.md:line` (for example, `docs/harmony/architecture/overview.md:42`) and quote ≤3 lines.
- Prefer concrete proof over speculation; do not infer new architectural decisions beyond what is clearly supported or directly implied by the cited text. When uncertain, record the item as an Open Question instead of asserting a decision.

---

## Expected Output

- Preferred: When you have write access, apply minimal edits directly to files under `docs/harmony/architecture` to remove conflicts/ambiguity, align architectural decisions, and add cross‑links. When you cannot edit files directly, provide minimal patch-style suggestions instead.
- Produce an Alignment Report. Format the report as Markdown using the following top-level sections:
  - `## Executive Summary`
  - `## Key Misalignments`
  - `## Normalized Glossary`
  - `## Edits by File`
  - `## Open Questions`
- Within these sections, summarize:
  - Executive summary (≤150 words), an overall architecture alignment score (0–100) with brief rationale, and top issues addressed.
  - Key misalignments (ranked high/medium/low) with symptom, impact, evidence (path:line), and either a concrete recommended resolution (when the intended architectural decision is explicit) or a short set of options with a pointer to the relevant Open Question when a decision is still pending.
  - Normalized glossary (preferred term → aliases).
  - List of edits by file with evidence citations.
  - Residual Open Questions, especially unresolved architectural decisions requiring clarifying input, if any.

✅ If the set is already fully aligned, state exactly:
> “No updates required. The Harmony architecture documentation is internally aligned and consistent.”
and do not modify any files.

⛔ Stop Instruction
Once alignment is confirmed and your report is produced, stop all processing immediately and end execution. Do not re‑analyze, re‑edit, or iterate after this point.

---

## Quality Rubric (guide your judgment)

- Terminology consistency (20)
- Conflict detection and resolution quality (25)
- Cross‑link coverage and canonical sourcing (15)
- Structural/frontmatter consistency (15)
- Clarity and unambiguity of language (25)

---

## Constraints

- Scope is strictly `docs/harmony/architecture` only.
- Keep edits minimal; preserve voice and structure.
- Prefer consolidation + links over duplication; avoid large rewrites.
- If information is missing, write concise, high‑confidence clarifications only when they are safe, non‑controversial refinements of existing intent. When information is missing or conflicting in a way that would require choosing between architectural options, do not invent a new decision; instead, record it as an Open Question and ask clarifying questions before making normative updates.

---

## Deliver format

- Use clear sections as above.
- Use relative paths with line numbers for every citation.
- Keep the main body focused; move exhaustive listings (for example, decision matrices or terminology maps) to an Appendix.
