---
title: Audit Skills System Expansion
description: Determine whether the skills system needs new features or artifacts to close real gaps.
access: human
---

# Audit Skills System Expansion

## Context

Use this prompt when you want to assess whether the Harmony skills system should stay as-is, be tightened within existing artifacts, or be expanded with a new feature or artifact.

## Inputs

- Target subsystem: `.harmony/capabilities/runtime/skills`
- Optional comparison scope: `.harmony/capabilities`, `.harmony/orchestration`, `.harmony/scaffolding`
- Optional severity bar for recommendations: only propose expansion for material gaps

## Instructions

1. Use `audit-domain-architecture` as the primary evaluator for `.harmony/capabilities/runtime/skills`.
2. Treat manifests, registries, validators, and `SKILL.md` files as evidence, not as correct by default.
3. Determine whether the current artifact model is sufficient for:
   - discovery
   - routing
   - authoring
   - validation
   - execution
   - logging
   - maintenance
   - gap detection
4. Evaluate:
   - whether any important invariant lacks a clear source of truth
   - whether any recurring failure mode cannot be solved cleanly with current artifacts
   - whether any real task class lacks capability coverage
   - whether a missing structure should be solved by tightening existing artifacts, adding validation, adding a new artifact, or adding a runtime feature
5. Apply this decision rule:
   - do not propose a new artifact or feature if the gap can be solved by improving existing manifests, registry entries, `SKILL.md` contracts, references, or validators
   - propose expansion only when the current model cannot represent or enforce the needed behavior cleanly
6. If needed, use `audit-subsystem-health` as a secondary pass to separate structural gaps from contract drift.
7. If needed, use `audit-cross-subsystem-coherence` to confirm that any proposed addition is not already represented elsewhere in Harmony.

## Output

Return:

- Current Surface Map
- Critical Gaps
- Keep As-Is decisions
- Candidate additions ranked by leverage
- For each candidate: problem solved, why current artifacts are insufficient, minimum viable design, affected surfaces, tradeoffs, and acceptance criteria
- Final recommendation: `no expansion`, `targeted expansion`, or `substantial expansion`

## Example

```text
Use /Users/jamesryancooper/Projects/harmony/.harmony/scaffolding/practices/prompts/audit-skills-system-expansion.md to evaluate whether .harmony/capabilities/runtime/skills needs a new artifact or runtime feature, or whether existing manifests, registries, validators, and skill contracts are sufficient.
```
