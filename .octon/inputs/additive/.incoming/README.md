# Incoming Additive Intake

`inputs/additive/.incoming/<intake-id>/` is the only staging surface for raw
additive intake before classification.

Allowed contents are unreviewed imported source artifacts for one intake unit.
Prohibited contents include normalized extension source packs, generated output,
state/control files, retained evidence, runtime or policy sources, host
projections, and nested `.incoming` or `.archive` staging roots.

Lifecycle:

1. A human explicitly invokes `/process-incoming-intake`.
2. The intake is validated and classified as additive extension, core skill, or
   blocked/proposal-required.
3. Final disposition removes the `.incoming/<intake-id>/` copy unless the run
   explicitly stops after classification.

Any `.incoming/<intake-id>/` directory that remains in place must include
`intake-status.yml` with the intake id, `authority_mode: non_authoritative`, a
status of `unclassified`, `classified-pending-normalization`,
`rejected-pending-archive`, `blocked`, or `intentionally-retained-temporarily`,
and a short reason.

Authority status: non-authoritative raw input only.

Validator coverage:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh`
