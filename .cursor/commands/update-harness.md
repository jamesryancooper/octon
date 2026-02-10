# Update Harness `/update-harness`

Align an existing `.harmony` directory with the canonical harness definition.

See `.harmony/orchestration/workflows/meta/update-harness/00-overview.md` for full description and steps.

## Usage

```text
/update-harness @path/to/.harmony
```

Or for the root harness:

```text
/update-harness @.harmony
```

## Implementation

Execute the workflow in `.harmony/orchestration/workflows/meta/update-harness/`.

Start with `00-overview.md`, then follow each step in sequence.

## References

- **Canonical:** `docs/architecture/harness/README.md`
- **Workflow:** `.harmony/orchestration/workflows/meta/update-harness/`
