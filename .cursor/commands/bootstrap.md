# Bootstrap Session `/bootstrap`

Quick-start a new agent session in a workspace.

See `.harmony/scaffolding/prompts/bootstrap-session.md` for full details.

## Usage

```text
/bootstrap @path/to/directory
```

Or for the current directory:

```text
/bootstrap
```

## Implementation

Execute `.harmony/scaffolding/prompts/bootstrap-session.md` in the target directory. Locates the nearest `.harmony/` and runs the boot sequence.

## References

- **Canonical:** `docs/architecture/workspaces/prompts.md`
- **Prompt:** `.harmony/scaffolding/prompts/bootstrap-session.md`

