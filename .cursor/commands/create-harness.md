# Create Harness `/create-harness`

Scaffold a new `.harmony/` directory in a target location.

See `.harmony/orchestration/workflows/meta/create-harness/00-overview.md` for full description and steps.

## Usage

```text
/create-harness @path/to/target/directory
```

With a scoped template:

```text
/create-harness @path/to/target/directory --template docs
/create-harness @path/to/target/directory --template node-ts
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `@path` | Yes | Target directory for the new harness |
| `--template` | No | Scoped template to use (`docs`, `node-ts`). Defaults to base `harmony` template. |

## Available Templates

| Template | Use For |
|----------|---------|
| (default) | Generic harness with all standard directories |
| `docs` | Documentation areas (includes ARE workflows) |
| `node-ts` | Node.js/TypeScript packages |

## Implementation

Execute the workflow in `.harmony/orchestration/workflows/meta/create-harness/`.

Start with `00-overview.md`, then follow each step in sequence.

## References

- **Canonical:** `docs/architecture/harness/README.md`
- **Workflow:** `.harmony/orchestration/workflows/meta/create-harness/`
- **Templates:** `.harmony/scaffolding/templates/`
