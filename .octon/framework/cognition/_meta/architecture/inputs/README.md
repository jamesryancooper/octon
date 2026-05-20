# Inputs Architecture

`inputs/**` contains raw source material that may inform governed work. It is
never runtime, policy, generated, state/control, publication, retained
evidence, or host-projection authority.

## Surface Decision Framework

Keep an intake surface only when it has all of the following:

- a distinct lifecycle job that is not already covered by another surface;
- a stable producer or consumer workflow;
- an explicit non-authority boundary and promotion/disposition route;
- validator coverage that fails closed on unmanaged entries.

Rename a surface when its noun implies the wrong lifecycle. Retire a surface
when it is empty, generic, duplicated, or cannot be validated without special
cases.

## Canonical Taxonomy

| Surface | Role | Disposition |
| --- | --- | --- |
| `inputs/additive/.incoming/<intake-id>/` | Raw additive intake unit before classification | classify through `/process-incoming-intake` |
| `inputs/additive/.archive/<intake-id>/` | Retained historical additive intake, only when safe and justified | retain with archive evidence or remove |
| `inputs/additive/extensions/<pack-id>/` | Normalized extension pack source | activate only through `instance/extensions.yml` and publish through extension pipelines |
| `inputs/exploratory/ideation/**` | Human-led divergent exploration | route by explicit human direction into governed proposal, plan, Change, retained evidence update, durable authored edit, or close without promotion |
| `inputs/exploratory/proposals/**` | Manifest-governed proposal packets | validate, promote, archive, or reject through proposal lifecycle |
| `inputs/exploratory/plans/*.md` | Advisory planning artifacts | implement through separate governed work, supersede, or retain as non-authoritative planning history |
| `inputs/exploratory/syntheses/*.md` | Research synthesis outputs | promote into durable authored surfaces only through separate governed edits |
| `inputs/exploratory/reports/<report-id>/` | Multi-file non-authoritative report sets | route into proposal, plan, durable authored update, or retained report history |

Root-level exploratory files are not a general intake surface. The clean-break
taxonomy admits only the documented exploratory directories and `README.md` at
the exploratory root.

## Glossary

- `intake unit`: raw pre-classification additive material under `.incoming`.
- `proposal`: manifest-governed exploratory packet with a lifecycle route.
- `report`: multi-file exploratory findings set; never an installable pack.
- `pack`: normalized extension, capability, or context unit with a schema.
- `artifact`: generic file or output; avoid using it as a lifecycle noun.
- `archive`: retained historical copy, not live input or authority.
- `authority`: source that can control runtime, policy, state, publication, or
  closeout after its governing contract admits it.
- `evidence`: retained operational proof under `state/evidence/**`; raw inputs
  may be cited by evidence but are not evidence authority.
