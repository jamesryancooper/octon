# Evaluate Workspace `/evaluate-workspace`

Evaluate a `.workspace` directory for token efficiency and agent effectiveness.

See `.harmony/workflows/workspace/evaluate-workspace/00-overview.md` for full description and steps.

## Usage

```text
/evaluate-workspace @.workspace
```

Or for a nested workspace:

```text
/evaluate-workspace @docs/my-feature/.workspace
```

## Implementation

Execute the workflow in `.harmony/workflows/workspace/evaluate-workspace/`.

Start with `00-overview.md`, then follow each step in sequence.

## References

- **Canonical:** `docs/architecture/workspaces/README.md`
- **Workflow:** `.harmony/workflows/workspace/evaluate-workspace/`
