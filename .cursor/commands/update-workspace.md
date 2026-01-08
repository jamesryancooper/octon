# Update Workspace `/update-workspace`

Align an existing `.workspace` directory with the canonical workspace definition.

See `.workspace/workflows/workspace/update-workspace/00-overview.md` for full description and steps.

## Usage

```text
/update-workspace @path/to/.workspace
```

Or for the root workspace:

```text
/update-workspace @.workspace
```

## Implementation

Execute the workflow in `.workspace/workflows/workspace/update-workspace/`.

Start with `00-overview.md`, then follow each step in sequence.

## References

- **Canonical:** `docs/architecture/workspaces/README.md`
- **Workflow:** `.workspace/workflows/workspace/update-workspace/`
