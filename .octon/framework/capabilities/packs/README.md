# Capability Packs

`packs/` defines governed capability-pack contracts that sit above individual
commands, tools, skills, and services when support-target policy needs to
bound a broader action surface.

Current pack surfaces:

- `repo`
- `git`
- `shell`
- `browser`
- `api`
- `telemetry`

Framework pack manifests define the pack contract. Repo-local governance intent
lives under `/.octon/instance/governance/capability-packs/**`, and runtime
admission under `/.octon/instance/capabilities/runtime/packs/**` is the
projected runtime-facing view that must stay in parity with the governance
pack declarations.
