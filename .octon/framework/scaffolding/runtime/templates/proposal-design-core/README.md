# {{PROPOSAL_TITLE}}

This is a temporary, implementation-scoped design proposal for
`{{PROPOSAL_ID}}`.
It is a build aid for engineers and operators. It is not a canonical runtime,
documentation, policy, or contract authority.

## Purpose

- proposal kind: `design`
- design class: `{{DESIGN_CLASS}}`
- promotion scope: `{{PROMOTION_SCOPE}}`
- summary: {{PROPOSAL_SUMMARY}}

## Promotion Targets

{{PROMOTION_TARGETS_BULLETS}}

## Included Modules

{{SELECTED_MODULES_BULLETS}}

## Reading Order

1. `proposal.yml`
2. `design-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `implementation/README.md`
5. class-specific `normative/` docs
6. optional module docs listed in the source-of-truth map
7. `/.octon/generated/proposals/registry.yml`

## Exit Path

{{EXIT_EXPECTATION}}

## Registry

Proposal operations regenerate `/.octon/generated/proposals/registry.yml` from
proposal manifests when this proposal is created, promoted, archived, or
materially reclassified. The registry is a committed discovery projection only
and does not outrank the proposal-local normative docs.
