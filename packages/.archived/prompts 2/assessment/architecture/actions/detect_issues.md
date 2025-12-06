---
title: Architecture – Detect Issues
description: Action prompt for the issue-detection phase of the Harmony architecture assessment.
meta:
  type: assessment
  mode: action
  action: detect_issues
  subject: architecture
  step_index: 4
---

# Architecture – Detect Issues

Use this action prompt to perform the **issue-detection** phase of the Harmony Architecture Assessment using the inventory and mapping artefacts.

## Mission

Identify and classify issues across the architecture documentation set, including:

- Conflicts and contradictions.
- Duplication and drift.
- Ambiguity and underspecification.
- Coverage gaps and missing architectural decisions.
- Cross-linking and navigation gaps.

## Process

1. **Conflict scan**
   - Find contradictory statements, diverging role names/scopes, misaligned invariants/practices, and conflicting or duplicated patterns/technologies/paradigms.
   - Flag version drift (for example, HSP naming) and inconsistent acceptance/quality gates.
2. **Duplication scan**
   - Detect overlapping or repeated content; identify a canonical home and mark secondary locations.
3. **Ambiguity scan**
   - Flag vague or underspecified statements; note where clarifications are needed.
4. **Coverage/gap scan**
   - Identify missing but implied architectural decisions or areas where required guidance is absent.
5. **Cross-link coverage**
   - Verify that each file links to relevant counterparts (for example:
     - `overview.md`
     - `repository-blueprint.md`
     - `layout/*.md`
     - governance/runtime/observability/knowledge-plane docs).

## Output Specification

- An **Issue Register** with entries such as:
  - `id`, `type` (conflict/duplication/ambiguity/gap/cross-link), `severity` (high/medium/low).
  - `location` (`relative/path.md:line`), short description, and supporting evidence.
- This step only **identifies** issues; actual alignment and edits are handled by later actions.

