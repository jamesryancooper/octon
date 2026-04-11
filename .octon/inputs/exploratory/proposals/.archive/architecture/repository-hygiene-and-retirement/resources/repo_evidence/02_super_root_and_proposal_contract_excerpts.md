# Repo Evidence 02 — Super-Root and Proposal Contract Excerpts

## Super-root authority boundary

**Source:** `/.octon/README.md`

- `framework/` = portable authored Octon core plus portable helper assets only
- `instance/` = repo-specific durable authored authority
- `inputs/` = non-authoritative additive and exploratory inputs
- `state/` = operational truth and retained evidence
- `generated/` = rebuildable outputs only
- only `framework/**` and `instance/**` are authored authority
- raw `inputs/**` never participate directly in runtime or policy decisions

## Cross-subsystem architecture invariant

**Source:** `/.octon/framework/cognition/_meta/architecture/specification.md`

- `generated/**` is never source of truth
- raw `inputs/**` paths must never become direct runtime or policy dependencies
- overlay-capable instance surfaces are legal only at framework-declared
  overlay points enabled by `instance/manifest.yml`
- overlay-capable artifacts may not target closed framework domains such as
  `framework/engine/runtime/**`
- repo-owned bootstrap, context, ADRs, repo-native capabilities, missions, and
  desired extension configuration belong in `instance/**`
- `instance/capabilities/runtime/**` is an instance-native surface

## Proposal contract excerpts

**Sources:** `/.octon/inputs/exploratory/proposals/README.md`,
`/.octon/framework/scaffolding/governance/patterns/proposal-standard.md`,
`/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`

- active proposals live under
  `/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/`
- archived proposals live under
  `/.octon/inputs/exploratory/proposals/.archive/<kind>/<proposal_id>/`
- `proposal.yml` and the subtype manifest are the only lifecycle authorities
- `navigation/source-of-truth-map.md` is the manual precedence and boundary map
- `navigation/artifact-catalog.md` is inventory, not semantic authority
- active proposals may not mix `.octon/**` and non-`.octon/**` promotion
  targets
- architecture proposals must include:
  - `architecture-proposal.yml`
  - `architecture/target-architecture.md`
  - `architecture/acceptance-criteria.md`
  - `architecture/implementation-plan.md`
