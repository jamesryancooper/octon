# Runtime Capability Pack Admission

This root publishes the runtime-facing projected admission view for governed
capability packs.

Framework manifests under `/.octon/framework/capabilities/packs/**` define the
pack contract, and repo-local governance intent lives under
`/.octon/instance/governance/capability-packs/**`. This instance root must stay
in parity with that governance intent for the active runtime route.
