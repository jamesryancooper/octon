# Additive Inputs

`inputs/additive/**` contains raw additive material that may add Octon
capability only after classification, validation, selection, and publication.
Everything in this tree is non-authoritative input.

## Surfaces

| Surface | Allowed contents | Prohibited contents | Lifecycle route |
| --- | --- | --- | --- |
| `.incoming/<intake-id>/` | Downloaded or imported intake before route classification | Installed packs, active state, generated output, evidence, host projections | `/process-incoming-intake` |
| `.archive/<intake-id>/` | Safely retained historical or blocked intake with retention evidence | Live dependencies, runtime/policy sources, unpublished activation state | archive receipt or removal |
| `extensions/<pack-id>/` | Normalized extension source packs with `pack.yml` and declared entrypoints | Unreviewed downloads, `.incoming` staging, generated effective output | `instance/extensions.yml` selection and extension publication |

Runtime, policy, generated, evidence, and host-projection consumers must not
consume additive inputs as authority.

Canonical architecture:

- `/.octon/framework/cognition/_meta/architecture/inputs/additive/README.md`
- `/.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`
