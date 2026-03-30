# Shim Independence

Audit scope:

- launchers and runtime entrypoints
- GitHub and CI binding workflows
- validators and governance scripts
- ingress entrypoints
- bootstrap entrypoints

Historical shims remain acceptable only as adapter-only, subordinate, or
retirement-conditioned surfaces. The closure validator fails if any
certification-critical path reads a historical shim as authority.

Result: PASS
