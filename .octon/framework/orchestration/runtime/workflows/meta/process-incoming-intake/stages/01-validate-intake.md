# Validate Intake

Confirm that the requested intake unit is raw additive intake with a bounded
non-authoritative envelope, not an installed capability.

Required checks:

1. Resolve `intake_id` to `.octon/inputs/additive/.incoming/<intake-id>/`.
2. Run
   `bash .octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh --intake-id <intake-id>`.
3. Require `intake.yml`, `payload/`, and no top-level entries except optional
   `README.md`.
4. Preserve the validator's deterministic payload inventory, checksum output,
   and classification findings in workflow evidence before classification.
5. Fail closed if the requested intake is under root `.archive/**`,
   `/Users/*/Downloads/**`, `.codex/skills/**`, `.claude/skills/**`,
   `.cursor/skills/**`, `generated/**`, `state/control/**`,
   `inputs/additive/extensions/.incoming/**`, or a normalized
   `inputs/additive/extensions/<extension-pack-id>/` root.
6. Inventory meaningful files only under `payload/` and explicitly exclude
   `.DS_Store` and equivalent platform noise from any install or normalization.
7. Record file paths and checksums in workflow evidence before classification.
8. Confirm no runtime, policy, publication, generated, host-projection, or
   evidence surface currently depends on `.incoming/<intake-id>/`.

Output:

- an intake receipt with source path, intake id, envelope facts, payload
  inventory, excluded noise, and classification findings.
