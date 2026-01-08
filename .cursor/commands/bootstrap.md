# Bootstrap Session `/bootstrap`

Quick-start a new agent session in a workspace.

See `.workspace/prompts/bootstrap-session.md` for full details.

## Usage

```text
/bootstrap @path/to/directory
```

Or for the current directory:

```text
/bootstrap
```

## Implementation

Execute `.workspace/prompts/bootstrap-session.md` in the target directory. Locates the nearest `.workspace/` and runs the boot sequence.

## References

- **Canonical:** `docs/architecture/workspaces/prompts.md`
- **Prompt:** `.workspace/prompts/bootstrap-session.md`

