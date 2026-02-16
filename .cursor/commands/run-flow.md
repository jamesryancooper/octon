# Run FlowKit Flow `/run-flow`

Execute a FlowKit LangGraph flow from its `.flow.json` config file.

See `.harmony/orchestration/workflows/flowkit/run-flow/00-overview.md` for full description and steps.

## Usage

```text
/run-flow @packages/workflows/<flowId>/config.flow.json
```

## Implementation

Execute the workflow in `.harmony/orchestration/workflows/flowkit/run-flow/`.

Start with `00-overview.md`, then follow each step in sequence.

> **Note:** `/run-flow` only accepts `.flow.json` configs. It does **not** take canonical prompts or manifests directly.

## References

- **Canonical:** `.harmony/capabilities/services/execution/flow/guide.md`
- **Workflow:** `.harmony/orchestration/workflows/flowkit/run-flow/`
