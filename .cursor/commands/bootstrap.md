# Bootstrap Session `/bootstrap`

Quick-start a new agent session in a harness.

See `.octon/scaffolding/prompts/bootstrap-session.md` for full details.

## Usage

```text
/bootstrap @path/to/directory
```

Or for the current directory:

```text
/bootstrap
```

## Implementation

Execute `.octon/scaffolding/prompts/bootstrap-session.md` in the target directory. Locates the nearest `.octon/` and runs the boot sequence.

## References

- **Canonical:** `.octon/scaffolding/_meta/architecture/prompts.md`
- **Prompt:** `.octon/scaffolding/prompts/bootstrap-session.md`

