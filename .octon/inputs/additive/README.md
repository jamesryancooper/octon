# Additive Inputs

`inputs/additive/**` contains raw additive material that may add Octon
capability only after classification, validation, selection, and publication.
Everything in this tree is non-authoritative input.

## Surfaces

| Surface | Allowed contents | Prohibited contents | Lifecycle route |
| --- | --- | --- | --- |
| `.incoming/<intake-id>/` | Downloaded or imported intake before route classification, with `intake.yml` plus `payload/` | Installed packs, active state, generated output, retained evidence, host projections | `/process-incoming-intake` |
| `.archive/<intake-id>/` | Safely retained historical or blocked intake with retention evidence | Live dependencies, runtime/policy sources, unpublished activation state | archive receipt or removal |
| `extensions/<pack-id>/` | Normalized extension source packs with `pack.yml` and declared entrypoints | Unreviewed downloads, `.incoming` staging, generated effective output | `instance/extensions.yml` selection and extension publication |

Runtime, policy, generated, evidence, and host-projection consumers must not
consume additive inputs as authority.

## Incoming Unit Contract

New incoming intake units use this minimal layout:

```text
.incoming/<intake-id>/
  intake.yml
  payload/
  README.md
```

`intake.yml` and `payload/` are required. `README.md` is optional
non-authoritative context. All raw material must live below `payload/`; a
candidate `pack.yml`, `SKILL.md`, generated-looking output, retained-evidence
looking tree, or host-projection-looking tree inside `payload/` remains raw
intake until a later route explicitly admits it.

Existing legacy incoming directories that still contain `intake-status.yml` are
legacy raw intake only. They are not authority and are not rewritten by this
contract without separate human governance approval.

Canonical architecture:

- `/.octon/framework/cognition/_meta/architecture/inputs/additive/README.md`
- `/.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`
