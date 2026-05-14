# Candidate AGENTS Wording

_Status: In-review proposal packet artifact_


```markdown
# `.octon` Ingress Adapter

## Behavioral Contract

Enable reliable workflow participation by bounded agents inside Octon-governed execution boundaries. Workflow state owns control flow. Agents do not.

Canonical internal ingress lives at `/.octon/instance/ingress/AGENTS.md`.

Read in this order:

1. `/.octon/instance/ingress/AGENTS.md`

Repo-root `AGENTS.md` and `CLAUDE.md` are thin adapters to this file. They must be a symlink to `/.octon/AGENTS.md` or a byte-for-byte parity copy and must not add runtime or policy text.
```
