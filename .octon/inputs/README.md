# Inputs

`inputs/**` contains raw source material that may inform governed Octon work.
It is never runtime, policy, generated, state/control, publication, retained
evidence, or host-projection authority.

## Surfaces

| Surface | Purpose | Lifecycle route | Validator coverage |
| --- | --- | --- | --- |
| `additive/.incoming/<intake-id>/` | Raw additive intake before classification | classify through `/process-incoming-intake` | `validate-incoming-intake-unit.sh` |
| `additive/.archive/<intake-id>/` | Safely retained additive intake history | retain with archive evidence or remove | `validate-input-archive-retention.sh` |
| `additive/extensions/<pack-id>/` | Normalized extension source packs | select in `instance/extensions.yml`, then publish | `validate-extension-pack-contract.sh` |
| `exploratory/ideation/**` | Human-led exploration | promote only by explicit human direction through governed work | `validate-exploratory-input-surfaces.sh` |
| `exploratory/proposals/**` | Manifest-governed proposal packets | validate, promote, archive, or reject | proposal validators |
| `exploratory/plans/**` | Advisory plans | implement separately, supersede, convert, or retain | `validate-exploratory-input-surfaces.sh` |
| `exploratory/syntheses/**` | Research syntheses | promote through governed edits outside `inputs/**` | `validate-exploratory-input-surfaces.sh` |
| `exploratory/reports/**` | Multi-file non-authoritative report sets | convert, summarize, promote, or retain | `validate-exploratory-input-surfaces.sh` |

## Boundaries

Allowed contents are raw additive intake, normalized extension source packs,
human-led ideation, proposal packets, advisory plans, syntheses, and reports.
Do not place runtime configuration, policy, generated outputs, state/control
records, publication receipts, retained evidence, or host projections here.

Canonical architecture:

- `/.octon/framework/cognition/_meta/architecture/inputs/README.md`
