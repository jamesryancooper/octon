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

Framework pack manifests define the pack contract. Repo-local admission remains
under `/.octon/instance/capabilities/runtime/packs/**`.
