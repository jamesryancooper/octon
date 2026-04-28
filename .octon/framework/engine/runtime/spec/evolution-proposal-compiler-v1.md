# Evolution Proposal Compiler v1

## Purpose

The Evolution Proposal Compiler turns a validated Evolution Candidate into a
manifest-governed proposal packet. It is a compiler for review material, not a
promotion or execution authority.

## Inputs

- `state/control/evolution/candidates/<candidate-id>.yml`
- `state/control/evolution/distillation/<distillation-id>.yml`
- required governance impact simulation records
- required assurance lab gate records
- required Decision Request or Constitutional Amendment Request refs

## Outputs

The compiler may create or update proposal packets only under:

- `.octon/inputs/exploratory/proposals/architecture/**`
- `.octon/inputs/exploratory/proposals/design/**`
- `.octon/inputs/exploratory/proposals/migration/**`
- `.octon/inputs/exploratory/proposals/policy/**`

Each compiled packet must contain `proposal.yml`, exactly one subtype manifest,
navigation files, subtype working docs, declared promotion targets, and explicit
candidate/simulation/lab/decision refs.

## Gates

- A candidate without evidence refs cannot compile.
- A constitutional-impacting candidate cannot compile without a Constitutional
  Amendment Request or equivalent elevated decision path.
- A compiled proposal remains temporary non-authoritative input.
- Compilation cannot promote, activate, publish, amend, or mutate durable
  authority by itself.
- Future durable outputs must not retain proposal-path dependencies.

## Failure Rule

Missing evidence, missing subtype manifests, missing declared promotion targets,
missing required decisions, or any attempt to use proposal material as runtime
or policy authority fails closed.
