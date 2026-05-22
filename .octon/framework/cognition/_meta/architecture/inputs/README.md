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
| `inputs/additive/.incoming/<intake-id>/` | Raw additive intake unit before classification, with required non-authoritative `intake.yml` and `payload/` root | classify through `/process-incoming-intake` |
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
- `intake envelope`: non-authoritative `intake.yml` metadata used only to make
  raw additive capture deterministic before classification.
- `proposal`: manifest-governed exploratory packet with a lifecycle route.
- `report`: multi-file exploratory findings set; never an installable pack.
- `pack`: normalized extension, capability, or context unit with a schema.
- `artifact`: generic file or output; avoid using it as a lifecycle noun.
- `archive`: retained historical copy, not live input or authority.
- `authority`: source that can control runtime, policy, state, publication, or
  closeout after its governing contract admits it.
- `evidence`: retained operational proof under `state/evidence/**`; raw inputs
  may be cited by evidence but are not evidence authority.

## Additive Intake Shape

Incoming additive intake is bounded before classification by the smallest
required filesystem shape:

```text
inputs/additive/.incoming/<intake-id>/
  intake.yml
  payload/
  README.md
```

`intake.yml` and `payload/` are required. `README.md` is optional human context.
All raw material must live under `payload/`; candidate extension packs, core
skills, generated-looking files, evidence-looking files, and host-projection
looking files inside `payload/` remain raw candidates only.

The intake validator checks envelope shape, id/path safety, payload containment,
and non-authority posture. Route fit, provenance sufficiency, trust, secrecy,
proprietary risk, binary/executable posture, oversized payloads, activation,
publication, archive retention, and durable evidence are later lifecycle
decisions.
