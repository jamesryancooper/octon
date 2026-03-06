---
name: audit-skills-system-expansion
description: Use when working in the Harmony repository and you need to decide whether the skills system should stay as-is, be tightened within existing artifacts, or be expanded with a new feature or artifact. This skill delegates to the repository prompt and uses the existing audit skills as needed.
---

# Audit Skills System Expansion

Use this skill only in the Harmony repository.

## Workflow

1. Read `.harmony/scaffolding/practices/prompts/audit-skills-system-expansion.md` and treat it as the authoritative evaluation contract.
2. Default the target subsystem to `.harmony/capabilities/runtime/skills` unless the user specifies a narrower or broader target.
3. Use `audit-domain-architecture` as the primary evaluator.
4. Use `audit-subsystem-health` when you need to separate structural gaps from contract drift.
5. Use `audit-cross-subsystem-coherence` when you need to confirm that a proposed artifact or feature is not already represented elsewhere in Harmony.
6. Return the output sections required by the prompt.

## Boundaries

- Keep the prompt as the source of truth.
- Do not propose a new artifact or feature when tightening existing manifests, registry entries, `SKILL.md` contracts, references, or validators would solve the gap.
- If `.harmony/scaffolding/practices/prompts/audit-skills-system-expansion.md` is missing, stop and report that the skill cannot run correctly.
