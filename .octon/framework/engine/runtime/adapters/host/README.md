# Host Adapters

Host adapters describe how Octon interacts with a host surface without letting
that surface become hidden authority.

Canonical host families for the current support envelope are:

- `github`
- `ci`
- `local-cli`
- `studio`

Each manifest must publish:

- one explicit host family
- support-tier declarations bounded by `instance/governance/support-targets.yml`
- conformance criteria refs
- known limitations
