# Create Workspace `/create-workspace`

Scaffold a new `.harmony/` directory in a target location.

See `.harmony/orchestration/workflows/workspace/create-workspace/00-overview.md` for full description and steps.

## Usage

```text
/create-workspace @path/to/target/directory
```

With a scoped template:

```text
/create-workspace @path/to/target/directory --template docs
/create-workspace @path/to/target/directory --template node-ts
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `@path` | Yes | Target directory for the new workspace |
| `--template` | No | Scoped template to use (`docs`, `node-ts`). Defaults to base `harmony` template. |

## Available Templates

| Template | Use For |
|----------|---------|
| (default) | Generic workspace with all standard directories |
| `docs` | Documentation areas (includes ARE workflows) |
| `node-ts` | Node.js/TypeScript packages |

## Implementation

Execute the workflow in `.harmony/orchestration/workflows/workspace/create-workspace/`.

Start with `00-overview.md`, then follow each step in sequence.

## References

- **Canonical:** `docs/architecture/workspaces/README.md`
- **Workflow:** `.harmony/orchestration/workflows/workspace/create-workspace/`
- **Templates:** `.harmony/scaffolding/templates/`
