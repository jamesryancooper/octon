# Proposals

`/.octon/inputs/exploratory/proposals/` is the repository-root, non-canonical workspace for temporary
proposal artifacts that shape durable implementation in either `/.octon/` or
repo-local targets outside `/.octon/`.

Every manifest-governed proposal must include:

- `proposal.yml` as the shared authority file
- exactly one subtype manifest:
  - `design-proposal.yml`
  - `migration-proposal.yml`
  - `policy-proposal.yml`
  - `architecture-proposal.yml`
- `README.md`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`
- optional `support/`

Manifest-governed proposals are projected into
`/.octon/generated/proposals/registry.yml`.

- active proposals live under
  `/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/`
- archived proposals live under
  `/.octon/inputs/exploratory/proposals/.archive/<kind>/<proposal_id>/`
- support material that is not itself a proposal may live in adjacent proposal
  support paths while active and should move under `/.octon/inputs/exploratory/proposals/.archive/` when
  archived

The final directory name must match `proposal_id` exactly. Packet numbering or
other path-local ordering prefixes are not part of the canonical proposal path
contract.

## Non-Canonical Rule

Proposals are implementation aids. They are not canonical runtime,
documentation, policy, or contract authorities.

Implications:

- proposals may be archived or removed after promotion lands
- promotion outputs must point to durable `/.octon/` or repo-native authority
  surfaces, not back to the proposal as a source of truth
- generated workflow reports, blueprints, plans, and summaries must not claim
  that the proposal is authoritative or canonical
- proposals are excluded from runtime resolution and policy resolution
- proposals are excluded from `bootstrap_core` and `repo_snapshot`
- no descendant-local or scope-local proposal workspace model exists in v1

## Shared Rules

All manifest-governed proposals must:

- remain temporary and implementation-scoped
- choose exactly one `promotion_scope`:
  - `octon-internal`
  - `repo-local`
- point `promotion_targets` only at durable, repo-local surfaces outside
  `/.octon/inputs/exploratory/proposals/`
- avoid mixed `.octon/**` and non-`.octon/**` promotion targets unless the
  archived proposal preserves historical mixed targets under an explicit
  `legacy-unknown` archive lineage
- describe their subtype-specific authority using the subtype standard under
  `.octon/framework/scaffolding/governance/patterns/`
- keep `generated/proposals/registry.yml` as a non-authoritative projection
  rather than a second lifecycle source of truth

## Lifecycle Expectation

Each proposal should make its exit path obvious:

- promotion targets
- archive or removal expectation after landing
- any temporary assumptions that must be resolved before retirement

## Manifest-Governed Discovery

For manifest-governed proposals, use this precedence model:

1. `proposal.yml`
2. subtype manifest
3. `navigation/source-of-truth-map.md`
4. subtype working docs
5. `navigation/artifact-catalog.md`
6. `/.octon/generated/proposals/registry.yml`
7. `README.md`

`/.octon/generated/proposals/registry.yml` is a deterministically rebuilt
projection for discovery only. It must not replace the base manifest or
subtype manifest as lifecycle authority.
