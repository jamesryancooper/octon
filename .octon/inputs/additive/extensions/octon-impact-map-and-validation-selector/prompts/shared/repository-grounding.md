# Repository Grounding

Ground every answer against the live repository before selecting validations.

## Grounding Order

1. current repo state
2. current extension routing and publication surfaces
3. current validator and workflow contracts
4. proposal manifests when a proposal packet is supplied
5. informative summaries only after the authoritative surfaces above

## Mandatory Rules

- Do not treat raw extension pack paths as runtime authority.
- Do not treat generated proposal registry outputs as proposal lifecycle
  authority.
- Prefer current touched paths over declared intent when they disagree.
- Reuse existing validators, audits, workflows, and repo-hygiene logic.
- Fail closed when a required grounding surface is missing.
