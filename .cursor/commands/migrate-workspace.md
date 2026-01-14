# Migrate Workspace `/migrate-workspace`

Upgrade an older `.workspace` to current conventions.

See `.harmony/workflows/workspace/migrate-workspace/00-overview.md` for full description and steps.

## Usage

```text
/migrate-workspace @path/to/.workspace
```

Or for the root workspace:

```text
/migrate-workspace @.workspace
```

## Implementation

Execute the workflow in `.harmony/workflows/workspace/migrate-workspace/`.

Start with `00-overview.md`, then follow each step in sequence.

## References

- **Canonical:** `docs/architecture/workspaces/README.md`
- **Workflow:** `.harmony/workflows/workspace/migrate-workspace/`

