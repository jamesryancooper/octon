# Validate Intake

Confirm that the requested intake unit is raw additive intake, not an installed
capability.

Required checks:

1. Resolve `intake_id` to `.octon/inputs/additive/.incoming/<intake-id>/`.
2. Run
   `bash .octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh --intake-id <intake-id>`.
3. Preserve the validator's deterministic inventory and checksum output in
   workflow evidence before classification.
4. Fail closed if the requested intake is under root `.archive/**`,
   `/Users/*/Downloads/**`, `.codex/skills/**`, `.claude/skills/**`,
   `.cursor/skills/**`, `generated/**`, `state/control/**`,
   `inputs/additive/extensions/.incoming/**`, or a normalized
   `inputs/additive/extensions/<extension-pack-id>/` root.
5. Inventory meaningful files and explicitly exclude `.DS_Store` and equivalent
   platform noise from any install or normalization.
6. Record file paths and checksums in workflow evidence before classification.
7. Confirm no runtime, policy, publication, generated, host-projection, or
   evidence surface currently depends on `.incoming/<intake-id>/`.

Output:

- an intake receipt with source path, intake id, inventory, excluded noise, and
  initial structural observations.
