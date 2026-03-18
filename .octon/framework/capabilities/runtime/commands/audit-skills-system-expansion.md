---
title: Audit Skills System Expansion
description: Invoke the skills-system expansion evaluation prompt through a slash-style command wrapper.
access: agent
argument-hint: "[subsystem-path] [--compare-scope <csv>] [--material-only true|false]"
---

# Audit Skills System Expansion `/audit-skills-system-expansion`

Evaluate whether the skills system needs a new artifact or runtime feature while keeping the prompt template as the evaluation contract.

See `.octon/framework/scaffolding/practices/prompts/audit-skills-system-expansion.md` for the full evaluation rubric.

## Usage

```text
/audit-skills-system-expansion
/audit-skills-system-expansion .octon/framework/capabilities/runtime/skills
/audit-skills-system-expansion .octon/framework/capabilities/runtime/skills --compare-scope .octon/framework/capabilities,.octon/framework/orchestration,.octon/framework/scaffolding
```

## Parameters

| Parameter | Required | Description | Default |
|---|---|---|---|
| `subsystem-path` | No | Target subsystem to evaluate | `.octon/framework/capabilities/runtime/skills` |
| `--compare-scope` | No | Comma-separated additional scopes to compare during the audit | `.octon/framework/capabilities,.octon/framework/orchestration,.octon/framework/scaffolding` |
| `--material-only` | No | Restrict expansion recommendations to material gaps only | `true` |

## Implementation

1. Use `.octon/framework/scaffolding/practices/prompts/audit-skills-system-expansion.md`.
2. Default the target subsystem to `.octon/framework/capabilities/runtime/skills` when no path is provided.
3. Pass any provided comparison scope or materiality threshold into the prompt inputs.
4. Keep the prompt as the source of truth for the evaluation contract; the command only standardizes invocation.

## Output

Return the output defined by the prompt:

- `Current Surface Map`
- `Critical Gaps`
- `Keep As-Is decisions`
- `Candidate additions ranked by leverage`
- `Final recommendation`

## References

- **Prompt:** `.octon/framework/scaffolding/practices/prompts/audit-skills-system-expansion.md`
- **Primary skill:** `.octon/framework/capabilities/runtime/skills/audit/audit-domain-architecture/SKILL.md`
- **Secondary skill:** `.octon/framework/capabilities/runtime/skills/audit/audit-subsystem-health/SKILL.md`
- **Cross-subsystem skill:** `.octon/framework/capabilities/runtime/skills/audit/audit-cross-subsystem-coherence/SKILL.md`
