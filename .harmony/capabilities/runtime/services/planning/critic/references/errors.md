# Critic Errors

- `CriticInputError`: malformed payload, missing command, or invalid step source.
- `CriticRuntimeError`: structural defects in the plan graph.

Recovery patterns:

- Retry with a fixed plan artifact or corrected inline plan.
- Use `command: "score"` to collect advisory signals without fail-closed enforcement.
