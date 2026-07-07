# Source Lineage

Relevant source and projection families:

- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`
- `.octon/framework/capabilities/runtime/commands/`
- `.octon/framework/capabilities/runtime/skills/`
- `.octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`
- `.octon/framework/assurance/governance/suites/host-projection-parity.yml`
- `.octon/framework/product/features/catalog.yml`
- `.octon/generated/effective/capabilities/routing.effective.yml`
- `.octon/generated/effective/capabilities/artifact-map.yml`
- `.octon/generated/effective/extensions/catalog.effective.yml`
- `.codex/commands/`
- `.codex/skills/`
- `.claude/commands/`
- `.claude/skills/`
- `.cursor/commands/`
- `.cursor/skills/`

Observed driver examples:

- The long lifecycle delivery aliases are projected across Codex, Claude, and
  Cursor.
- The shorter runtime delivery commands have uneven host adapter exposure.
- Packet delivery and program delivery are not documented with fully symmetric
  canonical operator command posture.

These refs are proposal lineage only. Generated/effective and host projections
remain derived-only and must not become authority.
