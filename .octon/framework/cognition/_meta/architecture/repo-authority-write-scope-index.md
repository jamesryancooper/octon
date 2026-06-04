# Repo Authority And Write-Scope Index

`repo-authority-write-scope-index-v1` is the generated proposal-program
orientation bundle for authority classes, proposal promotion targets, and child
write scopes.

The durable contract lives in
`/.octon/framework/engine/runtime/spec/repo-authority-write-scope-index-v1.md`.
The generated files live under `/.octon/generated/proposals/repo-authority/`
and remain derived-only:

- `repo-authority-graph.yml`
- `promotion-target-index.yml`
- `write-scope-index.yml`

The bundle may help context-pack assembly and lifecycle routes choose compact
refs before reading raw proposal packets. It never replaces the structural
architecture registry, proposal manifests, child-owned receipts, run control,
run evidence, generated-effective handle validation, or execution
authorization.

Validators must reject stale source digests and authority-boundary conflicts
before any reader uses the bundle.
