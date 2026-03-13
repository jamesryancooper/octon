# Proposals

`/.proposals/` is the repository-root, non-canonical workspace for temporary
proposal artifacts that shape durable implementation in either `/.octon/` or
repo-local targets outside `/.octon/`.

Every manifest-governed proposal must include:

- `proposal.yml` as the shared authority file
- one subtype manifest:
  - `design-proposal.yml`
  - `migration-proposal.yml`
  - `policy-proposal.yml`
  - `architecture-proposal.yml`

Manifest-governed proposals are projected into `registry.yml`.

- active proposals live under `/.proposals/<kind>/<proposal_id>/`
- archived proposals live under `/.proposals/.archive/<kind>/<proposal_id>/`
- support material that is not itself a proposal may live in adjacent proposal
  support paths while active and should move under `/.proposals/.archive/` when
  archived

## Non-Canonical Rule

Proposals are implementation aids. They are not canonical runtime,
documentation, policy, or contract authorities.

Implications:

- proposals may be archived or removed after promotion lands
- promotion outputs must point to durable `/.octon/` or repo-native authority
  surfaces, not back to the proposal as a source of truth
- generated workflow reports, blueprints, plans, and summaries must not claim
  that the proposal is authoritative or canonical

## Shared Rules

All manifest-governed proposals must:

- remain temporary and implementation-scoped
- choose exactly one `promotion_scope`:
  - `octon-internal`
  - `repo-local`
- point `promotion_targets` only at durable, repo-local surfaces outside
  `/.proposals/`
- avoid mixed `.octon/**` and non-`.octon/**` promotion targets unless the
  archived proposal preserves historical mixed targets under an explicit
  `legacy-unknown` archive lineage
- describe their subtype-specific authority using the subtype standard under
  `.octon/scaffolding/governance/patterns/`

## Lifecycle Expectation

Each proposal should make its exit path obvious:

- promotion targets
- archive or removal expectation after landing
- any temporary assumptions that must be resolved before retirement

## Manifest-Governed Discovery

For manifest-governed proposals, use this authority order:

1. `proposal.yml`
2. subtype manifest
3. `registry.yml`
4. `README.md`

`registry.yml` is a projection for fast lookup. It must not replace the base
manifest or subtype manifest as the lifecycle authority.
