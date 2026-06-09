# Extension Packs

Extension Packs are Octon's shared additive extension substrate. A pack stays
one pack model and one publication path, then declares composable capability
profiles for the surfaces it provides: validation, commands, skills, prompt
bundles, routing contracts, lifecycle contracts, and templates.

## Boundary

Raw extension pack files under `.octon/inputs/additive/extensions/**` are
authoring and publication inputs only. Runtime discovery uses generated
effective outputs under `.octon/generated/effective/extensions/**`, validated
against the generation lock and publication receipts.
For architecture/governance boundary detail, see
`.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`.

Capability profiles do not create mutually exclusive extension types. They
make artifact dependencies explicit and let validators and resolvers fail
closed when a pack declares or exposes routing, prompt, lifecycle, command,
skill, template, or validation behavior without the matching profile.

## Runtime Guardrails

- Route resolution requires the generated pack entry to carry
  `routing-contract`.
- Prompt bundle resolution requires the generated pack entry to carry
  `prompt-bundle`.
- Lifecycle discovery requires the generated pack entry to carry
  `lifecycle-contract`.
- Every active pack must carry `validation-surface`.

## Validation

Focused validation lives in the extension pack contract, extension publication
state, route resolver, prompt bundle resolver, lifecycle contract, and product
feature catalog tests referenced by the product feature catalog.
