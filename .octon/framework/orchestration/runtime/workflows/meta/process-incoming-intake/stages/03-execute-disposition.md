# Execute Disposition

Execute only the route selected by the classification receipt.

## Additive Extension Pack

Normalize the reviewed intake into
`.octon/inputs/additive/extensions/<extension-pack-id>/`.

Required behavior:

- create or verify `pack.yml`
- create or verify `validation/compatibility.yml`
- add required capability profiles, content fragments, provenance, and required
  contracts
- update `instance/extensions.yml` only when an explicit activation decision
  exists
- publish only with existing extension publication scripts
- remove or archive the `.incoming/<intake-id>/` source only after evidence and
  validation are captured; final disposition must leave no `.incoming/<intake-id>/`
  copy

## Core Octon Skill

Install only reviewed skill payload into
`.octon/framework/capabilities/runtime/skills/**`.

Required behavior:

- merge manifest, registry, capability, and group fragments into existing
  framework-owned skill surfaces
- never replace shared manifest, registry, or capability files wholesale
- validate allowed tools, triggers, skill id, skill family, and routing posture
- publish capability routing and host projections only through existing scripts
- remove or archive the `.incoming/<intake-id>/` source only after evidence and
  validation are captured; final disposition must leave no `.incoming/<intake-id>/`
  copy

## Blocked / Proposal-Required

Do not install, activate, publish, project, or expose the intake unit.

Required behavior:

- record the blocker and route to proposal/design work
- retain under `.octon/inputs/additive/.archive/<intake-id>/` when source
  material must remain reviewable
- otherwise leave only retained evidence under `state/evidence/**`
- remove the `.incoming/<intake-id>/` source when blocked disposition is final

Prohibited for every route:

- direct writes to `.codex/skills`, `.claude/skills`, or `.cursor/skills`
- direct generated/effective edits
- root `.archive/**` or Downloads staging
- validation, provenance, trust, compatibility, publication, or projection
  bypasses
- retaining `.incoming/<intake-id>/` after final disposition
