# Additive Extension Source Packs

`inputs/additive/extensions/<pack-id>/` contains normalized extension source
packs. This is the raw source-pack surface, not the published runtime-facing
extension surface.

Allowed contents are schema-governed extension source packs with `pack.yml`,
`README.md`, and declared `skills/`, `commands/`, `templates/`, `prompts/`,
`context/`, and `validation/` entrypoints. Prohibited contents include raw
downloads awaiting route classification, `.incoming` or `.archive` staging,
active/quarantine state, generated effective output, host projections, and
publication receipts.

Lifecycle:

1. Normalize from classified additive intake or authored first-party source.
2. Select desired packs only in `instance/extensions.yml`.
3. Publish selected packs through extension publication into
   `generated/effective/extensions/**`.
4. Consume only published extensions at runtime.

Authority status: non-authoritative extension source pack.

Validator coverage:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`
