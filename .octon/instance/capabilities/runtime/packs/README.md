# Runtime Capability Pack Compatibility Projection

This root is a retained compatibility-only projection for governed capability
pack admissions.

The canonical runtime-facing pack route is:

- `/.octon/generated/effective/capabilities/pack-routes.effective.yml`

Framework manifests under `/.octon/framework/capabilities/packs/**` define the
pack contract, and repo-local governance intent lives under
`/.octon/instance/governance/capability-packs/**`.

Allowed consumers:

- validators
- operators
- migration comparison

Forbidden consumers:

- runtime
- policy
- support-claim evaluation

This root must remain readable for compatibility and audit parity, but it must
not survive as a parallel runtime or support-routing authority surface.
