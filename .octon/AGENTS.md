# `.octon` Ingress Adapter

## Behavioral Contract

Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

Canonical internal ingress lives at `/.octon/instance/ingress/AGENTS.md`.

Read in this order:

1. `/.octon/instance/ingress/AGENTS.md`

Repo-root `AGENTS.md` and `CLAUDE.md` are thin adapters to this file. They
must be a symlink to `/.octon/AGENTS.md` or a byte-for-byte parity copy and
must not add runtime or policy text.
